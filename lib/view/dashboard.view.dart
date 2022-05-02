import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:orient_task/common/common_ui.dart';
import 'package:orient_task/common/responsive.controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:orient_task/controller/dashboard.controller.dart';
import 'package:orient_task/model/reports.model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Format {
  String? formatType;
  bool? isPdf;
  Format({this.formatType, this.isPdf});
}

class Dashboard extends StatelessWidget {
  Dashboard({Key? key}) : super(key: key);
  final DashboardController dashboardController =
      Get.put(DashboardController());
  final ResponsiveController responsiveController =
      Get.put(ResponsiveController());

  final pdf = pw.Document();
  Future<bool> getDirectoryMobile() async {
    try {
      final status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
      } else if (status == PermissionStatus.denied) {
        showToast("Permission Denied", isError: true);
      } else if (status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      dashboardController.directory = Directory('/storage/emulated/0/Download');
      if (!await dashboardController.directory!.exists()) {
        dashboardController.directory = (await getExternalStorageDirectory())!;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? Colors.red : Colors.blue,
        textColor: Colors.white,
        webBgColor: isError ? "880808" : "2196F3",
        fontSize: 16.0);
  }

  genratePdf() async {
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        build: (pw.Context context) {
          return [
            pw.Text("Reports",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 32)),
            pw.SizedBox(height: 16),
            reportGridPdf(),
            pw.SizedBox(height: 20),
            highlightListPdf()
          ];
        } // Page
        ));
  }

  genrateCsv() async {
    List<List<dynamic>> rows = <List<dynamic>>[];
    rows.add(['Reports', '\n', '\n']);
    for (int j = 0;
        j < dashboardController.reportsData[0].reports!.length;
        j++) {
      rows.add(['\n']);
      rows.add([dashboardController.reportsData[0].reports![j].title]);
      for (int i = 0;
          i < dashboardController.reportsData[0].reports![j].data!.length;
          i++) {
        List<dynamic> row = [];
        row.add(
            dashboardController.reportsData[0].reports![0].data![i].heading);
        row.add(dashboardController.reportsData[0].reports![0].data![i].value);

        rows.add(row);
      }
    }
    rows.add(['\n', '\n']);
    for (int i = 0;
        i < dashboardController.reportsData[0].highlights!.length;
        i++) {
      List<dynamic> row = [];

      row.add(dashboardController.reportsData[0].highlights![i].title);
      row.add(dashboardController.reportsData[0].highlights![i].data);

      rows.add(row);
    }
    dashboardController.csv = const ListToCsvConverter().convert(rows);
  }

  Future<bool> downloadPdfMobile() async {
    try {
      File file = File("${dashboardController.directory!.path}/reports.pdf");
      await file.writeAsBytes(await pdf.save());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadPdfWeb() async {
    try {
      final content = base64Encode(await pdf.save());
      final url =
          "data:application/octet-stream;charset=utf-16le;base64," + content;

      await launchUrl(
        Uri.parse(url),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadCsvMobile() async {
    try {
      File file = File("${dashboardController.directory!.path}/reports.csv");
      await file.writeAsString(dashboardController.csv!);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadCsvWeb() async {
    try {
      var csvContent = "data:text/csv;charset=utf-8,%EF%BB%BF" +
          Uri.encodeFull(dashboardController.csv!);

      await launchUrl(
        Uri.parse(csvContent),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  doc(bool isPdf, BuildContext context) async {
    if (isPdf) {
      genratePdf();
      if (kIsWeb) {
        downloadPdfWeb().then((isSuccess) {
          Navigator.pop(context);
          if (isSuccess) {
            showToast("PDF Downloaded");
          } else {
            showToast("Something went wrong", isError: true);
          }
        });
      } else {
        await getDirectoryMobile()
            .then((value) => downloadPdfMobile().then((isSuccess) {
                  Navigator.pop(context);
                  if (isSuccess) {
                    showToast("PDF Downloaded");
                  } else {
                    showToast("Something went wrong", isError: true);
                  }
                }));
      }
    } else {
      genrateCsv();
      if (kIsWeb) {
        downloadCsvWeb().then((isSuccess) {
          Navigator.pop(context);
          if (isSuccess) {
            showToast("CSV Downloaded");
          } else {
            showToast("Something went wrong", isError: true);
          }
        });
      } else {
        await getDirectoryMobile()
            .then((value) => downloadCsvMobile().then((isSuccess) {
                  Navigator.pop(context);
                  if (isSuccess) {
                    showToast("CSV Downloaded");
                  } else {
                    showToast("Something went wrong", isError: true);
                  }
                }));
      }
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dc) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Reports",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28)),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130,
                              child: DropdownButtonFormField<Format>(
                                value: dc.selectedFormat,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                // isExpanded: false,
                                hint: const Text("Select Format"),
                                onChanged: (val) {
                                  dc.selectedFormat = val;
                                  dc.isPdf = val!.isPdf;
                                  dc.update();
                                },
                                validator: (value) =>
                                    value == null ? 'Format required' : null,
                                items: dc.formats.map((Format value) {
                                  return DropdownMenuItem<Format>(
                                    value: value,
                                    child: Text(value.formatType!),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            dc.selectedFormat == null
                                                ? Colors.grey
                                                : Colors.blue)),
                                onPressed: () {
                                  var isValid =
                                      _formKey.currentState!.validate();
                                  if (isValid) {
                                    CommonUi().loadingDialog(context);
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      doc(dc.isPdf!, context);
                                    });
                                  }
                                },
                                child: const Text("Download Reports")),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  dc.reportsData.isNotEmpty
                      ? responsiveController.isMobile(context)
                          ? Column(
                              children: [
                                highlightList(context),
                                reportGrid(context),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: responsiveController.isTablet(context)
                                      ? 3
                                      : 2,
                                  child: reportGrid(context),
                                ),
                                Expanded(
                                  flex: responsiveController.isTablet(context)
                                      ? 2
                                      : 1,
                                  child: highlightList(context),
                                )
                              ],
                            )
                      : const Offstage(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  reportCard(Reports report, int count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 4,
            ),
            Text(report.title!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(report.data![0].value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(report.data![0].heading!,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  flex: count > 2 ? 1 : 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(report.data![1].value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(report.data![1].heading!,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                count > 2
                    ? Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(report.data![2].value.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(report.data![2].heading!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    : const Offstage(),
              ],
            )
          ],
        ),
      ),
    );
  }

  highlightCard(Highlights highlight) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(highlight.title!,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(highlight.data.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  reportGrid(BuildContext context) {
    return Padding(
      padding: responsiveController.isMobile(context)
          ? const EdgeInsets.all(8)
          : const EdgeInsets.only(right: 10),
      child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dashboardController.reportsData[0].reports!.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsiveController.isMobile(context)
                ? 1
                : responsiveController.isTablet(context)
                    ? 2
                    : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 140,
          ),
          itemBuilder: (context, index) {
            return reportCard(
                dashboardController.reportsData[0].reports![index],
                dashboardController
                    .reportsData[0].reports![index].data!.length);
          }),
    );
  }

  highlightList(BuildContext context) {
    return Padding(
      padding: responsiveController.isMobile(context)
          ? const EdgeInsets.all(8)
          : const EdgeInsets.only(right: 10),
      child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return highlightCard(
                      dashboardController.reportsData[0].highlights![index]);
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount:
                    dashboardController.reportsData[0].highlights!.length),
          )),
    );
  }

  pw.Widget reportGridPdf() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 10),
      child: pw.GridView(
        crossAxisCount: 2,
        childAspectRatio: 3 / 8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(
            dashboardController.reportsData[0].reports!.length, (index) {
          return reportCardPdf(
              dashboardController.reportsData[0].reports![index],
              dashboardController.reportsData[0].reports![index].data!.length);
        }),
      ),
    );
  }

  pw.Widget reportCardPdf(Reports report, int count) {
    return pw.Container(
      decoration: pw.BoxDecoration(
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(),
          color: const PdfColor.fromInt(0xffffffff),
          boxShadow: const [
            pw.BoxShadow(
              offset: PdfPoint.zero,
              blurRadius: 12,
              color: PdfColor.fromInt(0xff808080),
            )
          ]),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(16.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            pw.SizedBox(
              height: 4,
            ),
            pw.Text(report.title!,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.SizedBox(
              height: 10,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(report.data![0].value.toString(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(
                        height: 8,
                      ),
                      pw.Text(report.data![0].heading!,
                          style: const pw.TextStyle(
                              color: PdfColor.fromInt(0xff808080),
                              fontSize: 12)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: count > 2 ? 1 : 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(report.data![1].value.toString(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(
                        height: 8,
                      ),
                      pw.Text(report.data![1].heading!,
                          style: const pw.TextStyle(
                              color: PdfColor.fromInt(0xff808080),
                              fontSize: 12)),
                    ],
                  ),
                ),
                count > 2
                    ? pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(report.data![2].value.toString(),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(
                              height: 8,
                            ),
                            pw.Text(report.data![2].heading!,
                                style: const pw.TextStyle(
                                    color: PdfColor.fromInt(0xff808080),
                                    fontSize: 12)),
                          ],
                        ),
                      )
                    : pw.SizedBox.shrink(),
              ],
            )
          ],
        ),
      ),
    );
  }

  pw.Widget highlightListPdf() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 10),
      child: pw.Container(
          decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(),
              color: const PdfColor.fromInt(0xffffffff),
              boxShadow: const [
                pw.BoxShadow(
                  offset: PdfPoint.zero,
                  blurRadius: 12,
                  color: PdfColor.fromInt(0xff808080),
                )
              ]),
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(16.0),
            child: pw.ListView.separated(
                itemBuilder: (context, index) {
                  return highlightCardPdf(
                      dashboardController.reportsData[0].highlights![index]);
                },
                separatorBuilder: (context, i) => pw.Divider(),
                itemCount:
                    dashboardController.reportsData[0].highlights!.length),
          )),
    );
  }

  pw.Widget highlightCardPdf(Highlights highlight) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(highlight.title!,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(highlight.data.toString(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
        ],
      ),
    );
  }
}
