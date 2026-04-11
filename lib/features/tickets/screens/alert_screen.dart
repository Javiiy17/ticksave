import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';

/// Pantalla para configurar una alerta de vencimiento de garantía.
///
/// La idea es que el usuario elija la fecha de vencimiento y los días previos.
/// Actualmente controla la interfaz de configuración.
/// @author Luis Bermeo
class AlertScreen extends StatefulWidget {
  const AlertScreen({
    super.key,
    required this.storeName,
    required this.purchaseDate,
  });

  final String storeName;
  final String purchaseDate;

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController(text: '30');

  int _selectedDays = 30;

  @override
  void dispose() {
    _dateController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _selectSuggestedOneYear() {
    final now = DateTime.now();
    final nextYear = now.add(const Duration(days: 365));
    _dateController.text = '${nextYear.day}/${nextYear.month}/${nextYear.year}';
    setState(() {});
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    _dateController.text =
        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
    setState(() {});
  }

  void _saveAlert() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          AppStrings.of(context).alertSavedSuccess,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          AppStrings.of(context).configureAlert,
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
          _buildSummaryCard(),
          Expanded(child: _buildWhiteBody()),
        ],
      ),
    );
  }

  /// Tarjeta superior que resume a qué ticket se le está creando la alerta.
  Widget _buildSummaryCard() {
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
              widget.storeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.of(context).purchasedOn(widget.purchaseDate),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// Cuerpo blanco inferior con fecha de vencimiento y días de aviso.
  Widget _buildWhiteBody() {
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
            _buildExpirationSection(),
            const SizedBox(height: 20),
            _buildDaysSection(),
            const SizedBox(height: 30),
            _buildSaveButton(),
            const SizedBox(height: 20),
            _buildInfoHint(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationSection() {
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
              Icon(Icons.calendar_month_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                AppStrings.of(context).expirationDate,
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
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
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
            onPressed: _selectSuggestedOneYear,
            child: Text(AppStrings.of(context).useSuggestedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSection() {
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
              Icon(Icons.notifications_active_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                AppStrings.of(context).noticeDays,
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
            AppStrings.of(context).noticeDaysHint,
            style: const TextStyle(color: Colors.black, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Color(0xFF111827)),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              setState(() {
                _selectedDays = parsed ?? 0;
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
              _buildDayChip(7),
              _buildDayChip(15),
              _buildDayChip(30),
              _buildDayChip(60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _saveAlert,
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
          AppStrings.of(context).saveAlertButton,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.of(context).noticeInfoHint,
              style: TextStyle(color: Colors.blue[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Botón tipo "chip" que permite seleccionar rápidamente un número de días.
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
          AppStrings.of(context).daysX(days),
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

