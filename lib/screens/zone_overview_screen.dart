import 'package:flutter/material.dart';
import '../models/zone_routine.dart';
import '../models/zone_shedule_editor.dart'; // Corrected import path
import '../services/pico_service.dart'; // Renamed import

  late PicoService pico; // Renamed esp to pico, EspService to PicoService

class ZoneOverviewScreen extends StatefulWidget {
  const ZoneOverviewScreen({super.key}); // Used super parameter

  @override
  State<ZoneOverviewScreen> createState() => _ZoneOverviewScreenState();
}

class _ZoneOverviewScreenState extends State<ZoneOverviewScreen> {
  late Future<List<ZoneRoutine>> _zoneRoutines;

  @override
  void initState() {
    super.initState();
    _zoneRoutines = pico.getRoutinesFromPico(); // esp to pico
  }

  void _editRoutine(ZoneRoutine routine, {bool fromPico = true}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneScheduleEditor(
          initialRoutine: routine,
          isFromPico: fromPico,
          onSave: (updated) async {
            final success = await pico.sendZoneRoutines([updated]); // esp to pico
            if (!mounted) return; // Added mounted check
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? 'Routine gespeichert.' : 'Fehler beim Speichern.')),
            );
            setState(() => _zoneRoutines = pico.getRoutinesFromPico()); // esp to pico
          },
        ),
      ),
    );
  }

  void _createNewRoutine() async {
    await showDialog(
      context: context,
      builder: (context) {
        int selectedZone = 0;
        return AlertDialog(
          title: const Text('Neue Routine erstellen'), // Added const
          content: DropdownButton<int>(
            value: selectedZone,
            onChanged: (val) {
              if (val != null) selectedZone = val;
            },
            items: List.generate(8, (index) => DropdownMenuItem(
              value: index,
              child: Text('Zone $index'),
            )),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editRoutine(ZoneRoutine(zone: selectedZone, weeklySchedule: {}), fromPico: false);
              },
              child: const Text('Erstellen'), // Added const
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'), // Added const
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zonenübersicht'), // Added const
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Added const
            tooltip: 'Neue Routine',
            onPressed: _createNewRoutine,
          ),
        ],
      ),
      body: FutureBuilder<List<ZoneRoutine>>(
        future: _zoneRoutines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Added const
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Routinen gefunden.')); // Added const
          }

          final routines = snapshot.data!;

          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Card(
                color: Colors.red[100],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Added const
                child: ListTile(
                  title: Text('Zone ${routine.zone}'),
                  subtitle: Text('${routine.weeklySchedule.length} Tage geplant'),
                  trailing: const Icon(Icons.edit), // Added const
                  onTap: () => _editRoutine(routine),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
