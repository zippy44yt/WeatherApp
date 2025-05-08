import 'package:flutter/material.dart';
import 'home_content.dart';
import 'ajustes_screen.dart';
import 'PantallaPronostico.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App Guiu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NavigationWrapper(),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const PantallaPronostico(),
      const HomeContent(),
      const AjustesScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.access_time_filled, color: Colors.black),
          Icon(Icons.sunny_snowing, color: Colors.black),
          Icon(Icons.settings, color: Colors.black),
        ],
        inactiveIcons: const [
          Text("Pronóstico"),
          Text("Tiempo"),
          Text("Ajustes"),
        ],
        color: Colors.white,
        circleColor: Colors.white,
        height: 70,
        circleWidth: 60,
        activeIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
        shadowColor: Colors.yellowAccent,
        circleShadowColor: Colors.yellowAccent,
        elevation: 10,
        gradient: const LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.lightBlueAccent],
        ),
        circleGradient: const LinearGradient(
          colors: [Colors.yellowAccent, Colors.orangeAccent],
        ),
      ),
    );
  }
}