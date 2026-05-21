import 'package:flutter/material.dart';

import '../settings/app_settings_scope.dart';

/*
 * ¿Qué hace este archivo?
 * Aquí tenemos todos los textos de la app, tanto en Español como en Inglés.
 * Si alguna vez queremos traducir la app a Alemán o Francés, solo hay que 
 * añadirlo aquí en vez de ir buscando pantalla por pantalla.
 */
class TextosApp {
  TextosApp._(this._esIngles);

  final bool _esIngles;

  // Esto pilla el idioma que haya elegido el usuario en los ajustes
  static TextosApp de(BuildContext context) {
    final en = AlcanceAjustesApp.of(context).esIngles;
    return TextosApp._(en);
  }

  String get tituloInicio => _esIngles ? 'My tickets' : 'Mis Tickets';

  String ticketsGuardados(int n) =>
      _esIngles ? '$n saved tickets' : '$n tickets guardados';
  String get escanearTicket => _esIngles ? 'Scan ticket' : 'Escanear Ticket';
  String get tituloAjustes => _esIngles ? 'Settings' : 'Ajustes';
  String get seccionIdiomaAjustes =>
      _esIngles ? 'Language' : 'Idioma de la aplicación';
  String get pistaIdiomaAjustes =>
      _esIngles ? 'Affects labels in home and this screen.' : 'Afecta a textos del inicio y de esta pantalla.';
  String get idiomaEspanol => _esIngles ? 'Spanish' : 'Español';
  String get idiomaIngles => _esIngles ? 'English' : 'Inglés';
  String get seccionMonedaAjustes =>
      _esIngles ? 'Currency symbol' : 'Divisa (símbolo)';
  String get pistaMonedaAjustes => _esIngles
      ? 'Amounts are not converted; only the symbol shown changes.'
      : 'No se convierten importes; solo cambia el símbolo mostrado.';
  String get seccionAcercaDeAjustes => _esIngles ? 'About' : 'Acerca de';
  String get cuerpoAcercaDeAjustes => _esIngles
      ? 'TickSave — save tickets and warranties. More options will be added later.'
      : 'TickSave — guarda tickets y garantías. Más opciones se añadirán más adelante.';

  String get rellenarComercioFechaPrecio => _esIngles
      ? 'Fill store name, date and amount.'
      : 'Rellena comercio, fecha e importe.';

  // Pantalla de Inicio
  String get buscarComercio => _esIngles ? 'Search store...' : 'Buscar comercio...';
  String get sinComerciosEncontrados => _esIngles ? 'No stores found.' : 'No se encontraron comercios.';
  String get elegirModoEscaneo => _esIngles ? 'Choose how to scan' : 'Elige cómo escanear';
  String get tituloEscanearOcr => _esIngles ? 'Scan Receipt (OCR)' : 'Escanear Ticket (OCR)';
  String get subtituloEscanearOcr => _esIngles ? 'Take a photo of the store and date' : 'Toma una foto al comercio y fecha';
  String get tituloEscanearBarras => _esIngles ? 'Scan Code (QR / Barcode)' : 'Escanear Código (QR / Barras)';
  String get subtituloEscanearBarras => _esIngles ? 'Detect quick codes on the go' : 'Detecta códigos rápidos sobre la marcha';

