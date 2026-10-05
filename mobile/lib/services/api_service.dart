import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/time_slot.dart';

class ApiService {
  static const String baseUrl = 'http://10.137.39.116:5000/api'; // Use 10.0.2.2 for Android emulator

  // ================= SCHEDULE MANAGEMENT ================= //

  static Future<List<TimeSlot>> fetchSlots({
    String? date,
    String? courtName,
    bool managerView = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (date != null) queryParams['date'] = date;
      if (courtName != null) queryParams['courtName'] = courtName;
      if (managerView) queryParams['managerView'] = 'true';

      final uri = Uri.parse('$baseUrl/slots').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
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

  static Future<Map<String, dynamic>> createSlot(Map<String, dynamic> slotData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/slots'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(slotData),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create slot: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating slot: $e');
    }
  }

  static Future<Map<String, dynamic>> updateSlot(String id, Map<String, dynamic> slotData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/slots/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(slotData),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update slot: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating slot: $e');
    }
  }

  static Future<bool> deleteSlot(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/slots/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting slot: $e');
    }
  }

  static Future<Map<String, dynamic>> toggleBlockSlot(
    String id, {
    required bool blocked,
    String? reason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/slots/$id/block'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'blocked': blocked,
          'reason': reason,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to toggle slot block state: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error toggling slot block state: $e');
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

  // ================= MAINTENANCE MANAGEMENT ================= //

  static Future<List<dynamic>> fetchMaintenanceFlags({
    String? status,
    String? facilityName,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (facilityName != null) queryParams['facilityName'] = facilityName;

      final uri = Uri.parse('$baseUrl/maintenance').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load maintenance flags');
      }
    } catch (e) {
      throw Exception('Error fetching maintenance flags: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchMaintenanceSummary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/maintenance/overview/summary'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load maintenance summary');
      }
    } catch (e) {
      throw Exception('Error fetching maintenance summary: $e');
    }
  }

  static Future<Map<String, dynamic>> createMaintenanceFlag(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/maintenance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create maintenance flag: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating maintenance flag: $e');
    }
  }

  static Future<Map<String, dynamic>> updateMaintenanceFlag(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/maintenance/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update maintenance flag: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating maintenance flag: $e');
    }
  }

  static Future<Map<String, dynamic>> resolveMaintenanceFlag(String id, {String? resolutionNotes}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/maintenance/$id/resolve'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'resolutionNotes': resolutionNotes ?? 'Court verified ready for play',
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to resolve maintenance flag: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error resolving maintenance flag: $e');
    }
  }

  static Future<bool> deleteMaintenanceFlag(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/maintenance/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting maintenance flag: $e');
    }
  }

  // ================= PAYMENTS & BOOKINGS ================= //

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
      // Error creating payment intent: $e
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

  // ================= PAYMENT VERIFICATION (Manager Portal) ================= //

  static Future<List<dynamic>> fetchPaymentVerifications({
    String? paymentStatus,
    String? courtName,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;
      if (courtName != null) queryParams['courtName'] = courtName;

      final uri = Uri.parse('$baseUrl/payment-verifications').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load payment verifications');
      }
    } catch (e) {
      throw Exception('Error fetching payment verifications: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchVerificationStatus(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment-verifications/$bookingId/status'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load verification status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching verification status: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyPayment(
    String bookingId, {
    String? verifiedBy,
    String? notes,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/payment-verifications/$bookingId/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'verifiedBy': verifiedBy ?? 'Manager',
          'notes': notes ?? 'Payment verified by Manager',
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to verify payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying payment: $e');
    }
  }

  static Future<Map<String, dynamic>> markPaymentUnpaid(
    String bookingId, {
    String? verifiedBy,
    String? notes,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/payment-verifications/$bookingId/unpaid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'verifiedBy': verifiedBy ?? 'Manager',
          'notes': notes ?? 'Marked as unpaid by Manager',
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark payment unpaid: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking payment unpaid: $e');
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
