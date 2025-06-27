class Event {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String hostName;
  final String notes;
  final double latitude;
  final double longitude;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.hostName,
    required this.notes,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'hostName': hostName,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      time: map['time'],
      location: map['location'],
      hostName: map['hostName'],
      notes: map['notes'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}