  // Detalle de Ticket / Tickets del Comercio
  String tituloTicketsComercio(String tienda) => _esIngles ? '$tienda Tickets' : 'Tickets de $tienda';
  String get recibosX => _esIngles ? 'receipts' : 'recibos';
  String get formatoDesconocido => _esIngles ? 'Unknown' : 'Desconocido';
  String get tituloDetalleTicket => _esIngles ? 'Ticket Details' : 'Detalle del Ticket';
  String get categoria => _esIngles ? 'Category' : 'Categoría';
  String get nombreComercio => _esIngles ? 'Store' : 'Comercio';
  String get codigoLeido => _esIngles ? 'Scanned code' : 'Código leído';
  String get formatoCodigo => _esIngles ? 'Format' : 'Formato';
  String get fechaCompra => _esIngles ? 'Purchase Date' : 'Fecha de compra';
  String get importeTicket => _esIngles ? 'Amount' : 'Importe';
  String get protegerGarantia => _esIngles ? 'Protect your warranty' : 'Protege tu garantía';
  String get pistaAlertaGarantia => _esIngles ? 'Set an alert to remember warranty expiration' : 'Configura una alerta para recordar el vencimiento de la garantía';
  String get configurarAlerta => _esIngles ? 'Set Alert' : 'Configurar Alerta';
  String get editarTicket => _esIngles ? 'Edit' : 'Editar Ticket';
  String get tocarParaAmpliar => _esIngles ? 'Tap to enlarge and scan' : 'Toca para ampliar y escanear';
  String get escaneandoQr => _esIngles ? 'Scanning QR' : 'Escaneando QR';
  String get escaneandoBarras => _esIngles ? 'Scanning Barcode' : 'Escaneando Barras';
  String get compartirTicket => _esIngles ? 'Share Ticket' : 'Compartir Ticket';
  String mensajeCompartirTicket(String tienda, String fecha, String precio, {String? codigo}) {
    String msg = _esIngles 
      ? 'Here is my ticket from $tienda on $fecha for $precio.' 
      : 'Aquí tienes mi ticket de compra de $tienda del día $fecha por $precio.';
    
    if (codigo != null && codigo.isNotEmpty) {
      msg += _esIngles ? '\nScanned codigo: $codigo' : '\nCódigo escaneado: $codigo';
    }
    return msg;
  }

  // Editar Ticket
  String get tituloEditarTicket => _esIngles ? 'Edit Ticket' : 'Editar Ticket';
  String get guardarNuevoTicket => _esIngles ? 'Save New Ticket' : 'Guardar Nuevo Ticket';
  String get etiquetaComercio => _esIngles ? 'Store' : 'Comercio / Tienda';
  String get etiquetaFecha => _esIngles ? 'Date' : 'Fecha';
  String get etiquetaPrecio => _esIngles ? 'Price' : 'Precio';
  String get infoCodigo => _esIngles ? 'Code Information' : 'Información del Código';
  String get etiquetaIdTarjeta => _esIngles ? 'Card ID / Code' : 'ID de Tarjeta / Código';
  String get formatoDetectado => _esIngles ? 'Detected Format' : 'Formato Detectado';
  String get botonGuardarTicket => _esIngles ? 'SAVE TICKET' : 'GUARDAR TICKET';
  String get ticketCreadoExito => _esIngles ? 'Ticket successfully created!' : '¡Ticket creado con éxito!';
  String get ticketActualizadoExito => _esIngles ? 'Ticket successfully updated' : 'Ticket actualizado correctamente';
  String get errorConexionBd => _esIngles ? 'Error: Database connection failed' : 'Error: Falla conexión en bdd';
  String get campoObligatorio => _esIngles ? 'Required field' : 'Campo requerido';

  // Pantalla Escáner de Códigos
  String get tituloEscanearCodigo => _esIngles ? 'Scan Code' : 'Escanear Código';
  String get pestanaBarras => _esIngles ? 'Barcode' : 'Barras';
  String get pestanaQr => _esIngles ? 'QR Code' : 'Código QR';

  // Pantalla de Login
  String get protegerGarantiasNube => _esIngles ? 'Protect your warranties in the cloud' : 'Protege tus garantías en la nube';
  String get bienvenidoDeNuevo => _esIngles ? 'Welcome back' : 'Bienvenido de nuevo';
  String get etiquetaEmail => _esIngles ? 'Email' : 'Email';
  String get etiquetaContrasena => _esIngles ? 'Password' : 'Contraseña';
  String get pistaEmail => _esIngles ? 'you@email.com' : 'tu@correo.com';
  String get botonLogin => _esIngles ? 'LOGIN' : 'ENTRAR';
  String get iniciarConGoogle => _esIngles ? 'Continue with Google' : 'Continuar con Google';
  String get esNuevoUsuario => _esIngles ? 'NEW HERE?\n' : '¿NUEVO POR AQUÍ?\n';
  String get enlaceRegistro => _esIngles ? 'SIGN UP!' : '¡REGÍSTRATE!';
  String get rellenarEmailContrasena => _esIngles ? 'Please enter email and password.' : 'Rellena email y contraseña.';
  String get guardarTicketsGarantias => _esIngles ? 'Save your tickets and warranties' : 'Guarda tus tickets y garantías';
  String get crearCuenta => _esIngles ? 'Create Account' : 'Crear Cuenta';
  String get botonRegistro => _esIngles ? 'Register' : 'Registrarse';
  String get yaTienesCuenta => _esIngles ? 'Already have an account? ' : '¿Ya tienes cuenta? ';
  String get enlaceLogin => _esIngles ? 'Login' : 'Inicia sesión';
  String get cuentaCreadaExito => _esIngles ? 'Account created. You can now log in.' : 'Cuenta creada. Ya puedes iniciar sesión.';

