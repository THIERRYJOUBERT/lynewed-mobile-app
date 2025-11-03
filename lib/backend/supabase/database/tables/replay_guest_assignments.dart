import '../database.dart';

class ReplayGuestAssignmentsTable
    extends SupabaseTable<ReplayGuestAssignmentsRow> {
  @override
  String get tableName => 'replay_guest_assignments';

  @override
  ReplayGuestAssignmentsRow createRow(Map<String, dynamic> data) =>
      ReplayGuestAssignmentsRow(data);
}

class ReplayGuestAssignmentsRow extends SupabaseDataRow {
  ReplayGuestAssignmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReplayGuestAssignmentsTable();

  String get replayId => getField<String>('replay_id')!;
  set replayId(String value) => setField<String>('replay_id', value);

  String get guestId => getField<String>('guest_id')!;
  set guestId(String value) => setField<String>('guest_id', value);
}
