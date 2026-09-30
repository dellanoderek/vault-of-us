import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// --- Tabelas Mês 1-2: Cofre ---

class MediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hash => text()();
  IntColumn get albumId => integer().nullable().references(Albums, #id)();
  TextColumn get filePath => text()();
  TextColumn get thumbPath => text()();
  TextColumn get previewPath => text()();
  TextColumn get mediaType => text()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  BoolColumn get localOnly => boolean().withDefault(const Constant(true))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  TextColumn get encryptionIv => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  IntColumn get exifLevel => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class AppStateTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schemaVersion => integer()();
  TextColumn get masterKeyEncrypted => text()();
  TextColumn get pairedPartnerId => text().nullable()();
  BoolColumn get onboardingComplete => boolean()();

  @override
  String get tableName => 'app_state';
}

// --- Tabelas Mês 3: Feed e Organização ---

class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get postType => text()();
  TextColumn get contentEncrypted => text().nullable()();
  IntColumn get mediaId => integer().nullable().references(MediaItems, #id)();
  DateTimeColumn get postDate => dateTime()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Comments extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text().references(Posts, #id)();
  TextColumn get contentEncrypted => text()();
  TextColumn get authorId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get itemNameEncrypted => text()();
  BoolColumn get isBought => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get titleEncrypted => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SpecialDates extends Table {
  TextColumn get id => text()();
  TextColumn get titleEncrypted => text()();
  DateTimeColumn get eventDate => dateTime()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- Tabelas Mês 5: Chat ---

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get contentEncrypted => text()();
  TextColumn get messageType => text()();
  TextColumn get senderId => text()();
  BoolColumn get isTemporary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get sentAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  MediaItems,
  Albums,
  AppStateTable,
  Posts,
  Comments,
  ShoppingItems,
  Goals,
  SpecialDates,
  Messages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      // Criar índices obrigatórios
      await customStatement('CREATE INDEX IF NOT EXISTS idx_media_taken_at ON media_items(taken_at)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_media_album_id ON media_items(album_id)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_media_type ON media_items(media_type)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_media_favorite ON media_items(favorite)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_media_deleted_at ON media_items(deleted_at)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_media_hash ON media_items(hash)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_media_imported_at ON media_items(imported_at)');
    },
    onUpgrade: (migrator, from, to) async {
      // Lógica de migração entre versões futuras
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'vault_of_us', 'encrypted', 'db.sqlite'));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return NativeDatabase.createInBackground(file);
  });
}
