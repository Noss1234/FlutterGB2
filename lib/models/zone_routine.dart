import 'routine_time.dart';

enum DuengenFrequenz {
  beiJederBewasserung,
  einmalWoechentlich,
  manuell
}

/// Diese Klasse repräsentiert die geplante Bewässerung für eine Zone inklusive Düngestrategie.
class ZoneRoutine {
  final int zone;
  final Map<int, List<RoutineTime>> weeklySchedule;
  final Map<String, int> wasserMengeProZeitpunkt; // Key = "tag-hour-minute"
  final Map<String, int> duengenProZeitpunkt; // Optional, falls differenziert nötig

  /// Diese Einstellung sollte in der UI über ein Dropdown mit Icons angeboten werden.
  final DuengenFrequenz duengenFrequenz;

  /// Optionaler eindeutiger Zeitpunkt für Düngung, z. B. "1-7-15" = Montag 07:15
  final String? duengenZeitpunktKey;

  ZoneRoutine({
    required this.zone,
    required this.weeklySchedule,
    Map<String, int>? wasserMengeProZeitpunkt,
    Map<String, int>? duengenProZeitpunkt,
    this.duengenFrequenz = DuengenFrequenz.beiJederBewasserung,
    this.duengenZeitpunktKey,
  })  : wasserMengeProZeitpunkt = wasserMengeProZeitpunkt ?? {},
        duengenProZeitpunkt = duengenProZeitpunkt ?? {};

  factory ZoneRoutine.fromJsonList(List<dynamic> jsonList, int zone) {
    Map<int, List<RoutineTime>> schedule = {};
    Map<String, int> mengen = {};
    Map<String, int> duengen = {};

    for (var item in jsonList) {
      if (item['kanal'] == zone) {
        int tag = item['tag'];
        int stunde = item['stunde'];
        int minute = item['minute'];
        int menge = item['wassermenge'] ?? 400;
        int dung = item['duengen'] ?? 0;

        schedule.putIfAbsent(tag, () => []);
        schedule[tag]!.add(RoutineTime(hour: stunde, minute: minute));

        final key = '$tag-$stunde-$minute';
        mengen[key] = menge;
        duengen[key] = dung;
      }
    }

    return ZoneRoutine(
      zone: zone,
      weeklySchedule: schedule,
      wasserMengeProZeitpunkt: mengen,
      duengenProZeitpunkt: duengen,
    );
  }

  List<Map<String, dynamic>> toJsonList() {
    List<Map<String, dynamic>> list = [];
    weeklySchedule.forEach((tag, times) {
      for (var time in times) {
        final key = '$tag-${time.hour}-${time.minute}';

        bool duengenAktiv = false;
        if (duengenFrequenz == DuengenFrequenz.beiJederBewasserung) {
          duengenAktiv = true;
        } else if (duengenFrequenz == DuengenFrequenz.einmalWoechentlich) {
          // Automatischer Vorschlag: Falls kein expliziter Zeitpunkt gesetzt ist, verwende den ersten der Woche
          final vorgeschlagen = duengenZeitpunktKey ?? _findErstenZeitpunktKey();
          if (key == vorgeschlagen) {
            duengenAktiv = true;
          }
        }

        list.add({
          'kanal': zone,
          'tag': tag,
          'stunde': time.hour,
          'minute': time.minute,
          'wassermenge': wasserMengeProZeitpunkt[key] ?? 400,
          'duengen': duengenAktiv ? 1 : 0,
          'isEnabled': true,
        });
      }
    });
    return list;
  }

  /// Findet den frühesten geplanten Zeitpunkt (nach Wochentag und Uhrzeit sortiert)
  String? _findErstenZeitpunktKey() {
    final sortierteKeys = weeklySchedule.entries
        .expand((e) => e.value.map((time) => MapEntry(e.key, time)))
        .toList()
      ..sort((a, b) {
        int cmpTag = a.key.compareTo(b.key);
        if (cmpTag != 0) return cmpTag;
        return a.value.hour * 60 + a.value.minute - (b.value.hour * 60 + b.value.minute);
      });

    if (sortierteKeys.isEmpty) return null;
    final first = sortierteKeys.first;
    return '${first.key}-${first.value.hour}-${first.value.minute}';
  }
}
