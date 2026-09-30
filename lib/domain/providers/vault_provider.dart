import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

class VaultState {
  final List<MediaItem> mediaList;
  final List<Album> albums;
  final bool isLoading;

  const VaultState({
    this.mediaList = const [],
    this.albums = const [],
    this.isLoading = true,
  });

  VaultState copyWith({
    List<MediaItem>? mediaList,
    List<Album>? albums,
    bool? isLoading,
  }) {
    return VaultState(
      mediaList: mediaList ?? this.mediaList,
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VaultNotifier extends StateNotifier<VaultState> {
  final AppDatabase _db;
  final Ref _ref;

  VaultNotifier(this._db, this._ref) : super(const VaultState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    final mode = _ref.read(authProvider).mode;
    final isSecretMode = mode == AppMode.secret;

    // Filtra por modo (normal vs secreto) e exclui itens na lixeira
    final media = await (_db.select(_db.mediaItems)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.importedAt)]))
        .get();

    final albumList = await (_db.select(_db.albums)
          ..where((t) => t.isSecret.equals(isSecretMode)))
        .get();

    state = VaultState(
      mediaList: media,
      albums: albumList,
      isLoading: false,
    );
  }

  Future<void> toggleFavorite(int mediaId) async {
    final item = await (_db.select(_db.mediaItems)
          ..where((t) => t.id.equals(mediaId)))
        .getSingle();

    await (_db.update(_db.mediaItems)..where((t) => t.id.equals(mediaId)))
        .write(MediaItemsCompanion(
      favorite: Value(!item.favorite),
      updatedAt: Value(DateTime.now()),
    ));
    await loadData();
  }

  Future<void> moveToTrash(int mediaId) async {
    await (_db.update(_db.mediaItems)..where((t) => t.id.equals(mediaId)))
        .write(MediaItemsCompanion(
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
    await loadData();
  }

  Future<void> createAlbum(String name, {bool isSecret = false}) async {
    await _db.into(_db.albums).insert(AlbumsCompanion.insert(
          name: name,
          isSecret: Value(isSecret),
          createdAt: DateTime.now(),
        ));
    await loadData();
  }

  /// Purge automático: deleta permanentemente itens na lixeira há mais de 30 dias
  Future<void> purgeOldTrash() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await (_db.delete(_db.mediaItems)
          ..where(
              (t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(thirtyDaysAgo)))
        .go();
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>(
  (ref) {
    final db = ref.read(databaseProvider);
    return VaultNotifier(db, ref);
  },
);
