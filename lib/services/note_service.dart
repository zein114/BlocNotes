import 'package:flutter/foundation.dart';
import '../models/note.dart';

enum SortOption { dateDesc, dateAsc, titleAsc, titleDesc }

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateDesc;

  // Accesseurs
  List<Note> get notes {
    var filteredNotes = _notes;

    // 1. Filtrage par recherche
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredNotes = filteredNotes.where((note) {
        return note.titre.toLowerCase().contains(query) ||
            note.contenu.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Tri
    switch (_sortOption) {
      case SortOption.dateDesc:
        filteredNotes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case SortOption.dateAsc:
        filteredNotes.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case SortOption.titleAsc:
        filteredNotes.sort((a, b) => a.titre.compareTo(b.titre));
        break;
      case SortOption.titleDesc:
        filteredNotes.sort((a, b) => b.titre.compareTo(a.titre));
        break;
    }

    return List.unmodifiable(filteredNotes);
  }

  int get count => _notes.length;

  // Actions
  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  SortOption get currentSortOption => _sortOption;
}
