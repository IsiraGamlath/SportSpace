import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/manager_colors.dart';
import '../../widgets/manager/pending_payment_pill.dart';
import '../../widgets/manager/section_card.dart';
import 'manager_notifications_screen.dart';

class ManagerBookingDetailsScreen extends StatefulWidget {
  const ManagerBookingDetailsScreen({
    super.key,
    this.bookingId = 'SS-20481',
  });

  final String bookingId;

  @override
  State<ManagerBookingDetailsScreen> createState() =>
      _ManagerBookingDetailsScreenState();
}

class _ManagerBookingDetailsScreenState
    extends State<ManagerBookingDetailsScreen> {
  bool _isConfirmed = false;
  bool _isLoading = false;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchVerificationStatus();
  }

  Future<void> _fetchVerificationStatus() async {
    setState(() => _isLoading = true);
    try {
      final statusData = await ApiService.fetchVerificationStatus(widget.bookingId);
      if (mounted) {
        setState(() {
          _data = statusData;
          _isConfirmed = statusData['paymentStatus'] == 'verified';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
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

  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.verifyPayment(widget.bookingId);
      if (mounted) {
        setState(() {
          _isConfirmed = true;
          _isLoading = false;
          if (res['verification'] != null) {
            _data = res['verification'];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Confirmed! Booking status updated to Paid.'),
            backgroundColor: ManagerColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    }
  }

  Future<void> _markUnpaid() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.markPaymentUnpaid(widget.bookingId);
      if (mounted) {
        setState(() {
          _isConfirmed = false;
          _isLoading = false;
          if (res['verification'] != null) {
            _data = res['verification'];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking marked as Unpaid.'),
            backgroundColor: ManagerColors.amber,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerName = _data?['playerName'] as String? ?? 'Kasun Perera';
    final playerPhone = _data?['playerPhone'] as String? ?? '077 123 4567';
    final playerEmail = _data?['playerEmail'] as String? ?? 'kasun.p@email.com';
    final courtName = _data?['courtName'] as String? ?? 'Badminton Court 1';
    final amount = (_data?['amount'] as num?)?.toDouble() ?? 2500.0;
    final paymentRef = _data?['paymentRef'] as String? ?? 'PMT-88213';

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
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          onNotificationsTap: _openNotifications,
                        ),
                        const SizedBox(height: 18),

                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: ManagerColors.secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(text: 'Booking '),
                              TextSpan(
                                text: widget.bookingId,
                                style: const TextStyle(
                                  color: ManagerColors.navyDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const TextSpan(text: ' · Verification Record'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        const _SectionTitle('Player'),
                        const SizedBox(height: 10),

                        SectionCard(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: _PlayerInfo(
                            name: playerName,
                            phone: playerPhone,
                            email: playerEmail,
                          ),
                        ),

                        const SizedBox(height: 18),
                        const _SectionTitle('Booking Details'),
                        const SizedBox(height: 10),

                        SectionCard(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: _BookingInfo(
                            courtName: courtName,
                          ),
                        ),

                        const SizedBox(height: 18),
                        const _SectionTitle('Payment Verification'),
                        const SizedBox(height: 10),

                        SectionCard(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: _PaymentInfo(
                            isConfirmed: _isConfirmed,
                            amount: amount,
                            paymentRef: paymentRef,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Free cancellation up to 3 hours before the slot.',
                          style: TextStyle(
                            color: ManagerColors.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cancellations after this window are non-refundable.',
                          style: TextStyle(
                            color: ManagerColors.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : _markUnpaid,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ManagerColors.navy,
                                    backgroundColor: Colors.transparent,
                                    side: const BorderSide(
                                      color: ManagerColors.border,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Mark as Unpaid',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
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
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
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
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
  const _Header({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 22,
              color: ManagerColors.navy,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Booking Details',
          style: TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
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
              size: 21,
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
        fontSize: 15,
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
          radius: 24,
          backgroundColor: ManagerColors.avatarBlue,
          child: Text(
            initials.isNotEmpty ? initials : 'KP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: ManagerColors.secondaryText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    phone,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.mail_outline_rounded,
                    size: 14,
                    color: ManagerColors.secondaryText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
  const _BookingInfo({required this.courtName});

  final String courtName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Colombo Sports Centre',
          style: TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          courtName,
          style: const TextStyle(
            color: ManagerColors.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        const _InfoRow(
          label: 'Date',
          value: 'Tomorrow',
        ),
        const SizedBox(height: 8),
        const _InfoRow(
          label: 'Time',
          value: '6:00 PM – 7:00 PM',
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 13.5,
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
    required this.amount,
    required this.paymentRef,
  });

  final bool isConfirmed;
  final double amount;
  final String paymentRef;

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Card payment · Ref #$paymentRef',
                style: const TextStyle(
                  color: ManagerColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (isConfirmed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ManagerColors.greenSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: ManagerColors.green),
                SizedBox(width: 5),
                Text(
                  'Verified & Paid',
                  style: TextStyle(
                    color: ManagerColors.green,
                    fontSize: 12,
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
