import 'package:flutter/material.dart';
import '../models/zone_routine.dart';
import '../screens/zone_schedule_editor.dart';
import '../services/esp_service.dart';

  late EspService esp;

class ZoneOverviewScreen extends StatefulWidget {
  const ZoneOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ZoneOverviewScreen> createState() => _ZoneOverviewScreenState();
}

class _ZoneOverviewScreenState extends State<ZoneOverviewScreen> {
  late Future<List<ZoneRoutine>> _zoneRoutines;

  @override
  void initState() {
    super.initState();
    _zoneRoutines = esp.getRoutinesFromPico();
  }

  void _editRoutine(ZoneRoutine routine, {bool fromPico = true}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneScheduleEditor(
          initialRoutine: routine,
          isFromPico: fromPico,
          onSave: (updated) async {
            final success = await esp.sendZoneRoutines([updated]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? 'Routine gespeichert.' : 'Fehler beim Speichern.')),
            );
            setState(() => _zoneRoutines = esp.getRoutinesFromPico());
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
          title: Text('Neue Routine erstellen'),
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
              child: Text('Erstellen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abbrechen'),
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
        title: Text('Zonenübersicht'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Neue Routine',
            onPressed: _createNewRoutine,
          ),
        ],
      ),
      body: FutureBuilder<List<ZoneRoutine>>(
        future: _zoneRoutines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Keine Routinen gefunden.'));
          }

          final routines = snapshot.data!;

          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Card(
                color: Colors.red[100],
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Zone ${routine.zone}'),
                  subtitle: Text('${routine.weeklySchedule.length} Tage geplant'),
                  trailing: Icon(Icons.edit),
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
