import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool? isActive; // Nullable: Optional activation
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    this.isActive, // Now optional
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.4, // 40% of screen width
        height: screenWidth * 0.35, // 35% of screen width
        decoration: BoxDecoration(
          color: const Color(0xFF252A3A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: screenWidth * 0.1, color: Colors.white), // Dynamic icon size
                  SizedBox(height: screenWidth * 0.02), // Dynamic spacing
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // Dynamic font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive != null) // Show indicator only if isActive is not null
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: screenWidth * 0.012, // Dynamic radius
                  backgroundColor: isActive! ? Colors.green : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
