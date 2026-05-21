import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';

/*
 * ¿Qué hace este archivo?
 * Aquí gestionamos las alertas del calendario. Cuando a un ticket se le va a
 * acabar la garantía, desde esta pantalla podemos meter un evento directamente
 * en el calendario del móvil (Google Calendar, Apple, etc) para que pite
 * y nos avise con tiempo. ¡Así no perdemos dinero!
 */
class PantallaAlerta extends StatefulWidget {
  const PantallaAlerta({
    super.key,
    required this.nombreComercio,
    required this.fechaCompra,
  });

  final String nombreComercio;
  final String fechaCompra;

  @override
  State<PantallaAlerta> createState() => _EstadoPantallaAlerta();
}

class _EstadoPantallaAlerta extends State<PantallaAlerta> {
  final TextEditingController _controladorFecha = TextEditingController();
  final TextEditingController _controladorDias = TextEditingController(text: '30');

  int _diasSeleccionados = 30;

  @override
  void dispose() {
    _controladorFecha.dispose();
    _controladorDias.dispose();
    super.dispose();
  }

  // Te autocompleta la fecha para un año clavado desde hoy
  void _seleccionarUnAnoSugerido() {
    final ahora = DateTime.now();
    final elAnoQueViene = ahora.add(const Duration(days: 365));
    _controladorFecha.text = '${elAnoQueViene.day}/${elAnoQueViene.month}/${elAnoQueViene.year}';
    setState(() {});
  }

  // Abre el selector de fechas de Android/iOS
  Future<void> _elegirFecha() async {
    final fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fechaElegida == null) return;

    _controladorFecha.text =
        '${fechaElegida.day}/${fechaElegida.month}/${fechaElegida.year}';
    setState(() {});
  }

  // La magia ocurre aquí: crea un evento y lo tira pa'l calendario nativo
  Future<void> _guardarAlerta() async {
    final trozos = _controladorFecha.text.split('/');
    if (trozos.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fecha inválida', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final dia = int.tryParse(trozos[0]) ?? 1;
    final mes = int.tryParse(trozos[1]) ?? 1;
    final ano = int.tryParse(trozos[2]) ?? 2024;
    final fechaExpiracion = DateTime(ano, mes, dia, 10, 0); // Lo ponemos a las 10 de la mañana que ya estamos despiertos
    
    // Alarma predeterminada basada en los días seleccionados
    final duracionAviso = Duration(days: _diasSeleccionados);

    final Event evento = Event(
      title: 'Vencimiento Garantía: ${widget.nombreComercio}',
      description: 'Recordatorio de fin de garantía para la compra realizada el ${widget.fechaCompra} en ${widget.nombreComercio}. Generado por TickSave.',
      startDate: fechaExpiracion,
      endDate: fechaExpiracion.add(const Duration(hours: 1)),
      allDay: true,
      iosParams: IOSParams(
        reminder: duracionAviso, 
      ),
      androidParams: const AndroidParams(
        emailInvites: [], // Evita invitar a nadie sin querer
      ),
    );

    // Lanza la aplicación de calendario que tengas instalada
    try {
      final resultado = await Add2Calendar.addEvent2Cal(evento);

      if (mounted) {
        final mensajero = ScaffoldMessenger.of(context);
        Navigator.pop(context); // Volvemos pa'trás
        if (resultado) {
          mensajero.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Text(
                TextosApp.de(context).alertaGuardadaExito,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else {
          mensajero.showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el calendario', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo añadir la alarma.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          TextosApp.de(context).configurarAlerta,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _construirTarjetaResumen(),
          Expanded(child: _construirCuerpoBlanco()),
        ],
      ),
    );
  }

  // Tarjeta de arriba para que sepas a qué ticket le estás poniendo la alarma
  Widget _construirTarjetaResumen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nombreComercio,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TextosApp.de(context).compradoEl(widget.fechaCompra),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // La parte de abajo, blanca con los formularios
  Widget _construirCuerpoBlanco() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _construirSeccionCaducidad(),
            const SizedBox(height: 20),
            _construirSeccionDias(),
            const SizedBox(height: 30),
            _construirBotonGuardar(),
            const SizedBox(height: 20),
            _construirPistaInformacion(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _construirSeccionCaducidad() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                TextosApp.de(context).fechaVencimiento,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controladorFecha,
            readOnly: true,
            onTap: _elegirFecha,
            style: const TextStyle(color: Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: 'dd/mm/aaaa',
              filled: true,
              fillColor: Colors.grey[100],
              suffixIcon: const Icon(Icons.calendar_today, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          TextButton(
            onPressed: _seleccionarUnAnoSugerido,
            child: Text(TextosApp.de(context).usarFechaSugerida),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionDias() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                TextosApp.de(context).diasAviso,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            TextosApp.de(context).pistaDiasAviso,
            style: const TextStyle(color: Colors.black, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controladorDias,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Color(0xFF111827)),
            onChanged: (valor) {
              final numero = int.tryParse(valor);
              setState(() {
                _diasSeleccionados = numero ?? 0;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _construirPildoraDia(7),
              _construirPildoraDia(15),
              _construirPildoraDia(30),
              _construirPildoraDia(60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _guardarAlerta,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: const Color(0xFF1877F2).withValues(alpha: 0.4),
        ),
        child: Text(
          TextosApp.de(context).botonGuardarAlerta,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _construirPistaInformacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              TextosApp.de(context).pistaInfoAviso,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Las cajitas rápidas para elegir 7, 15 o 30 días
  Widget _construirPildoraDia(int dias) {
    final estaSeleccionado = _diasSeleccionados == dias;
    return GestureDetector(
      onTap: () {
        setState(() {
          _diasSeleccionados = dias;
          _controladorDias.text = dias.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: estaSeleccionado ? const Color(0xFF1877F2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          TextosApp.de(context).diasX(dias),
          style: TextStyle(
            color: estaSeleccionado ? Colors.white : const Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
