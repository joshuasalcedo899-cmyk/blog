import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> deleteById({
    required String table,
    required String id,
  }) async {
    await supabase
        .from(table)
        .delete()
        .eq('id', id);
  }
}
