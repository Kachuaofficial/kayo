import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  int _selectedTab = 0;
  final List<String> _tabs = const ['Upcoming', 'Active', 'Completed', 'Cancelled'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cached name lookups for workers and services
  final Map<String, String> _workerNames = {};
  final Map<String, String> _workerPhones = {};
  final Map<String, String> _serviceNames = {};

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final workersSnap = await _firestore.collection('workers').get();
      for (final doc in workersSnap.docs) {
        final data = doc.data();
        if (data.containsKey('name')) {
          _workerNames[doc.id] = data['name'] as String;
        }
        if (data.containsKey('phone')) {
          _workerPhones[doc.id] = data['phone'] as String;
        }
      }

      final servicesSnap = await _firestore.collection('services').get();
      for (final doc in servicesSnap.docs) {
        final data = doc.data();
        if (data.containsKey('name')) {
          _serviceNames[doc.id] = data['name'] as String;
        }
      }

      if (mounted) setState(() {});
    } catch (_) {}
  }

  IconData _getServiceIcon(String? serviceId, String? serviceName) {
    final sId = (serviceId ?? '').toLowerCase();
    final sName = (serviceName ?? '').toLowerCase();

    if (sId.contains('plumb') || sName.contains('plumb')) {
      return Icons.plumbing_rounded;
    } else if (sId.contains('elect') || sName.contains('elect')) {
      return Icons.electrical_services_rounded;
    } else if (sId.contains('clean') || sName.contains('clean')) {
      return Icons.cleaning_services_rounded;
    } else if (sId.contains('carpent') || sName.contains('carpent')) {
      return Icons.handyman_rounded;
    } else if (sId.contains('paint') || sName.contains('paint')) {
      return Icons.format_paint_rounded;
    } else if (sId.contains('mechanic') || sName.contains('mechanic') || sName.contains('car')) {
      return Icons.car_repair_rounded;
    } else if (sId.contains('garden') || sName.contains('garden')) {
      return Icons.yard_rounded;
    } else if (sId.contains('ac') || sName.contains('ac')) {
      return Icons.ac_unit_rounded;
    } else if (sId.contains('appliance') || sName.contains('appliance')) {
      return Icons.home_repair_service_rounded;
    } else if (sId.contains('care') || sName.contains('care')) {
      return Icons.home_rounded;
    }
    return Icons.build_rounded;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (dt.year == tomorrow.year && dt.month == tomorrow.month && dt.day == tomorrow.day) {
      return 'Tomorrow';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  bool _matchesTab(String status, int tabIndex) {
    final s = status.toLowerCase().trim();
    switch (tabIndex) {
      case 0: // Upcoming
        return s == 'confirmed' || s == 'accepted' || s == 'requested';
      case 1: // Active
        return s == 'in_progress' || s == 'worker_on_way' || s == 'arrived';
      case 2: // Completed
        return s == 'completed';
      case 3: // Cancelled
        return s == 'cancelled' || s == 'rejected';
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Build query: if logged in, stream user's bookings; otherwise stream all seeded bookings
    Query<Map<String, dynamic>> query = _firestore.collection('bookings');
    if (currentUserId != null) {
      // Stream user bookings if any, or general stream
      query = query.where('customerId', isEqualTo: currentUserId);
    }

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
                      'Activity',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your services and bookings in real-time.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tabs
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tabs.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = _selectedTab == index;

                          return ChoiceChip(
                            label: Text(_tabs[index]),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedTab = index;
                              });
                            },
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Firestore Stream
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                // If user-specific query is empty and user is logged in, fallback to all bookings to show demo data
                if (snapshot.hasData && snapshot.data!.docs.isEmpty && currentUserId != null) {
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _firestore.collection('bookings').snapshots(),
                    builder: (context, allSnap) {
                      return _buildSliverContent(context, allSnap);
                    },
                  );
                }

                return _buildSliverContent(context, snapshot);
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverContent(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (snapshot.hasError) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Failed to load bookings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final docs = snapshot.data?.docs ?? [];
    final filteredDocs = docs.where((doc) {
      final data = doc.data();
      final status = (data['status'] as String?) ?? 'confirmed';
      return _matchesTab(status, _selectedTab);
    }).toList();

    // Sort by scheduledAt descending
    filteredDocs.sort((a, b) {
      final tA = a.data()['scheduledAt'];
      final tB = b.data()['scheduledAt'];
      final dtA = (tA is Timestamp) ? tA.toDate() : DateTime.now();
      final dtB = (tB is Timestamp) ? tB.toDate() : DateTime.now();
      return dtB.compareTo(dtA);
    });

    if (filteredDocs.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_tabs[_selectedTab].toLowerCase()} bookings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'When you book a service, you will be able to track and manage its real-time progress right here.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    context.go('/services');
                  },
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Browse Services'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data();

            final bookingId = doc.id;
            final sId = data['serviceId'] as String? ?? '';
            final wId = data['workerId'] as String? ?? '';
            final cId = data['customerId'] as String? ?? '';

            final serviceTitle = (data['serviceTitle'] as String?) ??
                _serviceNames[sId] ??
                (sId.replaceAll('service_', '').replaceAll('_', ' ').toUpperCase());

            final workerName = _workerNames[wId] ??
                (wId.replaceAll('worker_', 'Worker #'));

            final workerPhone = _workerPhones[wId] ?? '';

            final schedRaw = data['scheduledAt'];
            final schedDate = (schedRaw is Timestamp)
                ? schedRaw.toDate()
                : (schedRaw is String ? DateTime.tryParse(schedRaw) ?? DateTime.now() : DateTime.now());

            final rawStatus = (data['status'] as String?) ?? 'confirmed';
            final amount = (data['amount'] as num?) ?? 0;
            final notes = (data['notes'] as String?) ?? '';
            final address = (data['address'] as Map<String, dynamic>?) ?? {};

            final icon = _getServiceIcon(sId, serviceTitle);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookingCard(
                bookingId: bookingId,
                customerId: cId,
                workerId: wId,
                workerName: workerName,
                workerPhone: workerPhone,
                serviceTitle: serviceTitle,
                serviceId: sId,
                date: _formatDate(schedDate),
                time: _formatTime(schedDate),
                status: rawStatus,
                amount: amount,
                notes: notes,
                address: address,
                icon: icon,
                onStatusUpdated: () => setState(() {}),
              ),
            );
          },
          childCount: filteredDocs.length,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Booking Card
