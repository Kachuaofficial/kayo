import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firestore_search_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory; // null = all

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Find trusted services and skilled workers near you.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Search Bar with Real-Time Filtering
                    _buildSearchBar(colorScheme),

                    const SizedBox(height: 20),

                    // Emergency CTA (show only when not actively searching)
                    if (_searchQuery.isEmpty && _selectedCategory == null) ...[
                      const _EmergencyCard(),
                      const SizedBox(height: 24),
                    ],

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Matching Services'
                              : 'Browse Services',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty || _selectedCategory != null)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _selectedCategory = null);
                            },
                            child: const Text('Reset filters'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Services Grid (Streamed from Firestore with real-time search filter)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Unable to load services')),
                      ),
                    );
                  }

                  final allDocs = snapshot.data?.docs ?? [];

                  // Apply client-side search query & category filter
                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data();
                    final name = (data['name']?.toString() ?? '').toLowerCase();
                    final desc = (data['description']?.toString() ?? '').toLowerCase();
                    final cat = (data['category']?.toString() ?? '').toLowerCase();

                    if (_selectedCategory != null &&
                        cat != _selectedCategory!.toLowerCase()) {
                      return false;
                    }

                    if (_searchQuery.isNotEmpty) {
                      return name.contains(_searchQuery) ||
                          desc.contains(_searchQuery) ||
                          cat.contains(_searchQuery);
                    }

                    return true;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'No services match "$_searchQuery"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data();
                      final category = _ExploreCategory.fromFirestore(doc.id, data);

                      final isSelected = _selectedCategory == category.category;

                      return _CategoryCard(
                        category: category,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (_selectedCategory == category.category) {
                              _selectedCategory = null;
                            } else {
                              _selectedCategory = category.category;
                            }
                          });
                        },
                      );
                    }, childCount: filteredDocs.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                  );
                },
              ),
            ),

            // Nearby / Matching Workers section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Matching Workers'
                          : 'Nearby Workers',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/search');
                      },
                      child: const Text('Search all'),
                    ),
                  ],
                ),
              ),
            ),

            // Live Workers from Firestore
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('workers')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final allWorkers = snapshot.data?.docs ?? [];

                  final filteredWorkers = allWorkers.where((doc) {
                    final data = doc.data();
                    final name = (data['name']?.toString() ?? '').toLowerCase();
                    final profession = (data['profession']?.toString() ?? '').toLowerCase();
                    final city = (data['city']?.toString() ?? '').toLowerCase();
                    final skills = (data['skills'] is List)
                        ? (data['skills'] as List).map((e) => e.toString().toLowerCase()).toList()
                        : <String>[];

                    if (_selectedCategory != null) {
                      final catMatch = profession.contains(_selectedCategory!.toLowerCase()) ||
                          skills.any((s) => s.contains(_selectedCategory!.toLowerCase()));
                      if (!catMatch) return false;
                    }

                    if (_searchQuery.isNotEmpty) {
                      final match = name.contains(_searchQuery) ||
                          profession.contains(_searchQuery) ||
                          city.contains(_searchQuery) ||
                          skills.any((s) => s.contains(_searchQuery));
                      if (!match) return false;
                    }

                    return true;
                  }).toList();

                  if (filteredWorkers.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyWorkersCard(
                        message: _searchQuery.isNotEmpty
                            ? 'No workers match "$_searchQuery"'
                            : 'No verified workers found in this category.',
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = filteredWorkers[index];
                        final data = doc.data();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WorkerCard(
                            id: doc.id,
                            data: data,
                            onTap: () => _showWorkerSheet(context, doc.id, data),
                          ),
                        );
                      },
                      childCount: filteredWorkers.length,
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search services, workers, or skills...',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.primary,
            size: 24,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => _searchController.clear(),
                ),
              IconButton(
                onPressed: () => context.push('/search'),
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Advanced Search',
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  void _showWorkerSheet(
    BuildContext context,
    String workerId,
    Map<String, dynamic> data,
  ) {
    final item = SearchResultItem(
      id: workerId,
      type: SearchItemType.worker,
      title: data['name']?.toString() ?? 'Worker',
      subtitle: data['profession']?.toString() ?? 'Professional',
      description: data['bio']?.toString() ?? data['about']?.toString() ?? '',
      imageUrl: data['profileImage']?.toString() ?? data['avatar']?.toString(),
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      totalJobsOrReviews: (data['totalJobs'] as num?)?.toInt() ?? 0,
      price: (data['hourlyRate'] as num?)?.toInt() ?? 299,
      tags: (data['skills'] is List)
          ? (data['skills'] as List).map((e) => e.toString()).toList()
          : [],
      rawData: data,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkerDetailModal(item: item),
    );
  }
}

