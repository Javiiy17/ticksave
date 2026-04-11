import 'package:flutter/material.dart';

import '../settings/app_settings_scope.dart';

/// Cadenas mínimas según idioma (es / en) para inicio y ajustes.
/// @author Luis Bermeo
class AppStrings {
  AppStrings._(this._en);

  final bool _en;

  static AppStrings of(BuildContext context) {
    final en = AppSettingsScope.of(context).isEnglish;
    return AppStrings._(en);
  }

  String get homeTitle => _en ? 'My tickets' : 'Mis Tickets';

  String homeSavedCount(int n) =>
      _en ? '$n saved tickets' : '$n tickets guardados';
  String get scanTicket => _en ? 'Scan ticket' : 'Escanear Ticket';
  String get settingsTitle => _en ? 'Settings' : 'Ajustes';
  String get settingsLanguageSection =>
      _en ? 'Language' : 'Idioma de la aplicación';
  String get settingsLanguageHint =>
      _en ? 'Affects labels in home and this screen.' : 'Afecta a textos del inicio y de esta pantalla.';
  String get langSpanish => _en ? 'Spanish' : 'Español';
  String get langEnglish => _en ? 'English' : 'Inglés';
  String get settingsCurrencySection =>
      _en ? 'Currency symbol' : 'Divisa (símbolo)';
  String get settingsCurrencyHint => _en
      ? 'Amounts are not converted; only the symbol shown changes.'
      : 'No se convierten importes; solo cambia el símbolo mostrado.';
  String get settingsAboutSection => _en ? 'About' : 'Acerca de';
  String get settingsAboutBody => _en
      ? 'TickSave — save tickets and warranties. More options will be added later.'
      : 'TickSave — guarda tickets y garantías. Más opciones se añadirán más adelante.';

  String get fillStoreDatePrice => _en
      ? 'Fill store name, date and amount.'
      : 'Rellena comercio, fecha e importe.';

  // Home Screen
  String get searchStore => _en ? 'Search store...' : 'Buscar comercio...';
  String get noStoresFound => _en ? 'No stores found.' : 'No se encontraron comercios.';
  String get chooseScanMode => _en ? 'Choose how to scan' : 'Elige cómo escanear';
  String get scanOcrTitle => _en ? 'Scan Receipt (OCR)' : 'Escanear Ticket (OCR)';
  String get scanOcrSubtitle => _en ? 'Take a photo of the store and date' : 'Toma una foto al comercio y fecha';
  String get scanBarcodeTitle => _en ? 'Scan Code (QR / Barcode)' : 'Escanear Código (QR / Barras)';
  String get scanBarcodeSubtitle => _en ? 'Detect quick codes on the go' : 'Detecta códigos rápidos sobre la marcha';

  // Ticket Detail / Store Tickets
  String storeTicketsTitle(String store) => _en ? '$store Tickets' : 'Tickets de $store';
  String get receiptX => _en ? 'receipts' : 'recibos';
  String get unknownFormat => _en ? 'Unknown' : 'Desconocido';
  String get ticketDetailTitle => _en ? 'Ticket Details' : 'Detalle del Ticket';
  String get category => _en ? 'Category' : 'Categoría';
  String get storeName => _en ? 'Store' : 'Comercio';
  String get codeRead => _en ? 'Scanned code' : 'Código leído';
  String get codeFormat => _en ? 'Format' : 'Formato';
  String get purchaseDate => _en ? 'Purchase Date' : 'Fecha de compra';
  String get ticketAmount => _en ? 'Amount' : 'Importe';
  String get protectWarranty => _en ? 'Protect your warranty' : 'Protege tu garantía';
  String get warrantyAlertHint => _en ? 'Set an alert to remember warranty expiration' : 'Configura una alerta para recordar el vencimiento de la garantía';
  String get configureAlert => _en ? 'Set Alert' : 'Configurar Alerta';
  String get editTicket => _en ? 'Edit' : 'Editar Ticket';
  String get tapToEnlarge => _en ? 'Tap to enlarge and scan' : 'Toca para ampliar y escanear';
  String get scanningQr => _en ? 'Scanning QR' : 'Escaneando QR';
  String get scanningBarcode => _en ? 'Scanning Barcode' : 'Escaneando Barras';

