import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/manager_colors.dart';
import '../../widgets/manager/pending_payment_pill.dart';
import '../../widgets/manager/section_card.dart';
import 'manager_notifications_screen.dart';

class ManagerBookingDetailsScreen extends StatefulWidget {
  const ManagerBookingDetailsScreen({
    super.key,
    this.bookingId,
    this.onBackTap,
  });

  final String? bookingId;
  final VoidCallback? onBackTap;

  @override
  State<ManagerBookingDetailsScreen> createState() =>
      ManagerBookingDetailsScreenState();
}

class ManagerBookingDetailsScreenState
    extends State<ManagerBookingDetailsScreen> {
  bool _isConfirmed = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentBookingId;
  Map<String, dynamic>? _data;
  List<Map<String, dynamic>> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _currentBookingId = widget.bookingId;
    _fetchVerificationStatus();
  }

  @override
  void didUpdateWidget(covariant ManagerBookingDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bookingId != null && widget.bookingId != oldWidget.bookingId) {
      _currentBookingId = widget.bookingId;
      _fetchVerificationStatus();
    }
  }

  void reload() {
    _fetchVerificationStatus();
  }

  void selectBooking(String bookingId) {
    setState(() => _currentBookingId = bookingId);
    _fetchVerificationStatus();
  }

  Future<void> _fetchVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> list = await ApiService.fetchPaymentVerifications();
      if (!mounted) return;

      final List<Map<String, dynamic>> bookingsList = list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        _allBookings = bookingsList;
      });

      Map<String, dynamic>? selected;
      if (_currentBookingId != null && _currentBookingId!.isNotEmpty) {
        selected = bookingsList.firstWhere(
          (b) => b['bookingId']?.toString() == _currentBookingId,
          orElse: () => <String, dynamic>{},
        );
      }

      if (selected == null || selected.isEmpty) {
        selected = bookingsList.firstWhere(
          (b) {
            final st = b['paymentStatus']?.toString().toLowerCase().trim();
            return st == 'pending' || st == 'unpaid' || st == 'pending_verification';
          },
          orElse: () => bookingsList.isNotEmpty ? bookingsList.first : <String, dynamic>{},
        );
      }

      if (selected.isNotEmpty) {
        _currentBookingId = selected['bookingId']?.toString();
        setState(() {
          _data = selected;
          _isConfirmed = selected?['paymentStatus']?.toString() == 'verified';
          _isLoading = false;
        });

        // Background refresh to get the latest slot relation data if needed
        if (_currentBookingId != null && _currentBookingId!.isNotEmpty) {
          try {
            final statusData =
                await ApiService.fetchVerificationStatus(_currentBookingId!);
            if (mounted && statusData.isNotEmpty) {
              setState(() {
                _data = Map<String, dynamic>.from(statusData);
                _isConfirmed =
                    _data?['paymentStatus']?.toString() == 'verified';
              });
            }
          } catch (_) {}
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching verification status: $e\n$st');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load bookings from server ($e)';
        });
      }
    }
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerNotificationsScreen(),
      ),
    );
  }

  void _showBookingSelectorSheet() {
    if (_allBookings.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.bookmark_border_rounded, color: ManagerColors.navy, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'All Bookings (${_allBookings.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ManagerColors.navyDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _allBookings.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = _allBookings[index];
                      final bId = item['bookingId']?.toString() ?? '';
                      final pName = item['playerName']?.toString() ?? 'Player';
                      final court = item['courtName']?.toString() ?? 'Badminton Court 1';
                      final amt = item['amount']?.toString() ?? '2500';
                      final status = item['paymentStatus']?.toString() ?? 'pending';
                      final isSelected = bId == _currentBookingId;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: ManagerColors.primaryBlue.withValues(alpha: 0.08),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? ManagerColors.navy
                              : ManagerColors.avatarBlue.withValues(alpha: 0.15),
                          child: Text(
                            pName.isNotEmpty ? pName[0].toUpperCase() : 'P',
                            style: TextStyle(
                              color: isSelected ? Colors.white : ManagerColors.navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              bId,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: ManagerColors.navyDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: ManagerColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('$court · LKR $amt', style: const TextStyle(fontSize: 11.5)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusBadge(status),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_rounded, color: ManagerColors.primaryBlue, size: 18),
                            ],
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          selectBooking(bId);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'verified') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: ManagerColors.greenSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Verified',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: ManagerColors.green),
        ),
      );
    } else if (status == 'unpaid') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200, width: 0.8),
        ),
        child: Text(
          'Unpaid',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.red.shade700),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ManagerColors.orangeSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: ManagerColors.orange),
      ),
    );
  }

  Future<void> _confirmPayment() async {
    if (_currentBookingId == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.verifyPayment(_currentBookingId!);
      if (mounted) {
        setState(() {
          _isConfirmed = true;
          _isLoading = false;
          if (res['verification'] is Map) {
            _data = Map<String, dynamic>.from(res['verification'] as Map);
          } else if (_data != null) {
            _data!['paymentStatus'] = 'verified';
          }
        });
        for (var b in _allBookings) {
          if (b['bookingId'] == _currentBookingId) {
            b['paymentStatus'] = 'verified';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Confirmed! Booking status updated to Paid.'),
            backgroundColor: ManagerColors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      // If error occurred (e.g. timeout race), check if DB was actually updated
      try {
        if (_currentBookingId != null) {
          final status =
              await ApiService.fetchVerificationStatus(_currentBookingId!);
          if (mounted && status['paymentStatus'] == 'verified') {
            setState(() {
              _isConfirmed = true;
              _isLoading = false;
              _data = Map<String, dynamic>.from(status);
            });
            for (var b in _allBookings) {
              if (b['bookingId'] == _currentBookingId) {
                b['paymentStatus'] = 'verified';
              }
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Payment Confirmed! Booking status updated to Paid.'),
                backgroundColor: ManagerColors.green,
              ),
            );
            return;
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    }
  }

  Future<void> _markUnpaid() async {
    if (_currentBookingId == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.markPaymentUnpaid(_currentBookingId!);
      if (mounted) {
        setState(() {
          _isConfirmed = false;
          _isLoading = false;
          if (res['verification'] is Map) {
            _data = Map<String, dynamic>.from(res['verification'] as Map);
          } else if (_data != null) {
            _data!['paymentStatus'] = 'unpaid';
          }
        });
        for (var b in _allBookings) {
          if (b['bookingId'] == _currentBookingId) {
            b['paymentStatus'] = 'unpaid';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking marked as Unpaid.'),
            backgroundColor: ManagerColors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking unpaid: $e');
      try {
        if (_currentBookingId != null) {
          final status =
              await ApiService.fetchVerificationStatus(_currentBookingId!);
          if (mounted && status['paymentStatus'] == 'unpaid') {
            setState(() {
              _isConfirmed = false;
              _isLoading = false;
              _data = Map<String, dynamic>.from(status);
            });
            for (var b in _allBookings) {
              if (b['bookingId'] == _currentBookingId) {
                b['paymentStatus'] = 'unpaid';
              }
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking marked as Unpaid.'),
                backgroundColor: ManagerColors.orange,
              ),
            );
            return;
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  void _viewSlip(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bank Transfer Slip',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: ManagerColors.navyDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        const Text(
                          'PDF Transfer Document Attached',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          url,
                          style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerName = _data?['playerName'] as String? ?? 'Player';
    final playerPhone = _data?['playerPhone'] as String? ?? 'N/A';
    final playerEmail = _data?['playerEmail'] as String? ?? '';
    final courtName = _data?['courtName'] as String? ?? 'Badminton Court 1';
    final facilityName = _data?['facilityName'] as String? ?? 'Colombo Sports Centre';
    final date = _data?['slotDate'] as String? ?? 'Tomorrow';
    final time = _data?['slotTime'] as String? ?? '6:00 PM – 7:00 PM';
    final amount = (_data?['amount'] as num?)?.toDouble() ?? 2500.0;
    final paymentRef = _data?['paymentRef'] as String? ?? 'PMT-88213';
    final paymentMethod = _data?['paymentMethod'] as String? ?? 'card';
    final slipUrl = _data?['slipUrl'] as String?;

    final currentIndex = _allBookings.indexWhere((b) => b['bookingId'] == _currentBookingId);

    return Scaffold(
      backgroundColor: ManagerColors.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width =
                constraints.maxWidth > 430 ? 430 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: RefreshIndicator(
                  onRefresh: _fetchVerificationStatus,
                  color: ManagerColors.navy,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          onNotificationsTap: _openNotifications,
                          onBackTap: widget.onBackTap,
                        ),
                        const SizedBox(height: 12),

                        if (_errorMessage != null && _data == null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _fetchVerificationStatus,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),

                        Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: ManagerColors.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Booking '),
                                    TextSpan(
                                      text: _currentBookingId ?? '...',
                                      style: const TextStyle(
                                        color: ManagerColors.navyDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const TextSpan(text: ' · Verification Record'),
                                  ],
                                ),
                              ),
                            ),
                            if (_allBookings.length > 1)
                              InkWell(
                                onTap: _showBookingSelectorSheet,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: ManagerColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${currentIndex >= 0 ? currentIndex + 1 : 1} of ${_allBookings.length}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: ManagerColors.navy,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Icon(
                                        Icons.unfold_more_rounded,
                                        size: 13,
                                        color: ManagerColors.navy,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (_isLoading && _data == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(color: ManagerColors.navy),
                            ),
                          )
                        else ...[
                          const _SectionTitle('Player'),
                          const SizedBox(height: 8),

                          SectionCard(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: _PlayerInfo(
                              name: playerName,
                              phone: playerPhone,
                              email: playerEmail,
                            ),
                          ),

                          const SizedBox(height: 14),
                          const _SectionTitle('Booking'),
                          const SizedBox(height: 8),

                          SectionCard(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: _BookingInfo(
                              facilityName: facilityName,
                              courtName: courtName,
                              date: date,
                              time: time,
                            ),
                          ),

                          const SizedBox(height: 14),
                          const _SectionTitle('Payment'),
                          const SizedBox(height: 8),

                          SectionCard(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: _PaymentInfo(
                              isConfirmed: _isConfirmed,
                              paymentStatus: _data?['paymentStatus']?.toString() ?? (_isConfirmed ? 'verified' : 'pending'),
                              amount: amount,
                              paymentRef: paymentRef,
                              paymentMethod: paymentMethod,
                              slipUrl: slipUrl,
                              onViewSlip: slipUrl != null ? () => _viewSlip(context, slipUrl) : null,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Free cancellation up to 3 hours before the slot.',
                            style: TextStyle(
                              color: ManagerColors.secondaryText,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Cancellations after this window are non-refundable.',
                            style: TextStyle(
                              color: ManagerColors.secondaryText,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: _isLoading ? null : _markUnpaid,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: ManagerColors.navy,
                                      backgroundColor: Colors.transparent,
                                      side: const BorderSide(
                                        color: ManagerColors.border,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text(
                                      'Mark as Unpaid',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _confirmPayment,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      backgroundColor: _isConfirmed
                                          ? ManagerColors.green
                                          : ManagerColors.primaryBlue,
                                      foregroundColor: ManagerColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _isConfirmed
                                                ? 'Payment Confirmed √'
                                                : 'Confirm Payment',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onNotificationsTap,
    this.onBackTap,
  });

  final VoidCallback onNotificationsTap;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                onBackTap?.call();
              }
            },
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: ManagerColors.navy,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Booking Details',
          style: TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: onNotificationsTap,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 16,
              color: ManagerColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: ManagerColors.navyDark,
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({
    required this.name,
    required this.phone,
    required this.email,
  });

  final String name;
  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join();

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: ManagerColors.avatarBlue,
          child: Text(
            initials.isNotEmpty ? initials : 'P',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: ManagerColors.secondaryText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    phone,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.mail_outline_rounded,
                    size: 13,
                    color: ManagerColors.secondaryText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingInfo extends StatelessWidget {
  const _BookingInfo({
    required this.courtName,
    this.facilityName = 'Colombo Sports Centre',
    this.date = 'Tomorrow',
    this.time = '6:00 PM – 7:00 PM',
  });

  final String courtName;
  final String facilityName;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          facilityName,
          style: const TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          courtName,
          style: const TextStyle(
            color: ManagerColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow(
          label: 'Date',
          value: date,
        ),
        const SizedBox(height: 6),
        _InfoRow(
          label: 'Time',
          value: time,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ManagerColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentInfo extends StatelessWidget {
  const _PaymentInfo({
    required this.isConfirmed,
    this.paymentStatus = 'pending',
    required this.amount,
    required this.paymentRef,
    this.paymentMethod = 'card',
    this.slipUrl,
    this.onViewSlip,
  });

  final bool isConfirmed;
  final String paymentStatus;
  final double amount;
  final String paymentRef;
  final String paymentMethod;
  final String? slipUrl;
  final VoidCallback? onViewSlip;

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = isConfirmed ? 'verified' : paymentStatus.toLowerCase().trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LKR ${amount.toInt()}',
                style: const TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${paymentMethod == 'bank' ? 'Bank transfer' : 'Card payment'} · Ref #$paymentRef',
                style: const TextStyle(
                  color: ManagerColors.secondaryText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  height: 1.15,
                ),
              ),
              if (slipUrl != null && slipUrl!.isNotEmpty) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: onViewSlip,
                  borderRadius: BorderRadius.circular(4),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attachment_rounded, size: 14, color: ManagerColors.primaryBlue),
                      SizedBox(width: 4),
                      Text(
                        'View Bank Slip',
                        style: TextStyle(
                          color: ManagerColors.primaryBlue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (effectiveStatus == 'verified')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ManagerColors.greenSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 13, color: ManagerColors.green),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: ManagerColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else if (effectiveStatus == 'unpaid')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Unpaid',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          const PendingPaymentPill(),
      ],
    );
  }
}
