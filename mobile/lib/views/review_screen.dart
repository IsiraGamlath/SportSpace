import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/review.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.facilityName});

  final String facilityName;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  static const _star = Color(0xFFF4A340);

  int _selectedFilter = 0;
  int? _starFilter; // tap a rating bar to filter by that star count
  late Future<Map<String, dynamic>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ApiService.fetchReviews(widget.facilityName);
  }

  Future<void> _reload() async {
    final future = ApiService.fetchReviews(widget.facilityName);
    setState(() => _reviewsFuture = future);
    try {
      await future;
    } catch (_) {
      // The FutureBuilder shows the error state.
    }
  }

  List<Review> _filteredReviews(List<Review> reviews) {
    var filtered = [...reviews];

    if (_selectedFilter == 1) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      filtered = filtered.where((r) => r.userId == uid).toList();
    }
    if (_starFilter != null) {
      filtered = filtered.where((r) => r.rating == _starFilter).toList();
    }

    if (_selectedFilter == 2) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      filtered.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.facilityName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.scaffoldBackground,
        foregroundColor: AppColors.darkNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // Small, always-visible action instead of a full-width button
      // at the bottom of a long list.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text(
          'Write review',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _errorState(snapshot.error);
          }

          final data = snapshot.data ?? {};
          final reviews = (data['reviews'] as List<Review>? ?? []);
          final average = (data['averageRating'] as double?) ?? 0;
          final count = (data['reviewCount'] as int?) ?? reviews.length;
          final visibleReviews = _filteredReviews(reviews);

          return RefreshIndicator(
            onRefresh: _reload,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildSummary(average, count, reviews),
                  ),
                ),
                // Filters stay pinned while the review list scrolls.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedBarDelegate(child: _buildFilters()),
                ),
                if (visibleReviews.isEmpty)
                  SliverToBoxAdapter(child: _emptyState(reviews.isEmpty))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildReviewCard(visibleReviews[index]),
                        childCount: visibleReviews.length,
                      ),
                    ),
                  ),
                // Space so the floating button never covers the last review.
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _errorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 36,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load reviews.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _reload, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(double average, int count, List<Review> reviews) {
    final distribution = List<int>.filled(5, 0);
    for (final review in reviews) {
      if (review.rating >= 1 && review.rating <= 5) {
        distribution[5 - review.rating]++;
      }
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Column(
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  _starText(average.round()),
                  style: const TextStyle(color: _star, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'review' : 'reviews'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: List.generate(
                5,
                (index) => _ratingBar(5 - index, distribution[index], count),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBar(int rating, int amount, int total) {
    final selected = _starFilter == rating;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => setState(() => _starFilter = selected ? null : rating),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 12,
              child: Text(
                '$rating',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
            const Icon(Icons.star, size: 12, color: _star),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: selected ? 8 : 6,
                  value: total == 0 ? 0 : amount / total,
                  backgroundColor: const Color(0xFFE9EEF0),
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.primaryTeal,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 26,
              child: Text(
                '$amount',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const labels = ['Most Recent', 'My Reviews', 'Highest Rated'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = _selectedFilter == index;
          return Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(labels[index]),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedFilter = index),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.darkNavy,
              ),
              selectedColor: AppColors.darkNavy,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.borderLight),
              visualDensity: VisualDensity.compact,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final isOwner = review.userId == FirebaseAuth.instance.currentUser?.uid;
    final initials = review.userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7ECEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.darkNavy,
            child: Text(
              initials.isEmpty ? 'P' : initials,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ),
                    Text(
                      _relativeDate(review.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (action) {
                          if (action == 'edit') {
                            _openEditor(review);
                          } else {
                            _deleteReview(review);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _starText(review.rating),
                  style: const TextStyle(fontSize: 13, color: _star),
                ),
                const SizedBox(height: 4),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _starText(int rating) {
    final r = rating.clamp(0, 5);
    return '${'★' * r}${'☆' * (5 - r)}';
  }

  String _relativeDate(DateTime? date) {
    if (date == null) return 'Recently';
    final days = DateTime.now().difference(date).inDays;
    if (days < 1) return 'Today';
    if (days < 7) return '$days ${days == 1 ? 'day' : 'days'} ago';
    final weeks = days ~/ 7;
    if (weeks < 5) return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    final months = days ~/ 30;
    if (months < 12) return '$months ${months == 1 ? 'month' : 'months'} ago';
    final years = days ~/ 365;
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  Widget _emptyState(bool noReviewsAtAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 36,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            noReviewsAtAll
                ? 'Be the first to review this facility.'
                : 'No reviews match this filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (_starFilter != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _starFilter = null),
              child: const Text('Clear star filter'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openComposer() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ReviewComposer(facilityName: widget.facilityName),
    );
    if (result == true && mounted) _reload();
  }

  Future<void> _openEditor(Review review) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          _ReviewComposer(facilityName: widget.facilityName, review: review),
    );
    if (result == true && mounted) _reload();
  }

  Future<void> _deleteReview(Review review) async {
    try {
      await ApiService.deleteReview(review.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review deleted.')));
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete review: $error')),
      );
    }
  }
}

/// Keeps the filter chips visible at the top while the list scrolls.
class _PinnedBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.scaffoldBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedBarDelegate oldDelegate) => true;
}

class _ReviewComposer extends StatefulWidget {
  const _ReviewComposer({required this.facilityName, this.review});

  final String facilityName;
  final Review? review;

  @override
  State<_ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends State<_ReviewComposer> {
  late int _rating;
  bool _submitting = false;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.rating ?? 0;
    _commentController = TextEditingController(text: widget.review?.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
      );
      return;
    }
    if (comment.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write at least 3 characters.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      if (widget.review == null) {
        await ApiService.submitReview(
          facilityName: widget.facilityName,
          rating: _rating,
          comment: comment,
        );
      } else {
        await ApiService.updateReview(
          reviewId: widget.review!.id,
          rating: _rating,
          comment: comment,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save review: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write a review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Row(
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFF4A340),
                  size: 30,
                ),
              ),
            ),
          ),
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Share your experience',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.review == null ? 'Submit review' : 'Update review',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
