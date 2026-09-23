import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeServices extends StatelessWidget {
  const HomeServices({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final services = [
      const _ServiceItem(title: 'Plumbing', icon: Icons.plumbing_rounded),
      const _ServiceItem(
        title: 'Electrician',
        icon: Icons.electrical_services_rounded,
      ),
      const _ServiceItem(
        title: 'Cleaning',
        icon: Icons.cleaning_services_rounded,
      ),
      const _ServiceItem(title: 'Carpenter', icon: Icons.handyman_rounded),
      const _ServiceItem(title: 'Painting', icon: Icons.format_paint_rounded),
      const _ServiceItem(title: 'Mechanic', icon: Icons.car_repair_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'What do you need help with?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {
                  // Navigate to all services
                          context.go('/explore');


                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 x 2 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final service = services[index];

              return _ServiceCard(
                service: service,
                onTap: () {
                  // Navigate to service details

                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// MODEL
// ------------------------------------------------------------

class _ServiceItem {
  final String title;
  final IconData icon;

  const _ServiceItem({required this.title, required this.icon});
}

// ------------------------------------------------------------
// CARD
// ------------------------------------------------------------

class _ServiceCard extends StatelessWidget {
  final _ServiceItem service;
  final VoidCallback? onTap;

  const _ServiceCard({required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.45),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(service.icon, size: 24, color: colorScheme.primary),
              ),

              const SizedBox(height: 10),

              // Name
              Text(
                service.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
