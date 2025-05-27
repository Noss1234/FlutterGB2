import 'package:shared_preferences/shared_preferences.dart';
import 'esp_service.dart';

late EspService esp;

Future<void> initializeEspService() async {
  final prefs = await SharedPreferences.getInstance();
  final ip = prefs.getString('esp_ip') ?? '192.168.1.123';
  esp = EspService('http://$ip');
}
