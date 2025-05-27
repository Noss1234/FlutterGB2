import 'package:shared_preferences/shared_preferences.dart';
import 'pico_service.dart'; // Renamed import

late PicoService pico; // Renamed esp to pico, EspService to PicoService

Future<void> initializePicoService() async { // Renamed initializeEspService to initializePicoService
  final prefs = await SharedPreferences.getInstance();
  prefs.getString('pico_ip') ?? '192.168.1.123'; // esp_ip to pico_ip
  pico = PicoService(); // esp to pico, EspService to PicoService
}
