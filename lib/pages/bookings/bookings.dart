import 'package:flutter/material.dart';

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  int _selectedTab = 0;

  final List<String> _tabs = ['Upcoming', 'Active', 'Completed', 'Cancelled'];

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
                      'Activity',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your services and bookings.',
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
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
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

            // Booking list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_buildBookings()),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBookings() {
    switch (_selectedTab) {
      case 0:
        return const [
          _BookingCard(
            service: 'Plumbing',
            worker: 'Rajesh Kumar',
            date: '24 Sep 2026',
            time: '10:30 AM',
            status: BookingStatus.confirmed,
            icon: Icons.plumbing_rounded,
          ),
          SizedBox(height: 12),
          _BookingCard(
            service: 'Home Cleaning',
            worker: 'Priya Sharma',
            date: '27 Sep 2026',
            time: '2:00 PM',
            status: BookingStatus.confirmed,
            icon: Icons.cleaning_services_rounded,
          ),
        ];

      case 1:
        return const [
          _BookingCard(
            service: 'Electrician',
            worker: 'Amit Singh',
            date: 'Today',
            time: '11:30 AM',
            status: BookingStatus.inProgress,
            icon: Icons.electrical_services_rounded,
          ),
        ];

      case 2:
        return const [
          _BookingCard(
            service: 'Carpenter',
            worker: 'Vikas Yadav',
            date: '18 Sep 2026',
            time: '3:00 PM',
            status: BookingStatus.completed,
            icon: Icons.handyman_rounded,
          ),
          SizedBox(height: 12),
          _BookingCard(
            service: 'Painting',
            worker: 'Mohit Verma',
            date: '12 Sep 2026',
            time: '9:00 AM',
            status: BookingStatus.completed,
            icon: Icons.format_paint_rounded,
          ),
        ];

      case 3:
        return const [
          _BookingCard(
            service: 'AC Repair',
            worker: 'Suresh Kumar',
            date: '10 Sep 2026',
            time: '12:00 PM',
            status: BookingStatus.cancelled,
            icon: Icons.ac_unit_rounded,
          ),
        ];

      default:
        return [];
    }
  }
}

// -----------------------------------------------------------------------------
// Booking Card
// -----------------------------------------------------------------------------

class _BookingCard extends StatelessWidget {
  final String service;
  final String worker;
  final String date;
  final String time;
  final BookingStatus status;
  final IconData icon;

  const _BookingCard({
    required this.service,
    required this.worker,
    required this.date,
    required this.time,
    required this.status,
    required this.icon,
  });

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _FeedbackBottomSheet(workerName: 'Vikas Yadav');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          // TODO: Open booking details
        },
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
                          service,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          worker,
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
                ],
              ),

              if (status == BookingStatus.confirmed) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: View booking
                    },
                    child: const Text('View booking'),
                  ),
                ),
              ],

              if (status == BookingStatus.completed) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showFeedbackSheet(context);
                    },
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
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    late String text;
    late Color background;
    late Color foreground;

    switch (status) {
      case BookingStatus.confirmed:
        text = 'Confirmed';
        background = colorScheme.primaryContainer;
        foreground = colorScheme.onPrimaryContainer;
        break;

      case BookingStatus.inProgress:
        text = 'In progress';
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        break;

      case BookingStatus.completed:
        text = 'Completed';
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        break;

      case BookingStatus.cancelled:
        text = 'Cancelled';
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        break;
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

enum BookingStatus { confirmed, inProgress, completed, cancelled }

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
  final String workerName;

  const _FeedbackBottomSheet({required this.workerName});

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  int _selectedExperience = -1;

  final Set<String> _selectedTags = {};

  final TextEditingController _commentController = TextEditingController();

  final List<_Experience> _experiences = [
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

                const SizedBox(height: 24),

                // Header
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

                // Selected message
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

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _selectedExperience == -1
                        ? null
                        : () {
                            _submitFeedback(context);
                          },
                    child: const Text(
                      'Share Feedback',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

  void _submitFeedback(BuildContext context) {
    // TODO:
    // Send:
    // - experience
    // - selected tags
    // - comment
    // - booking ID
    // to Firebase/API.

    Navigator.pop(context);

    _showThankYouSheet(context);
  }

  void _showThankYouSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _ThankYouSheet();
      },
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
              'Your feedback helps us recognize great workers and improve the experience for everyone.',
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
                onPressed: () {
                  Navigator.pop(context);
                },
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
