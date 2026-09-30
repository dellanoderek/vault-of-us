// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, Album> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSecretMeta =
      const VerificationMeta('isSecret');
  @override
  late final GeneratedColumn<bool> isSecret = GeneratedColumn<bool>(
      'is_secret', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_secret" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _exifLevelMeta =
      const VerificationMeta('exifLevel');
  @override
  late final GeneratedColumn<int> exifLevel = GeneratedColumn<int>(
      'exif_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, isSecret, exifLevel, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(Insertable<Album> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_secret')) {
      context.handle(_isSecretMeta,
          isSecret.isAcceptableOrUnknown(data['is_secret']!, _isSecretMeta));
    }
    if (data.containsKey('exif_level')) {
      context.handle(_exifLevelMeta,
          exifLevel.isAcceptableOrUnknown(data['exif_level']!, _exifLevelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Album map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Album(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isSecret: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_secret'])!,
      exifLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exif_level'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class Album extends DataClass implements Insertable<Album> {
  final int id;
  final String name;
  final bool isSecret;
  final int exifLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Album(
      {required this.id,
      required this.name,
      required this.isSecret,
      required this.exifLevel,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_secret'] = Variable<bool>(isSecret);
    map['exif_level'] = Variable<int>(exifLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      name: Value(name),
      isSecret: Value(isSecret),
      exifLevel: Value(exifLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Album.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Album(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isSecret: serializer.fromJson<bool>(json['isSecret']),
      exifLevel: serializer.fromJson<int>(json['exifLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isSecret': serializer.toJson<bool>(isSecret),
      'exifLevel': serializer.toJson<int>(exifLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Album copyWith(
          {int? id,
          String? name,
          bool? isSecret,
          int? exifLevel,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Album(
        id: id ?? this.id,
        name: name ?? this.name,
        isSecret: isSecret ?? this.isSecret,
        exifLevel: exifLevel ?? this.exifLevel,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Album copyWithCompanion(AlbumsCompanion data) {
    return Album(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isSecret: data.isSecret.present ? data.isSecret.value : this.isSecret,
      exifLevel: data.exifLevel.present ? data.exifLevel.value : this.exifLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Album(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSecret: $isSecret, ')
          ..write('exifLevel: $exifLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isSecret, exifLevel, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Album &&
          other.id == this.id &&
          other.name == this.name &&
          other.isSecret == this.isSecret &&
          other.exifLevel == this.exifLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isSecret;
  final Value<int> exifLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isSecret = const Value.absent(),
    this.exifLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AlbumsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isSecret = const Value.absent(),
    this.exifLevel = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Album> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isSecret,
    Expression<int>? exifLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isSecret != null) 'is_secret': isSecret,
      if (exifLevel != null) 'exif_level': exifLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AlbumsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<bool>? isSecret,
      Value<int>? exifLevel,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return AlbumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isSecret: isSecret ?? this.isSecret,
      exifLevel: exifLevel ?? this.exifLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isSecret.present) {
      map['is_secret'] = Variable<bool>(isSecret.value);
    }
    if (exifLevel.present) {
      map['exif_level'] = Variable<int>(exifLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSecret: $isSecret, ')
          ..write('exifLevel: $exifLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  @override
  late final GeneratedColumn<int> albumId = GeneratedColumn<int>(
      'album_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES albums (id)'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbPathMeta =
      const VerificationMeta('thumbPath');
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
      'thumb_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previewPathMeta =
      const VerificationMeta('previewPath');
  @override
  late final GeneratedColumn<String> previewPath = GeneratedColumn<String>(
      'preview_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _importedAtMeta =
      const VerificationMeta('importedAt');
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
      'imported_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _localOnlyMeta =
      const VerificationMeta('localOnly');
  @override
  late final GeneratedColumn<bool> localOnly = GeneratedColumn<bool>(
      'local_only', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("local_only" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _favoriteMeta =
      const VerificationMeta('favorite');
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
      'favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _encryptionIvMeta =
      const VerificationMeta('encryptionIv');
  @override
  late final GeneratedColumn<String> encryptionIv = GeneratedColumn<String>(
      'encryption_iv', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        hash,
        albumId,
        filePath,
        thumbPath,
        previewPath,
        mediaType,
        takenAt,
        importedAt,
        localOnly,
        deletedAt,
        favorite,
        encryptionIv,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(Insertable<MediaItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('thumb_path')) {
      context.handle(_thumbPathMeta,
          thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta));
    } else if (isInserting) {
      context.missing(_thumbPathMeta);
    }
    if (data.containsKey('preview_path')) {
      context.handle(
          _previewPathMeta,
          previewPath.isAcceptableOrUnknown(
              data['preview_path']!, _previewPathMeta));
    } else if (isInserting) {
      context.missing(_previewPathMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    }
    if (data.containsKey('imported_at')) {
      context.handle(
          _importedAtMeta,
          importedAt.isAcceptableOrUnknown(
              data['imported_at']!, _importedAtMeta));
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('local_only')) {
      context.handle(_localOnlyMeta,
          localOnly.isAcceptableOrUnknown(data['local_only']!, _localOnlyMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('favorite')) {
      context.handle(_favoriteMeta,
          favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta));
    }
    if (data.containsKey('encryption_iv')) {
      context.handle(
          _encryptionIvMeta,
          encryptionIv.isAcceptableOrUnknown(
              data['encryption_iv']!, _encryptionIvMeta));
    } else if (isInserting) {
      context.missing(_encryptionIvMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}album_id']),
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      thumbPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumb_path'])!,
      previewPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preview_path'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at']),
      importedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}imported_at'])!,
      localOnly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}local_only'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      favorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}favorite'])!,
      encryptionIv: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}encryption_iv'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final int id;
  final String hash;
  final int? albumId;
  final String filePath;
  final String thumbPath;
  final String previewPath;
  final String mediaType;
  final DateTime? takenAt;
  final DateTime importedAt;
  final bool localOnly;
  final DateTime? deletedAt;
  final bool favorite;
  final String encryptionIv;
  final DateTime updatedAt;
  const MediaItem(
      {required this.id,
      required this.hash,
      this.albumId,
      required this.filePath,
      required this.thumbPath,
      required this.previewPath,
      required this.mediaType,
      this.takenAt,
      required this.importedAt,
      required this.localOnly,
      this.deletedAt,
      required this.favorite,
      required this.encryptionIv,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hash'] = Variable<String>(hash);
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<int>(albumId);
    }
    map['file_path'] = Variable<String>(filePath);
    map['thumb_path'] = Variable<String>(thumbPath);
    map['preview_path'] = Variable<String>(previewPath);
    map['media_type'] = Variable<String>(mediaType);
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<DateTime>(takenAt);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['local_only'] = Variable<bool>(localOnly);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['favorite'] = Variable<bool>(favorite);
    map['encryption_iv'] = Variable<String>(encryptionIv);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      hash: Value(hash),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      filePath: Value(filePath),
      thumbPath: Value(thumbPath),
      previewPath: Value(previewPath),
      mediaType: Value(mediaType),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      importedAt: Value(importedAt),
      localOnly: Value(localOnly),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      favorite: Value(favorite),
      encryptionIv: Value(encryptionIv),
      updatedAt: Value(updatedAt),
    );
  }

  factory MediaItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<int>(json['id']),
      hash: serializer.fromJson<String>(json['hash']),
      albumId: serializer.fromJson<int?>(json['albumId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      thumbPath: serializer.fromJson<String>(json['thumbPath']),
      previewPath: serializer.fromJson<String>(json['previewPath']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      takenAt: serializer.fromJson<DateTime?>(json['takenAt']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      localOnly: serializer.fromJson<bool>(json['localOnly']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      encryptionIv: serializer.fromJson<String>(json['encryptionIv']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hash': serializer.toJson<String>(hash),
      'albumId': serializer.toJson<int?>(albumId),
      'filePath': serializer.toJson<String>(filePath),
      'thumbPath': serializer.toJson<String>(thumbPath),
      'previewPath': serializer.toJson<String>(previewPath),
      'mediaType': serializer.toJson<String>(mediaType),
      'takenAt': serializer.toJson<DateTime?>(takenAt),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'localOnly': serializer.toJson<bool>(localOnly),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'favorite': serializer.toJson<bool>(favorite),
      'encryptionIv': serializer.toJson<String>(encryptionIv),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MediaItem copyWith(
          {int? id,
          String? hash,
          Value<int?> albumId = const Value.absent(),
          String? filePath,
          String? thumbPath,
          String? previewPath,
          String? mediaType,
          Value<DateTime?> takenAt = const Value.absent(),
          DateTime? importedAt,
          bool? localOnly,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? favorite,
          String? encryptionIv,
          DateTime? updatedAt}) =>
      MediaItem(
        id: id ?? this.id,
        hash: hash ?? this.hash,
        albumId: albumId.present ? albumId.value : this.albumId,
        filePath: filePath ?? this.filePath,
        thumbPath: thumbPath ?? this.thumbPath,
        previewPath: previewPath ?? this.previewPath,
        mediaType: mediaType ?? this.mediaType,
        takenAt: takenAt.present ? takenAt.value : this.takenAt,
        importedAt: importedAt ?? this.importedAt,
        localOnly: localOnly ?? this.localOnly,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        favorite: favorite ?? this.favorite,
        encryptionIv: encryptionIv ?? this.encryptionIv,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      hash: data.hash.present ? data.hash.value : this.hash,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      previewPath:
          data.previewPath.present ? data.previewPath.value : this.previewPath,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      importedAt:
          data.importedAt.present ? data.importedAt.value : this.importedAt,
      localOnly: data.localOnly.present ? data.localOnly.value : this.localOnly,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      encryptionIv: data.encryptionIv.present
          ? data.encryptionIv.value
          : this.encryptionIv,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('hash: $hash, ')
          ..write('albumId: $albumId, ')
          ..write('filePath: $filePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('previewPath: $previewPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('takenAt: $takenAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('localOnly: $localOnly, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('favorite: $favorite, ')
          ..write('encryptionIv: $encryptionIv, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      hash,
      albumId,
      filePath,
      thumbPath,
      previewPath,
      mediaType,
      takenAt,
      importedAt,
      localOnly,
      deletedAt,
      favorite,
      encryptionIv,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.hash == this.hash &&
          other.albumId == this.albumId &&
          other.filePath == this.filePath &&
          other.thumbPath == this.thumbPath &&
          other.previewPath == this.previewPath &&
          other.mediaType == this.mediaType &&
          other.takenAt == this.takenAt &&
          other.importedAt == this.importedAt &&
          other.localOnly == this.localOnly &&
          other.deletedAt == this.deletedAt &&
          other.favorite == this.favorite &&
          other.encryptionIv == this.encryptionIv &&
          other.updatedAt == this.updatedAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<int> id;
  final Value<String> hash;
  final Value<int?> albumId;
  final Value<String> filePath;
  final Value<String> thumbPath;
  final Value<String> previewPath;
  final Value<String> mediaType;
  final Value<DateTime?> takenAt;
  final Value<DateTime> importedAt;
  final Value<bool> localOnly;
  final Value<DateTime?> deletedAt;
  final Value<bool> favorite;
  final Value<String> encryptionIv;
  final Value<DateTime> updatedAt;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.hash = const Value.absent(),
    this.albumId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.previewPath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.localOnly = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.favorite = const Value.absent(),
    this.encryptionIv = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    this.id = const Value.absent(),
    required String hash,
    this.albumId = const Value.absent(),
    required String filePath,
    required String thumbPath,
    required String previewPath,
    required String mediaType,
    this.takenAt = const Value.absent(),
    required DateTime importedAt,
    this.localOnly = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.favorite = const Value.absent(),
    required String encryptionIv,
    this.updatedAt = const Value.absent(),
  })  : hash = Value(hash),
        filePath = Value(filePath),
        thumbPath = Value(thumbPath),
        previewPath = Value(previewPath),
        mediaType = Value(mediaType),
        importedAt = Value(importedAt),
        encryptionIv = Value(encryptionIv);
  static Insertable<MediaItem> custom({
    Expression<int>? id,
    Expression<String>? hash,
    Expression<int>? albumId,
    Expression<String>? filePath,
    Expression<String>? thumbPath,
    Expression<String>? previewPath,
    Expression<String>? mediaType,
    Expression<DateTime>? takenAt,
    Expression<DateTime>? importedAt,
    Expression<bool>? localOnly,
    Expression<DateTime>? deletedAt,
    Expression<bool>? favorite,
    Expression<String>? encryptionIv,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hash != null) 'hash': hash,
      if (albumId != null) 'album_id': albumId,
      if (filePath != null) 'file_path': filePath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (previewPath != null) 'preview_path': previewPath,
      if (mediaType != null) 'media_type': mediaType,
      if (takenAt != null) 'taken_at': takenAt,
      if (importedAt != null) 'imported_at': importedAt,
      if (localOnly != null) 'local_only': localOnly,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (favorite != null) 'favorite': favorite,
      if (encryptionIv != null) 'encryption_iv': encryptionIv,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MediaItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? hash,
      Value<int?>? albumId,
      Value<String>? filePath,
      Value<String>? thumbPath,
      Value<String>? previewPath,
      Value<String>? mediaType,
      Value<DateTime?>? takenAt,
      Value<DateTime>? importedAt,
      Value<bool>? localOnly,
      Value<DateTime?>? deletedAt,
      Value<bool>? favorite,
      Value<String>? encryptionIv,
      Value<DateTime>? updatedAt}) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      hash: hash ?? this.hash,
      albumId: albumId ?? this.albumId,
      filePath: filePath ?? this.filePath,
      thumbPath: thumbPath ?? this.thumbPath,
      previewPath: previewPath ?? this.previewPath,
      mediaType: mediaType ?? this.mediaType,
      takenAt: takenAt ?? this.takenAt,
      importedAt: importedAt ?? this.importedAt,
      localOnly: localOnly ?? this.localOnly,
      deletedAt: deletedAt ?? this.deletedAt,
      favorite: favorite ?? this.favorite,
      encryptionIv: encryptionIv ?? this.encryptionIv,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (previewPath.present) {
      map['preview_path'] = Variable<String>(previewPath.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (localOnly.present) {
      map['local_only'] = Variable<bool>(localOnly.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (encryptionIv.present) {
      map['encryption_iv'] = Variable<String>(encryptionIv.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('hash: $hash, ')
          ..write('albumId: $albumId, ')
          ..write('filePath: $filePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('previewPath: $previewPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('takenAt: $takenAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('localOnly: $localOnly, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('favorite: $favorite, ')
          ..write('encryptionIv: $encryptionIv, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppStateTableTable extends AppStateTable
    with TableInfo<$AppStateTableTable, AppStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _masterKeyEncryptedMeta =
      const VerificationMeta('masterKeyEncrypted');
  @override
  late final GeneratedColumn<String> masterKeyEncrypted =
      GeneratedColumn<String>('master_key_encrypted', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pairedPartnerIdMeta =
      const VerificationMeta('pairedPartnerId');
  @override
  late final GeneratedColumn<String> pairedPartnerId = GeneratedColumn<String>(
      'paired_partner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
      'onboarding_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_complete" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schemaVersion,
        masterKeyEncrypted,
        pairedPartnerId,
        onboardingComplete
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_state';
  @override
  VerificationContext validateIntegrity(Insertable<AppStateTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('master_key_encrypted')) {
      context.handle(
          _masterKeyEncryptedMeta,
          masterKeyEncrypted.isAcceptableOrUnknown(
              data['master_key_encrypted']!, _masterKeyEncryptedMeta));
    } else if (isInserting) {
      context.missing(_masterKeyEncryptedMeta);
    }
    if (data.containsKey('paired_partner_id')) {
      context.handle(
          _pairedPartnerIdMeta,
          pairedPartnerId.isAcceptableOrUnknown(
              data['paired_partner_id']!, _pairedPartnerIdMeta));
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
          _onboardingCompleteMeta,
          onboardingComplete.isAcceptableOrUnknown(
              data['onboarding_complete']!, _onboardingCompleteMeta));
    } else if (isInserting) {
      context.missing(_onboardingCompleteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppStateTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
      masterKeyEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}master_key_encrypted'])!,
      pairedPartnerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}paired_partner_id']),
      onboardingComplete: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_complete'])!,
    );
  }

  @override
  $AppStateTableTable createAlias(String alias) {
    return $AppStateTableTable(attachedDatabase, alias);
  }
}

class AppStateTableData extends DataClass
    implements Insertable<AppStateTableData> {
  final int id;
  final int schemaVersion;
  final String masterKeyEncrypted;
  final String? pairedPartnerId;
  final bool onboardingComplete;
  const AppStateTableData(
      {required this.id,
      required this.schemaVersion,
      required this.masterKeyEncrypted,
      this.pairedPartnerId,
      required this.onboardingComplete});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['master_key_encrypted'] = Variable<String>(masterKeyEncrypted);
    if (!nullToAbsent || pairedPartnerId != null) {
      map['paired_partner_id'] = Variable<String>(pairedPartnerId);
    }
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    return map;
  }

  AppStateTableCompanion toCompanion(bool nullToAbsent) {
    return AppStateTableCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      masterKeyEncrypted: Value(masterKeyEncrypted),
      pairedPartnerId: pairedPartnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairedPartnerId),
      onboardingComplete: Value(onboardingComplete),
    );
  }

  factory AppStateTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppStateTableData(
      id: serializer.fromJson<int>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      masterKeyEncrypted:
          serializer.fromJson<String>(json['masterKeyEncrypted']),
      pairedPartnerId: serializer.fromJson<String?>(json['pairedPartnerId']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'masterKeyEncrypted': serializer.toJson<String>(masterKeyEncrypted),
      'pairedPartnerId': serializer.toJson<String?>(pairedPartnerId),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
    };
  }

  AppStateTableData copyWith(
          {int? id,
          int? schemaVersion,
          String? masterKeyEncrypted,
          Value<String?> pairedPartnerId = const Value.absent(),
          bool? onboardingComplete}) =>
      AppStateTableData(
        id: id ?? this.id,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        masterKeyEncrypted: masterKeyEncrypted ?? this.masterKeyEncrypted,
        pairedPartnerId: pairedPartnerId.present
            ? pairedPartnerId.value
            : this.pairedPartnerId,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
  AppStateTableData copyWithCompanion(AppStateTableCompanion data) {
    return AppStateTableData(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      masterKeyEncrypted: data.masterKeyEncrypted.present
          ? data.masterKeyEncrypted.value
          : this.masterKeyEncrypted,
      pairedPartnerId: data.pairedPartnerId.present
          ? data.pairedPartnerId.value
          : this.pairedPartnerId,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppStateTableData(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('masterKeyEncrypted: $masterKeyEncrypted, ')
          ..write('pairedPartnerId: $pairedPartnerId, ')
          ..write('onboardingComplete: $onboardingComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schemaVersion, masterKeyEncrypted,
      pairedPartnerId, onboardingComplete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppStateTableData &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.masterKeyEncrypted == this.masterKeyEncrypted &&
          other.pairedPartnerId == this.pairedPartnerId &&
          other.onboardingComplete == this.onboardingComplete);
}

class AppStateTableCompanion extends UpdateCompanion<AppStateTableData> {
  final Value<int> id;
  final Value<int> schemaVersion;
  final Value<String> masterKeyEncrypted;
  final Value<String?> pairedPartnerId;
  final Value<bool> onboardingComplete;
  const AppStateTableCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.masterKeyEncrypted = const Value.absent(),
    this.pairedPartnerId = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
  });
  AppStateTableCompanion.insert({
    this.id = const Value.absent(),
    required int schemaVersion,
    required String masterKeyEncrypted,
    this.pairedPartnerId = const Value.absent(),
    required bool onboardingComplete,
  })  : schemaVersion = Value(schemaVersion),
        masterKeyEncrypted = Value(masterKeyEncrypted),
        onboardingComplete = Value(onboardingComplete);
  static Insertable<AppStateTableData> custom({
    Expression<int>? id,
    Expression<int>? schemaVersion,
    Expression<String>? masterKeyEncrypted,
    Expression<String>? pairedPartnerId,
    Expression<bool>? onboardingComplete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (masterKeyEncrypted != null)
        'master_key_encrypted': masterKeyEncrypted,
      if (pairedPartnerId != null) 'paired_partner_id': pairedPartnerId,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
    });
  }

  AppStateTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? schemaVersion,
      Value<String>? masterKeyEncrypted,
      Value<String?>? pairedPartnerId,
      Value<bool>? onboardingComplete}) {
    return AppStateTableCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      masterKeyEncrypted: masterKeyEncrypted ?? this.masterKeyEncrypted,
      pairedPartnerId: pairedPartnerId ?? this.pairedPartnerId,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (masterKeyEncrypted.present) {
      map['master_key_encrypted'] = Variable<String>(masterKeyEncrypted.value);
    }
    if (pairedPartnerId.present) {
      map['paired_partner_id'] = Variable<String>(pairedPartnerId.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppStateTableCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('masterKeyEncrypted: $masterKeyEncrypted, ')
          ..write('pairedPartnerId: $pairedPartnerId, ')
          ..write('onboardingComplete: $onboardingComplete')
          ..write(')'))
        .toString();
  }
}

class $PostsTable extends Posts with TableInfo<$PostsTable, Post> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _postTypeMeta =
      const VerificationMeta('postType');
  @override
  late final GeneratedColumn<String> postType = GeneratedColumn<String>(
      'post_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentEncryptedMeta =
      const VerificationMeta('contentEncrypted');
  @override
  late final GeneratedColumn<String> contentEncrypted = GeneratedColumn<String>(
      'content_encrypted', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'media_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES media_items (id)'));
  static const VerificationMeta _postDateMeta =
      const VerificationMeta('postDate');
  @override
  late final GeneratedColumn<DateTime> postDate = GeneratedColumn<DateTime>(
      'post_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSecretMeta =
      const VerificationMeta('isSecret');
  @override
  late final GeneratedColumn<bool> isSecret = GeneratedColumn<bool>(
      'is_secret', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_secret" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, postType, contentEncrypted, mediaId, postDate, isSecret, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(Insertable<Post> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_type')) {
      context.handle(_postTypeMeta,
          postType.isAcceptableOrUnknown(data['post_type']!, _postTypeMeta));
    } else if (isInserting) {
      context.missing(_postTypeMeta);
    }
    if (data.containsKey('content_encrypted')) {
      context.handle(
          _contentEncryptedMeta,
          contentEncrypted.isAcceptableOrUnknown(
              data['content_encrypted']!, _contentEncryptedMeta));
    }
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    }
    if (data.containsKey('post_date')) {
      context.handle(_postDateMeta,
          postDate.isAcceptableOrUnknown(data['post_date']!, _postDateMeta));
    } else if (isInserting) {
      context.missing(_postDateMeta);
    }
    if (data.containsKey('is_secret')) {
      context.handle(_isSecretMeta,
          isSecret.isAcceptableOrUnknown(data['is_secret']!, _isSecretMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Post map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Post(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      postType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post_type'])!,
      contentEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}content_encrypted']),
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}media_id']),
      postDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}post_date'])!,
      isSecret: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_secret'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class Post extends DataClass implements Insertable<Post> {
  final String id;
  final String postType;
  final String? contentEncrypted;
  final int? mediaId;
  final DateTime postDate;
  final bool isSecret;
  final DateTime updatedAt;
  const Post(
      {required this.id,
      required this.postType,
      this.contentEncrypted,
      this.mediaId,
      required this.postDate,
      required this.isSecret,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['post_type'] = Variable<String>(postType);
    if (!nullToAbsent || contentEncrypted != null) {
      map['content_encrypted'] = Variable<String>(contentEncrypted);
    }
    if (!nullToAbsent || mediaId != null) {
      map['media_id'] = Variable<int>(mediaId);
    }
    map['post_date'] = Variable<DateTime>(postDate);
    map['is_secret'] = Variable<bool>(isSecret);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      postType: Value(postType),
      contentEncrypted: contentEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(contentEncrypted),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      postDate: Value(postDate),
      isSecret: Value(isSecret),
      updatedAt: Value(updatedAt),
    );
  }

  factory Post.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
      id: serializer.fromJson<String>(json['id']),
      postType: serializer.fromJson<String>(json['postType']),
      contentEncrypted: serializer.fromJson<String?>(json['contentEncrypted']),
      mediaId: serializer.fromJson<int?>(json['mediaId']),
      postDate: serializer.fromJson<DateTime>(json['postDate']),
      isSecret: serializer.fromJson<bool>(json['isSecret']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postType': serializer.toJson<String>(postType),
      'contentEncrypted': serializer.toJson<String?>(contentEncrypted),
      'mediaId': serializer.toJson<int?>(mediaId),
      'postDate': serializer.toJson<DateTime>(postDate),
      'isSecret': serializer.toJson<bool>(isSecret),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Post copyWith(
          {String? id,
          String? postType,
          Value<String?> contentEncrypted = const Value.absent(),
          Value<int?> mediaId = const Value.absent(),
          DateTime? postDate,
          bool? isSecret,
          DateTime? updatedAt}) =>
      Post(
        id: id ?? this.id,
        postType: postType ?? this.postType,
        contentEncrypted: contentEncrypted.present
            ? contentEncrypted.value
            : this.contentEncrypted,
        mediaId: mediaId.present ? mediaId.value : this.mediaId,
        postDate: postDate ?? this.postDate,
        isSecret: isSecret ?? this.isSecret,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
      id: data.id.present ? data.id.value : this.id,
      postType: data.postType.present ? data.postType.value : this.postType,
      contentEncrypted: data.contentEncrypted.present
          ? data.contentEncrypted.value
          : this.contentEncrypted,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      postDate: data.postDate.present ? data.postDate.value : this.postDate,
      isSecret: data.isSecret.present ? data.isSecret.value : this.isSecret,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Post(')
          ..write('id: $id, ')
          ..write('postType: $postType, ')
          ..write('contentEncrypted: $contentEncrypted, ')
          ..write('mediaId: $mediaId, ')
          ..write('postDate: $postDate, ')
          ..write('isSecret: $isSecret, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, postType, contentEncrypted, mediaId, postDate, isSecret, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          other.id == this.id &&
          other.postType == this.postType &&
          other.contentEncrypted == this.contentEncrypted &&
          other.mediaId == this.mediaId &&
          other.postDate == this.postDate &&
          other.isSecret == this.isSecret &&
          other.updatedAt == this.updatedAt);
}

class PostsCompanion extends UpdateCompanion<Post> {
  final Value<String> id;
  final Value<String> postType;
  final Value<String?> contentEncrypted;
  final Value<int?> mediaId;
  final Value<DateTime> postDate;
  final Value<bool> isSecret;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.postType = const Value.absent(),
    this.contentEncrypted = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.postDate = const Value.absent(),
    this.isSecret = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String id,
    required String postType,
    this.contentEncrypted = const Value.absent(),
    this.mediaId = const Value.absent(),
    required DateTime postDate,
    this.isSecret = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        postType = Value(postType),
        postDate = Value(postDate);
  static Insertable<Post> custom({
    Expression<String>? id,
    Expression<String>? postType,
    Expression<String>? contentEncrypted,
    Expression<int>? mediaId,
    Expression<DateTime>? postDate,
    Expression<bool>? isSecret,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postType != null) 'post_type': postType,
      if (contentEncrypted != null) 'content_encrypted': contentEncrypted,
      if (mediaId != null) 'media_id': mediaId,
      if (postDate != null) 'post_date': postDate,
      if (isSecret != null) 'is_secret': isSecret,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith(
      {Value<String>? id,
      Value<String>? postType,
      Value<String?>? contentEncrypted,
      Value<int?>? mediaId,
      Value<DateTime>? postDate,
      Value<bool>? isSecret,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PostsCompanion(
      id: id ?? this.id,
      postType: postType ?? this.postType,
      contentEncrypted: contentEncrypted ?? this.contentEncrypted,
      mediaId: mediaId ?? this.mediaId,
      postDate: postDate ?? this.postDate,
      isSecret: isSecret ?? this.isSecret,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postType.present) {
      map['post_type'] = Variable<String>(postType.value);
    }
    if (contentEncrypted.present) {
      map['content_encrypted'] = Variable<String>(contentEncrypted.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
    }
    if (postDate.present) {
      map['post_date'] = Variable<DateTime>(postDate.value);
    }
    if (isSecret.present) {
      map['is_secret'] = Variable<bool>(isSecret.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('postType: $postType, ')
          ..write('contentEncrypted: $contentEncrypted, ')
          ..write('mediaId: $mediaId, ')
          ..write('postDate: $postDate, ')
          ..write('isSecret: $isSecret, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentsTable extends Comments with TableInfo<$CommentsTable, Comment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
      'post_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES posts (id)'));
  static const VerificationMeta _contentEncryptedMeta =
      const VerificationMeta('contentEncrypted');
  @override
  late final GeneratedColumn<String> contentEncrypted = GeneratedColumn<String>(
      'content_encrypted', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorIdMeta =
      const VerificationMeta('authorId');
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
      'author_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, postId, contentEncrypted, authorId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comments';
  @override
  VerificationContext validateIntegrity(Insertable<Comment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(_postIdMeta,
          postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta));
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('content_encrypted')) {
      context.handle(
          _contentEncryptedMeta,
          contentEncrypted.isAcceptableOrUnknown(
              data['content_encrypted']!, _contentEncryptedMeta));
    } else if (isInserting) {
      context.missing(_contentEncryptedMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(_authorIdMeta,
          authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta));
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Comment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Comment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      postId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post_id'])!,
      contentEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}content_encrypted'])!,
      authorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CommentsTable createAlias(String alias) {
    return $CommentsTable(attachedDatabase, alias);
  }
}

class Comment extends DataClass implements Insertable<Comment> {
  final String id;
  final String postId;
  final String contentEncrypted;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Comment(
      {required this.id,
      required this.postId,
      required this.contentEncrypted,
      required this.authorId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['post_id'] = Variable<String>(postId);
    map['content_encrypted'] = Variable<String>(contentEncrypted);
    map['author_id'] = Variable<String>(authorId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CommentsCompanion toCompanion(bool nullToAbsent) {
    return CommentsCompanion(
      id: Value(id),
      postId: Value(postId),
      contentEncrypted: Value(contentEncrypted),
      authorId: Value(authorId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Comment(
      id: serializer.fromJson<String>(json['id']),
      postId: serializer.fromJson<String>(json['postId']),
      contentEncrypted: serializer.fromJson<String>(json['contentEncrypted']),
      authorId: serializer.fromJson<String>(json['authorId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postId': serializer.toJson<String>(postId),
      'contentEncrypted': serializer.toJson<String>(contentEncrypted),
      'authorId': serializer.toJson<String>(authorId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Comment copyWith(
          {String? id,
          String? postId,
          String? contentEncrypted,
          String? authorId,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Comment(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        contentEncrypted: contentEncrypted ?? this.contentEncrypted,
        authorId: authorId ?? this.authorId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Comment copyWithCompanion(CommentsCompanion data) {
    return Comment(
      id: data.id.present ? data.id.value : this.id,
      postId: data.postId.present ? data.postId.value : this.postId,
      contentEncrypted: data.contentEncrypted.present
          ? data.contentEncrypted.value
          : this.contentEncrypted,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Comment(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('contentEncrypted: $contentEncrypted, ')
          ..write('authorId: $authorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, postId, contentEncrypted, authorId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Comment &&
          other.id == this.id &&
          other.postId == this.postId &&
          other.contentEncrypted == this.contentEncrypted &&
          other.authorId == this.authorId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CommentsCompanion extends UpdateCompanion<Comment> {
  final Value<String> id;
  final Value<String> postId;
  final Value<String> contentEncrypted;
  final Value<String> authorId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CommentsCompanion({
    this.id = const Value.absent(),
    this.postId = const Value.absent(),
    this.contentEncrypted = const Value.absent(),
    this.authorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentsCompanion.insert({
    required String id,
    required String postId,
    required String contentEncrypted,
    required String authorId,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        postId = Value(postId),
        contentEncrypted = Value(contentEncrypted),
        authorId = Value(authorId),
        createdAt = Value(createdAt);
  static Insertable<Comment> custom({
    Expression<String>? id,
    Expression<String>? postId,
    Expression<String>? contentEncrypted,
    Expression<String>? authorId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postId != null) 'post_id': postId,
      if (contentEncrypted != null) 'content_encrypted': contentEncrypted,
      if (authorId != null) 'author_id': authorId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? postId,
      Value<String>? contentEncrypted,
      Value<String>? authorId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CommentsCompanion(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      contentEncrypted: contentEncrypted ?? this.contentEncrypted,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (contentEncrypted.present) {
      map['content_encrypted'] = Variable<String>(contentEncrypted.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentsCompanion(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('contentEncrypted: $contentEncrypted, ')
          ..write('authorId: $authorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingItemsTable extends ShoppingItems
    with TableInfo<$ShoppingItemsTable, ShoppingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemNameEncryptedMeta =
      const VerificationMeta('itemNameEncrypted');
  @override
  late final GeneratedColumn<String> itemNameEncrypted =
      GeneratedColumn<String>('item_name_encrypted', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isBoughtMeta =
      const VerificationMeta('isBought');
  @override
  late final GeneratedColumn<bool> isBought = GeneratedColumn<bool>(
      'is_bought', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_bought" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, itemNameEncrypted, isBought, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_items';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_name_encrypted')) {
      context.handle(
          _itemNameEncryptedMeta,
          itemNameEncrypted.isAcceptableOrUnknown(
              data['item_name_encrypted']!, _itemNameEncryptedMeta));
    } else if (isInserting) {
      context.missing(_itemNameEncryptedMeta);
    }
    if (data.containsKey('is_bought')) {
      context.handle(_isBoughtMeta,
          isBought.isAcceptableOrUnknown(data['is_bought']!, _isBoughtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemNameEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}item_name_encrypted'])!,
      isBought: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_bought'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ShoppingItemsTable createAlias(String alias) {
    return $ShoppingItemsTable(attachedDatabase, alias);
  }
}

class ShoppingItem extends DataClass implements Insertable<ShoppingItem> {
  final String id;
  final String itemNameEncrypted;
  final bool isBought;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ShoppingItem(
      {required this.id,
      required this.itemNameEncrypted,
      required this.isBought,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_name_encrypted'] = Variable<String>(itemNameEncrypted);
    map['is_bought'] = Variable<bool>(isBought);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingItemsCompanion(
      id: Value(id),
      itemNameEncrypted: Value(itemNameEncrypted),
      isBought: Value(isBought),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItem(
      id: serializer.fromJson<String>(json['id']),
      itemNameEncrypted: serializer.fromJson<String>(json['itemNameEncrypted']),
      isBought: serializer.fromJson<bool>(json['isBought']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemNameEncrypted': serializer.toJson<String>(itemNameEncrypted),
      'isBought': serializer.toJson<bool>(isBought),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShoppingItem copyWith(
          {String? id,
          String? itemNameEncrypted,
          bool? isBought,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ShoppingItem(
        id: id ?? this.id,
        itemNameEncrypted: itemNameEncrypted ?? this.itemNameEncrypted,
        isBought: isBought ?? this.isBought,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ShoppingItem copyWithCompanion(ShoppingItemsCompanion data) {
    return ShoppingItem(
      id: data.id.present ? data.id.value : this.id,
      itemNameEncrypted: data.itemNameEncrypted.present
          ? data.itemNameEncrypted.value
          : this.itemNameEncrypted,
      isBought: data.isBought.present ? data.isBought.value : this.isBought,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItem(')
          ..write('id: $id, ')
          ..write('itemNameEncrypted: $itemNameEncrypted, ')
          ..write('isBought: $isBought, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemNameEncrypted, isBought, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItem &&
          other.id == this.id &&
          other.itemNameEncrypted == this.itemNameEncrypted &&
          other.isBought == this.isBought &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShoppingItemsCompanion extends UpdateCompanion<ShoppingItem> {
  final Value<String> id;
  final Value<String> itemNameEncrypted;
  final Value<bool> isBought;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.itemNameEncrypted = const Value.absent(),
    this.isBought = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingItemsCompanion.insert({
    required String id,
    required String itemNameEncrypted,
    this.isBought = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemNameEncrypted = Value(itemNameEncrypted);
  static Insertable<ShoppingItem> custom({
    Expression<String>? id,
    Expression<String>? itemNameEncrypted,
    Expression<bool>? isBought,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemNameEncrypted != null) 'item_name_encrypted': itemNameEncrypted,
      if (isBought != null) 'is_bought': isBought,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemNameEncrypted,
      Value<bool>? isBought,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ShoppingItemsCompanion(
      id: id ?? this.id,
      itemNameEncrypted: itemNameEncrypted ?? this.itemNameEncrypted,
      isBought: isBought ?? this.isBought,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemNameEncrypted.present) {
      map['item_name_encrypted'] = Variable<String>(itemNameEncrypted.value);
    }
    if (isBought.present) {
      map['is_bought'] = Variable<bool>(isBought.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('itemNameEncrypted: $itemNameEncrypted, ')
          ..write('isBought: $isBought, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleEncryptedMeta =
      const VerificationMeta('titleEncrypted');
  @override
  late final GeneratedColumn<String> titleEncrypted = GeneratedColumn<String>(
      'title_encrypted', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
      'target_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, titleEncrypted, isCompleted, targetDate, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title_encrypted')) {
      context.handle(
          _titleEncryptedMeta,
          titleEncrypted.isAcceptableOrUnknown(
              data['title_encrypted']!, _titleEncryptedMeta));
    } else if (isInserting) {
      context.missing(_titleEncryptedMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      titleEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}title_encrypted'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}target_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String titleEncrypted;
  final bool isCompleted;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Goal(
      {required this.id,
      required this.titleEncrypted,
      required this.isCompleted,
      this.targetDate,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title_encrypted'] = Variable<String>(titleEncrypted);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      titleEncrypted: Value(titleEncrypted),
      isCompleted: Value(isCompleted),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      titleEncrypted: serializer.fromJson<String>(json['titleEncrypted']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'titleEncrypted': serializer.toJson<String>(titleEncrypted),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Goal copyWith(
          {String? id,
          String? titleEncrypted,
          bool? isCompleted,
          Value<DateTime?> targetDate = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Goal(
        id: id ?? this.id,
        titleEncrypted: titleEncrypted ?? this.titleEncrypted,
        isCompleted: isCompleted ?? this.isCompleted,
        targetDate: targetDate.present ? targetDate.value : this.targetDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      titleEncrypted: data.titleEncrypted.present
          ? data.titleEncrypted.value
          : this.titleEncrypted,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('titleEncrypted: $titleEncrypted, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, titleEncrypted, isCompleted, targetDate, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.titleEncrypted == this.titleEncrypted &&
          other.isCompleted == this.isCompleted &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> titleEncrypted;
  final Value<bool> isCompleted;
  final Value<DateTime?> targetDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.titleEncrypted = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String titleEncrypted,
    this.isCompleted = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        titleEncrypted = Value(titleEncrypted);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? titleEncrypted,
    Expression<bool>? isCompleted,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleEncrypted != null) 'title_encrypted': titleEncrypted,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? titleEncrypted,
      Value<bool>? isCompleted,
      Value<DateTime?>? targetDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GoalsCompanion(
      id: id ?? this.id,
      titleEncrypted: titleEncrypted ?? this.titleEncrypted,
      isCompleted: isCompleted ?? this.isCompleted,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (titleEncrypted.present) {
      map['title_encrypted'] = Variable<String>(titleEncrypted.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('titleEncrypted: $titleEncrypted, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpecialDatesTable extends SpecialDates
    with TableInfo<$SpecialDatesTable, SpecialDate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpecialDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleEncryptedMeta =
      const VerificationMeta('titleEncrypted');
  @override
  late final GeneratedColumn<String> titleEncrypted = GeneratedColumn<String>(
      'title_encrypted', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, titleEncrypted, eventDate, isRecurring, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'special_dates';
  @override
  VerificationContext validateIntegrity(Insertable<SpecialDate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title_encrypted')) {
      context.handle(
          _titleEncryptedMeta,
          titleEncrypted.isAcceptableOrUnknown(
              data['title_encrypted']!, _titleEncryptedMeta));
    } else if (isInserting) {
      context.missing(_titleEncryptedMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpecialDate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpecialDate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      titleEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}title_encrypted'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SpecialDatesTable createAlias(String alias) {
    return $SpecialDatesTable(attachedDatabase, alias);
  }
}

class SpecialDate extends DataClass implements Insertable<SpecialDate> {
  final String id;
  final String titleEncrypted;
  final DateTime eventDate;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SpecialDate(
      {required this.id,
      required this.titleEncrypted,
      required this.eventDate,
      required this.isRecurring,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title_encrypted'] = Variable<String>(titleEncrypted);
    map['event_date'] = Variable<DateTime>(eventDate);
    map['is_recurring'] = Variable<bool>(isRecurring);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SpecialDatesCompanion toCompanion(bool nullToAbsent) {
    return SpecialDatesCompanion(
      id: Value(id),
      titleEncrypted: Value(titleEncrypted),
      eventDate: Value(eventDate),
      isRecurring: Value(isRecurring),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SpecialDate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpecialDate(
      id: serializer.fromJson<String>(json['id']),
      titleEncrypted: serializer.fromJson<String>(json['titleEncrypted']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'titleEncrypted': serializer.toJson<String>(titleEncrypted),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SpecialDate copyWith(
          {String? id,
          String? titleEncrypted,
          DateTime? eventDate,
          bool? isRecurring,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SpecialDate(
        id: id ?? this.id,
        titleEncrypted: titleEncrypted ?? this.titleEncrypted,
        eventDate: eventDate ?? this.eventDate,
        isRecurring: isRecurring ?? this.isRecurring,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SpecialDate copyWithCompanion(SpecialDatesCompanion data) {
    return SpecialDate(
      id: data.id.present ? data.id.value : this.id,
      titleEncrypted: data.titleEncrypted.present
          ? data.titleEncrypted.value
          : this.titleEncrypted,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpecialDate(')
          ..write('id: $id, ')
          ..write('titleEncrypted: $titleEncrypted, ')
          ..write('eventDate: $eventDate, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, titleEncrypted, eventDate, isRecurring, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpecialDate &&
          other.id == this.id &&
          other.titleEncrypted == this.titleEncrypted &&
          other.eventDate == this.eventDate &&
          other.isRecurring == this.isRecurring &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SpecialDatesCompanion extends UpdateCompanion<SpecialDate> {
  final Value<String> id;
  final Value<String> titleEncrypted;
  final Value<DateTime> eventDate;
  final Value<bool> isRecurring;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SpecialDatesCompanion({
    this.id = const Value.absent(),
    this.titleEncrypted = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpecialDatesCompanion.insert({
    required String id,
    required String titleEncrypted,
    required DateTime eventDate,
    this.isRecurring = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        titleEncrypted = Value(titleEncrypted),
        eventDate = Value(eventDate);
  static Insertable<SpecialDate> custom({
    Expression<String>? id,
    Expression<String>? titleEncrypted,
    Expression<DateTime>? eventDate,
    Expression<bool>? isRecurring,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleEncrypted != null) 'title_encrypted': titleEncrypted,
      if (eventDate != null) 'event_date': eventDate,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpecialDatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? titleEncrypted,
      Value<DateTime>? eventDate,
      Value<bool>? isRecurring,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SpecialDatesCompanion(
      id: id ?? this.id,
      titleEncrypted: titleEncrypted ?? this.titleEncrypted,
      eventDate: eventDate ?? this.eventDate,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (titleEncrypted.present) {
      map['title_encrypted'] = Variable<String>(titleEncrypted.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpecialDatesCompanion(')
          ..write('id: $id, ')
          ..write('titleEncrypted: $titleEncrypted, ')
          ..write('eventDate: $eventDate, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentEncryptedMeta =
      const VerificationMeta('contentEncrypted');
  @override
  late final GeneratedColumn<String> contentEncrypted = GeneratedColumn<String>(
      'content_encrypted', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isTemporaryMeta =
      const VerificationMeta('isTemporary');
  @override
  late final GeneratedColumn<bool> isTemporary = GeneratedColumn<bool>(
      'is_temporary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_temporary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contentEncrypted,
        messageType,
        senderId,
        isTemporary,
        sentAt,
        readAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_encrypted')) {
      context.handle(
          _contentEncryptedMeta,
          contentEncrypted.isAcceptableOrUnknown(
              data['content_encrypted']!, _contentEncryptedMeta));
    } else if (isInserting) {
      context.missing(_contentEncryptedMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('is_temporary')) {
      context.handle(
          _isTemporaryMeta,
          isTemporary.isAcceptableOrUnknown(
              data['is_temporary']!, _isTemporaryMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      contentEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}content_encrypted'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      isTemporary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_temporary'])!,
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String contentEncrypted;
  final String messageType;
  final String senderId;
  final bool isTemporary;
  final DateTime sentAt;
  final DateTime? readAt;
  final DateTime updatedAt;
  const Message(
      {required this.id,
      required this.contentEncrypted,
      required this.messageType,
      required this.senderId,
      required this.isTemporary,
      required this.sentAt,
      this.readAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content_encrypted'] = Variable<String>(contentEncrypted);
    map['message_type'] = Variable<String>(messageType);
    map['sender_id'] = Variable<String>(senderId);
    map['is_temporary'] = Variable<bool>(isTemporary);
    map['sent_at'] = Variable<DateTime>(sentAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      contentEncrypted: Value(contentEncrypted),
      messageType: Value(messageType),
      senderId: Value(senderId),
      isTemporary: Value(isTemporary),
      sentAt: Value(sentAt),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      contentEncrypted: serializer.fromJson<String>(json['contentEncrypted']),
      messageType: serializer.fromJson<String>(json['messageType']),
      senderId: serializer.fromJson<String>(json['senderId']),
      isTemporary: serializer.fromJson<bool>(json['isTemporary']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentEncrypted': serializer.toJson<String>(contentEncrypted),
      'messageType': serializer.toJson<String>(messageType),
      'senderId': serializer.toJson<String>(senderId),
      'isTemporary': serializer.toJson<bool>(isTemporary),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Message copyWith(
          {String? id,
          String? contentEncrypted,
          String? messageType,
          String? senderId,
          bool? isTemporary,
          DateTime? sentAt,
          Value<DateTime?> readAt = const Value.absent(),
          DateTime? updatedAt}) =>
      Message(
        id: id ?? this.id,
        contentEncrypted: contentEncrypted ?? this.contentEncrypted,
        messageType: messageType ?? this.messageType,
        senderId: senderId ?? this.senderId,
        isTemporary: isTemporary ?? this.isTemporary,
        sentAt: sentAt ?? this.sentAt,
        readAt: readAt.present ? readAt.value : this.readAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      contentEncrypted: data.contentEncrypted.present
          ? data.contentEncrypted.value
          : this.contentEncrypted,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      isTemporary:
          data.isTemporary.present ? data.isTemporary.value : this.isTemporary,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('contentEncrypted: $contentEncrypted, ')
          ..write('messageType: $messageType, ')
          ..write('senderId: $senderId, ')
          ..write('isTemporary: $isTemporary, ')
          ..write('sentAt: $sentAt, ')
          ..write('readAt: $readAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contentEncrypted, messageType, senderId,
      isTemporary, sentAt, readAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.contentEncrypted == this.contentEncrypted &&
          other.messageType == this.messageType &&
          other.senderId == this.senderId &&
          other.isTemporary == this.isTemporary &&
          other.sentAt == this.sentAt &&
          other.readAt == this.readAt &&
          other.updatedAt == this.updatedAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> contentEncrypted;
  final Value<String> messageType;
  final Value<String> senderId;
  final Value<bool> isTemporary;
  final Value<DateTime> sentAt;
  final Value<DateTime?> readAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.contentEncrypted = const Value.absent(),
    this.messageType = const Value.absent(),
    this.senderId = const Value.absent(),
    this.isTemporary = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String contentEncrypted,
    required String messageType,
    required String senderId,
    this.isTemporary = const Value.absent(),
    required DateTime sentAt,
    this.readAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        contentEncrypted = Value(contentEncrypted),
        messageType = Value(messageType),
        senderId = Value(senderId),
        sentAt = Value(sentAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? contentEncrypted,
    Expression<String>? messageType,
    Expression<String>? senderId,
    Expression<bool>? isTemporary,
    Expression<DateTime>? sentAt,
    Expression<DateTime>? readAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentEncrypted != null) 'content_encrypted': contentEncrypted,
      if (messageType != null) 'message_type': messageType,
      if (senderId != null) 'sender_id': senderId,
      if (isTemporary != null) 'is_temporary': isTemporary,
      if (sentAt != null) 'sent_at': sentAt,
      if (readAt != null) 'read_at': readAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? contentEncrypted,
      Value<String>? messageType,
      Value<String>? senderId,
      Value<bool>? isTemporary,
      Value<DateTime>? sentAt,
      Value<DateTime?>? readAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      contentEncrypted: contentEncrypted ?? this.contentEncrypted,
      messageType: messageType ?? this.messageType,
      senderId: senderId ?? this.senderId,
      isTemporary: isTemporary ?? this.isTemporary,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentEncrypted.present) {
      map['content_encrypted'] = Variable<String>(contentEncrypted.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (isTemporary.present) {
      map['is_temporary'] = Variable<bool>(isTemporary.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('contentEncrypted: $contentEncrypted, ')
          ..write('messageType: $messageType, ')
          ..write('senderId: $senderId, ')
          ..write('isTemporary: $isTemporary, ')
          ..write('sentAt: $sentAt, ')
          ..write('readAt: $readAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $AppStateTableTable appStateTable = $AppStateTableTable(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $CommentsTable comments = $CommentsTable(this);
  late final $ShoppingItemsTable shoppingItems = $ShoppingItemsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $SpecialDatesTable specialDates = $SpecialDatesTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        albums,
        mediaItems,
        appStateTable,
        posts,
        comments,
        shoppingItems,
        goals,
        specialDates,
        messages
      ];
}

typedef $$AlbumsTableCreateCompanionBuilder = AlbumsCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> isSecret,
  Value<int> exifLevel,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
});
typedef $$AlbumsTableUpdateCompanionBuilder = AlbumsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> isSecret,
  Value<int> exifLevel,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$AlbumsTableReferences
    extends BaseReferences<_$AppDatabase, $AlbumsTable, Album> {
  $$AlbumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MediaItemsTable, List<MediaItem>>
      _mediaItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mediaItems,
              aliasName: 'albums__id__media_items__album_id');

  $$MediaItemsTableProcessedTableManager get mediaItemsRefs {
    final manager = $$MediaItemsTableTableManager($_db, $_db.mediaItems)
        .filter((f) => f.albumId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSecret => $composableBuilder(
      column: $table.isSecret, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exifLevel => $composableBuilder(
      column: $table.exifLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> mediaItemsRefs(
      Expression<bool> Function($$MediaItemsTableFilterComposer f) f) {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.albumId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableFilterComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSecret => $composableBuilder(
      column: $table.isSecret, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exifLevel => $composableBuilder(
      column: $table.exifLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isSecret =>
      $composableBuilder(column: $table.isSecret, builder: (column) => column);

  GeneratedColumn<int> get exifLevel =>
      $composableBuilder(column: $table.exifLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> mediaItemsRefs<T extends Object>(
      Expression<T> Function($$MediaItemsTableAnnotationComposer a) f) {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.albumId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AlbumsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlbumsTable,
    Album,
    $$AlbumsTableFilterComposer,
    $$AlbumsTableOrderingComposer,
    $$AlbumsTableAnnotationComposer,
    $$AlbumsTableCreateCompanionBuilder,
    $$AlbumsTableUpdateCompanionBuilder,
    (Album, $$AlbumsTableReferences),
    Album,
    PrefetchHooks Function({bool mediaItemsRefs})> {
  $$AlbumsTableTableManager(_$AppDatabase db, $AlbumsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isSecret = const Value.absent(),
            Value<int> exifLevel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AlbumsCompanion(
            id: id,
            name: name,
            isSecret: isSecret,
            exifLevel: exifLevel,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> isSecret = const Value.absent(),
            Value<int> exifLevel = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AlbumsCompanion.insert(
            id: id,
            name: name,
            isSecret: isSecret,
            exifLevel: exifLevel,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AlbumsTable, Album>(table),
                    $$AlbumsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mediaItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mediaItemsRefs) db.mediaItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaItemsRefs)
                    await $_getPrefetchedData<Album, $AlbumsTable, MediaItem>(
                        currentTable: table,
                        referencedTable:
                            $$AlbumsTableReferences._mediaItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AlbumsTableReferences(db, table, p0)
                                .mediaItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.albumId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AlbumsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlbumsTable,
    Album,
    $$AlbumsTableFilterComposer,
    $$AlbumsTableOrderingComposer,
    $$AlbumsTableAnnotationComposer,
    $$AlbumsTableCreateCompanionBuilder,
    $$AlbumsTableUpdateCompanionBuilder,
    (Album, $$AlbumsTableReferences),
    Album,
    PrefetchHooks Function({bool mediaItemsRefs})>;
typedef $$MediaItemsTableCreateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  required String hash,
  Value<int?> albumId,
  required String filePath,
  required String thumbPath,
  required String previewPath,
  required String mediaType,
  Value<DateTime?> takenAt,
  required DateTime importedAt,
  Value<bool> localOnly,
  Value<DateTime?> deletedAt,
  Value<bool> favorite,
  required String encryptionIv,
  Value<DateTime> updatedAt,
});
typedef $$MediaItemsTableUpdateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  Value<String> hash,
  Value<int?> albumId,
  Value<String> filePath,
  Value<String> thumbPath,
  Value<String> previewPath,
  Value<String> mediaType,
  Value<DateTime?> takenAt,
  Value<DateTime> importedAt,
  Value<bool> localOnly,
  Value<DateTime?> deletedAt,
  Value<bool> favorite,
  Value<String> encryptionIv,
  Value<DateTime> updatedAt,
});

final class $$MediaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem> {
  $$MediaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.albums.createAlias('media_items__album_id__albums__id');

  $$AlbumsTableProcessedTableManager? get albumId {
    final $_column = $_itemColumn<int>('album_id');
    if ($_column == null) return null;
    final manager = $$AlbumsTableTableManager($_db, $_db.albums)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PostsTable, List<Post>> _postsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.posts,
          aliasName: 'media_items__id__posts__media_id');

  $$PostsTableProcessedTableManager get postsRefs {
    final manager = $$PostsTableTableManager($_db, $_db.posts)
        .filter((f) => f.mediaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_postsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbPath => $composableBuilder(
      column: $table.thumbPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewPath => $composableBuilder(
      column: $table.previewPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get localOnly => $composableBuilder(
      column: $table.localOnly, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptionIv => $composableBuilder(
      column: $table.encryptionIv, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AlbumsTableFilterComposer get albumId {
    final $$AlbumsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.albumId,
        referencedTable: $db.albums,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlbumsTableFilterComposer(
              $db: $db,
              $table: $db.albums,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> postsRefs(
      Expression<bool> Function($$PostsTableFilterComposer f) f) {
    final $$PostsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.posts,
        getReferencedColumn: (t) => t.mediaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostsTableFilterComposer(
              $db: $db,
              $table: $db.posts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbPath => $composableBuilder(
      column: $table.thumbPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewPath => $composableBuilder(
      column: $table.previewPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get localOnly => $composableBuilder(
      column: $table.localOnly, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptionIv => $composableBuilder(
      column: $table.encryptionIv,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AlbumsTableOrderingComposer get albumId {
    final $$AlbumsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.albumId,
        referencedTable: $db.albums,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlbumsTableOrderingComposer(
              $db: $db,
              $table: $db.albums,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<String> get previewPath => $composableBuilder(
      column: $table.previewPath, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => column);

  GeneratedColumn<bool> get localOnly =>
      $composableBuilder(column: $table.localOnly, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<String> get encryptionIv => $composableBuilder(
      column: $table.encryptionIv, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AlbumsTableAnnotationComposer get albumId {
    final $$AlbumsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.albumId,
        referencedTable: $db.albums,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlbumsTableAnnotationComposer(
              $db: $db,
              $table: $db.albums,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> postsRefs<T extends Object>(
      Expression<T> Function($$PostsTableAnnotationComposer a) f) {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.posts,
        getReferencedColumn: (t) => t.mediaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostsTableAnnotationComposer(
              $db: $db,
              $table: $db.posts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MediaItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaItemsTable,
    MediaItem,
    $$MediaItemsTableFilterComposer,
    $$MediaItemsTableOrderingComposer,
    $$MediaItemsTableAnnotationComposer,
    $$MediaItemsTableCreateCompanionBuilder,
    $$MediaItemsTableUpdateCompanionBuilder,
    (MediaItem, $$MediaItemsTableReferences),
    MediaItem,
    PrefetchHooks Function({bool albumId, bool postsRefs})> {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<int?> albumId = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> thumbPath = const Value.absent(),
            Value<String> previewPath = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<DateTime?> takenAt = const Value.absent(),
            Value<DateTime> importedAt = const Value.absent(),
            Value<bool> localOnly = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            Value<String> encryptionIv = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MediaItemsCompanion(
            id: id,
            hash: hash,
            albumId: albumId,
            filePath: filePath,
            thumbPath: thumbPath,
            previewPath: previewPath,
            mediaType: mediaType,
            takenAt: takenAt,
            importedAt: importedAt,
            localOnly: localOnly,
            deletedAt: deletedAt,
            favorite: favorite,
            encryptionIv: encryptionIv,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String hash,
            Value<int?> albumId = const Value.absent(),
            required String filePath,
            required String thumbPath,
            required String previewPath,
            required String mediaType,
            Value<DateTime?> takenAt = const Value.absent(),
            required DateTime importedAt,
            Value<bool> localOnly = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            required String encryptionIv,
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MediaItemsCompanion.insert(
            id: id,
            hash: hash,
            albumId: albumId,
            filePath: filePath,
            thumbPath: thumbPath,
            previewPath: previewPath,
            mediaType: mediaType,
            takenAt: takenAt,
            importedAt: importedAt,
            localOnly: localOnly,
            deletedAt: deletedAt,
            favorite: favorite,
            encryptionIv: encryptionIv,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MediaItemsTable, MediaItem>(table),
                    $$MediaItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({albumId = false, postsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (postsRefs) db.posts],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (albumId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.albumId,
                    referencedTable:
                        $$MediaItemsTableReferences._albumIdTable(db),
                    referencedColumn:
                        $$MediaItemsTableReferences._albumIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postsRefs)
                    await $_getPrefetchedData<MediaItem, $MediaItemsTable,
                            Post>(
                        currentTable: table,
                        referencedTable:
                            $$MediaItemsTableReferences._postsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MediaItemsTableReferences(db, table, p0)
                                .postsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.mediaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MediaItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaItemsTable,
    MediaItem,
    $$MediaItemsTableFilterComposer,
    $$MediaItemsTableOrderingComposer,
    $$MediaItemsTableAnnotationComposer,
    $$MediaItemsTableCreateCompanionBuilder,
    $$MediaItemsTableUpdateCompanionBuilder,
    (MediaItem, $$MediaItemsTableReferences),
    MediaItem,
    PrefetchHooks Function({bool albumId, bool postsRefs})>;
typedef $$AppStateTableTableCreateCompanionBuilder = AppStateTableCompanion
    Function({
  Value<int> id,
  required int schemaVersion,
  required String masterKeyEncrypted,
  Value<String?> pairedPartnerId,
  required bool onboardingComplete,
});
typedef $$AppStateTableTableUpdateCompanionBuilder = AppStateTableCompanion
    Function({
  Value<int> id,
  Value<int> schemaVersion,
  Value<String> masterKeyEncrypted,
  Value<String?> pairedPartnerId,
  Value<bool> onboardingComplete,
});

class $$AppStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppStateTableTable> {
  $$AppStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get masterKeyEncrypted => $composableBuilder(
      column: $table.masterKeyEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pairedPartnerId => $composableBuilder(
      column: $table.pairedPartnerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnFilters(column));
}

class $$AppStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppStateTableTable> {
  $$AppStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get masterKeyEncrypted => $composableBuilder(
      column: $table.masterKeyEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pairedPartnerId => $composableBuilder(
      column: $table.pairedPartnerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnOrderings(column));
}

class $$AppStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppStateTableTable> {
  $$AppStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<String> get masterKeyEncrypted => $composableBuilder(
      column: $table.masterKeyEncrypted, builder: (column) => column);

  GeneratedColumn<String> get pairedPartnerId => $composableBuilder(
      column: $table.pairedPartnerId, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete, builder: (column) => column);
}

class $$AppStateTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppStateTableTable,
    AppStateTableData,
    $$AppStateTableTableFilterComposer,
    $$AppStateTableTableOrderingComposer,
    $$AppStateTableTableAnnotationComposer,
    $$AppStateTableTableCreateCompanionBuilder,
    $$AppStateTableTableUpdateCompanionBuilder,
    (
      AppStateTableData,
      BaseReferences<_$AppDatabase, $AppStateTableTable, AppStateTableData>
    ),
    AppStateTableData,
    PrefetchHooks Function()> {
  $$AppStateTableTableTableManager(_$AppDatabase db, $AppStateTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<String> masterKeyEncrypted = const Value.absent(),
            Value<String?> pairedPartnerId = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
          }) =>
              AppStateTableCompanion(
            id: id,
            schemaVersion: schemaVersion,
            masterKeyEncrypted: masterKeyEncrypted,
            pairedPartnerId: pairedPartnerId,
            onboardingComplete: onboardingComplete,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int schemaVersion,
            required String masterKeyEncrypted,
            Value<String?> pairedPartnerId = const Value.absent(),
            required bool onboardingComplete,
          }) =>
              AppStateTableCompanion.insert(
            id: id,
            schemaVersion: schemaVersion,
            masterKeyEncrypted: masterKeyEncrypted,
            pairedPartnerId: pairedPartnerId,
            onboardingComplete: onboardingComplete,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppStateTableTable, AppStateTableData>(table),
                    BaseReferences<_$AppDatabase, $AppStateTableTable,
                        AppStateTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppStateTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppStateTableTable,
    AppStateTableData,
    $$AppStateTableTableFilterComposer,
    $$AppStateTableTableOrderingComposer,
    $$AppStateTableTableAnnotationComposer,
    $$AppStateTableTableCreateCompanionBuilder,
    $$AppStateTableTableUpdateCompanionBuilder,
    (
      AppStateTableData,
      BaseReferences<_$AppDatabase, $AppStateTableTable, AppStateTableData>
    ),
    AppStateTableData,
    PrefetchHooks Function()>;
typedef $$PostsTableCreateCompanionBuilder = PostsCompanion Function({
  required String id,
  required String postType,
  Value<String?> contentEncrypted,
  Value<int?> mediaId,
  required DateTime postDate,
  Value<bool> isSecret,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$PostsTableUpdateCompanionBuilder = PostsCompanion Function({
  Value<String> id,
  Value<String> postType,
  Value<String?> contentEncrypted,
  Value<int?> mediaId,
  Value<DateTime> postDate,
  Value<bool> isSecret,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PostsTableReferences
    extends BaseReferences<_$AppDatabase, $PostsTable, Post> {
  $$PostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTable _mediaIdTable(_$AppDatabase db) =>
      db.mediaItems.createAlias('posts__media_id__media_items__id');

  $$MediaItemsTableProcessedTableManager? get mediaId {
    final $_column = $_itemColumn<int>('media_id');
    if ($_column == null) return null;
    final manager = $$MediaItemsTableTableManager($_db, $_db.mediaItems)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CommentsTable, List<Comment>> _commentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.comments,
          aliasName: 'posts__id__comments__post_id');

  $$CommentsTableProcessedTableManager get commentsRefs {
    final manager = $$CommentsTableTableManager($_db, $_db.comments)
        .filter((f) => f.postId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PostsTableFilterComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postType => $composableBuilder(
      column: $table.postType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get postDate => $composableBuilder(
      column: $table.postDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSecret => $composableBuilder(
      column: $table.isSecret, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$MediaItemsTableFilterComposer get mediaId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaId,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableFilterComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> commentsRefs(
      Expression<bool> Function($$CommentsTableFilterComposer f) f) {
    final $$CommentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.comments,
        getReferencedColumn: (t) => t.postId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommentsTableFilterComposer(
              $db: $db,
              $table: $db.comments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PostsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postType => $composableBuilder(
      column: $table.postType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get postDate => $composableBuilder(
      column: $table.postDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSecret => $composableBuilder(
      column: $table.isSecret, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$MediaItemsTableOrderingComposer get mediaId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaId,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableOrderingComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get postType =>
      $composableBuilder(column: $table.postType, builder: (column) => column);

  GeneratedColumn<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted, builder: (column) => column);

  GeneratedColumn<DateTime> get postDate =>
      $composableBuilder(column: $table.postDate, builder: (column) => column);

  GeneratedColumn<bool> get isSecret =>
      $composableBuilder(column: $table.isSecret, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaId,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> commentsRefs<T extends Object>(
      Expression<T> Function($$CommentsTableAnnotationComposer a) f) {
    final $$CommentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.comments,
        getReferencedColumn: (t) => t.postId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommentsTableAnnotationComposer(
              $db: $db,
              $table: $db.comments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PostsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PostsTable,
    Post,
    $$PostsTableFilterComposer,
    $$PostsTableOrderingComposer,
    $$PostsTableAnnotationComposer,
    $$PostsTableCreateCompanionBuilder,
    $$PostsTableUpdateCompanionBuilder,
    (Post, $$PostsTableReferences),
    Post,
    PrefetchHooks Function({bool mediaId, bool commentsRefs})> {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> postType = const Value.absent(),
            Value<String?> contentEncrypted = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
            Value<DateTime> postDate = const Value.absent(),
            Value<bool> isSecret = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostsCompanion(
            id: id,
            postType: postType,
            contentEncrypted: contentEncrypted,
            mediaId: mediaId,
            postDate: postDate,
            isSecret: isSecret,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String postType,
            Value<String?> contentEncrypted = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
            required DateTime postDate,
            Value<bool> isSecret = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostsCompanion.insert(
            id: id,
            postType: postType,
            contentEncrypted: contentEncrypted,
            mediaId: mediaId,
            postDate: postDate,
            isSecret: isSecret,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PostsTable, Post>(table),
                    $$PostsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mediaId = false, commentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (commentsRefs) db.comments],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mediaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaId,
                    referencedTable: $$PostsTableReferences._mediaIdTable(db),
                    referencedColumn:
                        $$PostsTableReferences._mediaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (commentsRefs)
                    await $_getPrefetchedData<Post, $PostsTable, Comment>(
                        currentTable: table,
                        referencedTable:
                            $$PostsTableReferences._commentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PostsTableReferences(db, table, p0).commentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.postId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PostsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PostsTable,
    Post,
    $$PostsTableFilterComposer,
    $$PostsTableOrderingComposer,
    $$PostsTableAnnotationComposer,
    $$PostsTableCreateCompanionBuilder,
    $$PostsTableUpdateCompanionBuilder,
    (Post, $$PostsTableReferences),
    Post,
    PrefetchHooks Function({bool mediaId, bool commentsRefs})>;
typedef $$CommentsTableCreateCompanionBuilder = CommentsCompanion Function({
  required String id,
  required String postId,
  required String contentEncrypted,
  required String authorId,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CommentsTableUpdateCompanionBuilder = CommentsCompanion Function({
  Value<String> id,
  Value<String> postId,
  Value<String> contentEncrypted,
  Value<String> authorId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CommentsTableReferences
    extends BaseReferences<_$AppDatabase, $CommentsTable, Comment> {
  $$CommentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postIdTable(_$AppDatabase db) =>
      db.posts.createAlias('comments__post_id__posts__id');

  $$PostsTableProcessedTableManager get postId {
    final $_column = $_itemColumn<String>('post_id')!;

    final manager = $$PostsTableTableManager($_db, $_db.posts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CommentsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorId => $composableBuilder(
      column: $table.authorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$PostsTableFilterComposer get postId {
    final $$PostsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.postId,
        referencedTable: $db.posts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostsTableFilterComposer(
              $db: $db,
              $table: $db.posts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorId => $composableBuilder(
      column: $table.authorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$PostsTableOrderingComposer get postId {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.postId,
        referencedTable: $db.posts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostsTableOrderingComposer(
              $db: $db,
              $table: $db.posts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PostsTableAnnotationComposer get postId {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.postId,
        referencedTable: $db.posts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostsTableAnnotationComposer(
              $db: $db,
              $table: $db.posts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommentsTable,
    Comment,
    $$CommentsTableFilterComposer,
    $$CommentsTableOrderingComposer,
    $$CommentsTableAnnotationComposer,
    $$CommentsTableCreateCompanionBuilder,
    $$CommentsTableUpdateCompanionBuilder,
    (Comment, $$CommentsTableReferences),
    Comment,
    PrefetchHooks Function({bool postId})> {
  $$CommentsTableTableManager(_$AppDatabase db, $CommentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> postId = const Value.absent(),
            Value<String> contentEncrypted = const Value.absent(),
            Value<String> authorId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentsCompanion(
            id: id,
            postId: postId,
            contentEncrypted: contentEncrypted,
            authorId: authorId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String postId,
            required String contentEncrypted,
            required String authorId,
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentsCompanion.insert(
            id: id,
            postId: postId,
            contentEncrypted: contentEncrypted,
            authorId: authorId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CommentsTable, Comment>(table),
                    $$CommentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({postId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (postId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.postId,
                    referencedTable: $$CommentsTableReferences._postIdTable(db),
                    referencedColumn:
                        $$CommentsTableReferences._postIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CommentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CommentsTable,
    Comment,
    $$CommentsTableFilterComposer,
    $$CommentsTableOrderingComposer,
    $$CommentsTableAnnotationComposer,
    $$CommentsTableCreateCompanionBuilder,
    $$CommentsTableUpdateCompanionBuilder,
    (Comment, $$CommentsTableReferences),
    Comment,
    PrefetchHooks Function({bool postId})>;
typedef $$ShoppingItemsTableCreateCompanionBuilder = ShoppingItemsCompanion
    Function({
  required String id,
  required String itemNameEncrypted,
  Value<bool> isBought,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ShoppingItemsTableUpdateCompanionBuilder = ShoppingItemsCompanion
    Function({
  Value<String> id,
  Value<String> itemNameEncrypted,
  Value<bool> isBought,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemNameEncrypted => $composableBuilder(
      column: $table.itemNameEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBought => $composableBuilder(
      column: $table.isBought, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemNameEncrypted => $composableBuilder(
      column: $table.itemNameEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBought => $composableBuilder(
      column: $table.isBought, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemNameEncrypted => $composableBuilder(
      column: $table.itemNameEncrypted, builder: (column) => column);

  GeneratedColumn<bool> get isBought =>
      $composableBuilder(column: $table.isBought, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShoppingItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShoppingItemsTable,
    ShoppingItem,
    $$ShoppingItemsTableFilterComposer,
    $$ShoppingItemsTableOrderingComposer,
    $$ShoppingItemsTableAnnotationComposer,
    $$ShoppingItemsTableCreateCompanionBuilder,
    $$ShoppingItemsTableUpdateCompanionBuilder,
    (
      ShoppingItem,
      BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItem>
    ),
    ShoppingItem,
    PrefetchHooks Function()> {
  $$ShoppingItemsTableTableManager(_$AppDatabase db, $ShoppingItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemNameEncrypted = const Value.absent(),
            Value<bool> isBought = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingItemsCompanion(
            id: id,
            itemNameEncrypted: itemNameEncrypted,
            isBought: isBought,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemNameEncrypted,
            Value<bool> isBought = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingItemsCompanion.insert(
            id: id,
            itemNameEncrypted: itemNameEncrypted,
            isBought: isBought,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ShoppingItemsTable, ShoppingItem>(table),
                    BaseReferences<_$AppDatabase, $ShoppingItemsTable,
                        ShoppingItem>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShoppingItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShoppingItemsTable,
    ShoppingItem,
    $$ShoppingItemsTableFilterComposer,
    $$ShoppingItemsTableOrderingComposer,
    $$ShoppingItemsTableAnnotationComposer,
    $$ShoppingItemsTableCreateCompanionBuilder,
    $$ShoppingItemsTableUpdateCompanionBuilder,
    (
      ShoppingItem,
      BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItem>
    ),
    ShoppingItem,
    PrefetchHooks Function()>;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String titleEncrypted,
  Value<bool> isCompleted,
  Value<DateTime?> targetDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> titleEncrypted,
  Value<bool> isCompleted,
  Value<DateTime?> targetDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleEncrypted => $composableBuilder(
      column: $table.titleEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleEncrypted => $composableBuilder(
      column: $table.titleEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titleEncrypted => $composableBuilder(
      column: $table.titleEncrypted, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> titleEncrypted = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> targetDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            titleEncrypted: titleEncrypted,
            isCompleted: isCompleted,
            targetDate: targetDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String titleEncrypted,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> targetDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            titleEncrypted: titleEncrypted,
            isCompleted: isCompleted,
            targetDate: targetDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GoalsTable, Goal>(table),
                    BaseReferences<_$AppDatabase, $GoalsTable, Goal>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()>;
typedef $$SpecialDatesTableCreateCompanionBuilder = SpecialDatesCompanion
    Function({
  required String id,
  required String titleEncrypted,
  required DateTime eventDate,
  Value<bool> isRecurring,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SpecialDatesTableUpdateCompanionBuilder = SpecialDatesCompanion
    Function({
  Value<String> id,
  Value<String> titleEncrypted,
  Value<DateTime> eventDate,
  Value<bool> isRecurring,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SpecialDatesTableFilterComposer
    extends Composer<_$AppDatabase, $SpecialDatesTable> {
  $$SpecialDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleEncrypted => $composableBuilder(
      column: $table.titleEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SpecialDatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpecialDatesTable> {
  $$SpecialDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleEncrypted => $composableBuilder(
      column: $table.titleEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SpecialDatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpecialDatesTable> {
  $$SpecialDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titleEncrypted => $composableBuilder(
      column: $table.titleEncrypted, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SpecialDatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SpecialDatesTable,
    SpecialDate,
    $$SpecialDatesTableFilterComposer,
    $$SpecialDatesTableOrderingComposer,
    $$SpecialDatesTableAnnotationComposer,
    $$SpecialDatesTableCreateCompanionBuilder,
    $$SpecialDatesTableUpdateCompanionBuilder,
    (
      SpecialDate,
      BaseReferences<_$AppDatabase, $SpecialDatesTable, SpecialDate>
    ),
    SpecialDate,
    PrefetchHooks Function()> {
  $$SpecialDatesTableTableManager(_$AppDatabase db, $SpecialDatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpecialDatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpecialDatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpecialDatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> titleEncrypted = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpecialDatesCompanion(
            id: id,
            titleEncrypted: titleEncrypted,
            eventDate: eventDate,
            isRecurring: isRecurring,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String titleEncrypted,
            required DateTime eventDate,
            Value<bool> isRecurring = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpecialDatesCompanion.insert(
            id: id,
            titleEncrypted: titleEncrypted,
            eventDate: eventDate,
            isRecurring: isRecurring,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SpecialDatesTable, SpecialDate>(table),
                    BaseReferences<_$AppDatabase, $SpecialDatesTable,
                        SpecialDate>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SpecialDatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SpecialDatesTable,
    SpecialDate,
    $$SpecialDatesTableFilterComposer,
    $$SpecialDatesTableOrderingComposer,
    $$SpecialDatesTableAnnotationComposer,
    $$SpecialDatesTableCreateCompanionBuilder,
    $$SpecialDatesTableUpdateCompanionBuilder,
    (
      SpecialDate,
      BaseReferences<_$AppDatabase, $SpecialDatesTable, SpecialDate>
    ),
    SpecialDate,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String contentEncrypted,
  required String messageType,
  required String senderId,
  Value<bool> isTemporary,
  required DateTime sentAt,
  Value<DateTime?> readAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> contentEncrypted,
  Value<String> messageType,
  Value<String> senderId,
  Value<bool> isTemporary,
  Value<DateTime> sentAt,
  Value<DateTime?> readAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTemporary => $composableBuilder(
      column: $table.isTemporary, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTemporary => $composableBuilder(
      column: $table.isTemporary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentEncrypted => $composableBuilder(
      column: $table.contentEncrypted, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<bool> get isTemporary => $composableBuilder(
      column: $table.isTemporary, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> contentEncrypted = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<bool> isTemporary = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            contentEncrypted: contentEncrypted,
            messageType: messageType,
            senderId: senderId,
            isTemporary: isTemporary,
            sentAt: sentAt,
            readAt: readAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String contentEncrypted,
            required String messageType,
            required String senderId,
            Value<bool> isTemporary = const Value.absent(),
            required DateTime sentAt,
            Value<DateTime?> readAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            contentEncrypted: contentEncrypted,
            messageType: messageType,
            senderId: senderId,
            isTemporary: isTemporary,
            sentAt: sentAt,
            readAt: readAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MessagesTable, Message>(table),
                    BaseReferences<_$AppDatabase, $MessagesTable, Message>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$AppStateTableTableTableManager get appStateTable =>
      $$AppStateTableTableTableManager(_db, _db.appStateTable);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$CommentsTableTableManager get comments =>
      $$CommentsTableTableManager(_db, _db.comments);
  $$ShoppingItemsTableTableManager get shoppingItems =>
      $$ShoppingItemsTableTableManager(_db, _db.shoppingItems);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$SpecialDatesTableTableManager get specialDates =>
      $$SpecialDatesTableTableManager(_db, _db.specialDates);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
