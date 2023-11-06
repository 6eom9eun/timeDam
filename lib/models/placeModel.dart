class VisitedPlaceModel {
  final String name;

  VisitedPlaceModel({required this.name});

  factory VisitedPlaceModel.fromJson(Map<String, dynamic> json) {
    return VisitedPlaceModel(
      name: json['place_name'] as String,
    );
  }

  // Convert a VisitedPlaceModel instance to a map
  Map<String, dynamic> toJson() {
    return {
      'place_name': name,
    };
  }
}