  // Pantalla de Alertas
  String compradoEl(String fecha) => _esIngles ? 'Purchased on $fecha' : 'Comprado el $fecha';
  String get fechaVencimiento => _esIngles ? 'Expiration date' : 'Fecha de vencimiento';
  String get usarFechaSugerida => _esIngles ? 'Use suggested date (1 year later)' : 'Usar fecha sugerida (1 año después)';
  String get diasAviso => _esIngles ? 'Notice days' : 'Días de aviso';
  String get pistaDiasAviso => _esIngles ? 'You will receive a notification this many days in advance.' : 'Recibirás una notificación con esta antelación.';
  String get botonGuardarAlerta => _esIngles ? 'Save Alert' : 'Guardar alerta';
  String get alertaGuardadaExito => _esIngles ? 'Alert saved successfully!' : '¡Alerta guardada correctamente!';
  String get pistaInfoAviso => _esIngles ? 'We will send you a notification when the expiration date approaches.' : 'Te enviaremos una notificación cuando se acerque la fecha de vencimiento.';
  String diasX(int n) => _esIngles ? '$n days' : '$n días';
  String get botonAtras => _esIngles ? 'Back' : 'Volver';
  
  // Funciones de Borrado
  String get eliminarTicket => _esIngles ? 'Delete Ticket' : 'Eliminar Ticket';
  String get tituloConfirmarEliminarTicket => _esIngles ? 'Delete Ticket?' : '¿Eliminar Ticket?';
  String get cuerpoConfirmarEliminarTicket => _esIngles ? 'Are you sure you want to borrar this ticket? This action cannot be undone.' : '¿Estás seguro de que deseas eliminar este ticket? Esta acción no se puede deshacer.';
  String get eliminarCarpeta => _esIngles ? 'Delete Folder' : 'Eliminar Carpeta';
  String get tituloConfirmarEliminarCarpeta => _esIngles ? 'Delete Folder?' : '¿Eliminar Carpeta?';
  String get cuerpoConfirmarEliminarCarpeta => _esIngles ? 'Are you sure you want to borrar this folder and all its tickets? This action cannot be undone.' : '¿Estás seguro de que deseas eliminar esta carpeta y todos sus tickets? Esta acción no se puede deshacer.';
  String get cancelar => _esIngles ? 'Cancel' : 'Cancelar';
  String get borrar => _esIngles ? 'Delete' : 'Eliminar';
  
  // Copia de Seguridad
  String get seccionCopiaSeguridad => _esIngles ? 'Backup & Restore' : 'Copias de Seguridad';
  String get pistaCopiaSeguridad => _esIngles ? 'Safely store your tickets and images in your personal Google Drive.' : 'Guarda tus tickets e imágenes de forma segura en tu Google Drive personal.';
  String get copiaDrive => _esIngles ? 'Backup to Google Drive' : 'Hacer copia en Google Drive';
  String get restaurarDrive => _esIngles ? 'Restore from Google Drive' : 'Restaurar de Google Drive';
  String get copiaSeguridadExito => _esIngles ? 'Backup completed successfully!' : '¡Copia de seguridad completada!';
  String get errorCopiaSeguridad => _esIngles ? 'Failed to create backup.' : 'Error al crear la copia de seguridad.';
  String get restauracionExito => _esIngles ? 'Restore completed successfully!' : '¡Restauración completada con éxito!';
  String get errorRestauracion => _esIngles ? 'Failed to restore backup (no backup found or network error).' : 'Error al restaurar (no hay copia o falló la conexión).';
  String get porFavorEspera => _esIngles ? 'Please wait...' : 'Por favor, espera...';
}
