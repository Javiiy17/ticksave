import 'package:flutter/material.dart';

/*
 * ¿Qué hace este archivo?
 * Como teníamos que poner los botoncitos de Ajustes y Salir arriba a la derecha,
 * en vez de ensuciar el código de la pantalla principal, lo sacamos a este archivo.
 * Básicamente es un icono blanco con un fondillo semi transparente redondo.
 */
class IconoCabecera extends StatelessWidget {
  const IconoCabecera({super.key, required this.icono, this.alPulsar});

  final IconData icono;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    // El circulito blanco transparente que tiene el icono dentro
    final widgetIcono = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icono, color: Colors.white, size: 24),
    );

    if (alPulsar == null) {
      return widgetIcono;
    }

    // Le metemos esto para que haga la "ondita" de Flutter al hacer tap
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: alPulsar,
        customBorder: const CircleBorder(),
        child: widgetIcono,
      ),
    );
  }
}
