import 'dart:math';

import 'package:flutter/material.dart';
import '../models/event.dart';
import '../styles/gradients.dart';
import '../widgets/event_type_grid.dart';

class EditEventPage extends StatefulWidget {
  final Event event;
  final Function(Event) onSave;

  const EditEventPage({Key? key, required this.event, required this.onSave})
      : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController _descriptionController;
  late TextEditingController maxParticipantsController;
  late String _typeController;
  late DateTime _dateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.event.name);
    locationController = TextEditingController(text: widget.event.location);
    _typeController = widget.event.type;
    _dateController = widget.event.startDate;
    maxParticipantsController = widget.event.maxParticipants != -1 ?
      TextEditingController(text: widget.event.maxParticipants.toString()) :
      TextEditingController(text: "");
  }

  // to dałoby się zrobić jako fun(context, controller)
  Future<void> _openTypeSelector(BuildContext context) async {
    final selectedType = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return EventTypeGrid(
          onEventTypeSelected: (String eventType) {
            Navigator.pop(context, eventType);
          },
        );
      },
    );

    if (selectedType != null) {
      setState(() {
        _typeController = selectedType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edytuj wydarzenie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nazwa wydarzenia'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Lokalizacja'),
            ),
            TextButton(
              onPressed: () => _openTypeSelector(context),
              child: Text(
                'Zmień typ wydarzenia: ${_typeController}'
              ),
            ),
            TextButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dateController,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if(pickedDate != null) {
                  setState(() {
                    _dateController = pickedDate;
                  });
                }
              },
              child: Text(
                'Zmień datę wydarzenia: ${_dateController.day}.${_dateController.month}.${_dateController.year}.'
              ),
            ),
            TextField(
                controller: maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Maksymalna liczba uczestników'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // zapis danych
                _saveChanges(
                  context,
                  nameController.text,
                  locationController.text,
                  _descriptionController.text,
                  _typeController,
                  _dateController,
                  int.tryParse(maxParticipantsController.text) ?? -1,
                  );
              },
              child: const Text('Zapisz zmiany'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context, String name, String location, String description, String type, DateTime date, int maxParticipants) {
    //TODO: połączenie się z bazą danych

    final updatedEvent = Event(
      id: widget.event.id, //id pozostaje bez zmian
      name: name,
      location: location,
      description: description,
      type: type,
      startDate: date,
      maxParticipants: maxParticipants,
      registeredParticipants: widget.event.registeredParticipants,
      imagePath: widget.event.imagePath, //?TODO: zmiana obrazu?
      //nazwa organizatora
    );

    widget.onSave(updatedEvent);

    Navigator.pop(context); // Powrót do poprzedniej strony po zapisaniu
  }
}