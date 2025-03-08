import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      width: 250, // Adjust width for a standard drawer size
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: const Color(0xFF252A3A),),
            child: Center(
              child: Text(
                "Settings",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          // ListTile(
          //   leading: Icon(
          //     themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
          //     color: Colors.green,
          //   ),
          //   title: Text("Dark Mode"),
          //   trailing: Switch(
          //     value: themeProvider.themeMode == ThemeMode.dark,
          //     onChanged: (value) {
          //       themeProvider.toggleTheme(value);
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
