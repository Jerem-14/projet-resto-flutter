class Reservation {
  final int id;
  final int userId;
  final int timeslotId;
  final String reservationDate;
  final int numberOfGuests;
  final bool isCancelled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Timeslot? timeslot;

  Reservation({
    required this.id,
    required this.userId,
    required this.timeslotId,
    required this.reservationDate,
    required this.numberOfGuests,
    required this.isCancelled,
    required this.createdAt,
    required this.updatedAt,
    this.timeslot,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      timeslotId: json['timeslot_id'],
      reservationDate: json['reservation_date'],
      numberOfGuests: json['number_of_guests'],
      isCancelled: json['is_cancelled'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      timeslot: json['timeslot'] != null ? Timeslot.fromJson(json['timeslot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'timeslot_id': timeslotId,
      'reservation_date': reservationDate,
      'number_of_guests': numberOfGuests,
      'is_cancelled': isCancelled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'timeslot': timeslot?.toJson(),
    };
  }

  // Helper method to get formatted date
  String get formattedDate {
    final date = DateTime.parse(reservationDate);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Helper method to get formatted time
  String get formattedTime {
    return timeslot?.formattedTime ?? 'N/A';
  }
}

class Timeslot {
  final int id;
  final String startTime;

  Timeslot({
    required this.id,
    required this.startTime,
  });

  factory Timeslot.fromJson(Map<String, dynamic> json) {
    return Timeslot(
      id: json['id'],
      startTime: json['start_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
    };
  }

  // Helper method to get formatted time (HH:MM)
  String get formattedTime {
    // startTime is in format "HH:MM:SS", we want "HH:MM"
    if (startTime.length >= 5) {
      return startTime.substring(0, 5);
    }
    return startTime;
  }
} 