import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart'; // Paquete para comprimir y descomprimir en ZIP
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../tickets/models/ticket.dart';
import '../../tickets/services/ticket_service.dart';

/*
 * Aquí manejamos toda la movida de las copias de seguridad en Google Drive.
 * Nos encargamos de empaquetar todos los tickets y las fotos en un archivo ZIP
 * para subirlo a la nube del usuario, y también de descargarlo y restaurarlo si 
 * cambia de móvil o algo así.
 */

// Este cliente HTTP es necesario para inyectar los tokens de Google en cada petición.
class ClienteAuthGoogle extends http.BaseClient {
  final Map<String, String> _cabeceras;
  final http.Client _cliente = http.Client();

  ClienteAuthGoogle(this._cabeceras);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest peticion) {
    return _cliente.send(peticion..headers.addAll(_cabeceras));
  }
}

class ServicioDrive {
  final ServicioTicket _servicioTicket = ServicioTicket();
  
  // Pedimos explícitamente permiso para crear y modificar archivos en el Drive del usuario
  final GoogleSignIn _inicioSesionGoogle = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  // Intentamos conseguir acceso a la API de Drive. Si el usuario no ha iniciado sesión, se lo pedimos.
  Future<drive.DriveApi?> _obtenerApiDrive() async {
    try {
      GoogleSignInAccount? cuenta = _inicioSesionGoogle.currentUser;
      if (cuenta == null) {
        cuenta = await _inicioSesionGoogle.signIn();
      } else {
        // Nos aseguramos de que realmente nos haya dado los permisos de Drive
        if (!await _inicioSesionGoogle.requestScopes([drive.DriveApi.driveFileScope])) {
          return null;
        }
      }

      if (cuenta == null) return null;

      final cabecerasAuth = await cuenta.authHeaders;
      final clienteAutenticado = ClienteAuthGoogle(cabecerasAuth);
      return drive.DriveApi(clienteAutenticado);
    } catch (e) {
      if (kDebugMode) print("Error al autenticar con Drive: $e");
      return null;
    }
  }

  // --- Lógica para subir la copia de seguridad ---
  Future<bool> hacerCopiaSeguridadTickets() async {
    final apiDrive = await _obtenerApiDrive();
    if (apiDrive == null) return false;

    try {
      // 1. Pillamos todos los tickets del usuario
      final flujoTickets = _servicioTicket.obtenerTicketsUsuario();
      final tickets = await flujoTickets.first; 

      // Preparamos una carpeta temporal en el móvil para ir guardando las cosas
      final directorioTemporal = await getTemporaryDirectory();
      final rutaDirectorioCopia = '${directorioTemporal.path}/ticksave_backup_tmp';
      final directorioCopia = Directory(rutaDirectorioCopia);
      
      // Limpiamos por si había basura de antes
      if (await directorioCopia.exists()) await directorioCopia.delete(recursive: true);
      await directorioCopia.create();

      // 2. Nos descargamos las imágenes de Firebase y preparamos el JSON
      List<Map<String, dynamic>> jsonTickets = [];
      int indiceImagen = 0;

      for (var ticket in tickets) {
        final mapaTicket = ticket.aMapa();
        mapaTicket['id'] = ticket.id; // Guardamos el ID por si acaso
        
        // Si el ticket tiene imagen y es una URL de verdad, la bajamos
        if (ticket.urlImagen.isNotEmpty && ticket.urlImagen.startsWith('http')) {
          try {
            final respuesta = await http.get(Uri.parse(ticket.urlImagen));
            if (respuesta.statusCode == 200) {
              final nombreImagen = 'imagen_$indiceImagen.jpg';
              final archivoImagen = File('${directorioCopia.path}/$nombreImagen');
              await archivoImagen.writeAsBytes(respuesta.bodyBytes);
              mapaTicket['ruta_imagen_local'] = nombreImagen;
              indiceImagen++;
            }
          } catch (e) {
            if (kDebugMode) print("Fallo al descargar la imagen: $e");
          }
        }
        jsonTickets.add(mapaTicket);
      }

      // Guardamos todos los datos en un archivo tickets.json
      final archivoJson = File('${directorioCopia.path}/tickets.json');
      await archivoJson.writeAsString(jsonEncode(jsonTickets));

      // 3. Lo metemos todo en un ZIP para que ocupe menos y sea un solo archivo
      final codificadorZip = ZipFileEncoder();
      final archivoZip = File('${directorioTemporal.path}/ticksave_backup.zip');
      codificadorZip.create(archivoZip.path);
      codificadorZip.addDirectory(directorioCopia);
      codificadorZip.close();

      // 4. Pa'rriba, lo subimos a Google Drive
      final contenidoMultimedia = drive.Media(archivoZip.openRead(), archivoZip.lengthSync());
      final archivoDrive = drive.File()..name = 'ticksave_backup.zip';

      // Buscamos a ver si ya hay una copia anterior para sobreescribirla
      final consulta = "name = 'ticksave_backup.zip' and trashed = false";
      final listaArchivos = await apiDrive.files.list(q: consulta, $fields: "files(id)");
      
      if (listaArchivos.files != null && listaArchivos.files!.isNotEmpty) {
        // Ya existe, la actualizamos
        final idArchivoExistente = listaArchivos.files!.first.id!;
        await apiDrive.files.update(archivoDrive, idArchivoExistente, uploadMedia: contenidoMultimedia);
      } else {
        // Es la primera vez, la creamos de cero
        await apiDrive.files.create(archivoDrive, uploadMedia: contenidoMultimedia);
      }

      // Limpiamos la basura que hemos creado en el móvil
      await directorioCopia.delete(recursive: true);
      await archivoZip.delete();

      return true;
    } catch (e) {
      if (kDebugMode) print("Error brutal al hacer el backup: $e");
      return false;
    }
  }

