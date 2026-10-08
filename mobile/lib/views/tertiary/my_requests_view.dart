import 'package:flutter/material.dart';

import '../../models/contact_request_model.dart';
import '../../services/app_services.dart';
import 'notifications_view.dart';

class MyRequestsView extends StatefulWidget {
  final String? initialFacilityId;
  final String? initialFacilityName;
  final String? initialRequestId;

  const MyRequestsView({
    super.key,
    this.initialFacilityId,
    this.initialFacilityName,
    this.initialRequestId,
  });

  @override
  State<MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<MyRequestsView> {
  final TextEditingController _messageController = TextEditingController();
  ContactRequestType _selectedType = ContactRequestType.generalEnquiry;
  String? _editingRequestId;
  String? _validationError;

  static const Color _navy = Color(0xFF0F2A44);
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _accent = Color(0xFF1D7A6B);
  static const Color _cardBorder = Color(0xFFE7EAF0);

  @override
  void initState() {
    super.initState();
    if (widget.initialRequestId != null) {
      final matches = appServices.contactRequestService.myRequests
          .where((r) => r.id == widget.initialRequestId);
      if (matches.isNotEmpty) {
        final req = matches.first;
        _editingRequestId = req.id;
        _selectedType = req.type;
        _messageController.text = req.message;
      }
    }
  }

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
        facilityId: widget.initialFacilityId ?? 'general',
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
      SnackBar(
        content: Text(isEdit ? 'Request saved successfully' : 'Request submitted successfully'),
        duration: const Duration(seconds: 2),
      ),
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
          'This will remove your submission permanently. This action cannot be undone.',
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
          const SnackBar(
            content: Text('Request deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Requests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              ),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardBorder),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    size: 18, color: _navy),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildSubmissionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final isEditing = _editingRequestId != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Request' : 'Contact Enquiry / Accessibility Request',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              if (isEditing)
                GestureDetector(
                  onTap: _cancelEdit,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Have a question or need something for accessibility? Send a request and the facility will follow up.',
            style: TextStyle(fontSize: 12, color: _subtext, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTypeSelector(
                  ContactRequestType.generalEnquiry,
                  'General Enquiry',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTypeSelector(
                  ContactRequestType.accessibilityRequest,
                  'Accessibility Request',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Describe your enquiry or accessibility needs...',
              hintStyle: const TextStyle(fontSize: 13, color: _subtext),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
                borderSide: const BorderSide(color: _accent, width: 1.5),
              ),
            ),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 6),
            Text(
              _validationError!,
              style: const TextStyle(fontSize: 11.5, color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Submit Request',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ContactRequestType type, String label) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
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
            color: isSelected ? Colors.white : _navy,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionsSection() {
    return ListenableBuilder(
      listenable: appServices.contactRequestService,
      builder: (context, _) {
        final requests = appServices.contactRequestService.myRequests;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Submissions (${requests.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            const SizedBox(height: 12),
            if (requests.isEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 38, color: Color(0xFF9AA4B2)),
                    SizedBox(height: 10),
                    Text(
                      'No requests yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _navy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Submissions you create through the form above will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: _subtext),
                    ),
                  ],
                ),
              )
            else
              ...requests.map((r) => _buildSubmissionCard(r)),
          ],
        );
      },
    );
  }

  Widget _buildSubmissionCard(ContactRequest request) {
    final isAccessibility =
        request.type == ContactRequestType.accessibilityRequest;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAccessibility
                      ? const Color(0xFFF2ECFC)
                      : const Color(0xFFEAF4FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAccessibility ? 'Accessibility Request' : 'General Enquiry',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAccessibility
                        ? const Color(0xFF7C4BD6)
                        : const Color(0xFF2B6CB0),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 17, color: _subtext),
                tooltip: 'Edit Request',
                onPressed: () => _startEdit(request),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 14),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 17, color: Colors.redAccent),
                tooltip: 'Delete Request',
                onPressed: () => _confirmDelete(request),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.message,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: _navy,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Submitted ${_formatDate(request.createdAt)}${request.updatedAt != null ? ' • Edited' : ''}',
            style: const TextStyle(fontSize: 11.5, color: _subtext),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
