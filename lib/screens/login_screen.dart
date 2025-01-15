// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'admin_main_screen.dart';
import 'texnik_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorText = '';

  final ApiService _apiService = ApiService();

  // Animatsiya uchun
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _doLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = 'Login va parolni kiriting!';
      });
      _animationController.forward(from: 0);
      return;
    }

    try {
      List<UserModel> users = await _apiService.getUsers();
      final matchedUser = users.firstWhere(
              (user) => user.login == login && user.password == password,
          orElse: () => UserModel(
            id: '',
            login: '',
            password: '',
            role: '',
          ));

      if (matchedUser.id.isEmpty) {
        setState(() {
          _errorText = 'Login yoki parol noto‘g‘ri!';
        });
        _animationController.forward(from: 0);
      } else {
        if (matchedUser.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          );
        } else if (matchedUser.role == 'texnik') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => TexnikMainScreen(texnikId: matchedUser.id)),
          );
        } else {
          setState(() {
            _errorText = 'Noma\'lum rol!';
          });
          _animationController.forward(from: 0);
        }
      }
    } catch (e) {
      setState(() {
        _errorText = 'Xatolik: ${e.toString()}';
      });
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kirish"),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _loginController,
                      decoration: const InputDecoration(
                        labelText: 'Login',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Parol',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    if (_errorText.isNotEmpty)
                      Text(
                        _errorText,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _doLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Kirish",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
