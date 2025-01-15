// lib/models/task_model.dart
import 'package:intl/intl.dart';

class TaskModel {
  String id;
  String texnikId;
  String details;
  bool maldirovka;
  bool oyildi;
  String status; // 'belgilangan', 'jarayonda', 'tugallangan'
  int soni;
  double narxi;
  DateTime sana;

  TaskModel({
    required this.id,
    required this.texnikId,
    required this.details,
    this.maldirovka = false,
    this.oyildi = false,
    this.status = 'belgilangan',
    this.soni = 0,
    this.narxi = 0.0,
    required this.sana,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      texnikId: json['texnikId'] ?? '',
      details: json['details'] ?? '',
      maldirovka: json['maldirovka'] ?? false,
      oyildi: json['oyildi'] ?? false,
      status: json['status'] ?? 'belgilangan',
      soni: json['soni'] ?? 0,
      narxi: json['narxi'] is int ? (json['narxi'] as int).toDouble() : json['narxi'] ?? 0.0,
      sana: DateTime.tryParse(json['sana'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'texnikId': texnikId,
      'details': details,
      'maldirovka': maldirovka,
      'oyildi': oyildi,
      'status': status,
      'soni': soni,
      'narxi': narxi,
      'sana': DateFormat('yyyy-MM-dd').format(sana),
    };
  }

  double get umumiyNarxi => soni * narxi;
}