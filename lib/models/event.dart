class Event {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String hostName;
  final String? imageUrl; // Kolom tambahan untuk gambar
  final List<String> paidUsers; // Menyimpan daftar username yang sudah bayar

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.hostName,
    this.imageUrl,
    this.paidUsers = const [], // Menambahkan default empty list
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
      'imageUrl': imageUrl,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      location: map['location'] as String,
      hostName: map['hostName'] as String,
      imageUrl: map['imageUrl'] as String?,
      paidUsers:
          (map['paidUsers'] as String?)?.split(',') ??
          [], // Mengonversi string kembali ke list
    );
  }
}
