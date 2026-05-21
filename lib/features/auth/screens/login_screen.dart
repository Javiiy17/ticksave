import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';

import '../../home/screens/home_screen.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

/*
 * ¿Qué hace este archivo?
 * Esta es la pantalla visual del Login. Aquí el usuario mete sus datos
 * para entrar en TickSave. Es la primera pantalla de la app y la hemos puesto bien
 * bonita con efectos de cristal y degradados para que se vea premium desde el segundo uno.
 */
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _EstadoPantallaLogin();
}

class _EstadoPantallaLogin extends State<PantallaLogin> {
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

  // Nos saca un mensajito por abajo (SnackBar) si el usuario la lía
  void _mostrarAvisoError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Cuando el usuario le da al botón de entrar con correo de toda la vida
  Future<void> _iniciarSesion() async {
    final email = _controladorEmail.text.trim();
    final contrasena = _controladorContrasena.text;

    if (email.isEmpty || contrasena.isEmpty) {
      _mostrarAvisoError(TextosApp.de(context).rellenarEmailContrasena);
      return;
    }

    setState(() => _estaCargando = true);
    try {
      await _servicioAutenticacion.iniciarSesionConEmail(email: email, contrasena: contrasena);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const PantallaInicio(), // Pantalla de inicio
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarAvisoError(errorAutenticacionAmigable(e));
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  // Cuando el usuario es un vago y prefiere entrar con Google
  Future<void> _iniciarSesionConGoogle() async {
    setState(() => _estaCargando = true);
    try {
      final credenciales = await _servicioAutenticacion.iniciarSesionConGoogle(); 
      if (!mounted) return;
      if (credenciales == null) {
        setState(() => _estaCargando = false);
        return; // Si ha cancelado la ventanita de Google
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const PantallaInicio(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarAvisoError('La hemos liado con el Sign-In de Google: $e');
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  // Te manda pa la pantalla de registro
  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const PantallaRegistro(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              const Color(0xFFE91E63).withValues(alpha: 0.1),
              const Color(0xFF9C27B0).withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _construirCabecera(context),
                  const SizedBox(height: 40),
                  _construirTarjetaLogin(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Cabecera to' guapa con el logo de nuestra app
  Widget _construirCabecera(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            size: 45,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'TickSave',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          TextosApp.de(context).protegerGarantiasNube,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Tarjeta de cristal donde va el formulario
  Widget _construirTarjetaLogin(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF140A26).withValues(alpha: 0.8),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextosApp.de(context).bienvenidoDeNuevo,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _construirEtiquetaCampo(TextosApp.de(context).etiquetaEmail),
          TextField(
            controller: _controladorEmail,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: TextosApp.de(context).pistaEmail,
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 20),
          _construirEtiquetaCampo(TextosApp.de(context).etiquetaContrasena),
          TextField(
            controller: _controladorContrasena,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _estaCargando ? null : _iniciarSesion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, 
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _estaCargando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          TextosApp.de(context).botonLogin,
                          style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _construirBotonGoogle(),
          const SizedBox(height: 30),
          _construirEnlaceRegistro(context),
        ],
      ),
    );
  }

  Widget _construirEtiquetaCampo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        texto,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
        ),
      ),
    );
  }

  // El botón pijo para entrar con Google
  Widget _construirBotonGoogle() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: _estaCargando ? null : _iniciarSesionConGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.02),
        ),
        icon: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/240px-Google_%22G%22_logo.svg.png',
          height: 24,
          width: 24,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.public, color: Colors.white),
        ),
        label: Text(
          TextosApp.de(context).iniciarConGoogle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  // Si no tienes cuenta te vas a registrar
  Widget _construirEnlaceRegistro(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: _irARegistro,
        style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
        child: Text.rich(
          TextSpan(
            text: TextosApp.de(context).esNuevoUsuario,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 1.2,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: TextosApp.de(context).enlaceRegistro,
                style: const TextStyle(
                  color: Color(0xFFFF4081),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
