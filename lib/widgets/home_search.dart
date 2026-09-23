import 'package:flutter/material.dart';

class HomeSearch extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onChanged;

  const HomeSearch({
    super.key,
    this.onFilterTap,
    this.onMicTap,
    this.onChanged,
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
            child: SearchBar(
              onChanged: onChanged,
              hintText: 'What service do you need?',
              hintStyle: WidgetStatePropertyAll(
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              leading: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
              trailing: [
                IconButton(
                  onPressed: onMicTap,
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
                colorScheme.surfaceContainerHighest.withOpacity(0.55),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.35),
                  ),
                ),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter Button
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onFilterTap,
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
