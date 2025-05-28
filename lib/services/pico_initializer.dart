// import 'package:shared_preferences/shared_preferences.dart'; // Removed unused import
import 'pico_service.dart'; // Renamed import

late PicoService pico; // Renamed esp to pico, EspService to PicoService

Future<void> initializePicoService() async { // Renamed initializeEspService to initializePicoService
  // SharedPreferences logic removed as pico_ip is no longer used by PicoService.getBaseUrl
  pico = PicoService(); // esp to pico, EspService to PicoService
}
