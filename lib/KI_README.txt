### 🧠 KI_README.txt

#### 🔧 Struktur & Architektur

- Die App kommuniziert über HTTP mit einem ESP32 (oder Raspberry Pi Pico W) zur Steuerung von Bewässerungszonen.
- Die Kommunikation erfolgt über eine zentrale Instanz der Klasse `EspService`, die in der Datei `esp_initializer.dart` als `late EspService esp` global bereitgestellt wird.

#### 🔄 Initialisierung

- Beim Starten der App wird die IP des ESP-Geräts aus den `SharedPreferences` gelesen.
- Die Methode `initializeEspService()` setzt basierend auf dieser IP die globale `esp`-Instanz.
- Diese Methode muss in `main.dart` vor dem `runApp()` ausgeführt werden:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeEspService(); // Initialisiert 'esp'
  runApp(const MyGardenApp());
}
```

#### 🧪 Zugriff auf ESP-Service

- Jeder Zugriff auf den ESP erfolgt über den globalen `esp`:

```dart
import '../services/esp_initializer.dart';

// Beispiel:
await esp.getStatus();
await esp.sendData(...);
```

#### 📁 Dateisystem-Erweiterungen

- **Neu hinzugekommen:**

  **`lib/services/esp_initializer.dart`**

  Enthält:

  ```dart
  import 'package:shared_preferences/shared_preferences.dart';
  import 'esp_service.dart';

  late EspService esp;

  Future<void> initializeEspService() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('esp_ip') ?? '192.168.1.123';
    esp = EspService('http://$ip');
  }
  ```

#### 🧰 Debugging-Hinweise (basierend auf Dart Analyzer-Fehlern)

- **`initializeEspService` not found** → Stelle sicher, dass `esp_initializer.dart` korrekt importiert ist:  
  `import 'package:your_project/services/esp_initializer.dart';`

- **Fehlende `SharedPreferences`** → Importiere `package:shared_preferences/shared_preferences.dart`.

- **`intl` nicht gefunden** → Füge `intl` in `pubspec.yaml` hinzu:
  ```yaml
  dependencies:
    intl: ^0.18.0
  ```

- **"Too many positional arguments" beim `EspService(...)`**  
  → Konstruktor anpassen oder `EspService`-Instanziierung prüfen.

- **`getJson()` nicht gefunden** → Die Methode existiert nicht mehr. Verwende direkt `http.get(...)` oder `esp.get(...)`.

- **Doppelte Methode `getRoutinesFromPico`**  
  → Entferne eine der beiden Definitionen in `esp_service.dart`.

- **Undefined `baseUrl`** → Verwende `esp.baseUrl`, oder passe Methoden entsprechend an.

#### ❗ Hinweise

- Entferne alle individuellen Instanzen wie `final EspService esp = ...` aus anderen Dateien.
- `SharedPreferences` kann über das `SettingsScreen` UI angepasst werden.
- Alle ESP-Endpunkte sollten dynamisch über die `esp.baseUrl` angesprochen werden.

#### 📦 ToDos

- Weitere Validierung der IP-Adresse im UI (z. B. Regex auf korrektes IPv4-Format).
- Automatischer Verbindungscheck nach Speichern neuer IP.


--------------------------
📘 ERWEITERUNG: Globale ESP-Instanz & Fehlerbehandlung
--------------------------

✅ Globale Verwendung des ESP-Service:
Statt EspService mehrfach mit fixer IP zu erstellen, wird nun beim Start des Programms dynamisch die IP geladen:

1. In `esp_initializer.dart`:
```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../services/esp_service.dart';

late EspService esp;

Future<void> initializeEspService() async {
  final prefs = await SharedPreferences.getInstance();
  final ip = prefs.getString('esp_ip') ?? '192.168.1.123';
  esp = EspService('http://$ip');
}
```

2. In `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeEspService(); // WICHTIG!
  runApp(MyApp());
}
```

3. Danach überall verwendbar via:
```dart
await esp.getXyz(); // z. B. Routinen oder Steuerung
```

--------------------------
🐞 Typische Fehler & Debug-Tipps
--------------------------

❗ Fehler: `The function 'initializeEspService' isn't defined.`
➡ Importiere `esp_initializer.dart`:  
```dart
import 'services/esp_initializer.dart';
```

❗ Fehler: `Too many positional arguments: 0 expected, but 1 found.`  
➡ Du hast `EspService(...)` direkt im Code verwendet. Verwende stattdessen:
```dart
late EspService esp; // global
```
und initialisiere ihn über `initializeEspService()` wie oben beschrieben.

❗ Fehler: `The method 'getJson' isn't defined for the type 'EspService'.`  
➡ Wahrscheinlich veralteter Code. Verwende `http.get(Uri.parse(...))` oder eigene Methode wie `esp.getData()`.

❗ Fehler: `Target of URI doesn't exist: 'package:intl/intl.dart'`  
➡ Füge `intl:` in deiner `pubspec.yaml` hinzu:
```yaml
dependencies:
  intl: ^0.18.0
```

--------------------------
🛠️ Best Practices
--------------------------
- Immer prüfen, ob alle `import`-Anweisungen korrekt sind.
- Bei neuen Methoden oder Klassen: Projekt einmal neustarten (`flutter clean`, `flutter pub get`).
- Verwende `if (mounted)` bei `setState()` nach `await`, um BuildContext-Warnungen zu vermeiden.
- Bei Änderungen an globalen Instanzen (wie esp): Neuladen oder Reinitialisierung bedenken.

