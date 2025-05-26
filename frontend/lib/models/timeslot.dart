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
    print('🔄 [Timeslot] Début conversion JSON: $json');

    try {
      // Extraction et validation de l'ID
      print('📊 [Timeslot] Extraction ID...');
      final id = json['id'];
      print('📊 [Timeslot] ID brut: $id (${id.runtimeType})');
      if (id == null) throw Exception('ID manquant');

      // Extraction et validation du start_time
      print('📊 [Timeslot] Extraction start_time...');
      final startTime = json['start_time'];
      print(
        '📊 [Timeslot] start_time brut: $startTime (${startTime.runtimeType})',
      );
      if (startTime == null) throw Exception('start_time manquant');

      // Extraction et validation de is_active
      print('📊 [Timeslot] Extraction is_active...');
      final isActive = json['is_active'] ?? true;
      print('📊 [Timeslot] is_active: $isActive (${isActive.runtimeType})');

      // Extraction et validation des dates
      print('📊 [Timeslot] Extraction createdAt...');
      final createdAtRaw = json['createdAt'] ?? json['created_at'];
      print(
        '📊 [Timeslot] createdAt brut: $createdAtRaw (${createdAtRaw?.runtimeType})',
      );
      if (createdAtRaw == null) throw Exception('createdAt manquant');

      print('📊 [Timeslot] Extraction updatedAt...');
      final updatedAtRaw = json['updatedAt'] ?? json['updated_at'];
      print(
        '📊 [Timeslot] updatedAt brut: $updatedAtRaw (${updatedAtRaw?.runtimeType})',
      );
      if (updatedAtRaw == null) throw Exception('updatedAt manquant');

      // Parsing des dates
      print('📅 [Timeslot] Parsing createdAt...');
      final createdAt = DateTime.parse(createdAtRaw.toString());
      print('📅 [Timeslot] createdAt parsé: $createdAt');

      print('📅 [Timeslot] Parsing updatedAt...');
      final updatedAt = DateTime.parse(updatedAtRaw.toString());
      print('📅 [Timeslot] updatedAt parsé: $updatedAt');

      // Création de l'objet
      print('🏗️ [Timeslot] Création de l\'objet...');
      final timeslot = Timeslot(
        id: id is int ? id : int.parse(id.toString()),
        startTime: startTime.toString(),
        isActive: isActive is bool
            ? isActive
            : (isActive.toString().toLowerCase() == 'true'),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      print('✅ [Timeslot] Objet créé avec succès: ${timeslot.toString()}');
      return timeslot;
    } catch (e, stackTrace) {
      print('💥 [Timeslot] Erreur lors de la conversion: $e');
      print('📚 [Timeslot] Stack trace: $stackTrace');
      print('📄 [Timeslot] JSON problématique: $json');
      rethrow;
    }
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
