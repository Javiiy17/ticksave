import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/settings/app_currency.dart';
import '../../../core/settings/app_settings_scope.dart';
import '../../backup/services/drive_service.dart';

/*
 * ¿Qué hace este archivo?
 * Esta es la pantalla de ajustes de toda la vida. 
 * Aquí el usuario puede cambiar el idioma de la app, decidir en qué moneda 
 * quiere ver los precios (Euros, Dólares...) y lo más importante: 
 * guardar o recuperar sus tickets de Google Drive para no perderlos si cambia de móvil.
 */
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  // Esto se encarga de subir los tickets a Drive o bajarlos si es nuevo en la app
  Future<void> _gestionarCopiaSeguridad(BuildContext context, bool esRestauracion) async {
    final textos = TextosApp.de(context);
    
    // Le plantamos un diálogo de carga para que vea que estamos haciendo cosas y no toque nada
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(textos.porFavorEspera),
          ],
        ),
      ),
    );

    final servicioDrive = ServicioDrive();
    final bool exito = esRestauracion 
      ? await servicioDrive.restaurarCopiaSeguridad() 
      : await servicioDrive.hacerCopiaSeguridadTickets();

    if (context.mounted) {
      Navigator.pop(context); // Quitamos el pop-up de carga
      
      // Y le avisamos de si ha ido bien o la ha liado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito 
                ? (esRestauracion ? textos.restauracionExito : textos.copiaSeguridadExito) 
                : (esRestauracion ? textos.errorRestauracion : textos.errorCopiaSeguridad),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: exito ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = AlcanceAjustesApp.of(context);
    final textos = TextosApp.de(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          textos.tituloAjustes,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: ajustes,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cajita para elegir si habla en Español o en Guiri
                _construirTarjetaSeccion(
                  context,
                  icono: Icons.language,
                  colorIcono: Colors.blue,
                  titulo: textos.seccionIdiomaAjustes,
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textos.pistaIdiomaAjustes,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _construirCasillaIdioma(
                        context,
                        titulo: textos.idiomaEspanol,
                        subtitulo: 'Español',
                        seleccionado: ajustes.idioma.languageCode == 'es',
                        alPulsar: () => ajustes.cambiarIdioma(const Locale('es')),
                      ),
                      const SizedBox(height: 8),
                      _construirCasillaIdioma(
                        context,
                        titulo: textos.idiomaIngles,
                        subtitulo: 'English',
                        seleccionado: ajustes.idioma.languageCode == 'en',
                        alPulsar: () => ajustes.cambiarIdioma(const Locale('en')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Cajita para elegir la pasta (€, $, £...)
                _construirTarjetaSeccion(
                  context,
                  icono: Icons.payments_outlined,
                  colorIcono: Colors.teal,
                  titulo: textos.seccionMonedaAjustes,
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textos.pistaMonedaAjustes,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...MonedaApp.values.map((moneda) {
                        final etiqueta =
                            ajustes.esIngles ? moneda.etiquetaEn : moneda.etiquetaEs;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _construirCasillaMoneda(
                            context,
                            titulo: etiqueta,
                            simbolo: moneda.simbolo,
                            seleccionado: ajustes.moneda == moneda,
                            alPulsar: () => ajustes.cambiarMoneda(moneda),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Zona de peligro: Copias de seguridad en Google Drive
                _construirTarjetaSeccion(
                  context,
                  icono: Icons.cloud_upload_outlined,
                  colorIcono: Colors.deepPurple,
                  titulo: textos.seccionCopiaSeguridad,
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textos.pistaCopiaSeguridad,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _gestionarCopiaSeguridad(context, false), // false = hacer backup
                          icon: const Icon(Icons.backup_outlined),
                          label: FittedBox(fit: BoxFit.scaleDown, child: Text(textos.copiaDrive)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _gestionarCopiaSeguridad(context, true), // true = restaurar backup
                          icon: const Icon(Icons.restore),
                          label: FittedBox(fit: BoxFit.scaleDown, child: Text(textos.restaurarDrive)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1877F2),
                            side: const BorderSide(color: Color(0xFF1877F2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Zona de créditos y "Acerca de"
                _construirTarjetaSeccion(
                  context,
                  icono: Icons.info_outline,
                  colorIcono: Colors.orange,
                  titulo: textos.seccionAcercaDeAjustes,
                  hijo: Text(
                    textos.cuerpoAcercaDeAjustes,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Plantilla para que todas las cajitas blancas de la pantalla sean igual de bonitas
  Widget _construirTarjetaSeccion(
    BuildContext context, {
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required Widget hijo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: colorIcono, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          hijo,
        ],
      ),
    );
  }

  // Fila para elegir idioma, si lo tocas se pone azulito
  Widget _construirCasillaIdioma(
    BuildContext context, {
    required String titulo,
    required String subtitulo,
    required bool seleccionado,
    required VoidCallback alPulsar,
  }) {
    return Material(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? const Color(0xFF1877F2)
                  : Colors.grey.shade200,
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (seleccionado)
                const Icon(Icons.check_circle, color: Color(0xFF1877F2)),
            ],
          ),
        ),
      ),
    );
  }

  // Fila para elegir moneda con el simbolito de la moneda destacado a la izquierda
  Widget _construirCasillaMoneda(
    BuildContext context, {
    required String titulo,
    required String simbolo,
    required bool seleccionado,
    required VoidCallback alPulsar,
  }) {
    return Material(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? const Color(0xFF1877F2)
                  : Colors.grey.shade200,
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  simbolo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
              if (seleccionado)
                const Icon(Icons.check_circle, color: Color(0xFF1877F2)),
            ],
          ),
        ),
      ),
    );
  }
}
