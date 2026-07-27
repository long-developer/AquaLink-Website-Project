import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_aqualink/app/providers/app_data_provider.dart';
import 'package:project_aqualink/app/screens/assistant_screen.dart';
import 'package:project_aqualink/app/screens/feed_screen.dart';
import 'package:project_aqualink/app/screens/post_screen.dart';
import 'package:project_aqualink/app/screens/search_screen.dart';
import 'package:project_aqualink/app/screens/settings_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = <Widget>[
    FeedScreen(),
    PostScreen(),
    SearchScreen(),
    SettingsScreen(),
    AssistantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppDataProvider>();

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: SizedBox(key: ValueKey(nav.index), child: _pages[nav.index]),
      ),
      bottomNavigationBar: const GlassBottomNav(),
    );
  }
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({super.key});

  static const _items = [
    _NavItem('feed_title', Icons.feed_rounded),
    _NavItem('post_feed', Icons.add_circle_outline_rounded),
    _NavItem('search_title', Icons.search_rounded),
    _NavItem('settings_title', Icons.settings_rounded),
    _NavItem('assistant_title', Icons.smart_toy_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppDataProvider>();
    final appData = context.watch<AppDataProvider>();

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005F73).withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _items.length;
                return Stack(
                  children: [
                    AnimatedAlign(
                      alignment: Alignment(-1 + nav.targetIndex * 0.5, 0),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        width: itemWidth - 8,
                        height: 56,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF007C89,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_items.length, (index) {
                        final item = _items[index];
                        final selected = nav.targetIndex == index;

                        return Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => nav.setIndex(index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: selected
                                        ? const Color(0xFF007C89)
                                        : const Color(0xFF5D7A83),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appData.translate(item.labelKey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? const Color(0xFF007C89)
                                          : const Color(0xFF5D7A83),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.labelKey, this.icon);
  final String labelKey;
  final IconData icon;
}
