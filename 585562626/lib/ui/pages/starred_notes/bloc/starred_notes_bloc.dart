import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/category.dart';
import '../../../../models/note.dart';
import '../../../../repository/note_repository.dart';
import 'starred_notes_event.dart';
import 'starred_notes_state.dart';

class StarredNotesBloc extends Bloc<StarredNotesEvent, StarredNotesState> {
  final NoteRepository noteRepository;
  final Category category;

  StarredNotesBloc(
    StarredNotesState initialState, {
    required this.noteRepository,
    required this.category,
  }) : super(initialState);

  @override
  Stream<StarredNotesState> mapEventToState(StarredNotesEvent event) async* {
    if (event is FetchStarredNotesEvent) {
      yield const FetchingStarredNotesState();
      yield await _fetchStarredNotes();
    } else if (event is DeleteFromStarredNotesEvent) {
      final currentState = state as FetchedStarredNotesState;
      await noteRepository.switchStar([event.note]);
      final list = List<Note>.from(currentState.notes);
      list.remove(event.note);
      yield FetchedStarredNotesState(list, switchedStar: true);
    }
  }

  Future<StarredNotesState> _fetchStarredNotes({bool switchedStar = false}) async {
    final notes = await noteRepository.fetchStarredNotes(category);
    return FetchedStarredNotesState(notes, switchedStar: switchedStar);
  }
}
