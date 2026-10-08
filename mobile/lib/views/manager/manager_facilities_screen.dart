import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/manager_colors.dart';

class ManagerFacilitiesScreen extends StatefulWidget {
  const ManagerFacilitiesScreen({super.key});

  @override
  State<ManagerFacilitiesScreen> createState() => _ManagerFacilitiesScreenState();
}

class _ManagerFacilitiesScreenState extends State<ManagerFacilitiesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _facilities = [];
  String _selectedType = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _sportTypes = [
    'All',
    'Badminton',
    'Tennis',
    'Basketball',
    'Futsal',
    'Squash',
    'Swimming Pool',
    'Cricket',
    'Table Tennis',
  ];

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.fetchFacilities(
        type: _selectedType == 'All' ? null : _selectedType,
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      );
      if (mounted) {
        setState(() {
          _facilities = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading facilities: $e')),
        );
      }
    }
  }

  void _showAddEditFacilityModal({Map<String, dynamic>? facilityToEdit}) {
    final isEditing = facilityToEdit != null;
    final nameController = TextEditingController(
      text: isEditing ? (facilityToEdit['name']?.toString() ?? '') : '',
    );
    String selectedType = isEditing
        ? (facilityToEdit['type']?.toString() ?? 'Badminton')
        : 'Badminton';
    final rateController = TextEditingController(
      text: isEditing ? (facilityToEdit['hourlyRate']?.toString() ?? '2500') : '2500',
    );
    final descController = TextEditingController(
      text: isEditing ? (facilityToEdit['description']?.toString() ?? '') : '',
    );
    final surfaceController = TextEditingController(
      text: isEditing ? (facilityToEdit['surface']?.toString() ?? 'Synthetic Mat') : 'Synthetic Mat',
    );
    String selectedStatus = isEditing
        ? (facilityToEdit['status']?.toString() ?? 'active')
        : 'active';
    bool isIndoor = isEditing
        ? (facilityToEdit['isIndoor'] == true)
        : true;
    String openingTime = isEditing
        ? (facilityToEdit['openingTime']?.toString() ?? '06:00 AM')
        : '06:00 AM';
    String closingTime = isEditing
        ? (facilityToEdit['closingTime']?.toString() ?? '10:00 PM')
        : '10:00 PM';

    bool isSubmitting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Facility' : 'Add New Facility',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ManagerColors.navyDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Facility Name
                    const Text(
                      'Facility Name *',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Badminton Court 3',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sport Type & Hourly Rate
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sport Type *',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedType,
                                    items: _sportTypes
                                        .where((t) => t != 'All')
                                        .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() => selectedType = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hourly Rate (LKR) *',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: rateController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '2500',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Operating Hours
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Opening Time',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 6, minute: 0),
                                  );
                                  if (time != null) {
                                    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                                    final min = time.minute.toString().padLeft(2, '0');
                                    final p = time.period == DayPeriod.am ? 'AM' : 'PM';
                                    setModalState(() => openingTime = '$hour:$min $p');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade400),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(openingTime, style: const TextStyle(fontSize: 13)),
                                      const Icon(Icons.access_time, size: 16, color: ManagerColors.navy),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Closing Time',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 22, minute: 0),
                                  );
                                  if (time != null) {
                                    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                                    final min = time.minute.toString().padLeft(2, '0');
                                    final p = time.period == DayPeriod.am ? 'AM' : 'PM';
                                    setModalState(() => closingTime = '$hour:$min $p');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade400),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(closingTime, style: const TextStyle(fontSize: 13)),
                                      const Icon(Icons.access_time, size: 16, color: ManagerColors.navy),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Status & Indoor
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedStatus,
                                    items: const [
                                      DropdownMenuItem(value: 'active', child: Text('Active', style: TextStyle(color: ManagerColors.green, fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'maintenance', child: Text('Maintenance', style: TextStyle(color: ManagerColors.orange, fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'inactive', child: Text('Inactive', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() => selectedStatus = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Surface / Floor',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: surfaceController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Synthetic Mat',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Indoor Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Indoor Facility', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(isIndoor ? 'Weatherproof indoor arena' : 'Open-air outdoor court', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      value: isIndoor,
                      onChanged: (val) => setModalState(() => isIndoor = val),
                    ),
                    const SizedBox(height: 6),

                    // Description
                    const Text(
                      'Description / Notes',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ManagerColors.navy),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Features LED lighting, umpire chair, seating...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ManagerColors.navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                if (name.isEmpty) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(content: Text('Please enter facility name')),
                                    );
                                  }
                                  return;
                                }

                                final rate = double.tryParse(rateController.text.trim()) ?? 2500.0;

                                setModalState(() => isSubmitting = true);

                                final facilityData = {
                                  'name': name,
                                  'type': selectedType,
                                  'hourlyRate': rate,
                                  'openingTime': openingTime,
                                  'closingTime': closingTime,
                                  'status': selectedStatus,
                                  'surface': surfaceController.text.trim(),
                                  'isIndoor': isIndoor,
                                  'description': descController.text.trim(),
                                };

                                try {
                                  if (isEditing) {
                                    final id = facilityToEdit['id']?.toString() ?? facilityToEdit['_id']?.toString() ?? '';
                                    await ApiService.updateFacility(id, facilityData);
                                  } else {
                                    await ApiService.createFacility(facilityData);
                                  }

                                  if (mounted) {
                                    Navigator.pop(ctx);
                                    _loadFacilities();
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? 'Facility "$name" updated successfully'
                                              : 'Facility "$name" created successfully',
                                        ),
                                        backgroundColor: ManagerColors.green,
                                      ),
                                    );
                                  }
                                } catch (err) {
                                  setModalState(() => isSubmitting = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text('$err'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isEditing ? 'Save Changes' : 'Create Facility',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteFacility(Map<String, dynamic> f) async {
    final name = f['name']?.toString() ?? 'Facility';
    final id = f['id']?.toString() ?? f['_id']?.toString() ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete $name?'),
        content: Text(
          'Are you sure you want to delete this facility? All available unbooked slots for this facility will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteFacility(id);
        if (mounted) {
          _loadFacilities();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Facility "$name" deleted.'),
              backgroundColor: ManagerColors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot delete: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  IconData _getSportIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'badminton':
        return Icons.sports_tennis_rounded;
      case 'tennis':
        return Icons.sports_tennis_outlined;
      case 'basketball':
        return Icons.sports_basketball_rounded;
      case 'futsal':
      case 'football':
        return Icons.sports_soccer_rounded;
      case 'cricket':
        return Icons.sports_cricket_rounded;
      case 'swimming pool':
        return Icons.pool_rounded;
      case 'squash':
        return Icons.sports_tennis;
      case 'table tennis':
        return Icons.sports_baseball_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ManagerColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ManagerColors.navyDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Facility Management',
              style: TextStyle(
                color: ManagerColors.navyDark,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            Text(
              'Colombo Sports Centre · Courts & Arenas',
              style: TextStyle(color: ManagerColors.secondaryText, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => _showAddEditFacilityModal(),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: ManagerColors.teal),
              label: const Text(
                'Add',
                style: TextStyle(color: ManagerColors.teal, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter & Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  // Search box
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _loadFacilities(),
                      decoration: InputDecoration(
                        hintText: 'Search facilities by name...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.blueGrey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadFacilities();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Sport Types Chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sportTypes.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final type = _sportTypes[index];
                        final isSelected = type == _selectedType;
                        return InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () {
                            setState(() => _selectedType = type);
                            _loadFacilities();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? ManagerColors.navy : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: isSelected ? ManagerColors.navy : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : ManagerColors.navyDark,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Facilities List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadFacilities,
                color: ManagerColors.navy,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _facilities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sports_soccer_outlined, size: 54, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text(
                                  'No facilities found',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ManagerColors.navyDark),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Add your first sports court or arena to get started.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ManagerColors.navy,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _showAddEditFacilityModal(),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Facility'),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                            itemCount: _facilities.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final f = _facilities[index];
                              final name = f['name']?.toString() ?? 'Facility';
                              final type = f['type']?.toString() ?? 'Sports';
                              final rate = f['hourlyRate']?.toString() ?? '2500';
                              final status = f['status']?.toString() ?? 'active';
                              final surface = f['surface']?.toString() ?? 'Synthetic';
                              final isIndoor = f['isIndoor'] == true;
                              final open = f['openingTime']?.toString() ?? '06:00 AM';
                              final close = f['closingTime']?.toString() ?? '10:00 PM';
                              final desc = f['description']?.toString() ?? '';

                              Color statusBg;
                              Color statusFg;
                              String statusLabel;
                              if (status == 'active') {
                                statusBg = ManagerColors.greenSoft;
                                statusFg = ManagerColors.green;
                                statusLabel = 'Active';
                              } else if (status == 'maintenance') {
                                statusBg = ManagerColors.orangeSoft;
                                statusFg = ManagerColors.orange;
                                statusLabel = 'Under Maintenance';
                              } else {
                                statusBg = Colors.grey.shade200;
                                statusFg = Colors.grey.shade700;
                                statusLabel = 'Inactive';
                              }

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: ManagerColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Sport Icon
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: ManagerColors.primaryBlue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            _getSportIcon(type),
                                            color: ManagerColors.navy,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Name and type
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w800,
                                                        color: ManagerColors.navyDark,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: statusBg,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      statusLabel,
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: statusFg,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '$type · $surface · ${isIndoor ? "Indoor" : "Outdoor"}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: ManagerColors.secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (desc.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        desc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],

                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(height: 1),
                                    ),

                                    // Bottom row: Rate & Hours + Edit/Delete
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'LKR $rate / slot',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: ManagerColors.navy,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.schedule_rounded, size: 12, color: Colors.blueGrey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$open – $close',
                                                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        Row(
                                          children: [
                                            // Edit Button
                                            OutlinedButton.icon(
                                              onPressed: () => _showAddEditFacilityModal(facilityToEdit: f),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                side: const BorderSide(color: ManagerColors.border),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              icon: const Icon(Icons.edit_outlined, size: 14, color: ManagerColors.navy),
                                              label: const Text('Edit', style: TextStyle(fontSize: 12, color: ManagerColors.navy, fontWeight: FontWeight.w700)),
                                            ),
                                            const SizedBox(width: 8),

                                            // Delete Button
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                              onPressed: () => _confirmDeleteFacility(f),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ManagerColors.teal,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditFacilityModal(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Facility', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
