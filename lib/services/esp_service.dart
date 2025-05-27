import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart'; // Assuming Plant model is one level up, in models/
import 'package:flutter/foundation.dart';
import '../models/zone_routine.dart';
// import '../models/routine_time.dart'; // Removed unused import

class EspService {
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('esp_ip') ?? '192.168.4.1';
    return 'http://$ip';
  }

  static Future<List<Plant>> getPlantsFromESP() async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/routines');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Plant.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Laden der Pflanzen vom ESP');
    }
  }

  static Future<void> startManualWatering(int kanal, int wassermenge) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/start_manual');
    final body = jsonEncode({
      'kanal': kanal,
      'wassermenge': wassermenge,
    });
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Start der manuellen Bewässerung fehlgeschlagen');
    }
  }

  static Future<Map<String, dynamic>> getStatus() async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/current_routine');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Status konnte nicht vom ESP geladen werden');
    }
  }

  static Future<Map<String, dynamic>> getWaterUsage() async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/water_usage');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Wasserverbrauch konnte nicht geladen werden');
    }
  }

  static Future<int> getPulseCount() async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/pulse_count');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // response.body from http.get is a non-nullable String.
      // An empty body is represented by an empty string.
      if (response.body.trim().isNotEmpty) {
        return int.parse(response.body.trim());
      } else {
        throw Exception('Leere Antwort vom Impulszähler');
      }
    } else {
      throw Exception('Fehler beim Abrufen des Impulszählers. Status: ${response.statusCode}');
    }
  }

  static Future<void> resetWaterUsage() async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/reset_water_usage');
    final response = await http.post(url); // Assuming no body is needed

    if (response.statusCode != 200) {
      throw Exception('Zurücksetzen des Wasserverbrauchs fehlgeschlagen');
    }
  }

  static Future<bool> ping() async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/status'); // Using /status as per current known state
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      debugPrint('📡 PING: $url → Status ${response.statusCode}');
      debugPrint('📦 Response: ${response.body}');
      return response.statusCode == 200;
    } catch (e, stacktrace) {
      debugPrint('❌ Ping fehlgeschlagen: $e');
      debugPrint('📛 Stacktrace: $stacktrace');
      return false;
    }
  }

  static Future<void> stopManualWatering(int kanal) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/stop_manual');
    final body = jsonEncode({'kanal': kanal});
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Stoppen der manuellen Bewässerung für Kanal $kanal fehlgeschlagen. Status: ${response.statusCode}');
    }
  }

  static Future<void> receiveRoutines(List<Map<String, dynamic>> routinesData) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/receive_routines');
    final body = jsonEncode(routinesData);
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Senden der Routinen fehlgeschlagen. Status: ${response.statusCode}');
    }
  }


Future<List<ZoneRoutine>> getRoutinesFromPico() async {
    final baseUrl = await EspService.getBaseUrl(); // Added baseUrl
    final uri = Uri.parse('$baseUrl/routines');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final Map<int, List<Map<String, dynamic>>> grouped = {};
        for (var item in data) {
          int zone = item['kanal'];
          grouped.putIfAbsent(zone, () => []);
          grouped[zone]!.add(Map<String, dynamic>.from(item));
        }

        return grouped.entries
            .map((e) => ZoneRoutine.fromJsonList(e.value, e.key))
            .toList();
      } else {
        throw Exception('Fehler beim Laden der Routinen: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HTTP-Fehler: $e'); // Replaced print with debugPrint
      return [];
    }
  }

  Future<bool> sendZoneRoutines(List<ZoneRoutine> routines) async {
    final baseUrl = await EspService.getBaseUrl(); // Added baseUrl
    final uri = Uri.parse('$baseUrl/receive_routines');

    final List<Map<String, dynamic>> jsonList =
        routines.expand((r) => r.toJsonList()).toList();

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonList),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Fehler beim Senden: ${response.statusCode}'); // Replaced print with debugPrint
        return false;
      }
    } catch (e) {
      debugPrint('HTTP-Fehler: $e'); // Replaced print with debugPrint
      return false;
    }
  }


}
