import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  bool _hasNewReservation = false;

  // Getter
  bool get hasNewReservation => _hasNewReservation;

  // Set new reservation notification
  void setNewReservation() {
    _hasNewReservation = true;
    notifyListeners();
  }

  // Clear notification (when user visits profile)
  void clearNewReservation() {
    _hasNewReservation = false;
    notifyListeners();
  }
} 