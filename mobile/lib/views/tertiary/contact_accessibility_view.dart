
import 'package:flutter/material.dart';

import '../../models/contact_request_model.dart';
import '../../services/app_services.dart';
import 'notifications_view.dart';

class ContactAccessibilityView extends StatefulWidget {
  final String facilityId;
  final String facilityName;
  final String phone;
  final String email;
  final String address;
  final String openingHours;

  const ContactAccessibilityView({
    super.key,
    required this.facilityId,
    required this.facilityName,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.openingHours = '',
  });

  @override
  State<ContactAccessibilityView> createState() =>
      _ContactAccessibilityViewState();
}

class _ContactAccessibilityViewState extends State<ContactAccessibilityView> {
  final TextEditingController _messageController = TextEditingController();
  ContactRequestType _selectedType = ContactRequestType.generalEnquiry;
  String? _editingRequestId;
  String? _validationError;

  // Local constants — replace with your app theme if available.
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _accent = Color(0xFF1D7A6B);
  static const Color _cardBorder = Color(0xFFE7EAF0);
  static const Color _infoBg = Color(0xFFEAF4FB);
  static const Color _infoText = Color(0xFF2B6CB0);
  static const Color _pillBg = Color(0xFFEAF4FB);

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() {
        _validationError =
            'Please describe your enquiry or accessibility needs.';
      });
      return;
    }

    final isEdit = _editingRequestId != null;

    if (isEdit) {
      appServices.contactRequestService.update(
        _editingRequestId!,
        type: _selectedType,
        message: message,
      );
    } else {
      appServices.contactRequestService.create(
        facilityId:
            widget.facilityId.isNotEmpty ? widget.facilityId : 'general',
        type: _selectedType,
        message: message,
      );
    }

    setState(() {
      _editingRequestId = null;
      _messageController.clear();
      _selectedType = ContactRequestType.generalEnquiry;
      _validationError = null;
    });
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEdit ? 'Request updated' : 'Request submitted')),
    );
  }

  void _startEdit(ContactRequest request) {
    setState(() {
      _editingRequestId = request.id;
      _selectedType = request.type;
      _messageController.text = request.message;
      _validationError = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingRequestId = null;
      _messageController.clear();
      _selectedType = ContactRequestType.generalEnquiry;
      _validationError = null;
    });
  }

  Future<void> _confirmDelete(ContactRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete request?'),
        content: const Text(
          'This will remove your submission. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      appServices.contactRequestService.delete(request.id);
      if (_editingRequestId == request.id) _cancelEdit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _heading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Contact & Accessibility',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: _heading),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              ),
              borderRadius: BorderRadius.circular(17),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardBorder),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    size: 16, color: _heading),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.facilityName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _heading,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.call_outlined,
                label: 'Phone',
                value: widget.phone,
                actionLabel: 'Call',
              ),
              const SizedBox(height: 10),
              _buildContactCard(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: widget.email,
                actionLabel: 'Email',
              ),
              const SizedBox(height: 10),
              _buildContactCard(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: widget.address,
                actionLabel: 'Directions',
              ),
              const SizedBox(height: 10),
              _buildContactCard(
                icon: Icons.access_time_rounded,
                label: 'Opening hours',
                value: widget.openingHours,
                actionLabel: null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Accessibility',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: _heading),
              ),
              const SizedBox(height: 10),
              _buildAccessibilityRow(
                  Icons.meeting_room_outlined, 'Accessible entrance'),
              _buildAccessibilityRow(
                  Icons.local_parking_outlined, 'Accessible parking'),
              _buildAccessibilityRow(Icons.wc_rounded, 'Accessible toilets'),
              _buildAccessibilityRow(Icons.accessible_rounded,
                  'Wheelchair-friendly areas throughout'),
              _buildAccessibilityRow(
                  Icons.checkroom_outlined, 'Accessible changing facilities'),
              const SizedBox(height: 20),
              _buildInfoBox(),
              const SizedBox(height: 28),
              _buildRequestFormSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Visual only — "Call"/"Email"/"Directions" are no-op per scope.
  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    String? actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11.5, color: _subtext)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _heading),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: _pillBg,
                foregroundColor: _accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccessibilityRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: _heading)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: _infoBg, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: _infoText),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please contact the facility before visiting if you require '
              'additional accessibility assistance.',
              style: TextStyle(fontSize: 12.5, color: _infoText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// The one fully functional part of this screen: Create/Update/Delete
  /// of the current user's own contact/accessibility requests.
  Widget _buildRequestFormSection() {
    final isEditing = _editingRequestId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditing
              ? 'Edit Your Request'
              : 'Contact Enquiry / Accessibility Request',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: _heading),
        ),
        const SizedBox(height: 4),
        const Text(
          'Have a question or need something for accessibility? Send a '
          'request and the facility will follow up.',
          style: TextStyle(fontSize: 12, color: _subtext, height: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeChip(
                  ContactRequestType.generalEnquiry, 'General Enquiry'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTypeChip(ContactRequestType.accessibilityRequest,
                  'Accessibility Request'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          maxLines: 4,
          onChanged: (val) {
            if (_validationError != null) {
              setState(() => _validationError = null);
            }
          },
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Describe your enquiry or accessibility needs...',
            errorText: _validationError,
            hintStyle: const TextStyle(fontSize: 13, color: _subtext),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Submit Request',
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: _cancelEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _heading,
                    side: const BorderSide(color: _cardBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Your Submissions',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: _heading),
        ),
        const SizedBox(height: 10),
        _buildSubmissionsList(),
      ],
    );
  }

  Widget _buildTypeChip(ContactRequestType type, String label) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _accent : _cardBorder),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _heading,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionsList() {
    return ListenableBuilder(
      listenable: appServices.contactRequestService,
      builder: (context, _) {
        final requests = appServices.contactRequestService.myRequests
            .where((r) =>
                widget.facilityId.isEmpty ||
                widget.facilityId == 'general' ||
                r.facilityId == widget.facilityId)
            .toList();

        if (requests.isEmpty) {
          return const Text(
            'No requests yet — submissions you create will appear here.',
            style: TextStyle(fontSize: 12.5, color: _subtext),
          );
        }

        return Column(
          children:
              requests.map((request) => _buildSubmissionCard(request)).toList(),
        );
      },
    );
  }

  Widget _buildSubmissionCard(ContactRequest request) {
    final isAccessibility =
        request.type == ContactRequestType.accessibilityRequest;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isAccessibility
                      ? const Color(0xFFF2ECFC)
                      : const Color(0xFFEAF4FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAccessibility ? 'Accessibility Request' : 'General Enquiry',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isAccessibility
                        ? const Color(0xFF7C4BD6)
                        : const Color(0xFF2B6CB0),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16, color: _subtext),
                onPressed: () => _startEdit(request),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Colors.redAccent),
                onPressed: () => _confirmDelete(request),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.message,
            style: const TextStyle(fontSize: 13, color: _heading, height: 1.4),
          ),
          const SizedBox(height: 6),
          Text(
            request.updatedAt != null
                ? 'Updated ${_formatDate(request.updatedAt!)}'
                : 'Submitted ${_formatDate(request.createdAt)}',
            style: const TextStyle(fontSize: 11, color: _subtext),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}