import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_service.dart';
import '../models/note.dart';

class CreateNotePage extends StatefulWidget {
  final Note? note;

  const CreateNotePage({super.key, this.note});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedColor = '#FFE082'; // Default color

  final List<String> _colors = [
    '#FFE082', // Amber
    '#FFAB91', // Deep Orange
    '#C5E1A5', // Light Green
    '#81D4FA', // Light Blue
    '#F48FB1', // Pulse
    '#CE93D8', // Purple
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.titre;
      _contentController.text = widget.note!.contenu;
      _selectedColor = widget.note!.couleur;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre ne peut pas être vide')),
      );
      return;
    }

    final newNote = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titre: _titleController.text.trim(),
      contenu: _contentController.text.trim(),
      couleur: _selectedColor,
      dateCreation: widget.note?.dateCreation ?? DateTime.now(),
      dateModification: widget.note != null ? DateTime.now() : null,
    );

    if (widget.note != null) {
      context.read<NoteService>().updateNote(newNote);
    } else {
      context.read<NoteService>().addNote(newNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la Note' : 'Nouvelle Note'),
        actions: [
          IconButton(onPressed: _saveNote, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de la note',
                border: OutlineInputBorder(),
              ),
              maxLength: 60,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Contenu...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: 10,
            ),
            const SizedBox(height: 24),
            const Text(
              'Couleur:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _colors.map((hex) {
                final color = _hexToColor(hex);
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditing ? 'Mettre à jour' : 'Sauvegarder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