// -----------------------------------------------------------------------------

class _BookingCard extends StatelessWidget {
  final String bookingId;
  final String customerId;
  final String workerId;
  final String workerName;
  final String workerPhone;
  final String serviceTitle;
  final String serviceId;
  final String date;
  final String time;
  final String status;
  final num amount;
  final String notes;
  final Map<String, dynamic> address;
  final IconData icon;
  final VoidCallback onStatusUpdated;

  const _BookingCard({
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
    required this.serviceTitle,
    required this.serviceId,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
    required this.notes,
    required this.address,
    required this.icon,
    required this.onStatusUpdated,
  });

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _FeedbackBottomSheet(
          bookingId: bookingId,
          customerId: customerId,
          workerId: workerId,
          workerName: workerName,
        );
      },
    );
  }

  void _showBookingDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BookingDetailsSheet(
          bookingId: bookingId,
          customerId: customerId,
          workerId: workerId,
          workerName: workerName,
          workerPhone: workerPhone,
          serviceTitle: serviceTitle,
          date: date,
          time: time,
          status: status,
          amount: amount,
          notes: notes,
          address: address,
          icon: icon,
          onCancelled: onStatusUpdated,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = status.toLowerCase();

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _showBookingDetailsSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Service icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: colorScheme.onPrimaryContainer,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Service + worker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          workerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(status: status),
                ],
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Text(date, style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time_rounded,
                    size: 17,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(time, style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  if (amount > 0)
                    Text(
                      '₹$amount',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),

              if (s == 'confirmed' || s == 'accepted' || s == 'requested') ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showBookingDetailsSheet(context),
                    child: const Text('View booking details'),
                  ),
                ),
              ],

              if (s == 'completed') ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showFeedbackSheet(context),
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    label: const Text('Share your experience'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Status Badge
// -----------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = status.toLowerCase();

    late String text;
    late Color background;
    late Color foreground;

    switch (s) {
      case 'confirmed':
        text = 'Confirmed';
        background = colorScheme.primaryContainer;
        foreground = colorScheme.onPrimaryContainer;
        break;
      case 'accepted':
        text = 'Accepted';
        background = colorScheme.primaryContainer;
        foreground = colorScheme.onPrimaryContainer;
        break;
      case 'requested':
        text = 'Requested';
        background = colorScheme.primaryContainer.withValues(alpha: 0.7);
        foreground = colorScheme.onPrimaryContainer;
        break;
      case 'in_progress':
        text = 'In progress';
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        break;
      case 'worker_on_way':
        text = 'On the way';
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        break;
      case 'arrived':
        text = 'Arrived';
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        break;
      case 'completed':
        text = 'Completed';
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        break;
      case 'cancelled':
        text = 'Cancelled';
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        break;
      case 'rejected':
        text = 'Rejected';
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        break;
      default:
        text = status;
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Booking Details Sheet
// -----------------------------------------------------------------------------

class _BookingDetailsSheet extends StatelessWidget {
  final String bookingId;
  final String customerId;
  final String workerId;
  final String workerName;
  final String workerPhone;
  final String serviceTitle;
  final String date;
  final String time;
  final String status;
  final num amount;
  final String notes;
  final Map<String, dynamic> address;
  final IconData icon;
  final VoidCallback onCancelled;

  const _BookingDetailsSheet({
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
    required this.serviceTitle,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
    required this.notes,
    required this.address,
    required this.icon,
    required this.onCancelled,
  });

  String get _formattedAddress {
    final house = address['house'] as String? ?? '';
    final area = address['area'] as String? ?? '';
    final city = address['city'] as String? ?? '';
    final state = address['state'] as String? ?? '';
    final pincode = address['pincode'] as String? ?? '';

    final parts = [house, area, city, state, pincode].where((p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return 'No address specified';
    return parts.join(', ');
  }

  Future<void> _handleCancelBooking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          Navigator.pop(context);
          onCancelled();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking has been cancelled.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel booking: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = status.toLowerCase();
    final canCancel = s == 'confirmed' || s == 'accepted' || s == 'requested';

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Booking #${bookingId.replaceAll('booking_', '')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 24),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 20),

              // Worker info
              _DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Assigned Professional',
                value: workerName,
                extra: workerPhone.isNotEmpty ? Text(workerPhone, style: TextStyle(color: colorScheme.primary, fontSize: 13)) : null,
              ),
              const SizedBox(height: 16),

              // Date & Time
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Schedule',
                value: '$date at $time',
              ),
              const SizedBox(height: 16),

              // Location / Address
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Service Address',
                value: _formattedAddress,
              ),
              const SizedBox(height: 16),

              // Amount
              if (amount > 0) ...[
                _DetailRow(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Total Amount',
                  value: '₹$amount',
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              if (notes.isNotEmpty) ...[
                _DetailRow(
                  icon: Icons.notes_rounded,
                  label: 'Special Instructions',
                  value: notes,
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 12),

              if (canCancel)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                    ),
                    onPressed: () => _handleCancelBooking(context),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel Booking'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? extra;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (extra != null) ...[
                const SizedBox(height: 2),
                extra!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Experience Model & Feedback Bottom Sheet
// -----------------------------------------------------------------------------

class _Experience {
  final String emoji;
  final String title;
  final String subtitle;

  const _Experience({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class _FeedbackBottomSheet extends StatefulWidget {
  final String bookingId;
  final String customerId;
  final String workerId;
  final String workerName;

  const _FeedbackBottomSheet({
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    required this.workerName,
  });

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  int _selectedExperience = -1;
  final Set<String> _selectedTags = {};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<_Experience> _experiences = const [
    _Experience(emoji: '🥲', title: 'Not great', subtitle: 'Could be better'),
    _Experience(emoji: '😕', title: 'Okay', subtitle: 'It was fine'),
    _Experience(emoji: '😐', title: 'Good', subtitle: 'Pretty decent'),
    _Experience(emoji: '😊', title: 'Great', subtitle: 'Really happy'),
    _Experience(emoji: '🤩', title: 'Amazing!', subtitle: 'Loved the service'),
  ];

  final List<String> _feedbackTags = const [
    '✨ Professional',
    '⚡ On time',
    '🛠 Great work',
    '😊 Friendly',
    '💰 Fair price',
    '🧹 Clean work',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'bookingId': widget.bookingId,
        'customerId': widget.customerId,
        'workerId': widget.workerId,
        'experience': _selectedExperience,
        'tags': _selectedTags.toList(),
        'comment': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      _showThankYouSheet();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  void _showThankYouSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ThankYouSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Column(
                    children: [
                      Text(
                        'How did we do?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'How was your experience with ${widget.workerName}?',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Experience selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_experiences.length, (index) {
                    final experience = _experiences[index];
                    final selected = _selectedExperience == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedExperience = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        width: selected ? 62 : 54,
                        height: selected ? 78 : 70,
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: selected ? 1.25 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                experience.emoji,
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              experience.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _selectedExperience >= 0
                      ? Center(
                          key: ValueKey(_selectedExperience),
                          child: Text(
                            _experiences[_selectedExperience].subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox(key: ValueKey('empty'), height: 20),
                ),
                const SizedBox(height: 24),

                // Tags
                Text(
                  'What went well?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _feedbackTags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: selected,
                      showCheckmark: true,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Comment
                Text(
                  'Want to say something?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: 'Tell us about your experience...',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _selectedExperience == -1 || _isSubmitting
                        ? null
                        : () => _submitFeedback(),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Share Feedback',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 6),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Maybe later'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThankYouSheet extends StatefulWidget {
  const _ThankYouSheet();

  @override
  State<_ThankYouSheet> createState() => _ThankYouSheetState();
}

class _ThankYouSheetState extends State<_ThankYouSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),

            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticOut,
              ),
              child: const Text('🎉', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 16),

            Text(
              'Thanks for your feedback!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Your feedback helps us recognize great workers and improve the experience for everyone on Savia.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
