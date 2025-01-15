// lib/screens/admin_main_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'texniklar_page.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _soniController = TextEditingController();
  final TextEditingController _narxiController = TextEditingController();
  String? _selectedTexnikId;
  String _status = 'belgilangan';
  bool _maldirovka = false;
  bool _oyildi = false;
  DateTime _selectedDate = DateTime.now();
  List<UserModel> _texniklar = [];

  @override
  void initState() {
    super.initState();
    _loadTexniklar();
  }

  Future<void> _loadTexniklar() async {
    try {
      List<UserModel> users = await _apiService.getUsers();
      setState(() {
        _texniklar = users.where((user) => user.role == 'texnik').toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: ${e.toString()}')),
      );
    }
  }

  Future<void> _addTask() async {
    if (_selectedTexnikId == null ||
        _detailsController.text.trim().isEmpty ||
        _soniController.text.trim().isEmpty ||
        _narxiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, barcha maydonlarni to‘ldiring')),
      );
      return;
    }

    try {
      final task = TaskModel(
        id: '',
        texnikId: _selectedTexnikId!,
        details: _detailsController.text.trim(),
        maldirovka: _maldirovka,
        oyildi: _oyildi,
        status: _status,
        soni: int.parse(_soniController.text.trim()),
        narxi: double.parse(_narxiController.text.trim()),
        sana: _selectedDate,
      );

      await _apiService.addTask(task);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ish qo‘shildi')),
      );

      _detailsController.clear();
      _soniController.clear();
      _narxiController.clear();

      setState(() {
        _selectedTexnikId = null;
        _status = 'belgilangan';
        _maldirovka = false;
        _oyildi = false;
        _selectedDate = DateTime.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: ${e.toString()}')),
      );
    }
  }


  // ... (Texniklarni boshqarish uchun funksiyalar)
  void _openTexniklarPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TexniklarPage()),
    );
  }

  // ... (Dialogni ochish funksiyasi)
  void _openAddTexnikDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _loginController = TextEditingController();
        final TextEditingController _passwordController = TextEditingController();

        return AlertDialog(
          title: const Text('Yangi Texnik Qo‘shish'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    labelText: 'Login',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Parol',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () async {
                final login = _loginController.text.trim();
                final password = _passwordController.text.trim();

                if (login.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Iltimos, barcha maydonlarni to‘ldiring')),
                  );
                  return;
                }

                final newUser = UserModel(
                  id: '',
                  login: login,
                  password: password,
                  role: 'texnik',
                );

                try {
                  await _apiService.addUser(newUser);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yangi texnik qo‘shildi')),
                  );
                  Navigator.pop(context);
                  _loadTexniklar();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xatolik: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Qo‘shish'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: _openTexniklarPage,
            icon: const Icon(Icons.list),
            tooltip: "Texniklar Ro'yxati",
          ),
          IconButton(
            onPressed: _openAddTexnikDialog,
            icon: const Icon(Icons.person_add),
            tooltip: "Yangi Texnik Qo‘shish",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView( // Scroll qo'shildi
              child: Column(
                children: [
                  const Text(
                    "Yangi Ish Qo‘shish",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedTexnikId,
                    decoration: const InputDecoration(
                      labelText: 'Texnikni tanlang',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: _texniklar.map((texnik) {
                      return DropdownMenuItem(
                        value: texnik.id,
                        child: Text(texnik.login),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedTexnikId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _soniController,
                    decoration: const InputDecoration(
                      labelText: 'Soni',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _narxiController,
                    decoration: const InputDecoration(
                      labelText: 'Narxi',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.info),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'belgilangan', child: Text("Belgilangan")),
                      DropdownMenuItem(
                          value: 'jarayonda', child: Text("Jarayonda")),
                      DropdownMenuItem(
                          value: 'tugallangan', child: Text("Tugallangan")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _status = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      labelText: 'Ish Tafsilotlari',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Maldirovka'),
                      Checkbox(
                        value: _maldirovka,
                        onChanged: (value) {
                          setState(() {
                            _maldirovka = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      const Text('O\'yildi'),
                      Checkbox(
                        value: _oyildi,
                        onChanged: (value) {
                          setState(() {
                            _oyildi = value!;
                          });
                        },
                      ),

                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.teal
                      ),
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: Text(
                          "Sana tanlang: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",style: TextStyle(color: Colors.white),),
                      )),
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.teal
                    ),
                    child: InkWell(
                      onTap: _addTask,
                       child: const Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save,color: Colors.white,),
                    SizedBox(width: 10,),
                    Text("Ish Qo‘shish",style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}