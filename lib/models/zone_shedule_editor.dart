import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine_time.dart';
import '../models/zone_routine.dart';
import '../services/pico_service.dart'; // Renamed import

  late PicoService pico; // Renamed esp to pico, EspService to PicoService

class ZoneScheduleEditor extends StatefulWidget {
  final ZoneRoutine initialRoutine;
  final bool isFromPico;
  final Function(ZoneRoutine) onSave;

  const ZoneScheduleEditor({
    super.key,
    required this.initialRoutine,
    required this.onSave,
    this.isFromPico = false,
  });

  @override
  State<ZoneScheduleEditor> createState() => _ZoneScheduleEditorState();
}

class _ZoneScheduleEditorState extends State<ZoneScheduleEditor> {
  late Map<int, List<RoutineTime>> _schedule;
  late Map<String, int> _mengen;
  late DuengenFrequenz _duengenFrequenz;
  late String? _duengenZeitpunkt;
  int _selectedDay = DateTime.monday;

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.initialRoutine.weeklySchedule);
    _mengen = Map.from(widget.initialRoutine.wasserMengeProZeitpunkt);
    _duengenFrequenz = widget.initialRoutine.duengenFrequenz;
    _duengenZeitpunkt = widget.initialRoutine.duengenZeitpunktKey;
  }

  void _addTime(TimeOfDay time) {
    setState(() {
      _schedule.putIfAbsent(_selectedDay, () => []);
      final newEntry = RoutineTime(hour: time.hour, minute: time.minute);
      _schedule[_selectedDay]!.add(newEntry);
      _mengen['$_selectedDay-${time.hour}-${time.minute}'] = 400;
    });
  }

  void _removeTime(int day, RoutineTime time) {
    setState(() {
      _schedule[day]?.remove(time);
      _mengen.remove('$day-${time.hour}-${time.minute}');
      if (_schedule[day]?.isEmpty ?? true) _schedule.remove(day);
    });
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      _addTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.isFromPico ? Colors.red[100] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('Zone ${widget.initialRoutine.zone} Zeitplan'),
        actions: [
          if (widget.isFromPico)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () async {
                final routines = await pico.getRoutinesFromPico(); // esp to pico
                final matching = routines.firstWhere(
                  (r) => r.zone == widget.initialRoutine.zone,
                  orElse: () => ZoneRoutine(zone: widget.initialRoutine.zone, weeklySchedule: {}),
                );
                setState(() {
                  _schedule = Map.from(matching.weeklySchedule);
                });
              },
              tooltip: 'Von Gerät neu laden',
            ),
        ],
      ),
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( // const Column(
          children: [
            DropdownButton<int>(
              value: _selectedDay,
              items: List.generate(7, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(DateFormat.EEEE().format(DateTime(2020, 1, index + 6))),
                );
              }),
              onChanged: (val) => setState(() => _selectedDay = val!),
            ),
            ElevatedButton(
              onPressed: _pickTime,
              child: const Text('Zeit hinzufügen'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row( // const Row(
                children: [
                  const Text("Düngung: ", style: TextStyle(fontWeight: FontWeight.w600)), // const Text
                  DropdownButton<DuengenFrequenz>(
                    value: _duengenFrequenz,
                    onChanged: (val) => setState(() => _duengenFrequenz = val!),
                    items: DuengenFrequenz.values.map((val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(val.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: _schedule.entries.expand((entry) {
                  return entry.value.map((time) {
                    final key = '${entry.key}-${time.hour}-${time.minute}';
                    final isDuengenZeit = _duengenFrequenz == DuengenFrequenz.einmalWoechentlich && _duengenZeitpunkt == key;
                    return ListTile(
                      title: Text(
                        '${DateFormat.EEEE().format(DateTime(2020, 1, entry.key + 5))} - ${time.format()}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Menge: '),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(text: _mengen[key]?.toString() ?? '400'),
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val);
                                    if (parsed != null) {
                                      _mengen[key] = parsed;
                                    }
                                  },
                                  decoration: const InputDecoration(hintText: 'ml'),
                                ),
                              ),
                            ],
                          ),
                          if (_duengenFrequenz == DuengenFrequenz.einmalWoechentlich)
                            Row( // const Row(
                              children: [
                                Checkbox(
                                  value: isDuengenZeit,
                                  onChanged: (value) {
                                    if (value == true) {
                                      setState(() => _duengenZeitpunkt = key);
                                    } else if (isDuengenZeit) {
                                      setState(() => _duengenZeitpunkt = null);
                                    }
                                  },
                                ),
                                const Text('Düngen einmal wöchentlich hier') // const Text
                              ],
                            )
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTime(entry.key, time),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_schedule.isEmpty || _schedule.values.every((list) => list.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bitte mindestens einen Zeitplanpunkt hinzufügen.')), // const SnackBar
                  );
                  return;
                }

                if (_duengenFrequenz == DuengenFrequenz.einmalWoechentlich && (_duengenZeitpunkt == null || !_mengen.containsKey(_duengenZeitpunkt!))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bitte wähle einen Düngungszeitpunkt für "einmal wöchentlich" aus.')), // const SnackBar
                  );
                  return;
                }

                widget.onSave(ZoneRoutine(
                  zone: widget.initialRoutine.zone,
                  weeklySchedule: _schedule,
                  wasserMengeProZeitpunkt: _mengen,
                  duengenFrequenz: _duengenFrequenz,
                  duengenZeitpunktKey: _duengenZeitpunkt,
                ));
                Navigator.pop(context);
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> initializePicoService() async { // Renamed initializeEspService
  final prefs = await SharedPreferences.getInstance();
  prefs.getString('pico_ip') ?? '192.168.1.123'; // esp_ip to pico_ip
  pico = PicoService(); // esp to pico, EspService to PicoService
}
}
