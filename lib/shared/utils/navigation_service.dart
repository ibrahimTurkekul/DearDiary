import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }
  Future<dynamic> navigateToAddEntry() => navigateTo('/addEntry');
  Future<dynamic> navigateToPreview(int index) => navigateTo('/preview', arguments: {'initialIndex': index});

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}