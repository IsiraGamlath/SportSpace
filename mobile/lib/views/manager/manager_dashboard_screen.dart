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
    this.isApproved = false,
  });

  final ValueChanged<int>? onNavigateTab;
  final bool isApproved;

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  bool _isLoading = true;
  int _bookingsCount = 0;
  int _pendingPaymentsCount = 0;
  int _maintenanceIssuesCount = 0;
  int _availableSlotsCount = 0;
  List<Map<String, dynamic>> _recentSlots = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.fetchBookings().catchError((_) => <dynamic>[]),
        ApiService.fetchPaymentVerifications(paymentStatus: 'pending')
            .catchError((_) => <dynamic>[]),
        ApiService.fetchMaintenanceSummary().catchError((_) => <String, dynamic>{}),
        ApiService.fetchManagerSlots(date: 'Tomorrow')
            .catchError((_) => <Map<String, dynamic>>[]),
      ]);

      final bookings = results[0] as List<dynamic>;
      final pendingPayments = results[1] as List<dynamic>;
      final maintenanceSummary = results[2] as Map<String, dynamic>;
      final slots = results[3] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _bookingsCount = bookings.length;
          _pendingPaymentsCount = pendingPayments.length;
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

  void _openBookingDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerBookingDetailsScreen(),
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

                    if (!widget.isApproved)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: ManagerColors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ManagerColors.amberBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: ManagerColors.amber, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your account is pending admin approval. You can view the dashboard but cannot manage venues yet.',
                                style: TextStyle(
                                  color: ManagerColors.amber.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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
                            onTap: () => widget.onNavigateTab?.call(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            value: _isLoading ? '...' : '$_pendingPaymentsCount',
                            label: 'Pending Payments',
                            valueColor: ManagerColors.amber,
                            onTap: () => _openBookingDetails(context),
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
                        onPressed: () => _openBookingDetails(context),
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
