import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TestLoginApp());
}

class TestLoginApp extends StatelessWidget {
  const TestLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'API Test',
      home: LoginTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginTestScreen extends StatefulWidget {
  const LoginTestScreen({super.key});

  @override
  State<LoginTestScreen> createState() => _LoginTestScreenState();
}

class _LoginTestScreenState extends State<LoginTestScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'jono@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'jono123');
  bool _isLoading = false;
  String _result = '';

  Future<void> _testLogin() async {
    debugPrint('=' * 50);
    debugPrint('TESTING API LOGIN');
    debugPrint('=' * 50);

    setState(() {
      _isLoading = true;
      _result = 'Testing login...';
    });

    const url = 'https://mollusklike-intactly-kennedi.ngrok-free.dev/api/mobile/login';

    debugPrint('URL: $url');
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Ambil dari nested 'data'
          final data = jsonResponse['data'];
          final user = data['user'];
          final token = data['token'];

          debugPrint('✅ LOGIN BERHASIL!');
          debugPrint('User: ${user['name']}');
          debugPrint('Email: ${user['email']}');
          debugPrint('Role: ${user['role']}');
          debugPrint('Token: $token');

          setState(() {
            _result = '✅ LOGIN BERHASIL!\n\n'
                'User: ${user['name']}\n'
                'Email: ${user['email']}\n'
                'Role: ${user['role']}\n'
                'Phone: ${user['phone']}\n\n'
                'Token: ${token.substring(0, 30)}...';
          });
        } else {
          debugPrint('❌ Login gagal: ${jsonResponse['message']}');
          setState(() {
            _result = '❌ LOGIN GAGAL\n\nMessage: ${jsonResponse['message']}';
          });
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        setState(() {
          _result = '❌ HTTP ERROR ${response.statusCode}';
        });
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() {
        _result = '❌ Error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });

    debugPrint('=' * 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Login Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Test Login'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hasil Test:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _result.isEmpty ? 'Tekan tombol untuk test' : _result,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}