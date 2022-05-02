import 'package:get/get.dart';
import 'package:orient_task/common/file_helper.dart';
import 'package:orient_task/model/reports.model.dart';
import 'package:orient_task/view/dashboard.view.dart';
import 'dart:io';

class DashboardController extends GetxController {
  List<ReportsModel> reportsData = [];
  Format? selectedFormat;
  bool? isPdf;
  String? csv;
  Directory? directory;
  List<Format> formats = [
    Format(formatType: "PDF", isPdf: true),
    Format(formatType: "CSV", isPdf: false)
  ];
  @override
  void onInit() async {
    super.onInit();

    await getReports();
  }

  getReports() async {
    var dataJson = await FileHelper.readDataFrom("data/reports_data.json");
    for (var report in dataJson) {
      ReportsModel reports = ReportsModel.fromJson(report);
      reportsData.add(reports);
    }
    update();
  }
}
