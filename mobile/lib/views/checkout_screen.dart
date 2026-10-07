import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/time_slot.dart';
import '../utils/app_colors.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'booking_confirmation_screen.dart';
import 'booking_pending_screen.dart';
import 'conflict_resolution_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final TimeSlot slot;
  final String date;
  final List<TimeSlot> alternatives;

  const CheckoutScreen({
    super.key,
    required this.slot,
    required this.date,
    required this.alternatives,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0: Card, 1: Bank, 2: Wallet
  bool _isProcessing = false;
  String? _selectedSlipPath;
  String? _selectedSlipName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Material(
              color: AppColors.cardBackground,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.borderLight),
              ),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        titleSpacing: 16,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Booking Summary'),
              const SizedBox(height: 12),
              _buildBookingSummaryCard(),
              const SizedBox(height: 28),

              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 12),
              _buildPaymentMethodOption(
                index: 0,
                title: 'Credit / Debit Card',
                icon: Icons.check,
                showLeadingIcon: true,
              ),
              const SizedBox(height: 10),
              _buildPaymentMethodOption(
                index: 1,
                title: 'Bank Transfer',
                showLeadingIcon: false,
              ),
              const SizedBox(height: 10),
              _buildPaymentMethodOption(
                index: 2,
                title: 'Mobile Wallet',
                icon: Icons.phone_android_outlined,
                showLeadingIcon: true,
              ),
              const SizedBox(height: 28),

              if (_selectedPaymentMethod == 1) ...[
                _buildSectionTitle('Bank Transfer Details'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow('Bank Name', 'Commercial Bank'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Account No.', '1234 5678 9012'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Branch', '012'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'pdf'],
                      );
                      if (result.isNotEmpty) {
                        final file = result.first;
                        setState(() {
                          _selectedSlipPath = file.path;
                          _selectedSlipName = file.name;
                        });
                      }
                    },
                    icon: Icon(
                      _selectedSlipPath != null
                          ? Icons.check_circle
                          : Icons.upload_file,
                    ),
                    label: Text(_selectedSlipName ?? 'Upload Transfer Slip'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: _selectedSlipPath != null
                            ? AppColors.availableText
                            : AppColors.primaryTeal,
                      ),
                      foregroundColor: _selectedSlipPath != null
                          ? AppColors.availableText
                          : AppColors.primaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else if (_selectedPaymentMethod == 2) ...[
                _buildSectionTitle('Mobile Wallet Details'),
                const SizedBox(height: 12),
                _buildTextField(
                  hintText: 'Mobile Number (e.g., 07x xxx xxxx)',
                  keyboardType: TextInputType.phone,
                ),
              ],

              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppColors.available,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payments are simulated for this prototype and are secured & encrypted.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () async {
                    setState(() => _isProcessing = true);

                    // Check for hardcoded conflict demo
                    if (widget.slot.isConflictTrigger) {
                      await Future.delayed(
                        const Duration(milliseconds: 800),
                      ); // fake delay
                      if (!context.mounted) return;
                      setState(() => _isProcessing = false);

                      // Push Conflict Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConflictResolutionScreen(
                            bookedSlot: widget.slot,
                            courtName: 'Badminton Court 1',
                            alternatives: widget.alternatives,
                            date: widget.date,
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      String? paymentIntentId;
                      String paymentMethod = 'card';

                      if (_selectedPaymentMethod == 0) {
                        if (kIsWeb) {
                          if (!context.mounted) return;
                          setState(() => _isProcessing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Card payments are available in the mobile app.',
                              ),
                            ),
                          );
                          return;
                        }

                        paymentMethod = 'card';
                        final intentData = await ApiService.createPaymentIntent(
                          widget.slot.price * 100,
                          'lkr',
                        );
                        if (intentData == null) {
                          throw Exception('Failed to initialize payment.');
                        }

                        final clientSecret = intentData['clientSecret'];
                        paymentIntentId = intentData['paymentIntentId'];

                        await Stripe.instance.initPaymentSheet(
                          paymentSheetParameters: SetupPaymentSheetParameters(
                            paymentIntentClientSecret: clientSecret,
                            merchantDisplayName: 'SportSpace',
                          ),
                        );

                        await Stripe.instance.presentPaymentSheet();
                      } else if (_selectedPaymentMethod == 1) {
                        paymentMethod = 'bank';
                        if (_selectedSlipPath == null) {
                          throw Exception(
                            'Please upload a bank transfer slip first.',
                          );
                        }
                      } else if (_selectedPaymentMethod == 2) {
                        paymentMethod = 'wallet';
                      }

                      await ApiService.bookSlot(
                        widget.slot.id,
                        paymentIntentId: paymentIntentId,
                        paymentMethod: paymentMethod,
                        slipFilePath: _selectedSlipPath,
                      );
                      if (!context.mounted) return;
                      setState(() => _isProcessing = false);

                      if (_selectedPaymentMethod == 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingPendingScreen(
                              slot: widget.slot,
                              date: widget.date,
                            ),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmationScreen(
                              slot: widget.slot,
                              date: widget.date,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isProcessing = false);

                      if (e.toString().contains('conflict')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConflictResolutionScreen(
                              bookedSlot: widget.slot,
                              courtName: 'Badminton Court 1',
                              alternatives: widget.alternatives,
                              date: widget.date,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment failed: $e'),
                            backgroundColor: AppColors.bookedText,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Proceed to Pay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.darkNavy,
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    final priceText =
        'LKR ${widget.slot.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Colombo Sports Centre',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Badminton Court 1',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Date', widget.date),
          const SizedBox(height: 6),
          _buildSummaryRow('Time', widget.slot.durationRange),
          const SizedBox(height: 6),
          _buildSummaryRow('Price', priceText),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required int index,
    required String title,
    IconData? icon,
    required bool showLeadingIcon,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.badgeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (showLeadingIcon && icon != null) ...[
              Icon(icon, size: 18, color: AppColors.darkNavy),
              const SizedBox(width: 12),
            ] else if (showLeadingIcon) ...[
              const SizedBox(width: 30), // placeholder if needed
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.darkNavy
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.darkNavy : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.darkNavy
                      : AppColors.borderLight,
                  width: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    bool isCenter = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkNavy, width: 1.5),
        ),
      ),
    );
  }
}
