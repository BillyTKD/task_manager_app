import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_list_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _login;
  late String _password;
  bool _showCreateAccount = true;

  @override
  void initState() {
    super.initState();
    _checkExistingUsers();
  }

  Future<void> _checkExistingUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users');
    if (users != null && users.isNotEmpty) {
      setState(() {
        _showCreateAccount = false;
      });
    }
  }

  Future<void> _loginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users');

    if (users != null) {
      for (String user in users) {
        Map<String, dynamic> userData = jsonDecode(prefs.getString(user)!);
        if (userData['login'] == _login && userData['password'] == _password) {
          await prefs.setString('loggedInUserId', userData['id']); // Salva o ID do usuário logado
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TaskListScreen()),
          );
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login ou senha incorretos.')),
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
                Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 32),
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
                      _loginUser();
                    }
                  },
                  child: Text('ENTRAR'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size(double.infinity, 50), // Define largura máxima
                  ),
                ),
                if (_showCreateAccount) // Exibe o botão "Criar nova conta" somente se não houver usuários
                  SizedBox(height: 16),
                if (_showCreateAccount)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => RegistrationScreen()),
                      );
                    },
                    child: Text('Criar nova conta'),
                    style: TextButton.styleFrom(
                      primary: Colors.blue,
                      textStyle: TextStyle(fontSize: 16),
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


/* criar mais de 1 usuario
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_list_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _login;
  late String _password;

  Future<void> _loginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users');

    if (users != null) {
      for (String user in users) {
        Map<String, dynamic> userData = jsonDecode(prefs.getString(user)!);
        if (userData['login'] == _login && userData['password'] == _password) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TaskListScreen()),
          );
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login ou senha incorretos.')),
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
                Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 32),
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
                      _loginUser();
                    }
                  },
                  child: Text('ENTRAR'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size(double.infinity, 50), // Define largura máxima
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: Text('Criar nova conta'),
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                    textStyle: TextStyle(fontSize: 16),
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
*/