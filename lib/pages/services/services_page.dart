import 'package:flutter/material.dart';
import 'package:kayo/widgets/home_search.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  static const List<_ServiceItem> services = [
    _ServiceItem(
      name: 'Plumbing',
      icon: Icons.plumbing_rounded,
    ),
    _ServiceItem(
      name: 'Electrician',
      icon: Icons.electrical_services_rounded,
    ),
    _ServiceItem(
      name: 'Cleaning',
      icon: Icons.cleaning_services_rounded,
    ),
    _ServiceItem(
      name: 'Carpenter',
      icon: Icons.handyman_rounded,
    ),
    _ServiceItem(
      name: 'Painting',
      icon: Icons.format_paint_rounded,
    ),
    _ServiceItem(
      name: 'Mechanic',
      icon: Icons.car_repair_rounded,
    ),
    _ServiceItem(
      name: 'Gardening',
      icon: Icons.yard_rounded,
    ),
    _ServiceItem(
      name: 'Home Care',
      icon: Icons.home_rounded,
    ),
    _ServiceItem(
      name: 'Driver',
      icon: Icons.drive_eta_rounded,
    ),
    _ServiceItem(
      name: 'Appliance Repair',
      icon: Icons.home_repair_service_rounded,
    ),
    _ServiceItem(
      name: 'Pest Control',
      icon: Icons.pest_control_rounded,
    ),
    _ServiceItem(
      name: 'Painting & Decor',
      icon: Icons.brush_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'All Services',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeSearch(),

                    const SizedBox(height: 24),

                    Text(
                      'What do you need help with?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Choose a service and find trusted workers near you.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = services[index];

                    return _ServiceCard(
                      service: service,
                      onTap: () {
                        // TODO: Navigate to service details
                      },
                    );
                  },
                  childCount: services.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
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

class _ServiceItem {
  final String name;
  final IconData icon;

  const _ServiceItem({
    required this.name,
    required this.icon,
  });
}
class _ServiceCard extends StatelessWidget {
  final _ServiceItem service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  service.icon,
                  size: 24,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                service.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
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