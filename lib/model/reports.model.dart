class ReportsModel {
  List<Reports>? reports;
  List<Highlights>? highlights;

  ReportsModel({this.reports, this.highlights});

  ReportsModel.fromJson(Map<String, dynamic> json) {
    reports = json["reports"] == null
        ? null
        : (json["reports"] as List).map((e) => Reports.fromJson(e)).toList();
    highlights = json["highlights"] == null
        ? null
        : (json["highlights"] as List)
            .map((e) => Highlights.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (reports != null) {
      data["reports"] = reports?.map((e) => e.toJson()).toList();
    }
    if (highlights != null) {
      data["highlights"] = highlights?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Highlights {
  String? title;
  int? data;

  Highlights({this.title, this.data});

  Highlights.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    data = json["data"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    data["data"] = data;
    return data;
  }
}

class Reports {
  String? title;
  List<Data>? data;

  Reports({this.title, this.data});

  Reports.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    data = json["data"] == null
        ? null
        : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    data["data"] = this.data?.map((e) => e.toJson()).toList();

    return data;
  }
}

class Data {
  String? heading;
  int? value;

  Data({this.heading, this.value});

  Data.fromJson(Map<String, dynamic> json) {
    heading = json["heading"];
    value = json["value"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["heading"] = heading;
    data["value"] = value;
    return data;
  }
}
