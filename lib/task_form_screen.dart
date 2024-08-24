import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  TaskFormScreen({this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late DateTime _dateTime;
  late String _address;
  late double _latitude;
  late double _longitude;
  late TextEditingController _dateTimeController;
  late TextEditingController _addressController;
  GoogleMapController? _mapController;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Carregar o ID do usuário logado

    if (widget.task != null) {
      _name = widget.task!.name;
      _dateTime = widget.task!.dateTime;
      _address = widget.task!.location;
      _latitude = widget.task!.latitude;
      _longitude = widget.task!.longitude;
    } else {
      _name = '';
      _dateTime = DateTime.now();
      _address = '';
      _latitude = 0.0;
      _longitude = 0.0;
    }
    _dateTimeController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(_dateTime),
    );
    _addressController = TextEditingController(text: _address);
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('loggedInUserId') ?? '';
  }

  Future<void> _geocodeAddress() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (_address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, digite um endereço.')),
      );
      return;
    }

    final apiKey = 'SUA_API_KEY_AQUI';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(_address)}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        setState(() {
          _latitude = location['lat'];
          _longitude = location['lng'];
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_latitude, _longitude),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhum resultado encontrado para o endereço.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao buscar dados de localização')),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text = DateFormat('dd/MM/yyyy HH:mm').format(_dateTime);
        });
      }
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId, // Associando a tarefa ao usuário logado
        name: _name,
        dateTime: _dateTime,
        location: _address,
        latitude: _latitude,
        longitude: _longitude,
      );
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? tasks = prefs.getStringList('tasks_$_userId') ?? [];
      tasks.add(jsonEncode(newTask.toJson()));
      await prefs.setStringList('tasks_$_userId', tasks);

      Navigator.of(context).pop(newTask);
    }
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              Text(
                widget.task == null ? 'Nova Atividade' : 'Editar Atividade',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Divider(
                color: Colors.blue,
                thickness: 2,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Atividade', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextFormField(
                              initialValue: _name,
                              decoration: InputDecoration(hintText: 'Digite a Atividade'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite a Atividade';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _name = value!;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Data e Hora', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextFormField(
                              controller: _dateTimeController,
                              decoration: InputDecoration(
                                hintText: 'Selecione a Data e Hora',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () => _selectDateTime(context),
                                ),
                              ),
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Local', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                hintText: 'Digite o Local',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: _geocodeAddress,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite o Local';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _address = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 200,
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(_latitude, _longitude),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('taskLocation'),
                              position: LatLng(_latitude, _longitude),
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('VOLTAR'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: TextStyle(fontSize: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      child: Text('SALVAR'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: TextStyle(fontSize: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
