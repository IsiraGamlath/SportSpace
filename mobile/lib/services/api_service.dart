import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/time_slot.dart';

class ApiService {
  static const String baseUrl = 'http://10.137.39.116:5000/api'; // Use 10.0.2.2 for Android emulator

  static Future<List<TimeSlot>> fetchSlots({String? date}) async {
    try {
      final uri = date != null ? Uri.parse('$baseUrl/slots?date=$date') : Uri.parse('$baseUrl/slots');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TimeSlot(
          id: json['id'],
          time: json['time'],
          durationRange: json['durationRange'],
          status: _parseStatus(json['status']),
          price: json['price'].toDouble(),
          isConflictTrigger: json['isConflictTrigger'] ?? false,
          date: json['date'],
        )).toList();
      } else {
        throw Exception('Failed to load slots');
      }
    } catch (e) {
      throw Exception('Error fetching slots: $e');
    }
  }

  static Future<bool> bookSlot(String id, {String? paymentIntentId, String paymentMethod = 'card'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/slots/$id/book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentIntentId': paymentIntentId,
          'paymentMethod': paymentMethod,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 409) {
        throw Exception('Slot already booked or conflict');
      } else {
        throw Exception('Failed to book slot');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(double amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount.toInt(),
          'currency': currency,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  static Future<List<dynamic>> fetchBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  static Future<bool> cancelBooking(String bookingId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/bookings/$bookingId/cancel'));
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel booking');
      }
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }

  static Future<bool> rescheduleBooking(String bookingId, String newSlotId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/reschedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'newSlotId': newSlotId,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to reschedule booking');
      }
    } catch (e) {
      throw Exception('Error rescheduling booking: $e');
    }
  }

  static SlotStatus _parseStatus(String status) {
    switch (status) {
      case 'available':
        return SlotStatus.available;
      case 'selected':
        return SlotStatus.selected;
      case 'booked':
        return SlotStatus.booked;
      default:
        return SlotStatus.available;
    }
  }
}
