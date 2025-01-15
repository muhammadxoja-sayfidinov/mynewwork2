// lib/screens/texnik_main_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import 'texnik_detail_page.dart';

class TexnikMainScreen extends StatefulWidget {
  final String texnikId;

  const TexnikMainScreen({Key? key, required this.texnikId}) : super(key: key);

  @override
  State<TexnikMainScreen> createState() => _TexnikMainScreenState();
}

class _TexnikMainScreenState extends State<TexnikMainScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<TaskModel>> _futureTasks;

  @override
  void initState() {
    super.initState();
    _futureTasks = _apiService.getTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _futureTasks = _apiService.getTasks();
    });
  }

  void _openDetailPage(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TexnikDetailPage(
          isOwner: false, taskId: task.id, // Texnik tahrirlash huquqi
        ),
      ),
    ).then((_) {
      _refreshTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Texnik Dashboard"),
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: _futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }
          final tasks = snapshot.data!
              .where((task) => task.texnikId == widget.texnikId)
              .toList();
          if (tasks.isEmpty) {
            return const Center(child: Text("Hozircha hech narsa yo‘q."));
          }
          return RefreshIndicator(
            onRefresh: _refreshTasks,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(task.details),
                    subtitle: Text('Status: ${task.status}'),
                    trailing: Icon(
                      task.status == 'belgilangan'
                          ? Icons.assignment
                          : task.status == 'jarayonda'
                          ? Icons.work
                          : Icons.check_circle,
                      color: task.status == 'tugallangan'
                          ? Colors.green
                          : (task.status == 'jarayonda'
                          ? Colors.orange
                          : Colors.blue),
                    ),
                    onTap: () => _openDetailPage(task),
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
