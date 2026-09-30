import 'package:drift/drift.dart' as drift;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/database/app_database.dart';

class SyncService {
  final SupabaseClient supabase;
  final AppDatabase db;
  final String currentUserId;

  SyncService(this.supabase, this.db, this.currentUserId);

  /// Sincronização E2E (Camada 5).
  /// O Supabase NUNCA recebe texto, imagens ou legendas em claro.
  Future<void> syncUp() async {
    final localPosts = await db.select(db.posts).get();
    for (final post in localPosts) {
      final payload = {
        'id': post.id,
        'post_type': post.postType,
        'content_encrypted': post.contentEncrypted,
        'media_id': post.mediaId,
        'post_date': post.postDate.toIso8601String(),
        'updated_at': post.updatedAt.toIso8601String(),
      };
      await supabase.from('posts').upsert(payload, onConflict: 'id');
    }
  }

  Future<void> syncDown() async {
    final lastSync = await _getLastSyncDate();
    final remotePosts = await supabase
        .from('posts')
        .select()
        .gte('updated_at', lastSync.toIso8601String());

    for (final remote in remotePosts) {
      final existing = await (db.select(db.posts)
            ..where((t) => t.id.equals(remote['id'] as String)))
          .getSingleOrNull();

      final remoteDate = DateTime.parse(remote['updated_at'] as String);

      if (existing == null || remoteDate.isAfter(existing.updatedAt)) {
        await db.into(db.posts).insertOnConflictUpdate(
              PostsCompanion(
                id: drift.Value(remote['id'] as String),
                postType: drift.Value(remote['post_type'] as String),
                contentEncrypted: drift.Value(remote['content_encrypted'] as String?),
                postDate: drift.Value(DateTime.parse(remote['post_date'] as String)),
                updatedAt: drift.Value(remoteDate),
              ),
            );
      }
    }
    await _setLastSyncDate(DateTime.now());
  }

  Future<DateTime> _getLastSyncDate() async {
    // TODO: Ler do SharedPreferences ou SecureStorage
    return DateTime(2000);
  }

  Future<void> _setLastSyncDate(DateTime date) async {
    // TODO: Salvar no SharedPreferences ou SecureStorage
  }
}
