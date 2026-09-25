import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeServices extends StatelessWidget {
  const HomeServices({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------
          // HEADER
          // ----------------------------------------------------------

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

          // ----------------------------------------------------------
          // FIRESTORE
          // ----------------------------------------------------------
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('services')
                .where('isActive', isEqualTo: true)
                .snapshots(),

            builder: (context, snapshot) {
              // Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Error
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Unable to load services',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              final documents = snapshot.data?.docs ?? [];

              // Empty
              if (documents.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No services available',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              // Convert Firestore documents
              final services = documents
                  .map((doc) => _ServiceItem.fromFirestore(doc.id, doc.data()))
                  .toList();

              // Home shows maximum 6 services
              final homeServices = services.take(6).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeServices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final service = homeServices[index];

                  return _ServiceCard(
                    service: service,
                    onTap: () {
                      // Later:
                      // context.push('/service/${service.id}');
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class _ServiceItem {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String category;
  final int basePrice;

  const _ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    required this.basePrice,
  });

  factory _ServiceItem.fromFirestore(String id, Map<String, dynamic> data) {
    return _ServiceItem(
      id: id,
      title: data['name']?.toString() ?? 'Service',
      description: data['description']?.toString() ?? '',
      iconName: data['icon']?.toString() ?? 'handyman_rounded',
      category: data['category']?.toString() ?? '',
      basePrice: (data['basePrice'] as num?)?.toInt() ?? 0,
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
        return Icons.elderly_rounded;

      case 'yard_rounded':
        return Icons.yard_rounded;

      default:
        return Icons.home_repair_service_rounded;
    }
  }
}

// ============================================================
// SERVICE CARD
// ============================================================

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
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
