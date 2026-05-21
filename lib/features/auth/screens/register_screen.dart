import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';

import '../services/auth_service.dart';

/*
 * ¿Qué hace este archivo?
 * Esta es la vista donde el usuario se hace una cuenta nueva en la app.
 * Metes tu correo y tu clave súper segura, y te crea el hueco en Firebase 
 * para empezar a guardar tus tickets.
 */
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorContrasena = TextEditingController();
  final ServicioAutenticacion _servicioAutenticacion = ServicioAutenticacion();

  bool _estaCargando = false;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  // Esta función es la que se pega con Firebase para crear de verdad el usuario
  Future<void> _registrar() async {
    final email = _controladorEmail.text.trim();
    final contrasena = _controladorContrasena.text;

    if (email.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TextosApp.de(context).rellenarEmailContrasena, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _estaCargando = true);
    try {
      await _servicioAutenticacion.registrarConEmail(email: email, contrasena: contrasena);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TextosApp.de(context).cuentaCreadaExito, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Lo devolvemos al login para que entre
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorAutenticacionAmigable(e), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _construirCabecera(context),
                const SizedBox(height: 30),
                _construirTarjetaRegistro(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cabecera apañada
  Widget _construirCabecera(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.confirmation_number_outlined,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'TickSave',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          TextosApp.de(context).guardarTicketsGarantias,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Formulario en plan chulo
  Widget _construirTarjetaRegistro(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextosApp.de(context).crearCuenta,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            TextosApp.de(context).etiquetaEmail,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controladorEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: TextosApp.de(context).pistaEmail,
              prefixIcon: const Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            TextosApp.de(context).etiquetaContrasena,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controladorContrasena,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _estaCargando ? null : _registrar,
              child: _estaCargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(TextosApp.de(context).botonRegistro),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: TextosApp.de(context).yaTienesCuenta,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  children: [
                    TextSpan(
                      text: TextosApp.de(context).enlaceLogin,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
