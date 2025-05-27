// providers/plant_provider.dart
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/pico_service.dart'; // Ensure this import is correct

class PlantProvider with ChangeNotifier {
  List<Plant> _plants = [];

  List<Plant> get plants => _plants;

  Future<void> fetchPlants() async {
    try {
      _plants = await PicoService.getPlantsFromPico(); // Changed EspService.getPlantsFromESP to PicoService.getPlantsFromPico
      notifyListeners();
    } catch (e) {
      debugPrint('Fehler beim Laden der Pflanzen: $e');
    }
  }

  void addPlant(Plant plant) {
    _plants.add(plant);
    notifyListeners();
    // Hier ggf. auch an ESP senden
  }

  void updatePlant(Plant updatedPlant) {
    final index = _plants.indexWhere((p) => p.id == updatedPlant.id);
    if (index >= 0) {
      _plants[index] = updatedPlant;
      notifyListeners();
      // Optional: update to ESP
    }
  }

  void removePlant(String id) {
    _plants.removeWhere((p) => p.id == id);
    notifyListeners();
    // Optional: remove from ESP
  }

Plant? getPlantById(String id) {
  try {
    return _plants.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
}
