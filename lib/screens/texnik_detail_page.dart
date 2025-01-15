// lib/screens/texnik_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';

class TexnikDetailPage extends StatefulWidget {
  final String taskId; // Changed from texnikId to taskId
  final bool isOwner; // true: admin, false: texnik

  const TexnikDetailPage({
    Key? key,
    required this.taskId,
    required this.isOwner,
  }) : super(key: key);

  @override
  State<TexnikDetailPage> createState() => _TexnikDetailPageState();
}

class _TexnikDetailPageState extends State<TexnikDetailPage> {
  final ApiService _apiService = ApiService();
  TaskModel? _task;
  bool _isLoading = true;
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _soniController = TextEditingController();
  final TextEditingController _narxiController = TextEditingController();
  String _status = 'belgilangan';
  bool _maldirovka = false;
  bool _oyildi = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      _task = await _apiService.getTaskById(widget.taskId); // Fetch task by ID
      if (_task != null) {
        setState(() {
          _detailsController.text = _task!.details;
          _soniController.text = _task!.soni.toString();
          _narxiController.text = _task!.narxi.toString();
          _status = _task!.status;
          _maldirovka = _task!.maldirovka;
          _oyildi = _task!.oyildi;
          _selectedDate = _task!.sana;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ish topilmadi")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_task == null || _task!.id.isEmpty) return;

    _task!.details = _detailsController.text.trim();
    _task!.status = _status;
    _task!.maldirovka = _maldirovka;
    _task!.oyildi = _oyildi;
    _task!.sana = _selectedDate;

    try {
      _task!.soni = int.tryParse(_soniController.text.trim()) ?? 0;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soni noto\'g\'ri formatda')),
      );
      return;
    }

    try {
      _task!.narxi = double.tryParse(_narxiController.text.trim()) ?? 0.0;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narxi noto\'g\'ri formatda')),
      );
      return;
    }

    try {
      await _apiService.updateTask(_task!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O\'zgartirishlar saqlandi')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Ish Ma'lumotlari"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null || _task!.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Ish Ma'lumotlari"),
        ),
        body: const Center(child: Text("Ish topilmadi")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ish: ${_task!.details.length <= 20 ? _task!.details : _task!.details.substring(0, 20)}",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Ish Tafsilotlari',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  readOnly: !widget.isOwner,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _maldirovka,
                      onChanged: widget.isOwner
                          ? (value) {
                        setState(() {
                          _maldirovka = value!;
                        });
                      }
                          : null,
                    ),
                    const Text('Maldirovka'),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: _oyildi,
                      onChanged: widget.isOwner
                          ? (value) {
                        setState(() {
                          _oyildi = value!;
                        });
                      }
                          : null,
                    ),
                    const Text('O\'yildi'),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _soniController,
                  decoration: const InputDecoration(
                    labelText: 'Soni',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  keyboardType: TextInputType.number,
                  readOnly: !widget.isOwner,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _narxiController,
                  decoration: const InputDecoration(
                    labelText: 'Narxi',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  readOnly: !widget.isOwner,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text("Sana tanlang: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'belgilangan', child: Text("Belgilangan")),
                    DropdownMenuItem(value: 'jarayonda', child: Text("Jarayonda")),
                    DropdownMenuItem(value: 'tugallangan', child: Text("Tugallangan")),
                  ],
                  onChanged: widget.isOwner
                      ? (val) {
                    if (val != null) {
                      setState(() {
                        _status = val;
                      });
                    }
                  }
                      : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: Text(widget.isOwner ? "Saqlash" : "Statusni Yangilash"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}