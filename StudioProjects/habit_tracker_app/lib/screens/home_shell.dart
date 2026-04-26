import 'package:flutter/material.dart';
import 'garden_screen.dart';
import 'missions_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [GardenScreen(), MissionsScreen()];
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.park), label: 'Garden'),
          NavigationDestination(
            icon: Icon(Icons.flag_circle),
            label: 'Missions',
          ),
        ],
      ),
    );
  }
}
