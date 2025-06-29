class CheckInLog {
  final int? id;
  final int? eventId;
  final String guestName;
  final String checkinTime;

  CheckInLog({
    this.id,
    this.eventId = 1,
    required this.guestName,
    required this.checkinTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'guest_name': guestName,
      'checkin_time': checkinTime,
    };
  }

  factory CheckInLog.fromMap(Map<String, dynamic> map) {
    return CheckInLog(
      id: map['id'] as int?,
      eventId: map['event_id'] as int?,
      guestName: map['guest_name'] as String,
      checkinTime: map['checkin_time'] as String,
    );
  }
}
