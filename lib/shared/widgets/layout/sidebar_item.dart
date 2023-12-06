import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

class SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color foreColor = isActive ? AppColors.primary : AppColors.lightGrey;
    return Container(
      decoration: BoxDecoration(
          border: Border(
        left: isActive
            ? const BorderSide(color: AppColors.primary, width: 2.0)
            : BorderSide.none,
      )),
      child: TextButton(
          onPressed: onPressed,
          style: isActive
              ? TextButton.styleFrom(
                  backgroundColor: const Color(0x0A00A0C3),
                )
              : TextButton.styleFrom(),
          child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: foreColor),
                    Text(text,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: foreColor)),
                  ]))),
    );
  }
}
