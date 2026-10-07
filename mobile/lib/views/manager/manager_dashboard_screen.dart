import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/manager_colors.dart';
import '../../widgets/manager/metric_card.dart';
import '../../widgets/manager/schedule_tile.dart';
import 'manager_booking_details_screen.dart';
import 'manager_notifications_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  final ValueChanged<int>? onNavigateTab;

  @override
  State<ManagerDashboardScreen> createState() => ManagerDashboardScreenState();
}

class ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  bool _isLoading = true;

  void reload() {
    _loadDashboardData();
  }
  int _bookingsCount = 0;
  int _pendingPaymentsCount = 0;
  int _maintenanceIssuesCount = 0;
  int _availableSlotsCount = 0;
  List<Map<String, dynamic>> _recentSlots = [];

  List<dynamic> _pendingPaymentsList = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.fetchPaymentVerifications().catchError((_) => <dynamic>[]),
        ApiService.fetchAllBookings().catchError((_) => <dynamic>[]),
        ApiService.fetchMaintenanceSummary().catchError((_) => <String, dynamic>{}),
        ApiService.fetchManagerSlots(date: 'Tomorrow')
            .catchError((_) => <Map<String, dynamic>>[]),
      ]);

      final allVerifications = results[0] as List<dynamic>;
      final allBookings = results[1] as List<dynamic>;
      final maintenanceSummary = results[2] as Map<String, dynamic>;
      final slots = results[3] as List<Map<String, dynamic>>;

      final pendingPayments = allVerifications
          .whereType<Map>()
          .where((p) => p['paymentStatus']?.toString() == 'pending')
          .toList();

      final totalBookings = allBookings.length >= allVerifications.length
          ? allBookings.length
          : allVerifications.length;

      if (mounted) {
        setState(() {
          _bookingsCount = totalBookings;
          _pendingPaymentsCount = pendingPayments.length;
          _pendingPaymentsList = pendingPayments;
          final requiredCount = (maintenanceSummary['required'] as num?)?.toInt() ?? 0;
          final scheduledCount = (maintenanceSummary['scheduled'] as num?)?.toInt() ?? 0;
          _maintenanceIssuesCount = requiredCount + scheduledCount;
          _availableSlotsCount = slots.where((s) => s['status'] == 'available').length;
          _recentSlots = slots.take(4).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openPendingPayments(BuildContext context) {
    if (_pendingPaymentsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pending payments requiring verification.'),
          backgroundColor: ManagerColors.navy,
        ),
      );
      return;
    }

    if (_pendingPaymentsList.length == 1) {
      final bId = _pendingPaymentsList.first['bookingId']?.toString() ?? 'SS-20481';
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ManagerBookingDetailsScreen(bookingId: bId),
        ),
      ).then((_) => _loadDashboardData());
      return;
    }

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
                    const Icon(Icons.payment_rounded, color: ManagerColors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Payments (${_pendingPaymentsList.length})',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: ManagerColors.navyDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _pendingPaymentsList.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = _pendingPaymentsList[index];
                      final bId = item['bookingId']?.toString() ?? 'Unknown';
                      final court = item['courtName']?.toString() ?? 'Badminton Court 1';
                      final amt = item['amount']?.toString() ?? '2500';
                      final method = item['paymentMethod']?.toString() ?? 'card';
                      final hasSlip = item['slipUrl'] != null;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: ManagerColors.amber.withValues(alpha: 0.15),
                          child: Icon(
                            method == 'bank' ? Icons.account_balance_rounded : Icons.credit_card_rounded,
                            color: ManagerColors.amber,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              bId,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: ManagerColors.navyDark,
                              ),
                            ),
                            if (hasSlip) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ManagerColors.teal.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Slip Attached',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: ManagerColors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('$court · LKR $amt'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ManagerBookingDetailsScreen(bookingId: bId),
                            ),
                          ).then((_) => _loadDashboardData());
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

  void _openBookingDetails(BuildContext context, [String? bookingId]) {
    final targetId = bookingId ??
        (_pendingPaymentsList.isNotEmpty
            ? _pendingPaymentsList.first['bookingId']?.toString()
            : null) ??
        'SS-20481';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManagerBookingDetailsScreen(bookingId: targetId),
      ),
    ).then((_) => _loadDashboardData());
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerNotificationsScreen(),
      ),
    );
  }

  ScheduleStatus _resolveScheduleStatus(String? status) {
    switch (status) {
      case 'booked':
        return ScheduleStatus.confirmed;
      case 'pending':
        return ScheduleStatus.pendingPayment;
      case 'paid':
        return ScheduleStatus.paid;
      default:
        return ScheduleStatus.confirmed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: ManagerColors.navy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(onNotificationsTap: () => _openNotifications(context)),
                    const SizedBox(height: 18),

                    Text(
                      DateTime.now().hour < 12
                          ? 'Good morning, Manager'
                          : (DateTime.now().hour < 17
                              ? 'Good afternoon, Manager'
                              : 'Good evening, Manager'),
                      style: const TextStyle(
                        color: ManagerColors.navy,
                        fontSize: 20,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Colombo Sports Centre',
                      style: TextStyle(
                        color: ManagerColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            value: _isLoading ? '...' : '$_bookingsCount',
                            label: "Total Bookings",
                            valueColor: ManagerColors.navy,
                            onTap: () => widget.onNavigateTab?.call(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            value: _isLoading ? '...' : '$_pendingPaymentsCount',
                            label: 'Pending Payments',
                            valueColor: ManagerColors.amber,
                            onTap: () => _openPendingPayments(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            value: _isLoading ? '...' : '$_maintenanceIssuesCount',
                            label: 'Maintenance Issues',
                            valueColor: ManagerColors.red,
                            onTap: () => widget.onNavigateTab?.call(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            value: _isLoading ? '...' : '$_availableSlotsCount',
                            label: 'Available Slots',
                            valueColor: ManagerColors.teal,
                            onTap: () => widget.onNavigateTab?.call(1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () => widget.onNavigateTab?.call(3),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _maintenanceIssuesCount > 0
                              ? const Color(0xFFFFF8EF)
                              : const Color(0xFFEFF8F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _maintenanceIssuesCount > 0
                                ? ManagerColors.amberBorder
                                : const Color(0xFFC6E7D2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _maintenanceIssuesCount > 0
                                  ? Icons.build_outlined
                                  : Icons.check_circle_outline,
                              size: 20,
                              color: _maintenanceIssuesCount > 0
                                  ? ManagerColors.amber
                                  : ManagerColors.green,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _maintenanceIssuesCount > 0
                                  ? '$_maintenanceIssuesCount facilities require attention.'
                                  : 'All facilities in good condition.',
                              style: const TextStyle(
                                color: ManagerColors.navy,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 22,
                              color: _maintenanceIssuesCount > 0
                                  ? ManagerColors.amber
                                  : ManagerColors.green,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Schedule",
                          style: TextStyle(
                            color: ManagerColors.navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.onNavigateTab?.call(1),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Full Schedule',
                            style: TextStyle(
                              color: ManagerColors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: ManagerColors.navy),
                        ),
                      )
                    else if (_recentSlots.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: const Text(
                          'No slots scheduled for today',
                          style: TextStyle(color: ManagerColors.secondaryText),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentSlots.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final slot = _recentSlots[index];
                          final time = slot['time'] as String? ?? '5:00 PM';
                          final courtName = slot['courtName'] as String? ?? 'Court';
                          final statusStr = slot['status'] as String? ?? 'available';

                          return ScheduleTile(
                            time: time,
                            title: courtName,
                            subtitle: statusStr == 'blocked'
                                ? (slot['blockedReason'] as String? ?? 'Under Maintenance')
                                : (statusStr == 'booked' ? 'Player booking' : 'Open for booking'),
                            status: _resolveScheduleStatus(statusStr),
                            onTap: () => _openBookingDetails(context),
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => widget.onNavigateTab?.call(2),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ManagerColors.navy,
                          side: const BorderSide(
                            color: ManagerColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text(
                          'View Bookings & Payment Verification',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 20,
          color: ManagerColors.navy,
        ),
        const SizedBox(width: 6),
        const Text(
          'SportSpace',
          style: TextStyle(
            color: ManagerColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: ManagerColors.tealSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Manager',
            style: TextStyle(
              color: ManagerColors.teal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: ManagerColors.cardBackground,
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
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 19,
          backgroundColor: Color(0xFF245D7D),
          child: Icon(
            Icons.manage_accounts_rounded,
            size: 21,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
