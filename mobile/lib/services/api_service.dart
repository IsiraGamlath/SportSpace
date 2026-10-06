import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/time_slot.dart';

class ApiService {
  static const String _webUrl = 'http://localhost:5000/api';
  static const String _usbUrl = 'http://127.0.0.1:5000/api';
  static const String _wifiUrl = 'http://192.168.8.100:5000/api';
  static const String _emulatorUrl = 'http://10.0.2.2:5000/api';
  static String? _activeBaseUrl;

  static String get baseUrl =>
      _activeBaseUrl ?? (kIsWeb ? _webUrl : _emulatorUrl);

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _post(
      '/auth/register',
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    return _decodeAuthResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      '/auth/login',
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    return _decodeAuthResponse(response);
  }

  static Map<String, dynamic> _decodeAuthResponse(http.Response response) {
    final body = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw Exception(body['message'] ?? 'Authentication request failed');
  }

  static Future<void> syncUserProfile({
    required String fullName,
    required String role,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to sync your profile.');
    }

    final token = await user.getIdToken();
    final response = await _post(
      '/users/profile',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'fullName': fullName, 'role': role}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Unable to save profile to MongoDB');
    }
  }

  static final List<String> _candidates = [_usbUrl, _wifiUrl, _emulatorUrl];

  static Future<http.Response> _get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$path',
      ).replace(queryParameters: queryParams);
      return await http.get(uri).timeout(const Duration(milliseconds: 2500));
    } catch (_) {}

    for (final candidate in _candidates) {
      if (candidate == baseUrl) continue;
      try {
        final uri = Uri.parse(
          '$candidate$path',
        ).replace(queryParameters: queryParams);
        final res = await http
            .get(uri)
            .timeout(const Duration(milliseconds: 2500));
        _activeBaseUrl = candidate;
        return res;
      } catch (_) {}
    }
    throw Exception('Failed to connect to backend on any host (USB or Wi-Fi)');
  }

  static Future<http.Response> _post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http
          .post(Uri.parse('$baseUrl$path'), headers: headers, body: body)
          .timeout(const Duration(milliseconds: 2500));
    } catch (_) {}

    for (final candidate in _candidates) {
      if (candidate == baseUrl) continue;
      try {
        final res = await http
            .post(Uri.parse('$candidate$path'), headers: headers, body: body)
            .timeout(const Duration(milliseconds: 2500));
        _activeBaseUrl = candidate;
        return res;
      } catch (_) {}
    }
    throw Exception('Failed to connect to backend on any host');
  }

  static Future<http.Response> _put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http
          .put(Uri.parse('$baseUrl$path'), headers: headers, body: body)
          .timeout(const Duration(milliseconds: 2500));
    } catch (_) {}

    for (final candidate in _candidates) {
      if (candidate == baseUrl) continue;
      try {
        final res = await http
            .put(Uri.parse('$candidate$path'), headers: headers, body: body)
            .timeout(const Duration(milliseconds: 2500));
        _activeBaseUrl = candidate;
        return res;
      } catch (_) {}
    }
    throw Exception('Failed to connect to backend on any host');
  }

  static Future<http.Response> _patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http
          .patch(Uri.parse('$baseUrl$path'), headers: headers, body: body)
          .timeout(const Duration(milliseconds: 2500));
    } catch (_) {}

    for (final candidate in _candidates) {
      if (candidate == baseUrl) continue;
      try {
        final res = await http
            .patch(Uri.parse('$candidate$path'), headers: headers, body: body)
            .timeout(const Duration(milliseconds: 2500));
        _activeBaseUrl = candidate;
        return res;
      } catch (_) {}
    }
    throw Exception('Failed to connect to backend on any host');
  }

  static Future<http.Response> _delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      return await http
          .delete(Uri.parse('$baseUrl$path'), headers: headers)
          .timeout(const Duration(milliseconds: 2500));
    } catch (_) {}

    for (final candidate in _candidates) {
      if (candidate == baseUrl) continue;
      try {
        final res = await http
            .delete(Uri.parse('$candidate$path'), headers: headers)
            .timeout(const Duration(milliseconds: 2500));
        _activeBaseUrl = candidate;
        return res;
      } catch (_) {}
    }
    throw Exception('Failed to connect to backend on any host');
  }

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

      final response = await _get(
        '/slots',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (json) => TimeSlot(
                id: json['id'],
                time: json['time'],
                durationRange: json['durationRange'],
                status: _parseStatus(json['status']),
                price: json['price'].toDouble(),
                isConflictTrigger: json['isConflictTrigger'] ?? false,
                date: json['date'],
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load slots');
      }
    } catch (e) {
      throw Exception('Error fetching slots: $e');
    }
  }


  static Future<List<Map<String, dynamic>>> fetchManagerSlots({
    String? date,
    String? courtName,
  }) async {
    try {
      final queryParams = <String, String>{'managerView': 'true'};
      if (date != null && date.isNotEmpty) queryParams['date'] = date;
      if (courtName != null &&
          courtName.isNotEmpty &&
          courtName != 'All Courts') {
        queryParams['courtName'] = courtName;
      }

      final response = await _get('/slots', queryParams: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load manager slots');
      }
    } catch (e) {
      throw Exception('Error fetching manager slots: $e');
    }
  }

  static Future<Map<String, dynamic>> createSlot(
    Map<String, dynamic> slotData,
  ) async {
    try {
      final response = await _post(
        '/slots',
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

  static Future<Map<String, dynamic>> updateSlot(
    String id,
    Map<String, dynamic> slotData,
  ) async {
    try {
      final response = await _put(
        '/slots/$id',
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
      final response = await _delete('/slots/$id');
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
      final response = await _patch(
        '/slots/$id/block',
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'blocked': blocked, 'reason': reason}),
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

  static Future<Map<String, dynamic>> bookSlot(String id, {String? paymentIntentId, String paymentMethod = 'card', String? slipFilePath}) async {
    try {
      if (slipFilePath != null) {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/slots/$id/book'));
        request.fields['paymentMethod'] = paymentMethod;
        if (paymentIntentId != null) {
          request.fields['paymentIntentId'] = paymentIntentId;
        }
        
        request.files.add(await http.MultipartFile.fromPath('slip', slipFilePath));
        
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 409) {
          throw Exception('Slot already booked or conflict');
        } else {
          throw Exception('Failed to book slot');
        }
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl/slots/$id/book'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'paymentIntentId': paymentIntentId,
            'paymentMethod': paymentMethod,
          }),
        );
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 409) {
          throw Exception('Slot already booked or conflict');
        } else {
          throw Exception('Failed to book slot');
        }
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

      final response = await _get(
        '/maintenance',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

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
      final response = await _get('/maintenance/overview/summary');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load maintenance summary');
      }
    } catch (e) {
      throw Exception('Error fetching maintenance summary: $e');
    }
  }

  static Future<Map<String, dynamic>> createMaintenanceFlag(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _post(
        '/maintenance',
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

  static Future<Map<String, dynamic>> updateMaintenanceFlag(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _put(
        '/maintenance/$id',
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

  static Future<Map<String, dynamic>> resolveMaintenanceFlag(
    String id, {
    String? resolutionNotes,
  }) async {
    try {
      final response = await _patch(
        '/maintenance/$id/resolve',
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
      final response = await _delete('/maintenance/$id');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting maintenance flag: $e');
    }
  }

  // ================= PAYMENTS & BOOKINGS ================= //

  static Future<Map<String, dynamic>?> createPaymentIntent(
    double amount,
    String currency,
  ) async {
    try {
      final response = await _post(
        '/payments/create-intent',
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount.toInt(), 'currency': currency}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  static Future<List<dynamic>> fetchBookings() async {
    try {
      final response = await _get('/bookings');
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
      final response = await _post('/bookings/$bookingId/cancel');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }

  static Future<bool> rescheduleBooking(
    String bookingId,
    String newSlotId,
  ) async {
    try {
      final response = await _post(
        '/bookings/$bookingId/reschedule',
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'newSlotId': newSlotId}),
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

      final response = await _get(
        '/payment-verifications',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load payment verifications');
      }
    } catch (e) {
      throw Exception('Error fetching payment verifications: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchVerificationStatus(
    String bookingId,
  ) async {
    try {
      final response = await _get('/payment-verifications/$bookingId/status');
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
      final response = await _patch(
        '/payment-verifications/$bookingId/verify',
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
      final response = await _patch(
        '/payment-verifications/$bookingId/unpaid',
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
