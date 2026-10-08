import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../../services/api_service.dart';
import '../../theme/manager_colors.dart';

class ManagerFacilitiesScreen extends StatefulWidget {
  const ManagerFacilitiesScreen({super.key});

  @override
  State<ManagerFacilitiesScreen> createState() =>
      _ManagerFacilitiesScreenState();
}

class _ManagerFacilitiesScreenState extends State<ManagerFacilitiesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _facilities = [];
  String _selectedSportFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _allSportsOptions = [
    'Badminton',
    'Tennis',
    'Basketball',
    'Futsal',
    'Squash',
    'Swimming Pool',
    'Cricket',
    'Table Tennis',
    'Volleyball',
  ];

  static const List<String> _amenitiesOptions = [
    'Parking',
    'Changing Rooms',
    'Showers',
    'Lockers',
    'Floodlights',
    'WiFi',
    'Cafeteria',
    'Equipment Rental',
    'First Aid',
    'Spectator Seating',
  ];

  static const List<String> _accessibilityOptions = [
    'Wheelchair Accessible',
    'Ground Floor Access',
    'Elevator',
    'Accessible Restroom',
    'Ramp Access',
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
      final list = await ApiService.fetchManagerFacilities(
        type: _selectedSportFilter == 'All' ? null : _selectedSportFilter,
        search: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading facilities: $e')));
      }
    }
  }

  void _showAddEditFacilityModal({Map<String, dynamic>? facilityToEdit}) {
    final isEditing = facilityToEdit != null;

    final nameController = TextEditingController(
      text: isEditing ? (facilityToEdit['name']?.toString() ?? '') : '',
    );
    final locationController = TextEditingController(
      text: isEditing
          ? (facilityToEdit['location']?.toString() ??
                'Colombo 07, Reid Avenue')
          : 'Colombo 07, Reid Avenue',
    );
    final descController = TextEditingController(
      text: isEditing ? (facilityToEdit['description']?.toString() ?? '') : '',
    );
    final contactController = TextEditingController(
      text: isEditing
          ? (facilityToEdit['contactNumber']?.toString() ?? '+94 11 269 1111')
          : '+94 11 269 1111',
    );
    final rateController = TextEditingController(
      text: isEditing
          ? (facilityToEdit['hourlyRate']?.toString() ?? '2500')
          : '2500',
    );
    final photoUrlController = TextEditingController(
      text: isEditing ? (facilityToEdit['photoUrl']?.toString() ?? '') : '',
    );
    final photoUrls = <String>[];
    if (isEditing && facilityToEdit['photos'] is List) {
      photoUrls.addAll(
        (facilityToEdit['photos'] as List)
            .map((photo) => photo.toString().trim())
            .where((photo) => photo.isNotEmpty)
            .take(5),
      );
    }
    if (photoUrls.isEmpty && photoUrlController.text.trim().isNotEmpty) {
      photoUrls.add(photoUrlController.text.trim());
    }

    String openTime = isEditing
        ? (facilityToEdit['openTime']?.toString() ?? '06:00 AM – 10:00 PM')
        : '06:00 AM – 10:00 PM';
    String openingTime = isEditing
        ? (facilityToEdit['openingTime']?.toString() ?? '06:00 AM')
        : '06:00 AM';
    String closingTime = isEditing
        ? (facilityToEdit['closingTime']?.toString() ?? '10:00 PM')
        : '10:00 PM';

    String selectedStatus = isEditing
        ? (facilityToEdit['status']?.toString() ?? 'active')
        : 'active';

    // Sports list
    List<String> selectedSports = [];
    if (isEditing && facilityToEdit['availableSports'] is List) {
      selectedSports = (facilityToEdit['availableSports'] as List)
          .map((e) => e.toString())
          .toList();
    }
    if (selectedSports.isEmpty) {
      final initialType = isEditing
          ? (facilityToEdit['type']?.toString() ?? 'Badminton')
          : 'Badminton';
      selectedSports = [initialType];
    }

    // Amenities list
    List<String> selectedAmenities = [];
    if (isEditing && facilityToEdit['amenities'] is List) {
      selectedAmenities = (facilityToEdit['amenities'] as List)
          .map((e) => e.toString())
          .toList();
    }
    if (selectedAmenities.isEmpty) {
      selectedAmenities = ['Parking', 'Changing Rooms', 'Showers'];
    }

    // Accessibility list
    List<String> selectedAccessibility = [];
    if (isEditing && facilityToEdit['accessibility'] is List) {
      selectedAccessibility = (facilityToEdit['accessibility'] as List)
          .map((e) => e.toString())
          .toList();
    }
    if (selectedAccessibility.isEmpty) {
      selectedAccessibility = ['Wheelchair Accessible'];
    }

    // Multi-photo list (up to 3 photos)
    List<String> uploadedPhotos = [];
    if (isEditing && facilityToEdit['photos'] is List) {
      uploadedPhotos = (facilityToEdit['photos'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (uploadedPhotos.isEmpty && photoUrlController.text.trim().isNotEmpty) {
      uploadedPhotos.add(photoUrlController.text.trim());
    }

    bool isUploadingPhoto = false;
    bool isSubmitting = false;
    Uint8List? pickedPhotoBytes;

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
            final hasPhoto = pickedPhotoBytes != null || photoUrls.isNotEmpty;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                            isEditing ? 'Edit Facility' : 'Create New Facility',
                            style: const TextStyle(
                              fontSize: 19,
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
                      const SizedBox(height: 12),

                      // 1. PHOTO UPLOAD SECTION
                      const Text(
                        'Facility Photos (up to 5)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ManagerColors.border,
                            width: 1.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (pickedPhotoBytes != null)
                                Image.memory(
                                  pickedPhotoBytes!,
                                  fit: BoxFit.cover,
                                )
                              else if (photoUrls.isNotEmpty)
                                Image.network(
                                  photoUrls.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image_rounded,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                              else
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: ManagerColors.teal.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 28,
                                          color: ManagerColors.teal,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Upload Facility Photo',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: ManagerColors.navy,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Works on Chrome & Mobile (JPG, PNG, WebP)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (isUploadingPhoto)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Uploading to Cloud...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Pick / Change Button Overlay
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasPhoto
                                        ? Colors.black87
                                        : ManagerColors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: isUploadingPhoto
                                      ? null
                                      : () async {
                                          try {
                                            if (photoUrls.length >= 5) {
                                              ScaffoldMessenger.of(
                                                ctx,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'A facility can have up to 5 photos',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final result = await FilePicker
                                                .platform
                                                .pickFiles(
                                                  type: FileType.image,
                                                  withData: true,
                                                );
                                            final file = result?.files.single;
                                            if (file != null) {
                                              final bytes = file.bytes;
                                              if (bytes == null) return;
                                              setModalState(() {
                                                pickedPhotoBytes = bytes;
                                                isUploadingPhoto = true;
                                              });

                                              // Upload to Cloudinary backend
                                              final cloudUrl =
                                                  await ApiService.uploadFacilityPhoto(
                                                    fileBytes: bytes,
                                                    fileName: file.name,
                                                  );

                                              if (cloudUrl != null &&
                                                  cloudUrl.isNotEmpty) {
                                                setModalState(() {
                                                  photoUrls.add(cloudUrl);
                                                  photoUrlController.text =
                                                      photoUrls.first;
                                                  isUploadingPhoto = false;
                                                });
                                              } else {
                                                setModalState(
                                                  () =>
                                                      isUploadingPhoto = false,
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            setModalState(
                                              () => isUploadingPhoto = false,
                                            );
                                            if (ctx.mounted) {
                                              ScaffoldMessenger.of(
                                                ctx,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Photo upload failed: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  icon: Icon(
                                    hasPhoto ? Icons.edit : Icons.upload_file,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Add Photo (${photoUrls.length}/5)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. FACILITY NAME
                      const Text(
                        'Facility Name *',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Badminton Court 1 / Tennis Arena',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. FACILITY LOCATION
                      const Text(
                        'Facility Location *',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Colombo 07, Reid Avenue (Arena B)',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: ManagerColors.teal,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. AVAILABLE SPORTS
                      const Text(
                        'Available Sports * (Select all that apply)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allSportsOptions.map((sport) {
                          final isSelected = selectedSports.contains(sport);
                          return FilterChip(
                            label: Text(sport),
                            selected: isSelected,
                            selectedColor: ManagerColors.navy,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : ManagerColors.navyDark,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? ManagerColors.navy
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedSports.add(sport);
                                } else {
                                  if (selectedSports.length > 1) {
                                    selectedSports.remove(sport);
                                  }
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 5. OPEN TIME & OPERATING HOURS
                      const Text(
                        'Operating Hours (Open Time) *',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: const TimeOfDay(
                                    hour: 6,
                                    minute: 0,
                                  ),
                                );
                                if (time != null) {
                                  final hour = time.hourOfPeriod == 0
                                      ? 12
                                      : time.hourOfPeriod;
                                  final min = time.minute.toString().padLeft(
                                    2,
                                    '0',
                                  );
                                  final p = time.period == DayPeriod.am
                                      ? 'AM'
                                      : 'PM';
                                  setModalState(() {
                                    openingTime = '$hour:$min $p';
                                    openTime = '$openingTime – $closingTime';
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'From: $openingTime',
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: ManagerColors.navy,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: const TimeOfDay(
                                    hour: 22,
                                    minute: 0,
                                  ),
                                );
                                if (time != null) {
                                  final hour = time.hourOfPeriod == 0
                                      ? 12
                                      : time.hourOfPeriod;
                                  final min = time.minute.toString().padLeft(
                                    2,
                                    '0',
                                  );
                                  final p = time.period == DayPeriod.am
                                      ? 'AM'
                                      : 'PM';
                                  setModalState(() {
                                    closingTime = '$hour:$min $p';
                                    openTime = '$openingTime – $closingTime';
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'To: $closingTime',
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: ManagerColors.navy,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 6. HOURLY RATE & CONTACT NUMBER
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hourly Rate (LKR) *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: ManagerColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: rateController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '2500',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                  'Contact Number *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: ManagerColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: contactController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: '+94 11 269 1111',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 7. ADDITIONAL AMENITIES
                      const Text(
                        'Additional Amenities',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenitiesOptions.map((item) {
                          final isSelected = selectedAmenities.contains(item);
                          return FilterChip(
                            label: Text(item),
                            selected: isSelected,
                            selectedColor: ManagerColors.teal,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : ManagerColors.navyDark,
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? ManagerColors.teal
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedAmenities.add(item);
                                } else {
                                  selectedAmenities.remove(item);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 8. OPTIONAL ACCESSIBILITY
                      const Text(
                        'Optional Accessibility Features',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _accessibilityOptions.map((item) {
                          final isSelected = selectedAccessibility.contains(
                            item,
                          );
                          return FilterChip(
                            label: Text(item),
                            selected: isSelected,
                            selectedColor: const Color(0xFF6366F1), // Indigo
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : ManagerColors.navyDark,
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedAccessibility.add(item);
                                } else {
                                  selectedAccessibility.remove(item);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 9. DESCRIPTION
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Standard indoor arena, tournament lighting, wooden floor...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 10. STATUS
                      const Text(
                        'Facility Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ManagerColors.navy,
                        ),
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
                              DropdownMenuItem(
                                value: 'active',
                                child: Text(
                                  'Active (Open for Booking)',
                                  style: TextStyle(
                                    color: ManagerColors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'maintenance',
                                child: Text(
                                  'Under Maintenance',
                                  style: TextStyle(
                                    color: ManagerColors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text(
                                  'Inactive (Closed)',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedStatus = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ManagerColors.navy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter a facility name',
                                          ),
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  final rate =
                                      double.tryParse(
                                        rateController.text.trim(),
                                      ) ??
                                      2500.0;
                                  setModalState(() => isSubmitting = true);

                                  final finalPhotos = photoUrls
                                      .take(5)
                                      .toList();
                                  final finalPhoto = finalPhotos.isNotEmpty
                                      ? finalPhotos.first
                                      : photoUrlController.text.trim();

                                  final facilityData = {
                                    'name': name,
                                    'location': locationController.text.trim(),
                                    'description': descController.text.trim(),
                                    'openTime': openTime,
                                    'openingTime': openingTime,
                                    'closingTime': closingTime,
                                    'availableSports': selectedSports,
                                    'amenities': selectedAmenities,
                                    'accessibility': selectedAccessibility,
                                    'contactNumber': contactController.text
                                        .trim(),
                                    'photoUrl': finalPhoto,
                                    'photos': finalPhotos.isNotEmpty
                                        ? finalPhotos
                                        : (finalPhoto.isNotEmpty
                                              ? [finalPhoto]
                                              : []),
                                    'hourlyRate': rate,
                                    'type': selectedSports.isNotEmpty
                                        ? selectedSports.first
                                        : 'Badminton',
                                    'status': selectedStatus,
                                  };

                                  try {
                                    if (isEditing) {
                                      final id =
                                          facilityToEdit['id']?.toString() ??
                                          facilityToEdit['_id']?.toString() ??
                                          '';
                                      await ApiService.updateFacility(
                                        id,
                                        facilityData,
                                      );
                                    } else {
                                      await ApiService.createFacility(
                                        facilityData,
                                      );
                                    }

                                    if (!mounted) return;
                                    Navigator.of(ctx).pop();
                                    _loadFacilities();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? 'Facility "$name" updated successfully'
                                              : 'Facility "$name" created successfully',
                                        ),
                                        backgroundColor: ManagerColors.green,
                                      ),
                                    );
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
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEditing
                                      ? 'Save Changes'
                                      : 'Create Facility',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ManagerColors.navyDark,
            size: 20,
          ),
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
              'Colombo Sports Centre · Courts, Photos & Amenities',
              style: TextStyle(
                color: ManagerColors.secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => _showAddEditFacilityModal(),
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: ManagerColors.teal,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: ManagerColors.teal,
                  fontWeight: FontWeight.w800,
                ),
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
                        hintText: 'Search facilities by name or location...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.blueGrey,
                        ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Sport Types Chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _allSportsOptions.length + 1,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final type = index == 0
                            ? 'All'
                            : _allSportsOptions[index - 1];
                        final isSelected = type == _selectedSportFilter;
                        return InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () {
                            setState(() => _selectedSportFilter = type);
                            _loadFacilities();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ManagerColors.navy
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: isSelected
                                    ? ManagerColors.navy
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : ManagerColors.navyDark,
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
                            const Icon(
                              Icons.sports_soccer_outlined,
                              size: 54,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No facilities found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ManagerColors.navyDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Add your first sports court or arena with photos & details.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ManagerColors.navy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final f = _facilities[index];
                          final name = f['name']?.toString() ?? 'Facility';
                          final location =
                              f['location']?.toString() ??
                              'Colombo 07, Reid Avenue';
                          final openTimeStr =
                              f['openTime']?.toString() ??
                              '06:00 AM – 10:00 PM';
                          final contact =
                              f['contactNumber']?.toString() ??
                              '+94 11 269 1111';
                          final rate = f['hourlyRate']?.toString() ?? '2500';
                          final status = f['status']?.toString() ?? 'active';
                          final desc = f['description']?.toString() ?? '';
                          final photoUrl = f['photoUrl']?.toString() ?? '';
                          final List<String> photosList =
                              (f['photos'] is List &&
                                  (f['photos'] as List).isNotEmpty)
                              ? (f['photos'] as List)
                                    .map((e) => e.toString().trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList()
                              : (photoUrl.isNotEmpty ? [photoUrl] : <String>[]);

                          // Sports list
                          final sportsList = (f['availableSports'] is List)
                              ? (f['availableSports'] as List)
                                    .map((e) => e.toString())
                                    .toList()
                              : [f['type']?.toString() ?? 'Badminton'];

                          // Amenities list
                          final amenitiesList = (f['amenities'] is List)
                              ? (f['amenities'] as List)
                                    .map((e) => e.toString())
                                    .toList()
                              : <String>[];

                          // Accessibility list
                          final accessibilityList = (f['accessibility'] is List)
                              ? (f['accessibility'] as List)
                                    .map((e) => e.toString())
                                    .toList()
                              : <String>[];

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
                            statusLabel = 'Maintenance';
                          } else {
                            statusBg = Colors.grey.shade200;
                            statusFg = Colors.grey.shade700;
                            statusLabel = 'Inactive';
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: ManagerColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // PHOTO HERO / BANNER
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: SizedBox(
                                    height: 155,
                                    width: double.infinity,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _FacilityPhotoCarousel(
                                          photos: photosList,
                                          fallbackIcon: _getSportIcon(
                                            sportsList.isNotEmpty
                                                ? sportsList.first
                                                : 'sports',
                                          ),
                                        ),

                                        // Top Gradient Overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withValues(
                                                  alpha: 0.35,
                                                ),
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.55,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Status Badge Top Right
                                        Positioned(
                                          top: 10,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: statusFg,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Rate Badge Bottom Left
                                        Positioned(
                                          bottom: 10,
                                          left: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.75,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'LKR $rate / slot',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // CARD CONTENT
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title & Edit / Delete
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w800,
                                                color: ManagerColors.navyDark,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 20,
                                                  color: ManagerColors.navy,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () =>
                                                    _showAddEditFacilityModal(
                                                      facilityToEdit: f,
                                                    ),
                                              ),
                                              const SizedBox(width: 14),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 20,
                                                  color: Colors.redAccent,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () =>
                                                    _confirmDeleteFacility(f),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Location
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 15,
                                            color: ManagerColors.teal,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              location,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color:
                                                    ManagerColors.secondaryText,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Open Time & Contact
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            openTimeStr,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.phone_outlined,
                                            size: 14,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            contact,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Description
                                      if (desc.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          desc,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 10),

                                      // Available Sports Badges
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: sportsList.map((sport) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ManagerColors.primaryBlue
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getSportIcon(sport),
                                                  size: 12,
                                                  color: ManagerColors.navy,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  sport,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: ManagerColors.navy,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),

                                      // Amenities Badges
                                      if (amenitiesList.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: amenitiesList.map((
                                            amenity,
                                          ) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2.5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '✓ $amenity',
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  color: Colors.blueGrey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],

                                      // Accessibility Badges
                                      if (accessibilityList.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: accessibilityList.map((
                                            item,
                                          ) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2.5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFEEF2FF,
                                                ), // Indigo soft
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.accessible_rounded,
                                                    size: 12,
                                                    color: Color(0xFF4F46E5),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 10.5,
                                                      color: Color(0xFF4F46E5),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
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
        label: const Text(
          'Add Facility',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FacilityPhotoCarousel extends StatefulWidget {
  final List<String> photos;
  final IconData fallbackIcon;

  const _FacilityPhotoCarousel({
    required this.photos,
    required this.fallbackIcon,
  });

  @override
  State<_FacilityPhotoCarousel> createState() => _FacilityPhotoCarouselState();
}

class _FacilityPhotoCarouselState extends State<_FacilityPhotoCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Container(
        color: const Color(0xFFE2E8F0),
        child: Icon(widget.fallbackIcon, size: 48, color: ManagerColors.navy),
      );
    }

    if (widget.photos.length == 1) {
      return Image.network(
        widget.photos.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFE2E8F0),
          child: Icon(widget.fallbackIcon, size: 48, color: ManagerColors.navy),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.photos.length,
          onPageChanged: (idx) => setState(() => _currentPage = idx),
          itemBuilder: (context, idx) {
            return Image.network(
              widget.photos[idx],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE2E8F0),
                child: Icon(
                  widget.fallbackIcon,
                  size: 48,
                  color: ManagerColors.navy,
                ),
              ),
            );
          },
        ),
        // Dots / Counter Badge at bottom-left
        Positioned(
          bottom: 10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_library_rounded,
                  size: 11,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currentPage + 1}/${widget.photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
