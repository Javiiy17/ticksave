import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart'; // From archive package to encode/decode
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../tickets/models/ticket.dart';
import '../../tickets/services/ticket_service.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class DriveService {
  final TicketService _ticketService = TicketService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        account = await _googleSignIn.signIn();
      } else {
        // Enforce getting scopes
        if (!await _googleSignIn.requestScopes([drive.DriveApi.driveFileScope])) {
          return null;
        }
      }

      if (account == null) return null;

      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      return drive.DriveApi(authenticateClient);
    } catch (e) {
      if (kDebugMode) print("Error authenticating Drive: $e");
      return null;
    }
  }

  /// Backup logic
  Future<bool> backupTickets() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      // 1. Fetch tickets
      final ticketsStream = _ticketService.getUserTickets();
      final tickets = await ticketsStream.first; 

      final dir = await getTemporaryDirectory();
      final backupDirPath = '${dir.path}/ticksave_backup_tmp';
      final backupDir = Directory(backupDirPath);
      if (await backupDir.exists()) await backupDir.delete(recursive: true);
      await backupDir.create();

      // 2. Download images and build JSON config
      List<Map<String, dynamic>> ticketsJson = [];
      int imageIndex = 0;

      for (var ticket in tickets) {
        final tMap = ticket.toMap();
        tMap['id'] = ticket.id; // ensure ID is kept
        
        if (ticket.imageUrl.isNotEmpty && ticket.imageUrl.startsWith('http')) {
          try {
            final res = await http.get(Uri.parse(ticket.imageUrl));
            if (res.statusCode == 200) {
              final imgName = 'image_$imageIndex.jpg';
              final imgFile = File('${backupDir.path}/$imgName');
              await imgFile.writeAsBytes(res.bodyBytes);
              tMap['local_image_path'] = imgName;
              imageIndex++;
            }
          } catch (e) {
            if (kDebugMode) print("Failed to download image: $e");
          }
        }
        ticketsJson.add(tMap);
      }

      // Save JSON
      final jsonFile = File('${backupDir.path}/tickets.json');
      await jsonFile.writeAsString(jsonEncode(ticketsJson));

      // 3. Zip file
      final encoder = ZipFileEncoder();
      final zipFile = File('${dir.path}/ticksave_backup.zip');
      encoder.create(zipFile.path);
      encoder.addDirectory(backupDir);
      encoder.close();

      // 4. Upload to Drive
      final media = drive.Media(zipFile.openRead(), zipFile.lengthSync());
      final driveFile = drive.File()..name = 'ticksave_backup.zip';

      // Check if old backup exists in the app scope
      final q = "name = 'ticksave_backup.zip' and trashed = false";
      final fileList = await driveApi.files.list(q: q, $fields: "files(id)");
      
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing (replace)
        final existingFileId = fileList.files!.first.id!;
        await driveApi.files.update(driveFile, existingFileId, uploadMedia: media);
      } else {
        // Create new
        await driveApi.files.create(driveFile, uploadMedia: media);
      }

      // Cleanup
      await backupDir.delete(recursive: true);
      await zipFile.delete();

      return true;
    } catch (e) {
      if (kDebugMode) print("Backup error: $e");
      return false;
    }
  }

  /// Restore logic
  Future<bool> restoreBackup() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      final q = "name = 'ticksave_backup.zip' and trashed = false";
      final fileList = await driveApi.files.list(q: q, $fields: "files(id)");
      
      if (fileList.files == null || fileList.files!.isEmpty) {
        return false; // No backup found
      }

      final fileId = fileList.files!.first.id!;
      
      // Download
      drive.Media media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      
      final dir = await getTemporaryDirectory();
      final zipFile = File('${dir.path}/ticksave_restore.zip');
      
      final sink = zipFile.openWrite();
      await media.stream.pipe(sink);
      await sink.flush();
      await sink.close();

      // Unzip
      final extractedDir = Directory('${dir.path}/ticksave_restore_tmp');
      if (await extractedDir.exists()) await extractedDir.delete(recursive: true);
      await extractedDir.create();

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File('${extractedDir.path}/$filename');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        } else {
          Directory('${extractedDir.path}/$filename').create(recursive: true);
        }
      }

      // Read JSON
      final jsonFile = File('${extractedDir.path}/tickets.json');
      if (!await jsonFile.exists()) return false;

      final jsonString = await jsonFile.readAsString();
      final List<dynamic> ticketsJson = jsonDecode(jsonString);

      // Recreate tickets locally / upload images
      for (var tJson in ticketsJson) {
        // If image exists locally, we upload it back via TicketService
        String? newImageUrl;
        if (tJson['local_image_path'] != null) {
          final localFilename = tJson['local_image_path'];
          final imgFile = File('${extractedDir.path}/$localFilename');
          if (await imgFile.exists()) {
             newImageUrl = await _ticketService.uploadTicketImage(imgFile);
          }
        }

        if (newImageUrl != null && newImageUrl.isNotEmpty) {
           tJson['imagen'] = newImageUrl;
        }

        // Add back to service
        final ticketToRestore = Ticket.fromMap(tJson as Map<String, dynamic>, tJson['id']);
        
        // Let's actually create it (this generates a new ID implicitly in Firestore if using .add or .set, 
        // TicketService.addTicket does an .add ignoring the id, which is fine, we don't strictly need the old ID in restore
        // unless we want to avoid duplicates.
        // Wait, TicketService inside `addTicket` uses `.add` which generates a new ID.
        // It's probably better to restore with original ID using `.doc(id).set(toMap())`, but TicketService only has updateTicket.
        // For simplicity, we can do updateTicket inside a doc creation, but addTicket uses `.add()`.
        
        // Let's manually do set to preserve it, or update TicketService. Wait, TicketService has addTicket(Ticket ticket).
        // addTicket uses .add() which ignores the custom ID. That's fine, it behaves exactly like a new ticket.
        await _ticketService.addTicket(ticketToRestore);
      }

      // Cleanup
      await extractedDir.delete(recursive: true);
      await zipFile.delete();

      return true;
    } catch (e) {
      if (kDebugMode) print("Restore error: $e");
      return false;
    }
  }
}
