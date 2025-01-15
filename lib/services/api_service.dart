// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/task_model.dart';

class ApiService {
  final String baseUrl = 'https://mynewapp-d7d20-default-rtdb.firebaseio.com';

  // USER METHODS

  // GET: Barcha foydalanuvchilarni olish
  Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data == null) return [];
      List<UserModel> users = [];
      data.forEach((id, value) {
        users.add(UserModel.fromJson(value, id));
      });
      return users;
    } else {
      throw Exception('Foydalanuvchilarni olishda xatolik yuz berdi');
    }
  }

  // POST: Yangi foydalanuvchi qo‘shish
  Future<void> addUser(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users.json'),
      body: json.encode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Foydalanuvchini qo\'shishda xatolik yuz berdi');
    }
  }

  // PATCH: Foydalanuvchini yangilash
  Future<void> updateUser(UserModel user) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/${user.id}.json'),
      body: json.encode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Foydalanuvchini yangilashda xatolik yuz berdi');
    }
  }

  // TASK METHODS

  // GET: Barcha texnik ishlarini olish
  Future<List<TaskModel>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data == null) return [];
      List<TaskModel> tasks = [];
      data.forEach((id, value) {
        tasks.add(TaskModel.fromJson(value, id));
      });
      return tasks;
    } else {
      throw Exception('Ishlarni olishda xatolik yuz berdi');
    }
  }

  // POST: Yangi ish qo‘shish
  Future<void> addTask(TaskModel task) async {

    final response = await http.post(
      Uri.parse('$baseUrl/tasks.json'),
      body: json.encode(task.toJson()), // toJson() qo'shildi
    );
    if (response.statusCode != 200 && response.statusCode != 201) { // 201 ham qo'shildi
      throw Exception('Ishni qo\'shishda xatolik yuz berdi: ${response.statusCode}, ${response.body}'); // Xatolik haqida batafsil ma'lumot
    }
  }

  // PATCH: Ishni yangilash
  Future<void> updateTask(TaskModel task) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/tasks/${task.id}.json'),
      body: json.encode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Ishni yangilashda xatolik yuz berdi');
    }
  }

  // DELETE: Ishni o‘chirish (agar kerak bo‘lsa)
  Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id.json'),
    );

    if (response.statusCode != 200) {
      throw Exception('Ishni o\'chirishda xatolik yuz berdi');
    }
  }
  Future<TaskModel?> getTaskById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/$id.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        return TaskModel.fromJson(data, id);
      } else {
        return null;
      }
    } else {
      throw Exception('Vazifani olishda xatolik yuz berdi');
    }
  }
}
