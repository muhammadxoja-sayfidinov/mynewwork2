// lib/screens/texniklar_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'texnik_detail_page.dart';

class TexniklarPage extends StatefulWidget {
  const TexniklarPage({Key? key}) : super(key: key);

  @override
  State<TexniklarPage> createState() => _TexniklarPageState();
}

class _TexniklarPageState extends State<TexniklarPage> {
  final ApiService _apiService = ApiService();
  late Future<List<UserModel>> _futureTexniklar;

  @override
  void initState() {
    super.initState();
    _futureTexniklar = _apiService.getUsers();
  }

  Future<void> _refreshTexniklar() async {
    setState(() {
      _futureTexniklar = _apiService.getUsers();
    });
  }

  void _openDetailPage(UserModel texnik) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TexnikDetailPage(
          taskId: texnik.id,
          isOwner: true, // Admin tahrirlash huquqi
        ),
      ),
    ).then((_) {
      _refreshTexniklar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Texniklar Ro'yxati"),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _futureTexniklar,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }
          final texniklar = snapshot.data!
              .where((user) => user.role == 'texnik')
              .toList();
          if (texniklar.isEmpty) {
            return const Center(child: Text("Hech narsa topilmadi."));
          }
          return RefreshIndicator(
            onRefresh: _refreshTexniklar,
            child: ListView.builder(
              itemCount: texniklar.length,
              itemBuilder: (context, index) {
                final texnik = texniklar[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        texnik.login[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(texnik.login),
                    subtitle: Text('ID: ${texnik.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () => _openDetailPage(texnik),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
