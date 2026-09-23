import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  static const List<_ExploreCategory> categories = [
    _ExploreCategory(
      title: 'Plumbing',
      icon: Icons.plumbing_rounded,
    ),
    _ExploreCategory(
      title: 'Electrician',
      icon: Icons.electrical_services_rounded,
    ),
    _ExploreCategory(
      title: 'Cleaning',
      icon: Icons.cleaning_services_rounded,
    ),
    _ExploreCategory(
      title: 'Carpenter',
      icon: Icons.handyman_rounded,
    ),
    _ExploreCategory(
      title: 'Painting',
      icon: Icons.format_paint_rounded,
    ),
    _ExploreCategory(
      title: 'Mechanic',
      icon: Icons.car_repair_rounded,
    ),
  ];

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

                    // Search
                    _ExploreSearchBar(),

                    const SizedBox(height: 24),

                    // Emergency CTA
                    _EmergencyCard(),

                    const SizedBox(height: 28),

                    Text(
                      'Browse Services',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Categories
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];

                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        // TODO: Open service category
                      },
                    );
                  },
                  childCount: categories.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
              ),
            ),

            // Nearby section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nearby Workers',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: View all workers
                      },
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),
            ),

            // Worker placeholder
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _EmptyWorkersCard(),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Search Bar
// -----------------------------------------------------------------------------

class _ExploreSearchBar extends StatelessWidget {
  const _ExploreSearchBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SearchBar(
      hintText: 'Search services or workers',
      leading: Icon(
        Icons.search_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      trailing: [
        IconButton(
          onPressed: () {
            // TODO: Filter
          },
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
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

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: colorScheme.onErrorContainer,
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
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 23,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
// Empty Workers
// -----------------------------------------------------------------------------

class _EmptyWorkersCard extends StatelessWidget {
  const _EmptyWorkersCard();

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
          color: colorScheme.outlineVariant,
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
            'Nearby verified workers will appear here.',
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
// Model
// -----------------------------------------------------------------------------

class _ExploreCategory {
  final String title;
  final IconData icon;

  const _ExploreCategory({
    required this.title,
    required this.icon,
  });
}