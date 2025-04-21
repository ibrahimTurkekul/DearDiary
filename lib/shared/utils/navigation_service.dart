import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToAddEntry({DateTime? date}) {
   // Eğer tarih verilmemişse, bugünün tarihini kullan
     final now = DateTime.now();
     final selectedDate = DateTime(
       date?.year ?? now.year,
       date?.month ?? now.month,
       date?.day ?? now.day,
       now.hour,
       now.minute,
     );
  return navigateTo('/addEntry', arguments: {'date': selectedDate});
  }
  
  Future<dynamic> navigateToPreview(int index) => navigateTo('/preview', arguments: {'initialIndex': index});
  
  Future<dynamic> navigateToCalendar() => navigateTo('/calendar'); // CalendarPage için eklenen kod
  Future<dynamic> navigateToSearch() => navigateTo('/search'); // SearchPage için eklenen kod
  

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}