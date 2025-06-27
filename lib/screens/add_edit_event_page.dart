import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class AddEditEventPage extends StatefulWidget {
  final Event? event;

  const AddEditEventPage({Key? key, this.event}) : super(key: key);

  @override
  State<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _hostController;
  late TextEditingController _notesController;

  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title);
    _descriptionController = TextEditingController(text: event?.description);
    _dateController = TextEditingController(text: event?.date);
    _timeController = TextEditingController(text: event?.time);
    _locationController = TextEditingController(text: event?.location);
    _hostController = TextEditingController(text: event?.hostName);
    _notesController = TextEditingController(text: event?.notes);
    _latitude = event?.latitude ?? 0.0;
    _longitude = event?.longitude ?? 0.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _hostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        id: widget.event?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        time: _timeController.text,
        location: _locationController.text,
        hostName: _hostController.text,
        notes: _notesController.text,
        latitude: _latitude,
        longitude: _longitude,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      if (widget.event == null) {
        provider.addEvent(newEvent);
      } else {
        provider.updateEvent(newEvent);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Tambah Acara' : 'Edit Acara'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul Acara'),
                  validator: (value) =>
                      value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Tanggal'),
                ),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Waktu'),
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(labelText: 'Nama Tuan Rumah'),
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _saveEvent,
                  child: const Text('Simpan'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}