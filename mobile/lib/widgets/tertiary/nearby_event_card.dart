// lib/widgets/tertiary/nearby_event_card.dart
//
// Reusable card for a "Nearby & Recommended" event matching the prototype design
// (Image on top, Title + Status badge row, Sport • Date • Time row, Location row).

import 'package:flutter/material.dart';
import '../../models/sport_event_model.dart';

class NearbyEventCard extends StatelessWidget {
  final NearbyEvent event;
  final VoidCallback? onTap;

  const NearbyEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  // Local color constants matching the screenshot prototype
  static const Color _cardBg = Colors.white;
  static const Color _borderColor = Color(0xFFE8ECF2);
  static const Color _titleColor = Color(0xFF0F2A44);
  static const Color _subColor = Color(0xFF8A93A3);
  static const Color _locationColor = Color(0xFF147A70);
  static const Color _dotColor = Color(0xFFC3C9D3);
  static const Color _statusBg = Color(0xFFE6F7ED);
  static const Color _statusDot = Color(0xFF2E8B57);
  static const Color _statusText = Color(0xFF1B804E);

  Widget _buildImage() {
    final isAsset = event.imageUrl.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        event.imageUrl,
        width: double.infinity,
        height: 165,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      );
    }

    return Image.network(
      event.imageUrl,
      width: double.infinity,
      height: 165,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 165,
          color: const Color(0xFFF0F3F7),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2E8B57),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 165,
      color: const Color(0xFFE7ECF3),
      child: const Center(
        child: Icon(
          Icons.sports_tennis_rounded,
          size: 40,
          color: Color(0xFFA6B2C2),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: _statusBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _statusDot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            event.status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _statusText,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0xFF2E8B57).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF2E8B57).withValues(alpha: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Title and Status Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: _titleColor,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Row 2: Sport • Date • Time
                    Row(
                      children: [
                        Text(
                          event.sport,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: _subColor,
                          ),
                        ),
                        _dot(),
                        Text(
                          event.date,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: _subColor,
                          ),
                        ),
                        _dot(),
                        Expanded(
                          child: Text(
                            event.time,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: _subColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Row 3: Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: _locationColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _locationColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          width: 3.5,
          height: 3.5,
          decoration: const BoxDecoration(
            color: _dotColor,
            shape: BoxShape.circle,
          ),
        ),
      );
}