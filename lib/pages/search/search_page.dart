import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../services/firestore_search_service.dart';
import '../../services/worker_location_service.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreSearchService _searchService = FirestoreSearchService();
  final WorkerLocationService _workerLocationService = WorkerLocationService();
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  String _currentQuery = '';
  SearchItemType? _selectedFilter; // null = All
  Position? _userPosition;

  final List<String> _trendingSearches = const [
    'Plumber',
    'Electrician',
    'Cleaning',
    'AC Repair',
    'Carpenter',
    'Painting',
    'Gardening',
    'Appliance Repair',
  ];

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _currentQuery);
    _searchController.addListener(_onSearchChanged);
    _fetchLocation();

    if (_currentQuery.isNotEmpty) {
      _searchService.addRecentSearch(_currentQuery);
    }
  }

  Future<void> _fetchLocation() async {
    final pos = await _workerLocationService.getUserPosition();
    if (mounted) {
      setState(() {
        _userPosition = pos;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _currentQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.trim().isNotEmpty) {
      _searchService.addRecentSearch(query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: 'Search services, workers, skills...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          _buildFilterChips(colorScheme),

          const Divider(height: 1),

          // Main Content
          Expanded(
            child: _currentQuery.trim().isEmpty
                ? _buildEmptyQueryContent(theme, colorScheme)
                : _buildSearchResults(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            label: 'All',
            icon: Icons.apps_rounded,
            isSelected: _selectedFilter == null,
            onSelected: () => setState(() => _selectedFilter = null),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Services',
            icon: Icons.handyman_rounded,
            isSelected: _selectedFilter == SearchItemType.service,
            onSelected: () =>
                setState(() => _selectedFilter = SearchItemType.service),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Workers',
            icon: Icons.person_rounded,
            isSelected: _selectedFilter == SearchItemType.worker,
            onSelected: () =>
                setState(() => _selectedFilter = SearchItemType.worker),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelected,
    required ColorScheme colorScheme,
  }) {
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEmptyQueryContent(ThemeData theme, ColorScheme colorScheme) {
    final recentList = _searchService.recentSearches;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Recent Searches
        if (recentList.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchService.clearRecentSearches();
                  });
                },
                child: const Text('Clear all', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentList.map((term) {
              return InputChip(
                label: Text(term),
                avatar: const Icon(Icons.history_rounded, size: 16),
                onPressed: () {
                  _searchController.text = term;
                  _submitSearch(term);
                },
                onDeleted: () {
                  setState(() {
                    _searchService.removeRecentSearch(term);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Trending Searches
        Text(
          'Trending Services',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trendingSearches.map((term) {
            return ActionChip(
              avatar: Icon(Icons.trending_up_rounded, size: 16, color: colorScheme.primary),
              label: Text(term),
              onPressed: () {
                _searchController.text = term;
                _submitSearch(term);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // Live Popular Services from Firestore
        Text(
          'Popular Services on Savia',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        StreamBuilder<List<SearchResultItem>>(
          stream: _searchService.streamServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final services = snapshot.data ?? [];
            if (services.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.take(4).length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = services[index];
                return _buildServiceTile(item, theme, colorScheme);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(ThemeData theme, ColorScheme colorScheme) {
    return StreamBuilder<List<SearchResultItem>>(
      stream: _searchService.searchLive(
        query: _currentQuery,
        filterType: _selectedFilter,
        userLat: _userPosition?.latitude,
        userLng: _userPosition?.longitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error searching Firestore: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 36,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No matches found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No services or workers matched "$_currentQuery". Try searching for "Plumber", "Electrician", or "Cleaning".',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Found ${results.length} results for "$_currentQuery"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = results[index];
                if (item.type == SearchItemType.worker) {
                  return _buildWorkerTile(item, theme, colorScheme);
                } else {
                  return _buildServiceTile(item, theme, colorScheme);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceTile(
    SearchResultItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showItemDetailsSheet(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  size: 26,
                  color: colorScheme.onPrimaryContainer,
                ),
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
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (item.price != null)
                          Text(
                            '₹${item.price}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description ?? item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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

  Widget _buildWorkerTile(
    SearchResultItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final rating = item.rating ?? 4.8;
    final totalJobs = item.totalJobsOrReviews ?? 50;
    final hourlyRate = item.price ?? 299;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showItemDetailsSheet(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Online Badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: item.imageUrl != null
                        ? NetworkImage(item.imageUrl!)
                        : null,
                    child: item.imageUrl == null
                        ? Text(
                            item.title.isNotEmpty ? item.title[0] : 'W',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (item.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
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
                            item.title,
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
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.formattedDistance,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
                        const Spacer(),
                        Text(
                          '₹$hourlyRate/hr',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
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

  void _showItemDetailsSheet(SearchResultItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchResultDetailSheet(item: item),
    );
  }
}

/// Detail modal sheet for search result items
class _SearchResultDetailSheet extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWorker = item.type == SearchItemType.worker;

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
          // Drag handle
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
              if (isWorker)
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
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    size: 30,
                    color: colorScheme.onPrimaryContainer,
                  ),
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
                    if (isWorker) ...[
                      const SizedBox(height: 2),
                      Text(
                        '• ${item.formattedDistance}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (item.description != null && item.description!.isNotEmpty) ...[
            Text(
              'About',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (item.tags.isNotEmpty) ...[
            Text(
              isWorker ? 'Skills & Expertise' : 'Included in Service',
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
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],

          // Pricing & Booking CTA
          Row(
            children: [
              if (item.price != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWorker ? 'Hourly Rate' : 'Starting Price',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '₹${item.price}',
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
                  onPressed: () => _handleBookNow(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isWorker ? 'Hire Now' : 'Book Service',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleBookNow(BuildContext context) async {
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
        'workerId': item.type == SearchItemType.worker ? item.id : 'worker_001',
        'workerName': item.type == SearchItemType.worker ? item.title : 'Verified Professional',
        'serviceId': item.type == SearchItemType.service ? item.id : 'service_custom',
        'serviceTitle': item.title,
        'status': 'requested',
        'scheduledDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'timeSlot': '10:00 AM - 12:00 PM',
        'amount': item.price ?? 299,
        'notes': 'Booked via Search',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Booking requested successfully! Ref: ${bookingRef.id.substring(0, 6)}'),
          backgroundColor: Colors.green.shade700,
          action: SnackBarAction(
            label: 'View Bookings',
            textColor: Colors.white,
            onPressed: () => context.go('/activity'),
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }
}
