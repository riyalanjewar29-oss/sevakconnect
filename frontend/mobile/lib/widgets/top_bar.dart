import 'package:flutter/material.dart';
import 'profile_dialog.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String activeRole;
  final VoidCallback? onRoleToggle;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onLogout;

  const TopBar({
    super.key,
    required this.title,
    this.activeRole = 'Admin',
    this.onRoleToggle,
    this.onMenuPressed,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Title / Drawer trigger
          Row(
            children: [
              if (!isDesktop && onMenuPressed != null) ...[
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Color(0xFF333333)),
                  onPressed: onMenuPressed,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1C1C),
                ),
              ),
            ],
          ),

          // Right: Notifications & User Profile Menu
          Row(
            children: [
              // Notifications
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF4A4A4A),
                      size: 22,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new operational alerts'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: const Center(
                        child: Text(
                          '0',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Profile Chip
              InkWell(
                onTap: () => showProfileDialog(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E0E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF757575),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activeRole,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1C1C),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF757575),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
