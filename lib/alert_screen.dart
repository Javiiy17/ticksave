import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  final String storeName;
  final String purchaseDate;

  const AlertScreen({
    super.key,
    required this.storeName,
    required this.purchaseDate,
  });

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController(text: "30");

  // Variable para saber qué chip está seleccionado
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Configurar Alerta",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          // --- RESUMEN SUPERIOR ---
          // Muestra qué ticket estamos editando
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                    widget.storeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Comprado el ${widget.purchaseDate}",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- CUERPO BLANCO INFERIOR ---
          Expanded(
            child: Container(
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

                    // --- 1. SECCIÓN FECHA VENCIMIENTO ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_month_outlined, color: Colors.blue),
                              SizedBox(width: 8),
                              Text("Fecha de Vencimiento", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _dateController,
                            readOnly: true, // No se puede escribir, solo tocar
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 365)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                // Formateo simple de fecha
                                setState(() {
                                  _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "dd/mm/aaaa",
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
                            onPressed: () {
                              // Lógica rápida: sumar 1 año a la fecha actual
                              final now = DateTime.now();
                              final nextYear = now.add(const Duration(days: 365));
                              setState(() {
                                _dateController.text = "${nextYear.day}/${nextYear.month}/${nextYear.year}";
                              });
                            },
                            child: const Text("Usar fecha sugerida (1 año después)"),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- 2. SECCIÓN DÍAS DE AVISO ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.notifications_active_outlined, color: Colors.orange),
                              SizedBox(width: 8),
                              Text("Días de Aviso", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Recibirás una notificación con esta anticipación",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _daysController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _selectedDays = int.tryParse(value) ?? 0;
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

                          // Chips de selección rápida
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDayChip(7),
                              _buildDayChip(15),
                              _buildDayChip(30),
                              _buildDayChip(60),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- BOTÓN GUARDAR ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // AQUÍ SE GUARDARÍA LA ALERTA
                          Navigator.pop(context); // Volver atrás simulando guardado
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("¡Alerta guardada correctamente!")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF1877F2).withOpacity(0.4),
                        ),
                        child: const Text(
                          "Guardar Alerta",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- INFO FINAL ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Te enviaremos una notificación cuando se acerque la fecha de vencimiento.",
                              style: TextStyle(color: Colors.blue[800], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30), // Espacio extra final
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para los botones pequeños de días
  Widget _buildDayChip(int days) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
          _daysController.text = days.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1877F2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "$days días",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}