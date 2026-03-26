import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/appBarBottom.dart';
// import '../widgets/appBackground.dart';

class LayoutPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const LayoutPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // body: AppBackground(
      //   child: navigationShell,
      // ),
      body: navigationShell,
      bottomNavigationBar: AppBottomBar(navigationShell: navigationShell),
    );
  }
}