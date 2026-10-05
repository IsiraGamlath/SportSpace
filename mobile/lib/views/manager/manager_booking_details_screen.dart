import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/pending_payment_pill.dart';
import '../../widgets/manager/section_card.dart';
import 'manager_notifications_screen.dart';

class ManagerBookingDetailsScreen extends StatefulWidget {
  const ManagerBookingDetailsScreen({super.key});

  @override
  State<ManagerBookingDetailsScreen> createState() =>
      _ManagerBookingDetailsScreenState();
}

class _ManagerBookingDetailsScreenState
    extends State<ManagerBookingDetailsScreen> {
  bool _isConfirmed = false;

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerNotificationsScreen(),
      ),
    );
  }

  void _confirmPayment() {
    setState(() {
      _isConfirmed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Confirmed! Booking status updated to Paid.'),
        backgroundColor: ManagerColors.green,
      ),
    );
  }

  void _markUnpaid() {
    setState(() {
      _isConfirmed = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking marked as Unpaid.'),
        backgroundColor: ManagerColors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        onNotificationsTap: _openNotifications,
                      ),
                      const SizedBox(height: 18),

                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: ManagerColors.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(text: 'Booking '),
                            TextSpan(
                              text: 'SS-20481',
                              style: TextStyle(
                                color: ManagerColors.navyDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: ' · Created today, 2:14 PM'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      const _SectionTitle('Player'),
                      const SizedBox(height: 10),

                      const SectionCard(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: _PlayerInfo(),
                      ),

                      const SizedBox(height: 18),
                      const _SectionTitle('Booking Details'),
                      const SizedBox(height: 10),

                      const SectionCard(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: _BookingInfo(),
                      ),

                      const SizedBox(height: 18),
                      const _SectionTitle('Payment Verification'),
                      const SizedBox(height: 10),

                      SectionCard(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: _PaymentInfo(isConfirmed: _isConfirmed),
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
                                onPressed: _markUnpaid,
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
                                onPressed: _confirmPayment,
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
                                child: Text(
                                  _isConfirmed ? 'Payment Confirmed √' : 'Confirm Payment',
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
  const _PlayerInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: ManagerColors.avatarBlue,
          child: Text(
            'KP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kasun Perera',
                style: TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: ManagerColors.secondaryText,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '077 123 4567',
                    style: TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 14,
                    color: ManagerColors.secondaryText,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'kasun.p@email.com',
                    style: TextStyle(
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
  const _BookingInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colombo Sports Centre',
          style: TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Badminton Court 1',
          style: TextStyle(
            color: ManagerColors.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 14),
        _InfoRow(
          label: 'Date',
          value: '16 September',
        ),
        SizedBox(height: 8),
        _InfoRow(
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
  const _PaymentInfo({required this.isConfirmed});

  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LKR 2,500',
                style: TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Card payment · Ref #PMT-88213',
                style: TextStyle(
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
