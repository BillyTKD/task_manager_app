import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _login;
  late String _password;
  late String _username;

  Future<void> _registerUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users') ?? [];

    String userId = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, String> newUser = {
      'id': userId,
      'login': _login,
      'password': _password,
      'username': _username,
    };

    users.add(userId);
    await prefs.setStringList('users', users);
    await prefs.setString(userId, jsonEncode(newUser));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[100]!, Colors.grey[400]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Registrar', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nome do Usuário',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o nome de usuário';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Login',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o login';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _login = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite a senha';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _registerUser();
                    }
                  },
                  child: Text('REGISTRAR'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size(double.infinity, 50), 
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
