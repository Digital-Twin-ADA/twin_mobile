import 'package:flutter/material.dart';

import '../../shared/models/navigation_item.dart';

final List<NavigationItem> navigationItems = [
  const NavigationItem(icon: Icons.home_filled, label: 'Home', route: '/home'),
  const NavigationItem(icon: Icons.telegram, label: 'Test Page', route: '/test'),
];