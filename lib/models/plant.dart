// models/plant.dart

class Plant {
  final String id;
  final String name;
  final String category;      // z. B. "Gemüse", "Zierpflanze", "Kräuter"
  final double idealPH;       // Optimaler pH-Wert
  final int waterNeed;        // Wasserbedarf in ml pro Tag
  final String imagePath;     // Lokaler Pfad zur Bilddatei
  final String description;   // Kurze Beschreibung
  final String zone;          // Zugeordnete Zone im Garten

  Plant({
    required this.id,
    required this.name,
    required this.category,
    required this.idealPH,
    required this.waterNeed,
    required this.imagePath,
    required this.description,
    required this.zone,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      idealPH: (json['idealPH'] as num).toDouble(),
      waterNeed: json['waterNeed'],
      imagePath: json['imagePath'] ?? '', // fallback falls nicht vorhanden
      description: json['description'],
      zone: json['zone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'idealPH': idealPH,
      'waterNeed': waterNeed,
      'imagePath': imagePath,
      'description': description,
      'zone': zone,
    };
  }
}
