import 'package:flutter/material.dart';

/// Icono circular utilizado en la cabecera de la pantalla de inicio.
///
/// Se extrae a un widget propio para reutilizarlo y mantener
/// `HomeScreen` más legible.
class HeaderIcon extends StatelessWidget {
  const HeaderIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

