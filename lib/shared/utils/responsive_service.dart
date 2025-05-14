import 'package:flutter/material.dart';

class ResponsiveService {
  final BuildContext context;

  ResponsiveService(this.context);

  /// Ekran genişliğini döndürür
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Ekran yüksekliğini döndürür
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Responsive bir genişlik döndür (ekran genişliğine göre)
  double widthPercent(double percent) {
    return screenWidth * (percent / 100);
  }

  /// Responsive bir yükseklik döndür (ekran yüksekliğine göre)
  double heightPercent(double percent) {
    return screenHeight * (percent / 100);
  }

  /// Cihazın ekran oranını döndürür
  double get aspectRatio => screenWidth / screenHeight;

  /// Cihazın ekran türünü döndürür (mobil, tablet vb.)
  bool get isTablet => screenWidth > 600;
}