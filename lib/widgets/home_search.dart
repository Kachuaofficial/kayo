import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearch extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool readOnly;
  final String hintText;
  final bool autoFocus;

  const HomeSearch({
    super.key,
    this.onFilterTap,
    this.onMicTap,
    this.onTap,
    this.onChanged,
    this.controller,
    this.readOnly = false,
    this.hintText = 'What service do you need?',
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap ??
                    () {
                      context.push('/search');
                    },
                child: IgnorePointer(
                  ignoring: onTap == null && onChanged == null && !autoFocus,
                  child: SearchBar(
                    controller: controller,
                    onChanged: onChanged,
                    onTap: onTap ??
                        () {
                          context.push('/search');
                        },
                    hintText: hintText,
                    hintStyle: WidgetStatePropertyAll(
                      TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    leading: Icon(
                      Icons.search_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    trailing: [
                      IconButton(
                        onPressed: onMicTap ??
                            () {
                              context.push('/search');
                            },
                        tooltip: 'Voice search',
                        icon: Icon(
                          Icons.mic_none_rounded,
                          color: colorScheme.primary,
                          size: 21,
                        ),
                      ),
                    ],
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter Button
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onFilterTap ??
                  () {
                    context.push('/search');
                  },
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Icon(
                  Icons.tune_rounded,
                  color: colorScheme.onPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
