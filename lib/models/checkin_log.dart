class CheckInLog {
  final int? id;
  final int eventId;
  final String guestName;
  final String checkinTime;

  CheckInLog({
    this.id,
    required this.eventId,
    required this.guestName,
    required this.checkinTime,
  });

  // Konversi objek CheckInLog menjadi Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'guest_name': guestName,
      'checkin_time': checkinTime,
    };
  }

  // Factory untuk membuat objek CheckInLog dari Map (hasil query database)
  factory CheckInLog.fromMap(Map<String, dynamic> map) {
    return CheckInLog(
      id: map['id'],
      eventId: map['event_id'],
      guestName: map['guest_name'],
      checkinTime: map['checkin_time'],
    );
  }
}
