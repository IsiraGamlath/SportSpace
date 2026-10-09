import 'package:flutter/material.dart';

import '../../services/api_service.dart';
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
  bool _isLoading = true;
  List<dynamic> _flags = [];

  List<String> _facilityOptions = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceFlags();
  }

  Future<void> _loadMaintenanceFlags() async {
    setState(() => _isLoading = true);
    try {
      final flags = await ApiService.fetchMaintenanceFlags();
      final facilities = await ApiService.fetchFacilities();
      if (mounted) {
        setState(() {
          _flags = flags;
          _facilityOptions = facilities.map((f) => f.name).toList();
          if (_facilityOptions.isEmpty) {
            _facilityOptions = ['No Facilities Found'];
          }
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

  Future<void> _markUnderMaintenance(String id, String facilityName) async {
    try {
      await ApiService.updateMaintenanceFlag(id, {'status': 'scheduled'});
      _loadMaintenanceFlags();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$facilityName marked as Under Maintenance and hidden from players.'),
            backgroundColor: ManagerColors.amber,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _markResolved(String id, String facilityName) async {
    try {
      await ApiService.resolveMaintenanceFlag(id, resolutionNotes: 'Verified and playable');
      _loadMaintenanceFlags();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Issue resolved! $facilityName is now Available for booking.'),
            backgroundColor: ManagerColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  void _showScheduleRepairModal(String id, String facilityName) {
    final controller = TextEditingController(text: 'Today, 2:00 PM – 4:00 PM');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Schedule Repair for $facilityName', style: const TextStyle(fontSize: 16)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Repair Window',
              hintText: 'e.g. Today, 2:00 PM',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ApiService.updateMaintenanceFlag(id, {
                    'status': 'scheduled',
                    'scheduledRepairTime': controller.text.trim(),
                  });
                  _loadMaintenanceFlags();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Repair scheduled: ${controller.text}')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Save Schedule'),
            ),
          ],
        );
      },
    );
  }

  void _showAddFlagModal() {
    String selectedFacility = _facilityOptions.isNotEmpty ? _facilityOptions[0] : 'No Facilities Found';
    final issueController = TextEditingController();
    String selectedPriority = 'medium';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                22,
                22,
                MediaQuery.of(context).viewInsets.bottom + 26,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Report Maintenance Issue',
                        style: TextStyle(
                          color: ManagerColors.navyDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Facility',
                    style: TextStyle(
                      color: ManagerColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ManagerColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedFacility,
                        items: _facilityOptions
                            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedFacility = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  TextField(
                    controller: issueController,
                    decoration: const InputDecoration(
                      labelText: 'Issue Description',
                      hintText: 'e.g. Net torn, light bulb replaced',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'Priority',
                    style: TextStyle(
                      color: ManagerColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['low', 'medium', 'high'].map((p) {
                      final selected = selectedPriority == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p.toUpperCase()),
                          selected: selected,
                          onSelected: (_) {
                            setModalState(() => selectedPriority = p);
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final issue = issueController.text.trim();
                        if (issue.isEmpty) return;
                        Navigator.pop(context);
                        try {
                          await ApiService.createMaintenanceFlag({
                            'facilityName': selectedFacility,
                            'issue': issue,
                            'priority': selectedPriority,
                            'status': 'required',
                          });
                          _loadMaintenanceFlags();
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedFacility maintenance flag created. Slots auto-blocked!'),
                                backgroundColor: ManagerColors.amber,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ManagerColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Create Flag & Auto-Block Facility'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  MaintenanceStatus _resolveStatus(String? status) {
    switch (status) {
      case 'scheduled':
        return MaintenanceStatus.scheduled;
      case 'available':
      case 'resolved':
        return MaintenanceStatus.available;
      case 'required':
      default:
        return MaintenanceStatus.required;
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
              onRefresh: _loadMaintenanceFlags,
              color: ManagerColors.navy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      onNotificationsTap: _openNotifications,
                      onAddFlagTap: _showAddFlagModal,
                    ),
                    const SizedBox(height: 18),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: CircularProgressIndicator(color: ManagerColors.navy),
                        ),
                      )
                    else if (_flags.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: const Text(
                          'No maintenance flags reported.',
                          style: TextStyle(
                            color: ManagerColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _flags.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = _flags[index];
                          final id = item['id'] ?? item['_id'] ?? '';
                          final facilityName = item['facilityName'] as String? ?? 'Court';
                          final issue = item['issue'] as String? ?? '';
                          final statusStr = item['status'] as String? ?? 'required';
                          final priorityStr = (item['priority'] as String? ?? 'medium');
                          final scheduledTime = item['scheduledRepairTime'] as String?;
                          final notes = item['notes'] as String? ?? '';
                          final status = _resolveStatus(statusStr);

                          if (status == MaintenanceStatus.available) {
                            return _SimpleFacilityCard(
                              title: facilityName,
                              status: status,
                              description: notes.isNotEmpty ? notes : (issue.isNotEmpty ? issue : 'Clean, marked and fully playable.'),
                            );
                          }

                          return _MaintenanceRequiredCard(
                            facilityName: facilityName,
                            issue: issue,
                            priority: priorityStr,
                            scheduledTime: scheduledTime,
                            status: status,
                            onMarkUnderMaintenance: () => _markUnderMaintenance(id, facilityName),
                            onScheduleRepair: () => _showScheduleRepairModal(id, facilityName),
                            onMarkResolved: () => _markResolved(id, facilityName),
                          );
                        },
                      ),

                    const SizedBox(height: 18),
                    _InfoNotice(),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.onNotificationsTap,
    required this.onAddFlagTap,
  });

  final VoidCallback onNotificationsTap;
  final VoidCallback onAddFlagTap;

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
        IconButton(
          onPressed: onAddFlagTap,
          icon: const Icon(Icons.add_circle_outline, color: ManagerColors.navy, size: 24),
          tooltip: 'Report Issue',
        ),
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
    required this.facilityName,
    required this.issue,
    required this.priority,
    this.scheduledTime,
    required this.status,
    required this.onMarkUnderMaintenance,
    required this.onScheduleRepair,
    required this.onMarkResolved,
  });

  final String facilityName;
  final String issue;
  final String priority;
  final String? scheduledTime;
  final MaintenanceStatus status;
  final VoidCallback onMarkUnderMaintenance;
  final VoidCallback onScheduleRepair;
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
              Expanded(
                child: Text(
                  facilityName,
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

          const SizedBox(height: 10),

          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: ManagerColors.secondaryText,
                fontSize: 13,
                height: 1.35,
              ),
              children: [
                const TextSpan(
                  text: 'Issue: ',
                  style: TextStyle(
                    color: ManagerColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: issue.isNotEmpty ? issue : 'Maintenance required'),
              ],
            ),
          ),

          if (scheduledTime != null && scheduledTime!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: ManagerColors.secondaryText,
                  fontSize: 13,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(
                    text: 'Scheduled: ',
                    style: TextStyle(
                      color: ManagerColors.navyDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: scheduledTime!),
                ],
              ),
            ),
          ],

          const SizedBox(height: 4),

          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: ManagerColors.secondaryText,
                fontSize: 13,
                height: 1.35,
              ),
              children: [
                const TextSpan(
                  text: 'Priority: ',
                  style: TextStyle(
                    color: ManagerColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: priority[0].toUpperCase() + priority.substring(1),
                  style: TextStyle(
                    color: priority == 'high'
                        ? ManagerColors.red
                        : ManagerColors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (!isResolved) ...[
            if (status == MaintenanceStatus.required) ...[
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
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onScheduleRepair,
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
