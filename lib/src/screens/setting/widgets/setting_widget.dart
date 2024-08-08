import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.endIcon = true,
    this.startIcon = true,
    this.textColor,
    required int maxLines,
    required TextOverflow overflow,
  });

  final String title;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool endIcon;
  final Color? textColor;
  final bool startIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selectedTileColor: Colors.white,
      selectedColor: Colors.white,
      onTap: onPressed,
      leading: startIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                icon,
              ),
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyLarge?.apply(color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                // color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.arrow_right,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