  // Edit Ticket
  String get editTicketTitle => _en ? 'Edit Ticket' : 'Editar Ticket';
  String get saveNewTicket => _en ? 'Save New Ticket' : 'Guardar Nuevo Ticket';
  String get storeLabel => _en ? 'Store' : 'Comercio / Tienda';
  String get dateLabel => _en ? 'Date' : 'Fecha';
  String get priceLabel => _en ? 'Price' : 'Precio';
  String get codeInfo => _en ? 'Code Information' : 'Información del Código';
  String get cardIdLabel => _en ? 'Card ID / Code' : 'ID de Tarjeta / Código';
  String get formatDetected => _en ? 'Detected Format' : 'Formato Detectado';
  String get saveTicketButton => _en ? 'SAVE TICKET' : 'GUARDAR TICKET';
  String get ticketCreatedSuccess => _en ? 'Ticket successfully created!' : '¡Ticket creado con éxito!';
  String get ticketUpdatedSuccess => _en ? 'Ticket successfully updated' : 'Ticket actualizado correctamente';
  String get dbConnectionError => _en ? 'Error: Database connection failed' : 'Error: Falla conexión en bdd';
  String get requiredField => _en ? 'Required field' : 'Campo requerido';

  // Barcode Scanner Form
  String get scanCodeTitle => _en ? 'Scan Code' : 'Escanear Código';
  String get barcodeTab => _en ? 'Barcode' : 'Barras';
  String get qrTab => _en ? 'QR Code' : 'Código QR';

  // Login Screen
  String get protectWarrantiesCloud => _en ? 'Protect your warranties in the cloud' : 'Protege tus garantías en la nube';
  String get welcomeBack => _en ? 'Welcome back' : 'Bienvenido de nuevo';
  String get emailLabel => _en ? 'Email' : 'Email';
  String get passwordLabel => _en ? 'Password' : 'Contraseña';
  String get emailHint => _en ? 'you@email.com' : 'tu@correo.com';
  String get loginButton => _en ? 'LOGIN' : 'ENTRAR';
  String get googleSignIn => _en ? 'Continue with Google' : 'Continuar con Google';
  String get isNewUser => _en ? 'NEW HERE?\n' : '¿NUEVO POR AQUÍ?\n';
  String get signUpLink => _en ? 'SIGN UP!' : '¡REGÍSTRATE!';
  String get fillEmailPass => _en ? 'Please enter email and password.' : 'Rellena email y contraseña.';
  String get saveTicketsWarranties => _en ? 'Save your tickets and warranties' : 'Guarda tus tickets y garantías';
  String get createAccount => _en ? 'Create Account' : 'Crear Cuenta';
  String get registerButton => _en ? 'Register' : 'Registrarse';
  String get alreadyHaveAccount => _en ? 'Already have an account? ' : '¿Ya tienes cuenta? ';
  String get loginLink => _en ? 'Login' : 'Inicia sesión';
  String get accountCreatedSuccess => _en ? 'Account created. You can now log in.' : 'Cuenta creada. Ya puedes iniciar sesión.';

  // Alert Screen
  String purchasedOn(String date) => _en ? 'Purchased on $date' : 'Comprado el $date';
  String get expirationDate => _en ? 'Expiration date' : 'Fecha de vencimiento';
  String get useSuggestedDate => _en ? 'Use suggested date (1 year later)' : 'Usar fecha sugerida (1 año después)';
  String get noticeDays => _en ? 'Notice days' : 'Días de aviso';
  String get noticeDaysHint => _en ? 'You will receive a notification this many days in advance.' : 'Recibirás una notificación con esta antelación.';
  String get saveAlertButton => _en ? 'Save Alert' : 'Guardar alerta';
  String get alertSavedSuccess => _en ? 'Alert saved successfully!' : '¡Alerta guardada correctamente!';
  String get noticeInfoHint => _en ? 'We will send you a notification when the expiration date approaches.' : 'Te enviaremos una notificación cuando se acerque la fecha de vencimiento.';
  String daysX(int n) => _en ? '$n days' : '$n días';
  String get backButton => _en ? 'Back' : 'Volver';
}
