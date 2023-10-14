import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib untuk shared_preferences
  await SharedPreferences.getInstance();
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = "";

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final apiUrl = "http://192.168.100.12/programphpapi/login.php";

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == "success") {
        final username = data['user']['username'];

        // Simpan data login
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(username: username),
          ),
        );
      } else {
        setState(() {
          _message = "Login gagal";
        });
      }
    } else {
      setState(() {
        _message = "Terjadi kesalahan saat mengakses server.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login App"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text("Login"),
                ),
                SizedBox(height: 20),
                Text(_message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
