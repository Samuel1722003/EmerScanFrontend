import 'package:flutter/material.dart';
import 'package:hfe_frontend/screens/screen.dart';

class MedicalCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MedicalCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    final titleSize = isTablet ? 28.0 : 20.0;
    final contentSize = isTablet ? 35.0 : 27.0;
    final iconSize = isTablet ? 37.0 : 29.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: iconSize),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: isTablet ? 30.0 : 20.0,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: contentSize,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
