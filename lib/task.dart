class Task {
  final String id;
  final String userId;
  final String name;
  final DateTime dateTime;
  final String location;
  final double latitude;
  final double longitude;

  Task({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  // Método para converter uma tarefa em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Método para criar uma tarefa a partir de um mapa JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
