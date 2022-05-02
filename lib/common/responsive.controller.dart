import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveController extends GetxController {
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 790;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 760;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
  final double itemHeight = (Get.size.height - kToolbarHeight - 24);
  final double itemWidth = Get.size.width / 2;
}
