import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/maintenance_status_chip.dart';
import 'manager_notifications_screen.dart';

class ManagerMaintenanceScreen extends StatefulWidget {
  const ManagerMaintenanceScreen({super.key});

  @override
  State<ManagerMaintenanceScreen> createState() =>
      _ManagerMaintenanceScreenState();
}

class _ManagerMaintenanceScreenState extends State<ManagerMaintenanceScreen> {
  MaintenanceStatus _tennisStatus = MaintenanceStatus.required;

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerNotificationsScreen(),
      ),
    );
  }

  void _markUnderMaintenance() {
    setState(() {
      _tennisStatus = MaintenanceStatus.scheduled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tennis Court 1 marked as Under Maintenance and hidden from players.'),
        backgroundColor: ManagerColors.amber,
      ),
    );
  }

  void _markResolved() {
    setState(() {
      _tennisStatus = MaintenanceStatus.available;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Issue resolved! Tennis Court 1 is now Available for booking.'),
        backgroundColor: ManagerColors.green,
      ),
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(onNotificationsTap: _openNotifications),
                  const SizedBox(height: 18),

                  const _SimpleFacilityCard(
                    title: 'Badminton Court 2',
                    status: MaintenanceStatus.available,
                    description: 'No reported issues. Clean, marked and fully playable.',
                  ),

                  const SizedBox(height: 14),

                  _MaintenanceRequiredCard(
                    status: _tennisStatus,
                    onMarkUnderMaintenance: _markUnderMaintenance,
                    onMarkResolved: _markResolved,
                  ),

                  const SizedBox(height: 14),

                  const _SimpleFacilityCard(
                    title: 'Swimming Pool',
                    status: MaintenanceStatus.scheduled,
                    description:
                        '8:00 AM – 10:00 AM · Routine filtration & chlorination window.',
                  ),

                  const SizedBox(height: 18),

                  _InfoNotice(),
                ],
              ),
            ),
          ),
        );
      },
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
        const Text(
          'Maintenance Flags',
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

class _SimpleFacilityCard extends StatelessWidget {
  const _SimpleFacilityCard({
    required this.title,
    required this.status,
    required this.description,
  });

  final String title;
  final MaintenanceStatus status;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: ManagerColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ManagerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: ManagerColors.navyDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MaintenanceStatusChip(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: ManagerColors.secondaryText,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceRequiredCard extends StatelessWidget {
  const _MaintenanceRequiredCard({
    required this.status,
    required this.onMarkUnderMaintenance,
    required this.onMarkResolved,
  });

  final MaintenanceStatus status;
  final VoidCallback onMarkUnderMaintenance;
  final VoidCallback onMarkResolved;

  @override
  Widget build(BuildContext context) {
    final bool isResolved = status == MaintenanceStatus.available;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: ManagerColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isResolved ? ManagerColors.border : ManagerColors.amberBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Tennis Court 1',
                  style: TextStyle(
                    color: ManagerColors.navyDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MaintenanceStatusChip(status: status),
            ],
          ),

          const SizedBox(height: 10),

          const Text.rich(
            TextSpan(
              style: TextStyle(
                color: ManagerColors.secondaryText,
                fontSize: 13,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: 'Issue: ',
                  style: TextStyle(
                    color: ManagerColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: 'Net damaged'),
              ],
            ),
          ),

          const SizedBox(height: 4),

          const Text.rich(
            TextSpan(
              style: TextStyle(
                color: ManagerColors.secondaryText,
                fontSize: 13,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: 'Reported: ',
                  style: TextStyle(
                    color: ManagerColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: 'Today, 9:20 AM'),
              ],
            ),
          ),

          const SizedBox(height: 4),

          const Text.rich(
            TextSpan(
              style: TextStyle(
                color: ManagerColors.secondaryText,
                fontSize: 13,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: 'Priority: ',
                  style: TextStyle(
                    color: ManagerColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'Medium',
                  style: TextStyle(
                    color: ManagerColors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (!isResolved) ...[
            InkWell(
              onTap: onMarkUnderMaintenance,
              child: const Text(
                'Mark Under Maintenance (Hide from schedule)',
                style: TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Repair scheduled for 2:00 PM')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Schedule Repair',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onMarkResolved,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: ManagerColors.green,
                      foregroundColor: ManagerColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Mark Resolved',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ManagerColors.greenSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: ManagerColors.green),
                  SizedBox(width: 8),
                  Text(
                    'Court verified ready for play',
                    style: TextStyle(
                      color: ManagerColors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: ManagerColors.infoBlueSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ManagerColors.infoBlueBorder,
          width: 1,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: ManagerColors.infoBlue,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Facilities marked under maintenance are automatically hidden from player availability and cannot be booked.',
              style: TextStyle(
                color: ManagerColors.navyDark,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