// -----------------------------------------------------------------------------
// Emergency Card
// -----------------------------------------------------------------------------

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.errorContainer,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: colorScheme.onError,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help right now?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Book an emergency service near you.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Category Card
// -----------------------------------------------------------------------------

class _CategoryCard extends StatelessWidget {
  final _ExploreCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 23,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Worker Card
// -----------------------------------------------------------------------------

class _WorkerCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _WorkerCard({
    required this.id,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final name = data['name']?.toString() ?? 'Verified Worker';
    final profession = data['profession']?.toString() ?? 'Professional';
    final rating = (data['rating'] as num?)?.toDouble() ?? 4.8;
    final totalJobs = (data['totalJobs'] as num?)?.toInt() ?? 50;
    final hourlyRate = (data['hourlyRate'] as num?)?.toInt() ?? 299;
    final imageUrl = data['profileImage']?.toString() ?? data['avatar']?.toString();

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0] : 'W',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profession,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalJobs jobs',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.currency_rupee_rounded,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        Text(
                          '$hourlyRate/hr',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
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
}

// -----------------------------------------------------------------------------
// Empty Workers Card
// -----------------------------------------------------------------------------

class _EmptyWorkersCard extends StatelessWidget {
  final String message;

  const _EmptyWorkersCard({
    this.message = 'Nearby verified workers will appear here.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 42,
            color: colorScheme.primary,
          ),

          const SizedBox(height: 12),

          Text(
            'Workers near you',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Worker Detail Modal
// -----------------------------------------------------------------------------

class _WorkerDetailModal extends StatelessWidget {
  final SearchResultItem item;

  const _WorkerDetailModal({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: item.imageUrl != null
                    ? NetworkImage(item.imageUrl!)
                    : null,
                child: item.imageUrl == null
                    ? Text(
                        item.title.isNotEmpty ? item.title[0] : 'W',
                        style: TextStyle(
                          fontSize: 22,
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (item.tags.isNotEmpty) ...[
            Text(
              'Skills & Services',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.tags.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  backgroundColor:
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hourly Rate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '₹${item.price ?? 299}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () => _handleHire(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Hire Professional',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleHire(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (user == null) {
      nav.pop();
      context.go('/auth');
      return;
    }

    try {
      final bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
        'customerId': user.uid,
        'customerName': user.displayName ?? 'Customer',
        'customerPhone': user.phoneNumber ?? '',
        'workerId': item.id,
        'workerName': item.title,
        'serviceId': 'service_direct',
        'serviceTitle': item.subtitle,
        'status': 'requested',
        'scheduledDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'timeSlot': '11:00 AM - 01:00 PM',
        'amount': item.price ?? 299,
        'notes': 'Direct booking via Explore',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Hiring request sent! Ref: ${bookingRef.id.substring(0, 6)}'),
          backgroundColor: Colors.green.shade700,
          action: SnackBarAction(
            label: 'View Activity',
            textColor: Colors.white,
            onPressed: () => context.go('/activity'),
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to book worker: $e')),
      );
    }
  }
}

// -----------------------------------------------------------------------------
// Category Model
// -----------------------------------------------------------------------------

class _ExploreCategory {
  final String id;
  final String title;
  final String description;
  final String category;
  final int basePrice;
  final String iconName;

  const _ExploreCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.iconName,
  });

  factory _ExploreCategory.fromFirestore(String id, Map<String, dynamic> data) {
    return _ExploreCategory(
      id: id,
      title: data['name']?.toString() ?? 'Service',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      basePrice: (data['basePrice'] as num?)?.toInt() ?? 0,
      iconName: data['icon']?.toString() ?? 'handyman_rounded',
    );
  }

  IconData get icon {
    switch (iconName) {
      case 'plumbing_rounded':
        return Icons.plumbing_rounded;
      case 'electrical_services_rounded':
        return Icons.electrical_services_rounded;
      case 'cleaning_services_rounded':
        return Icons.cleaning_services_rounded;
      case 'handyman_rounded':
        return Icons.handyman_rounded;
      case 'format_paint_rounded':
        return Icons.format_paint_rounded;
      case 'car_repair_rounded':
        return Icons.car_repair_rounded;
      case 'ac_unit_rounded':
        return Icons.ac_unit_rounded;
      case 'home_repair_service_rounded':
        return Icons.home_repair_service_rounded;
      case 'elderly_rounded':
      case 'home_rounded':
        return Icons.home_rounded;
      case 'yard_rounded':
        return Icons.yard_rounded;
      case 'drive_eta_rounded':
        return Icons.drive_eta_rounded;
      case 'pest_control_rounded':
        return Icons.pest_control_rounded;
      case 'brush_rounded':
        return Icons.brush_rounded;
      default:
        return Icons.home_repair_service_rounded;
    }
  }
}
