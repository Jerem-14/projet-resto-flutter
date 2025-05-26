class Timeslot {
  final int id;
  final String startTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Timeslot({
    required this.id,
    required this.startTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Timeslot.fromJson(Map<String, dynamic> json) {
    return Timeslot(
      id: json['id'],
      startTime: json['start_time'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
      'is_active': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Getter pour afficher l'heure au format HH:MM
  String get displayTime {
    // Convertir de HH:MM:SS vers HH:MM
    final parts = startTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return startTime;
  }

  // Getter pour déterminer la période de la journée
  String get period {
    final hour = int.tryParse(startTime.split(':')[0]) ?? 0;

    if (hour >= 11 && hour < 15) {
      return 'Déjeuner';
    } else if (hour >= 19 && hour < 24) {
      return 'Dîner';
    } else {
      return 'Autre';
    }
  }

  // Méthode pour obtenir la couleur selon le statut
  String get statusColor {
    return isActive ? 'green' : 'red';
  }

  // Copie avec modifications
  Timeslot copyWith({
    int? id,
    String? startTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Timeslot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Timeslot(id: $id, startTime: $startTime, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Timeslot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Validation des heures
  static bool isValidTime(String time) {
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  // Vérifier si l'heure est dans les créneaux autorisés (12h-23h)
  static bool isInAllowedRange(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return false;

    final hour = int.tryParse(parts[0]);
    if (hour == null) return false;

    return hour >= 12 && hour <= 23;
  }

  // Comparer deux créneaux pour le tri
  int compareTo(Timeslot other) {
    return startTime.compareTo(other.startTime);
  }
}
