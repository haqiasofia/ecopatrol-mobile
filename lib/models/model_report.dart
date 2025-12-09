class ReportModel {
  int? id;
  String title;
  String description;
  String photoPath;
  double latitude;
  double longitude;
  String status;
  String createdAt;

  ReportModel({
    this.id,
    required this.title,
    required this.description,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    this.status = "pending",
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "photoPath": photoPath,
      "latitude": latitude,
      "longitude": longitude,
      "status": status,
      "createdAt": createdAt,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map["id"],
      title: map["title"],
      description: map["description"],
      photoPath: map["photoPath"],
      latitude: map["latitude"],
      longitude: map["longitude"],
      status: map["status"],
      createdAt: map["createdAt"],
    );
  }
}
