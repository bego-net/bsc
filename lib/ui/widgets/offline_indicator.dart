import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

/// Reusable banner / chip indicating offline mode or pending background sync.
///
/// Uses [hasPendingWrites] and [isFromCache] to show:
/// - "Saved on this phone, will sync" when local changes are pending upload.
/// - "Offline mode" when reading cached data while offline.
class OfflineIndicator extends StatelessWidget {
  final bool hasPendingWrites;
  final bool isFromCache;
  final EdgeInsetsGeometry padding;
  final bool compact;

  const OfflineIndicator({
    super.key,
    required this.hasPendingWrites,
    required this.isFromCache,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasPendingWrites && !isFromCache) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final isSyncing = hasPendingWrites;
    final text = isSyncing
        ? (l10n?.savedOnPhoneWillSync ?? 'Saved on this phone, will sync')
        : (l10n?.offlineMode ?? 'Offline mode');

    final icon = isSyncing ? Icons.sync_rounded : Icons.cloud_off_rounded;
    final bg = isSyncing
        ? const Color(0xFFFEF3C7)
        : AppColors.surfaceMuted;
    final fg = isSyncing ? AppColors.bronze : AppColors.textSecondary;
    final border = isSyncing
        ? AppColors.streakBorder
        : AppColors.border;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.caption(color: fg),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.caption(color: fg, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