  // --- Lógica para restaurar la copia de seguridad ---
  Future<bool> restaurarCopiaSeguridad() async {
    final apiDrive = await _obtenerApiDrive();
    if (apiDrive == null) return false;

    try {
      // Buscamos el ZIP en el Drive del usuario
      final consulta = "name = 'ticksave_backup.zip' and trashed = false";
      final listaArchivos = await apiDrive.files.list(q: consulta, $fields: "files(id)");
      
      if (listaArchivos.files == null || listaArchivos.files!.isEmpty) {
        return false; // Ni rastro del backup
      }

      final idArchivo = listaArchivos.files!.first.id!;
      
      // 1. Descargamos el ZIP
      drive.Media contenidoMultimedia = await apiDrive.files.get(idArchivo, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      
      final directorioTemporal = await getTemporaryDirectory();
      final archivoZip = File('${directorioTemporal.path}/ticksave_restore.zip');
      
      final flujoEscritura = archivoZip.openWrite();
      await contenidoMultimedia.stream.pipe(flujoEscritura);
      await flujoEscritura.flush();
      await flujoEscritura.close();

      // 2. Lo descomprimimos
      final directorioDescomprimido = Directory('${directorioTemporal.path}/ticksave_restore_tmp');
      if (await directorioDescomprimido.exists()) await directorioDescomprimido.delete(recursive: true);
      await directorioDescomprimido.create();

      final bytesZip = await archivoZip.readAsBytes();
      final archivoComprimido = ZipDecoder().decodeBytes(bytesZip);

      for (final archivo in archivoComprimido) {
        final nombreArchivo = archivo.name;
        if (archivo.isFile) {
          final datos = archivo.content as List<int>;
          final archivoSalida = File('${directorioDescomprimido.path}/$nombreArchivo');
          await archivoSalida.create(recursive: true);
          await archivoSalida.writeAsBytes(datos);
        } else {
          Directory('${directorioDescomprimido.path}/$nombreArchivo').create(recursive: true);
        }
      }

      // 3. Leemos el JSON con todos los tickets
      final archivoJson = File('${directorioDescomprimido.path}/tickets.json');
      if (!await archivoJson.exists()) return false;

      final textoJson = await archivoJson.readAsString();
      final List<dynamic> jsonTickets = jsonDecode(textoJson);

      // 4. Recreamos los tickets en Firebase y resubimos las imágenes
      for (var jsonTicket in jsonTickets) {
        String? nuevaUrlImagen;
        
        // Si teníamos la imagen guardada localmente, la subimos al Storage de Firebase
        if (jsonTicket['ruta_imagen_local'] != null) {
          final nombreArchivoLocal = jsonTicket['ruta_imagen_local'];
          final archivoImagen = File('${directorioDescomprimido.path}/$nombreArchivoLocal');
          if (await archivoImagen.exists()) {
             nuevaUrlImagen = await _servicioTicket.subirImagenTicket(archivoImagen);
          }
        }

        if (nuevaUrlImagen != null && nuevaUrlImagen.isNotEmpty) {
           jsonTicket['url_imagen'] = nuevaUrlImagen; // Aquí usamos la clave original de Firebase
        }

        // Creamos nuestro objeto Ticket y lo mandamos a Firebase
        final ticketParaRestaurar = Ticket.desdeMapa(jsonTicket as Map<String, dynamic>, jsonTicket['id']);
        
        // Usamos la función de añadir ticket, que crea uno nuevo y genera un ID.
        // Ojo: Esto ignora el ID antiguo, pero nos vale para restaurar sin liarla.
        await _servicioTicket.anadirTicket(ticketParaRestaurar);
      }

      // Limpieza final
      await directorioDescomprimido.delete(recursive: true);
      await archivoZip.delete();

      return true;
    } catch (e) {
      if (kDebugMode) print("Error gordo al restaurar: $e");
      return false;
    }
  }
}
