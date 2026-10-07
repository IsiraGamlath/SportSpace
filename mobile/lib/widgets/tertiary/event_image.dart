

import 'package:flutter/material.dart';

class EventImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final BoxFit fit;

  const EventImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.fit = BoxFit.cover,
  });

  static const Color _placeholderBg = Color(0xFFE5E8EC);
  static const Color _placeholderIcon = Color(0xFFAEB5BF);

  bool get _isAsset => imageUrl.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (_isAsset) {
      return Image.asset(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
      );
    }

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          color: _placeholderBg,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: height,
      color: _placeholderBg,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 36, color: _placeholderIcon),
      ),
    );
  }
}