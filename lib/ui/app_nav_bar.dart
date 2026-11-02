import 'package:flutter/material.dart';

/// Item definition for the floating pill navigation bar.
class AppNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label; // kept for Semantics / accessibility

  const AppNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Floating light-surface pill navigation bar (no labels).
///
/// - Light warm-white pill with subtle shadow.
/// - Selected tab: green (#2F6F5E) circular background with a white icon.
/// - Unselected tabs: muted grey icons.
/// - Smooth 300 ms AnimatedContainer on selection change.
/// - Respects bottom SafeArea; min 48 px tap targets; 3–5 tabs.
class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavItem> items;

  // Kept for API compatibility; page background behind the pill.
  final Color backgroundColor;

  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.backgroundColor = const Color(0xFFF4F1EA),
  });

  static const _pillBg = Colors.white;
  static const _selectedBg = Color(0xFF2F6F5E);
  static const _selectedIcon = Colors.white;
  static const _unselectedIcon = Color(0xFF9BA5A0);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: bottomPadding + 16,
        top: 10,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _pillBg,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = selectedIndex == index;
              final icon =
                  isSelected ? (item.selectedIcon ?? item.icon) : item.icon;

              return Expanded(
                child: Semantics(
                  selected: isSelected,
                  label: item.label,
                  button: true,
                  child: GestureDetector(
                    onTap: () => onDestinationSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 48,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? _selectedBg : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                icon,
                                key: ValueKey('${index}_$isSelected'),
                                size: 22,
                                color:
                                    isSelected ? _selectedIcon : _unselectedIcon,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
