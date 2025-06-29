import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../utils/db_helper.dart';

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

  File? _imageFile;
  String? _imageUrl;

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
    _imageUrl = event?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      _dateController.text = pickedDate.toIso8601String().split('T')[0];
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      _timeController.text = pickedTime.format(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 75);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageUrl = picked.path; // Simpan path lokal
      });
    }
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
        imageUrl: _imageUrl,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      if (widget.event == null) {
        provider.addEvent(newEvent);
      } else {
        provider.updateEvent(newEvent);
      }
      imageCache.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.event == null
                ? 'Acara berhasil ditambahkan'
                : 'Acara berhasil diperbarui',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah Anda yakin ingin menghapus acara ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ya'),
              ),
            ],
          ),
    );

    if (confirm == true && widget.event != null) {
      await DBHelper.instance.deleteEvent(widget.event!.id!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Acara berhasil dihapus')));
      Navigator.pop(context);
    }
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        validator:
            isRequired
                ? (value) =>
                    value == null || value.isEmpty ? '$label wajib diisi' : null
                : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Tambah Acara' : 'Edit Acara'),
        backgroundColor: const Color(0xFFFFC100),
        actions:
            widget.event != null
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteEvent,
                  ),
                ]
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (ctx) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Ambil Foto'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Pilih dari Galeri'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                    );
                  },
                  child:
                      _imageUrl != null
                          ? Image.file(
                            File(_imageUrl!),
                            height: 180,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.add_a_photo, size: 50),
                            ),
                          ),
                ),
                const SizedBox(height: 16),
                _buildInputField(_titleController, 'Judul Acara'),
                _buildInputField(_descriptionController, 'Deskripsi'),
                _buildInputField(
                  _dateController,
                  'Tanggal',
                  readOnly: true,
                  onTap: _pickDate,
                ),
                _buildInputField(
                  _timeController,
                  'Waktu',
                  readOnly: true,
                  onTap: _pickTime,
                ),
                _buildInputField(_locationController, 'Lokasi'),
                _buildInputField(_hostController, 'Nama Tuan Rumah'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC100),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveEvent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
