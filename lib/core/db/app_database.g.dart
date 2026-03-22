// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RiwayaTableTable extends RiwayaTable
    with TableInfo<$RiwayaTableTable, RiwayaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RiwayaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBundledMeta = const VerificationMeta(
    'isBundled',
  );
  @override
  late final GeneratedColumn<bool> isBundled = GeneratedColumn<bool>(
    'is_bundled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bundled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDownloadedMeta = const VerificationMeta(
    'isDownloaded',
  );
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
    'is_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageNativeWidthMeta = const VerificationMeta(
    'imageNativeWidth',
  );
  @override
  late final GeneratedColumn<int> imageNativeWidth = GeneratedColumn<int>(
    'image_native_width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2268),
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(604),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    key,
    displayName,
    isBundled,
    isDownloaded,
    downloadedAt,
    imageNativeWidth,
    totalPages,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'riwaya_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RiwayaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('is_bundled')) {
      context.handle(
        _isBundledMeta,
        isBundled.isAcceptableOrUnknown(data['is_bundled']!, _isBundledMeta),
      );
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
        _isDownloadedMeta,
        isDownloaded.isAcceptableOrUnknown(
          data['is_downloaded']!,
          _isDownloadedMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('image_native_width')) {
      context.handle(
        _imageNativeWidthMeta,
        imageNativeWidth.isAcceptableOrUnknown(
          data['image_native_width']!,
          _imageNativeWidthMeta,
        ),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RiwayaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RiwayaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      isBundled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bundled'],
      )!,
      isDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_downloaded'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
      imageNativeWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_native_width'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      )!,
    );
  }

  @override
  $RiwayaTableTable createAlias(String alias) {
    return $RiwayaTableTable(attachedDatabase, alias);
  }
}

class RiwayaTableData extends DataClass implements Insertable<RiwayaTableData> {
  final int id;
  final String key;
  final String displayName;
  final bool isBundled;
  final bool isDownloaded;
  final DateTime? downloadedAt;
  final int imageNativeWidth;
  final int totalPages;
  const RiwayaTableData({
    required this.id,
    required this.key,
    required this.displayName,
    required this.isBundled,
    required this.isDownloaded,
    this.downloadedAt,
    required this.imageNativeWidth,
    required this.totalPages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['display_name'] = Variable<String>(displayName);
    map['is_bundled'] = Variable<bool>(isBundled);
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    map['image_native_width'] = Variable<int>(imageNativeWidth);
    map['total_pages'] = Variable<int>(totalPages);
    return map;
  }

  RiwayaTableCompanion toCompanion(bool nullToAbsent) {
    return RiwayaTableCompanion(
      id: Value(id),
      key: Value(key),
      displayName: Value(displayName),
      isBundled: Value(isBundled),
      isDownloaded: Value(isDownloaded),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
      imageNativeWidth: Value(imageNativeWidth),
      totalPages: Value(totalPages),
    );
  }

  factory RiwayaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RiwayaTableData(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      displayName: serializer.fromJson<String>(json['displayName']),
      isBundled: serializer.fromJson<bool>(json['isBundled']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
      imageNativeWidth: serializer.fromJson<int>(json['imageNativeWidth']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'displayName': serializer.toJson<String>(displayName),
      'isBundled': serializer.toJson<bool>(isBundled),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
      'imageNativeWidth': serializer.toJson<int>(imageNativeWidth),
      'totalPages': serializer.toJson<int>(totalPages),
    };
  }

  RiwayaTableData copyWith({
    int? id,
    String? key,
    String? displayName,
    bool? isBundled,
    bool? isDownloaded,
    Value<DateTime?> downloadedAt = const Value.absent(),
    int? imageNativeWidth,
    int? totalPages,
  }) => RiwayaTableData(
    id: id ?? this.id,
    key: key ?? this.key,
    displayName: displayName ?? this.displayName,
    isBundled: isBundled ?? this.isBundled,
    isDownloaded: isDownloaded ?? this.isDownloaded,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
    imageNativeWidth: imageNativeWidth ?? this.imageNativeWidth,
    totalPages: totalPages ?? this.totalPages,
  );
  RiwayaTableData copyWithCompanion(RiwayaTableCompanion data) {
    return RiwayaTableData(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      isBundled: data.isBundled.present ? data.isBundled.value : this.isBundled,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      imageNativeWidth: data.imageNativeWidth.present
          ? data.imageNativeWidth.value
          : this.imageNativeWidth,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RiwayaTableData(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('displayName: $displayName, ')
          ..write('isBundled: $isBundled, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('imageNativeWidth: $imageNativeWidth, ')
          ..write('totalPages: $totalPages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    key,
    displayName,
    isBundled,
    isDownloaded,
    downloadedAt,
    imageNativeWidth,
    totalPages,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RiwayaTableData &&
          other.id == this.id &&
          other.key == this.key &&
          other.displayName == this.displayName &&
          other.isBundled == this.isBundled &&
          other.isDownloaded == this.isDownloaded &&
          other.downloadedAt == this.downloadedAt &&
          other.imageNativeWidth == this.imageNativeWidth &&
          other.totalPages == this.totalPages);
}

class RiwayaTableCompanion extends UpdateCompanion<RiwayaTableData> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> displayName;
  final Value<bool> isBundled;
  final Value<bool> isDownloaded;
  final Value<DateTime?> downloadedAt;
  final Value<int> imageNativeWidth;
  final Value<int> totalPages;
  const RiwayaTableCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isBundled = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.imageNativeWidth = const Value.absent(),
    this.totalPages = const Value.absent(),
  });
  RiwayaTableCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String displayName,
    this.isBundled = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.imageNativeWidth = const Value.absent(),
    this.totalPages = const Value.absent(),
  }) : key = Value(key),
       displayName = Value(displayName);
  static Insertable<RiwayaTableData> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? displayName,
    Expression<bool>? isBundled,
    Expression<bool>? isDownloaded,
    Expression<DateTime>? downloadedAt,
    Expression<int>? imageNativeWidth,
    Expression<int>? totalPages,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (displayName != null) 'display_name': displayName,
      if (isBundled != null) 'is_bundled': isBundled,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (imageNativeWidth != null) 'image_native_width': imageNativeWidth,
      if (totalPages != null) 'total_pages': totalPages,
    });
  }

  RiwayaTableCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? displayName,
    Value<bool>? isBundled,
    Value<bool>? isDownloaded,
    Value<DateTime?>? downloadedAt,
    Value<int>? imageNativeWidth,
    Value<int>? totalPages,
  }) {
    return RiwayaTableCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      displayName: displayName ?? this.displayName,
      isBundled: isBundled ?? this.isBundled,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      imageNativeWidth: imageNativeWidth ?? this.imageNativeWidth,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isBundled.present) {
      map['is_bundled'] = Variable<bool>(isBundled.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (imageNativeWidth.present) {
      map['image_native_width'] = Variable<int>(imageNativeWidth.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RiwayaTableCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('displayName: $displayName, ')
          ..write('isBundled: $isBundled, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('imageNativeWidth: $imageNativeWidth, ')
          ..write('totalPages: $totalPages')
          ..write(')'))
        .toString();
  }
}

class $SurahTableTable extends SurahTable
    with TableInfo<$SurahTableTable, SurahTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameTransliteratedMeta =
      const VerificationMeta('nameTransliterated');
  @override
  late final GeneratedColumn<String> nameTransliterated =
      GeneratedColumn<String>(
        'name_transliterated',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ayahCountMeta = const VerificationMeta(
    'ayahCount',
  );
  @override
  late final GeneratedColumn<int> ayahCount = GeneratedColumn<int>(
    'ayah_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameArabic,
    nameTransliterated,
    ayahCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surah_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurahTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_transliterated')) {
      context.handle(
        _nameTransliteratedMeta,
        nameTransliterated.isAcceptableOrUnknown(
          data['name_transliterated']!,
          _nameTransliteratedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameTransliteratedMeta);
    }
    if (data.containsKey('ayah_count')) {
      context.handle(
        _ayahCountMeta,
        ayahCount.isAcceptableOrUnknown(data['ayah_count']!, _ayahCountMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SurahTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameTransliterated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_transliterated'],
      )!,
      ayahCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_count'],
      )!,
    );
  }

  @override
  $SurahTableTable createAlias(String alias) {
    return $SurahTableTable(attachedDatabase, alias);
  }
}

class SurahTableData extends DataClass implements Insertable<SurahTableData> {
  final int id;
  final String nameArabic;
  final String nameTransliterated;
  final int ayahCount;
  const SurahTableData({
    required this.id,
    required this.nameArabic,
    required this.nameTransliterated,
    required this.ayahCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_transliterated'] = Variable<String>(nameTransliterated);
    map['ayah_count'] = Variable<int>(ayahCount);
    return map;
  }

  SurahTableCompanion toCompanion(bool nullToAbsent) {
    return SurahTableCompanion(
      id: Value(id),
      nameArabic: Value(nameArabic),
      nameTransliterated: Value(nameTransliterated),
      ayahCount: Value(ayahCount),
    );
  }

  factory SurahTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahTableData(
      id: serializer.fromJson<int>(json['id']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameTransliterated: serializer.fromJson<String>(
        json['nameTransliterated'],
      ),
      ayahCount: serializer.fromJson<int>(json['ayahCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameTransliterated': serializer.toJson<String>(nameTransliterated),
      'ayahCount': serializer.toJson<int>(ayahCount),
    };
  }

  SurahTableData copyWith({
    int? id,
    String? nameArabic,
    String? nameTransliterated,
    int? ayahCount,
  }) => SurahTableData(
    id: id ?? this.id,
    nameArabic: nameArabic ?? this.nameArabic,
    nameTransliterated: nameTransliterated ?? this.nameTransliterated,
    ayahCount: ayahCount ?? this.ayahCount,
  );
  SurahTableData copyWithCompanion(SurahTableCompanion data) {
    return SurahTableData(
      id: data.id.present ? data.id.value : this.id,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameTransliterated: data.nameTransliterated.present
          ? data.nameTransliterated.value
          : this.nameTransliterated,
      ayahCount: data.ayahCount.present ? data.ayahCount.value : this.ayahCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahTableData(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameTransliterated: $nameTransliterated, ')
          ..write('ayahCount: $ayahCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nameArabic, nameTransliterated, ayahCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahTableData &&
          other.id == this.id &&
          other.nameArabic == this.nameArabic &&
          other.nameTransliterated == this.nameTransliterated &&
          other.ayahCount == this.ayahCount);
}

class SurahTableCompanion extends UpdateCompanion<SurahTableData> {
  final Value<int> id;
  final Value<String> nameArabic;
  final Value<String> nameTransliterated;
  final Value<int> ayahCount;
  const SurahTableCompanion({
    this.id = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameTransliterated = const Value.absent(),
    this.ayahCount = const Value.absent(),
  });
  SurahTableCompanion.insert({
    this.id = const Value.absent(),
    required String nameArabic,
    required String nameTransliterated,
    required int ayahCount,
  }) : nameArabic = Value(nameArabic),
       nameTransliterated = Value(nameTransliterated),
       ayahCount = Value(ayahCount);
  static Insertable<SurahTableData> custom({
    Expression<int>? id,
    Expression<String>? nameArabic,
    Expression<String>? nameTransliterated,
    Expression<int>? ayahCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameTransliterated != null) 'name_transliterated': nameTransliterated,
      if (ayahCount != null) 'ayah_count': ayahCount,
    });
  }

  SurahTableCompanion copyWith({
    Value<int>? id,
    Value<String>? nameArabic,
    Value<String>? nameTransliterated,
    Value<int>? ayahCount,
  }) {
    return SurahTableCompanion(
      id: id ?? this.id,
      nameArabic: nameArabic ?? this.nameArabic,
      nameTransliterated: nameTransliterated ?? this.nameTransliterated,
      ayahCount: ayahCount ?? this.ayahCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameTransliterated.present) {
      map['name_transliterated'] = Variable<String>(nameTransliterated.value);
    }
    if (ayahCount.present) {
      map['ayah_count'] = Variable<int>(ayahCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahTableCompanion(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameTransliterated: $nameTransliterated, ')
          ..write('ayahCount: $ayahCount')
          ..write(')'))
        .toString();
  }
}

class $PageAyahIndexTableTable extends PageAyahIndexTable
    with TableInfo<$PageAyahIndexTableTable, PageAyahIndexTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PageAyahIndexTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riwayaIdMeta = const VerificationMeta(
    'riwayaId',
  );
  @override
  late final GeneratedColumn<int> riwayaId = GeneratedColumn<int>(
    'riwaya_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pageNumber,
    surahId,
    ayahNumber,
    riwayaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page_ayah_index_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageAyahIndexTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('riwaya_id')) {
      context.handle(
        _riwayaIdMeta,
        riwayaId.isAcceptableOrUnknown(data['riwaya_id']!, _riwayaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_riwayaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    pageNumber,
    surahId,
    ayahNumber,
    riwayaId,
  };
  @override
  PageAyahIndexTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageAyahIndexTableData(
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      riwayaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}riwaya_id'],
      )!,
    );
  }

  @override
  $PageAyahIndexTableTable createAlias(String alias) {
    return $PageAyahIndexTableTable(attachedDatabase, alias);
  }
}

class PageAyahIndexTableData extends DataClass
    implements Insertable<PageAyahIndexTableData> {
  final int pageNumber;
  final int surahId;
  final int ayahNumber;
  final int riwayaId;
  const PageAyahIndexTableData({
    required this.pageNumber,
    required this.surahId,
    required this.ayahNumber,
    required this.riwayaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['page_number'] = Variable<int>(pageNumber);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['riwaya_id'] = Variable<int>(riwayaId);
    return map;
  }

  PageAyahIndexTableCompanion toCompanion(bool nullToAbsent) {
    return PageAyahIndexTableCompanion(
      pageNumber: Value(pageNumber),
      surahId: Value(surahId),
      ayahNumber: Value(ayahNumber),
      riwayaId: Value(riwayaId),
    );
  }

  factory PageAyahIndexTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageAyahIndexTableData(
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      riwayaId: serializer.fromJson<int>(json['riwayaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pageNumber': serializer.toJson<int>(pageNumber),
      'surahId': serializer.toJson<int>(surahId),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'riwayaId': serializer.toJson<int>(riwayaId),
    };
  }

  PageAyahIndexTableData copyWith({
    int? pageNumber,
    int? surahId,
    int? ayahNumber,
    int? riwayaId,
  }) => PageAyahIndexTableData(
    pageNumber: pageNumber ?? this.pageNumber,
    surahId: surahId ?? this.surahId,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    riwayaId: riwayaId ?? this.riwayaId,
  );
  PageAyahIndexTableData copyWithCompanion(PageAyahIndexTableCompanion data) {
    return PageAyahIndexTableData(
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      riwayaId: data.riwayaId.present ? data.riwayaId.value : this.riwayaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageAyahIndexTableData(')
          ..write('pageNumber: $pageNumber, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('riwayaId: $riwayaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pageNumber, surahId, ayahNumber, riwayaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageAyahIndexTableData &&
          other.pageNumber == this.pageNumber &&
          other.surahId == this.surahId &&
          other.ayahNumber == this.ayahNumber &&
          other.riwayaId == this.riwayaId);
}

class PageAyahIndexTableCompanion
    extends UpdateCompanion<PageAyahIndexTableData> {
  final Value<int> pageNumber;
  final Value<int> surahId;
  final Value<int> ayahNumber;
  final Value<int> riwayaId;
  final Value<int> rowid;
  const PageAyahIndexTableCompanion({
    this.pageNumber = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.riwayaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PageAyahIndexTableCompanion.insert({
    required int pageNumber,
    required int surahId,
    required int ayahNumber,
    required int riwayaId,
    this.rowid = const Value.absent(),
  }) : pageNumber = Value(pageNumber),
       surahId = Value(surahId),
       ayahNumber = Value(ayahNumber),
       riwayaId = Value(riwayaId);
  static Insertable<PageAyahIndexTableData> custom({
    Expression<int>? pageNumber,
    Expression<int>? surahId,
    Expression<int>? ayahNumber,
    Expression<int>? riwayaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pageNumber != null) 'page_number': pageNumber,
      if (surahId != null) 'surah_id': surahId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (riwayaId != null) 'riwaya_id': riwayaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PageAyahIndexTableCompanion copyWith({
    Value<int>? pageNumber,
    Value<int>? surahId,
    Value<int>? ayahNumber,
    Value<int>? riwayaId,
    Value<int>? rowid,
  }) {
    return PageAyahIndexTableCompanion(
      pageNumber: pageNumber ?? this.pageNumber,
      surahId: surahId ?? this.surahId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      riwayaId: riwayaId ?? this.riwayaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (riwayaId.present) {
      map['riwaya_id'] = Variable<int>(riwayaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PageAyahIndexTableCompanion(')
          ..write('pageNumber: $pageNumber, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('riwayaId: $riwayaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GlyphTableTable extends GlyphTable
    with TableInfo<$GlyphTableTable, GlyphTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlyphTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNumberMeta = const VerificationMeta(
    'lineNumber',
  );
  @override
  late final GeneratedColumn<int> lineNumber = GeneratedColumn<int>(
    'line_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minXMeta = const VerificationMeta('minX');
  @override
  late final GeneratedColumn<int> minX = GeneratedColumn<int>(
    'min_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxXMeta = const VerificationMeta('maxX');
  @override
  late final GeneratedColumn<int> maxX = GeneratedColumn<int>(
    'max_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minYMeta = const VerificationMeta('minY');
  @override
  late final GeneratedColumn<int> minY = GeneratedColumn<int>(
    'min_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxYMeta = const VerificationMeta('maxY');
  @override
  late final GeneratedColumn<int> maxY = GeneratedColumn<int>(
    'max_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riwayaIdMeta = const VerificationMeta(
    'riwayaId',
  );
  @override
  late final GeneratedColumn<int> riwayaId = GeneratedColumn<int>(
    'riwaya_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageNumber,
    lineNumber,
    surahId,
    ayahNumber,
    position,
    minX,
    maxX,
    minY,
    maxY,
    riwayaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glyph_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlyphTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('line_number')) {
      context.handle(
        _lineNumberMeta,
        lineNumber.isAcceptableOrUnknown(data['line_number']!, _lineNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNumberMeta);
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('min_x')) {
      context.handle(
        _minXMeta,
        minX.isAcceptableOrUnknown(data['min_x']!, _minXMeta),
      );
    } else if (isInserting) {
      context.missing(_minXMeta);
    }
    if (data.containsKey('max_x')) {
      context.handle(
        _maxXMeta,
        maxX.isAcceptableOrUnknown(data['max_x']!, _maxXMeta),
      );
    } else if (isInserting) {
      context.missing(_maxXMeta);
    }
    if (data.containsKey('min_y')) {
      context.handle(
        _minYMeta,
        minY.isAcceptableOrUnknown(data['min_y']!, _minYMeta),
      );
    } else if (isInserting) {
      context.missing(_minYMeta);
    }
    if (data.containsKey('max_y')) {
      context.handle(
        _maxYMeta,
        maxY.isAcceptableOrUnknown(data['max_y']!, _maxYMeta),
      );
    } else if (isInserting) {
      context.missing(_maxYMeta);
    }
    if (data.containsKey('riwaya_id')) {
      context.handle(
        _riwayaIdMeta,
        riwayaId.isAcceptableOrUnknown(data['riwaya_id']!, _riwayaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_riwayaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlyphTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlyphTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      lineNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_number'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      minX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_x'],
      )!,
      maxX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_x'],
      )!,
      minY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_y'],
      )!,
      maxY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_y'],
      )!,
      riwayaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}riwaya_id'],
      )!,
    );
  }

  @override
  $GlyphTableTable createAlias(String alias) {
    return $GlyphTableTable(attachedDatabase, alias);
  }
}

class GlyphTableData extends DataClass implements Insertable<GlyphTableData> {
  final int id;
  final int pageNumber;
  final int lineNumber;
  final int surahId;
  final int ayahNumber;
  final int position;
  final int minX;
  final int maxX;
  final int minY;
  final int maxY;
  final int riwayaId;
  const GlyphTableData({
    required this.id,
    required this.pageNumber,
    required this.lineNumber,
    required this.surahId,
    required this.ayahNumber,
    required this.position,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.riwayaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_number'] = Variable<int>(pageNumber);
    map['line_number'] = Variable<int>(lineNumber);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['position'] = Variable<int>(position);
    map['min_x'] = Variable<int>(minX);
    map['max_x'] = Variable<int>(maxX);
    map['min_y'] = Variable<int>(minY);
    map['max_y'] = Variable<int>(maxY);
    map['riwaya_id'] = Variable<int>(riwayaId);
    return map;
  }

  GlyphTableCompanion toCompanion(bool nullToAbsent) {
    return GlyphTableCompanion(
      id: Value(id),
      pageNumber: Value(pageNumber),
      lineNumber: Value(lineNumber),
      surahId: Value(surahId),
      ayahNumber: Value(ayahNumber),
      position: Value(position),
      minX: Value(minX),
      maxX: Value(maxX),
      minY: Value(minY),
      maxY: Value(maxY),
      riwayaId: Value(riwayaId),
    );
  }

  factory GlyphTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlyphTableData(
      id: serializer.fromJson<int>(json['id']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      lineNumber: serializer.fromJson<int>(json['lineNumber']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      position: serializer.fromJson<int>(json['position']),
      minX: serializer.fromJson<int>(json['minX']),
      maxX: serializer.fromJson<int>(json['maxX']),
      minY: serializer.fromJson<int>(json['minY']),
      maxY: serializer.fromJson<int>(json['maxY']),
      riwayaId: serializer.fromJson<int>(json['riwayaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'lineNumber': serializer.toJson<int>(lineNumber),
      'surahId': serializer.toJson<int>(surahId),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'position': serializer.toJson<int>(position),
      'minX': serializer.toJson<int>(minX),
      'maxX': serializer.toJson<int>(maxX),
      'minY': serializer.toJson<int>(minY),
      'maxY': serializer.toJson<int>(maxY),
      'riwayaId': serializer.toJson<int>(riwayaId),
    };
  }

  GlyphTableData copyWith({
    int? id,
    int? pageNumber,
    int? lineNumber,
    int? surahId,
    int? ayahNumber,
    int? position,
    int? minX,
    int? maxX,
    int? minY,
    int? maxY,
    int? riwayaId,
  }) => GlyphTableData(
    id: id ?? this.id,
    pageNumber: pageNumber ?? this.pageNumber,
    lineNumber: lineNumber ?? this.lineNumber,
    surahId: surahId ?? this.surahId,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    position: position ?? this.position,
    minX: minX ?? this.minX,
    maxX: maxX ?? this.maxX,
    minY: minY ?? this.minY,
    maxY: maxY ?? this.maxY,
    riwayaId: riwayaId ?? this.riwayaId,
  );
  GlyphTableData copyWithCompanion(GlyphTableCompanion data) {
    return GlyphTableData(
      id: data.id.present ? data.id.value : this.id,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      lineNumber: data.lineNumber.present
          ? data.lineNumber.value
          : this.lineNumber,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      position: data.position.present ? data.position.value : this.position,
      minX: data.minX.present ? data.minX.value : this.minX,
      maxX: data.maxX.present ? data.maxX.value : this.maxX,
      minY: data.minY.present ? data.minY.value : this.minY,
      maxY: data.maxY.present ? data.maxY.value : this.maxY,
      riwayaId: data.riwayaId.present ? data.riwayaId.value : this.riwayaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlyphTableData(')
          ..write('id: $id, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('lineNumber: $lineNumber, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('position: $position, ')
          ..write('minX: $minX, ')
          ..write('maxX: $maxX, ')
          ..write('minY: $minY, ')
          ..write('maxY: $maxY, ')
          ..write('riwayaId: $riwayaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageNumber,
    lineNumber,
    surahId,
    ayahNumber,
    position,
    minX,
    maxX,
    minY,
    maxY,
    riwayaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlyphTableData &&
          other.id == this.id &&
          other.pageNumber == this.pageNumber &&
          other.lineNumber == this.lineNumber &&
          other.surahId == this.surahId &&
          other.ayahNumber == this.ayahNumber &&
          other.position == this.position &&
          other.minX == this.minX &&
          other.maxX == this.maxX &&
          other.minY == this.minY &&
          other.maxY == this.maxY &&
          other.riwayaId == this.riwayaId);
}

class GlyphTableCompanion extends UpdateCompanion<GlyphTableData> {
  final Value<int> id;
  final Value<int> pageNumber;
  final Value<int> lineNumber;
  final Value<int> surahId;
  final Value<int> ayahNumber;
  final Value<int> position;
  final Value<int> minX;
  final Value<int> maxX;
  final Value<int> minY;
  final Value<int> maxY;
  final Value<int> riwayaId;
  const GlyphTableCompanion({
    this.id = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.lineNumber = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.position = const Value.absent(),
    this.minX = const Value.absent(),
    this.maxX = const Value.absent(),
    this.minY = const Value.absent(),
    this.maxY = const Value.absent(),
    this.riwayaId = const Value.absent(),
  });
  GlyphTableCompanion.insert({
    this.id = const Value.absent(),
    required int pageNumber,
    required int lineNumber,
    required int surahId,
    required int ayahNumber,
    required int position,
    required int minX,
    required int maxX,
    required int minY,
    required int maxY,
    required int riwayaId,
  }) : pageNumber = Value(pageNumber),
       lineNumber = Value(lineNumber),
       surahId = Value(surahId),
       ayahNumber = Value(ayahNumber),
       position = Value(position),
       minX = Value(minX),
       maxX = Value(maxX),
       minY = Value(minY),
       maxY = Value(maxY),
       riwayaId = Value(riwayaId);
  static Insertable<GlyphTableData> custom({
    Expression<int>? id,
    Expression<int>? pageNumber,
    Expression<int>? lineNumber,
    Expression<int>? surahId,
    Expression<int>? ayahNumber,
    Expression<int>? position,
    Expression<int>? minX,
    Expression<int>? maxX,
    Expression<int>? minY,
    Expression<int>? maxY,
    Expression<int>? riwayaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageNumber != null) 'page_number': pageNumber,
      if (lineNumber != null) 'line_number': lineNumber,
      if (surahId != null) 'surah_id': surahId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (position != null) 'position': position,
      if (minX != null) 'min_x': minX,
      if (maxX != null) 'max_x': maxX,
      if (minY != null) 'min_y': minY,
      if (maxY != null) 'max_y': maxY,
      if (riwayaId != null) 'riwaya_id': riwayaId,
    });
  }

  GlyphTableCompanion copyWith({
    Value<int>? id,
    Value<int>? pageNumber,
    Value<int>? lineNumber,
    Value<int>? surahId,
    Value<int>? ayahNumber,
    Value<int>? position,
    Value<int>? minX,
    Value<int>? maxX,
    Value<int>? minY,
    Value<int>? maxY,
    Value<int>? riwayaId,
  }) {
    return GlyphTableCompanion(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      lineNumber: lineNumber ?? this.lineNumber,
      surahId: surahId ?? this.surahId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      position: position ?? this.position,
      minX: minX ?? this.minX,
      maxX: maxX ?? this.maxX,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
      riwayaId: riwayaId ?? this.riwayaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (lineNumber.present) {
      map['line_number'] = Variable<int>(lineNumber.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (minX.present) {
      map['min_x'] = Variable<int>(minX.value);
    }
    if (maxX.present) {
      map['max_x'] = Variable<int>(maxX.value);
    }
    if (minY.present) {
      map['min_y'] = Variable<int>(minY.value);
    }
    if (maxY.present) {
      map['max_y'] = Variable<int>(maxY.value);
    }
    if (riwayaId.present) {
      map['riwaya_id'] = Variable<int>(riwayaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlyphTableCompanion(')
          ..write('id: $id, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('lineNumber: $lineNumber, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('position: $position, ')
          ..write('minX: $minX, ')
          ..write('maxX: $maxX, ')
          ..write('minY: $minY, ')
          ..write('maxY: $maxY, ')
          ..write('riwayaId: $riwayaId')
          ..write(')'))
        .toString();
  }
}

class $BookmarkTableTable extends BookmarkTable
    with TableInfo<$BookmarkTableTable, BookmarkTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _riwayaIdMeta = const VerificationMeta(
    'riwayaId',
  );
  @override
  late final GeneratedColumn<int> riwayaId = GeneratedColumn<int>(
    'riwaya_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageNumber,
    surahId,
    ayahNumber,
    riwayaId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    }
    if (data.containsKey('riwaya_id')) {
      context.handle(
        _riwayaIdMeta,
        riwayaId.isAcceptableOrUnknown(data['riwaya_id']!, _riwayaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_riwayaIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      ),
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      ),
      riwayaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}riwaya_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BookmarkTableTable createAlias(String alias) {
    return $BookmarkTableTable(attachedDatabase, alias);
  }
}

class BookmarkTableData extends DataClass
    implements Insertable<BookmarkTableData> {
  final int id;
  final int pageNumber;
  final int? surahId;
  final int? ayahNumber;
  final int riwayaId;
  final DateTime updatedAt;
  const BookmarkTableData({
    required this.id,
    required this.pageNumber,
    this.surahId,
    this.ayahNumber,
    required this.riwayaId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_number'] = Variable<int>(pageNumber);
    if (!nullToAbsent || surahId != null) {
      map['surah_id'] = Variable<int>(surahId);
    }
    if (!nullToAbsent || ayahNumber != null) {
      map['ayah_number'] = Variable<int>(ayahNumber);
    }
    map['riwaya_id'] = Variable<int>(riwayaId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BookmarkTableCompanion toCompanion(bool nullToAbsent) {
    return BookmarkTableCompanion(
      id: Value(id),
      pageNumber: Value(pageNumber),
      surahId: surahId == null && nullToAbsent
          ? const Value.absent()
          : Value(surahId),
      ayahNumber: ayahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ayahNumber),
      riwayaId: Value(riwayaId),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookmarkTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkTableData(
      id: serializer.fromJson<int>(json['id']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      surahId: serializer.fromJson<int?>(json['surahId']),
      ayahNumber: serializer.fromJson<int?>(json['ayahNumber']),
      riwayaId: serializer.fromJson<int>(json['riwayaId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'surahId': serializer.toJson<int?>(surahId),
      'ayahNumber': serializer.toJson<int?>(ayahNumber),
      'riwayaId': serializer.toJson<int>(riwayaId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BookmarkTableData copyWith({
    int? id,
    int? pageNumber,
    Value<int?> surahId = const Value.absent(),
    Value<int?> ayahNumber = const Value.absent(),
    int? riwayaId,
    DateTime? updatedAt,
  }) => BookmarkTableData(
    id: id ?? this.id,
    pageNumber: pageNumber ?? this.pageNumber,
    surahId: surahId.present ? surahId.value : this.surahId,
    ayahNumber: ayahNumber.present ? ayahNumber.value : this.ayahNumber,
    riwayaId: riwayaId ?? this.riwayaId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BookmarkTableData copyWithCompanion(BookmarkTableCompanion data) {
    return BookmarkTableData(
      id: data.id.present ? data.id.value : this.id,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      riwayaId: data.riwayaId.present ? data.riwayaId.value : this.riwayaId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkTableData(')
          ..write('id: $id, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('riwayaId: $riwayaId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pageNumber, surahId, ayahNumber, riwayaId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkTableData &&
          other.id == this.id &&
          other.pageNumber == this.pageNumber &&
          other.surahId == this.surahId &&
          other.ayahNumber == this.ayahNumber &&
          other.riwayaId == this.riwayaId &&
          other.updatedAt == this.updatedAt);
}

class BookmarkTableCompanion extends UpdateCompanion<BookmarkTableData> {
  final Value<int> id;
  final Value<int> pageNumber;
  final Value<int?> surahId;
  final Value<int?> ayahNumber;
  final Value<int> riwayaId;
  final Value<DateTime> updatedAt;
  const BookmarkTableCompanion({
    this.id = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.riwayaId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BookmarkTableCompanion.insert({
    this.id = const Value.absent(),
    required int pageNumber,
    this.surahId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    required int riwayaId,
    required DateTime updatedAt,
  }) : pageNumber = Value(pageNumber),
       riwayaId = Value(riwayaId),
       updatedAt = Value(updatedAt);
  static Insertable<BookmarkTableData> custom({
    Expression<int>? id,
    Expression<int>? pageNumber,
    Expression<int>? surahId,
    Expression<int>? ayahNumber,
    Expression<int>? riwayaId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageNumber != null) 'page_number': pageNumber,
      if (surahId != null) 'surah_id': surahId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (riwayaId != null) 'riwaya_id': riwayaId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BookmarkTableCompanion copyWith({
    Value<int>? id,
    Value<int>? pageNumber,
    Value<int?>? surahId,
    Value<int?>? ayahNumber,
    Value<int>? riwayaId,
    Value<DateTime>? updatedAt,
  }) {
    return BookmarkTableCompanion(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      surahId: surahId ?? this.surahId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      riwayaId: riwayaId ?? this.riwayaId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (riwayaId.present) {
      map['riwaya_id'] = Variable<int>(riwayaId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkTableCompanion(')
          ..write('id: $id, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('riwayaId: $riwayaId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionTableTable extends ReadingSessionTable
    with TableInfo<$ReadingSessionTableTable, ReadingSessionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startPageMeta = const VerificationMeta(
    'startPage',
  );
  @override
  late final GeneratedColumn<int> startPage = GeneratedColumn<int>(
    'start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endPageMeta = const VerificationMeta(
    'endPage',
  );
  @override
  late final GeneratedColumn<int> endPage = GeneratedColumn<int>(
    'end_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagesReadMeta = const VerificationMeta(
    'pagesRead',
  );
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
    'pages_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riwayaIdMeta = const VerificationMeta(
    'riwayaId',
  );
  @override
  late final GeneratedColumn<int> riwayaId = GeneratedColumn<int>(
    'riwaya_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    startPage,
    endPage,
    pagesRead,
    riwayaId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_session_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSessionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_page')) {
      context.handle(
        _startPageMeta,
        startPage.isAcceptableOrUnknown(data['start_page']!, _startPageMeta),
      );
    } else if (isInserting) {
      context.missing(_startPageMeta);
    }
    if (data.containsKey('end_page')) {
      context.handle(
        _endPageMeta,
        endPage.isAcceptableOrUnknown(data['end_page']!, _endPageMeta),
      );
    } else if (isInserting) {
      context.missing(_endPageMeta);
    }
    if (data.containsKey('pages_read')) {
      context.handle(
        _pagesReadMeta,
        pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta),
      );
    } else if (isInserting) {
      context.missing(_pagesReadMeta);
    }
    if (data.containsKey('riwaya_id')) {
      context.handle(
        _riwayaIdMeta,
        riwayaId.isAcceptableOrUnknown(data['riwaya_id']!, _riwayaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_riwayaIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSessionTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSessionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      startPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_page'],
      )!,
      endPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_page'],
      )!,
      pagesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_read'],
      )!,
      riwayaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}riwaya_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReadingSessionTableTable createAlias(String alias) {
    return $ReadingSessionTableTable(attachedDatabase, alias);
  }
}

class ReadingSessionTableData extends DataClass
    implements Insertable<ReadingSessionTableData> {
  final int id;
  final DateTime date;
  final int startPage;
  final int endPage;
  final int pagesRead;
  final int riwayaId;
  final DateTime createdAt;
  const ReadingSessionTableData({
    required this.id,
    required this.date,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
    required this.riwayaId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['start_page'] = Variable<int>(startPage);
    map['end_page'] = Variable<int>(endPage);
    map['pages_read'] = Variable<int>(pagesRead);
    map['riwaya_id'] = Variable<int>(riwayaId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReadingSessionTableCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionTableCompanion(
      id: Value(id),
      date: Value(date),
      startPage: Value(startPage),
      endPage: Value(endPage),
      pagesRead: Value(pagesRead),
      riwayaId: Value(riwayaId),
      createdAt: Value(createdAt),
    );
  }

  factory ReadingSessionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSessionTableData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      startPage: serializer.fromJson<int>(json['startPage']),
      endPage: serializer.fromJson<int>(json['endPage']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      riwayaId: serializer.fromJson<int>(json['riwayaId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'startPage': serializer.toJson<int>(startPage),
      'endPage': serializer.toJson<int>(endPage),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'riwayaId': serializer.toJson<int>(riwayaId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReadingSessionTableData copyWith({
    int? id,
    DateTime? date,
    int? startPage,
    int? endPage,
    int? pagesRead,
    int? riwayaId,
    DateTime? createdAt,
  }) => ReadingSessionTableData(
    id: id ?? this.id,
    date: date ?? this.date,
    startPage: startPage ?? this.startPage,
    endPage: endPage ?? this.endPage,
    pagesRead: pagesRead ?? this.pagesRead,
    riwayaId: riwayaId ?? this.riwayaId,
    createdAt: createdAt ?? this.createdAt,
  );
  ReadingSessionTableData copyWithCompanion(ReadingSessionTableCompanion data) {
    return ReadingSessionTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      startPage: data.startPage.present ? data.startPage.value : this.startPage,
      endPage: data.endPage.present ? data.endPage.value : this.endPage,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      riwayaId: data.riwayaId.present ? data.riwayaId.value : this.riwayaId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('riwayaId: $riwayaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, startPage, endPage, pagesRead, riwayaId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSessionTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.startPage == this.startPage &&
          other.endPage == this.endPage &&
          other.pagesRead == this.pagesRead &&
          other.riwayaId == this.riwayaId &&
          other.createdAt == this.createdAt);
}

class ReadingSessionTableCompanion
    extends UpdateCompanion<ReadingSessionTableData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> startPage;
  final Value<int> endPage;
  final Value<int> pagesRead;
  final Value<int> riwayaId;
  final Value<DateTime> createdAt;
  const ReadingSessionTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.startPage = const Value.absent(),
    this.endPage = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.riwayaId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReadingSessionTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int startPage,
    required int endPage,
    required int pagesRead,
    required int riwayaId,
    required DateTime createdAt,
  }) : date = Value(date),
       startPage = Value(startPage),
       endPage = Value(endPage),
       pagesRead = Value(pagesRead),
       riwayaId = Value(riwayaId),
       createdAt = Value(createdAt);
  static Insertable<ReadingSessionTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? startPage,
    Expression<int>? endPage,
    Expression<int>? pagesRead,
    Expression<int>? riwayaId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (startPage != null) 'start_page': startPage,
      if (endPage != null) 'end_page': endPage,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (riwayaId != null) 'riwaya_id': riwayaId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReadingSessionTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? startPage,
    Value<int>? endPage,
    Value<int>? pagesRead,
    Value<int>? riwayaId,
    Value<DateTime>? createdAt,
  }) {
    return ReadingSessionTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      pagesRead: pagesRead ?? this.pagesRead,
      riwayaId: riwayaId ?? this.riwayaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startPage.present) {
      map['start_page'] = Variable<int>(startPage.value);
    }
    if (endPage.present) {
      map['end_page'] = Variable<int>(endPage.value);
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (riwayaId.present) {
      map['riwaya_id'] = Variable<int>(riwayaId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('riwayaId: $riwayaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AyahTextTableTable extends AyahTextTable
    with TableInfo<$AyahTextTableTable, AyahTextTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahTextTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahTextMeta = const VerificationMeta(
    'ayahText',
  );
  @override
  late final GeneratedColumn<String> ayahText = GeneratedColumn<String>(
    'ayah_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textNormalizedMeta = const VerificationMeta(
    'textNormalized',
  );
  @override
  late final GeneratedColumn<String> textNormalized = GeneratedColumn<String>(
    'text_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahId,
    ayahNumber,
    pageNumber,
    ayahText,
    textNormalized,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah_text_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahTextTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('ayah_text')) {
      context.handle(
        _ayahTextMeta,
        ayahText.isAcceptableOrUnknown(data['ayah_text']!, _ayahTextMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahTextMeta);
    }
    if (data.containsKey('text_normalized')) {
      context.handle(
        _textNormalizedMeta,
        textNormalized.isAcceptableOrUnknown(
          data['text_normalized']!,
          _textNormalizedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AyahTextTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahTextTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      ayahText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ayah_text'],
      )!,
      textNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_normalized'],
      )!,
    );
  }

  @override
  $AyahTextTableTable createAlias(String alias) {
    return $AyahTextTableTable(attachedDatabase, alias);
  }
}

class AyahTextTableData extends DataClass
    implements Insertable<AyahTextTableData> {
  final int id;
  final int surahId;
  final int ayahNumber;
  final int pageNumber;
  final String ayahText;

  /// Ayah text with all tashkeel/diacritics stripped for search matching.
  final String textNormalized;
  const AyahTextTableData({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.pageNumber,
    required this.ayahText,
    required this.textNormalized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['page_number'] = Variable<int>(pageNumber);
    map['ayah_text'] = Variable<String>(ayahText);
    map['text_normalized'] = Variable<String>(textNormalized);
    return map;
  }

  AyahTextTableCompanion toCompanion(bool nullToAbsent) {
    return AyahTextTableCompanion(
      id: Value(id),
      surahId: Value(surahId),
      ayahNumber: Value(ayahNumber),
      pageNumber: Value(pageNumber),
      ayahText: Value(ayahText),
      textNormalized: Value(textNormalized),
    );
  }

  factory AyahTextTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahTextTableData(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      ayahText: serializer.fromJson<String>(json['ayahText']),
      textNormalized: serializer.fromJson<String>(json['textNormalized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'ayahText': serializer.toJson<String>(ayahText),
      'textNormalized': serializer.toJson<String>(textNormalized),
    };
  }

  AyahTextTableData copyWith({
    int? id,
    int? surahId,
    int? ayahNumber,
    int? pageNumber,
    String? ayahText,
    String? textNormalized,
  }) => AyahTextTableData(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    pageNumber: pageNumber ?? this.pageNumber,
    ayahText: ayahText ?? this.ayahText,
    textNormalized: textNormalized ?? this.textNormalized,
  );
  AyahTextTableData copyWithCompanion(AyahTextTableCompanion data) {
    return AyahTextTableData(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      ayahText: data.ayahText.present ? data.ayahText.value : this.ayahText,
      textNormalized: data.textNormalized.present
          ? data.textNormalized.value
          : this.textNormalized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahTextTableData(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('ayahText: $ayahText, ')
          ..write('textNormalized: $textNormalized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surahId,
    ayahNumber,
    pageNumber,
    ayahText,
    textNormalized,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahTextTableData &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.ayahNumber == this.ayahNumber &&
          other.pageNumber == this.pageNumber &&
          other.ayahText == this.ayahText &&
          other.textNormalized == this.textNormalized);
}

class AyahTextTableCompanion extends UpdateCompanion<AyahTextTableData> {
  final Value<int> id;
  final Value<int> surahId;
  final Value<int> ayahNumber;
  final Value<int> pageNumber;
  final Value<String> ayahText;
  final Value<String> textNormalized;
  const AyahTextTableCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.ayahText = const Value.absent(),
    this.textNormalized = const Value.absent(),
  });
  AyahTextTableCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required int ayahNumber,
    required int pageNumber,
    required String ayahText,
    this.textNormalized = const Value.absent(),
  }) : surahId = Value(surahId),
       ayahNumber = Value(ayahNumber),
       pageNumber = Value(pageNumber),
       ayahText = Value(ayahText);
  static Insertable<AyahTextTableData> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<int>? ayahNumber,
    Expression<int>? pageNumber,
    Expression<String>? ayahText,
    Expression<String>? textNormalized,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (pageNumber != null) 'page_number': pageNumber,
      if (ayahText != null) 'ayah_text': ayahText,
      if (textNormalized != null) 'text_normalized': textNormalized,
    });
  }

  AyahTextTableCompanion copyWith({
    Value<int>? id,
    Value<int>? surahId,
    Value<int>? ayahNumber,
    Value<int>? pageNumber,
    Value<String>? ayahText,
    Value<String>? textNormalized,
  }) {
    return AyahTextTableCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      ayahText: ayahText ?? this.ayahText,
      textNormalized: textNormalized ?? this.textNormalized,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (ayahText.present) {
      map['ayah_text'] = Variable<String>(ayahText.value);
    }
    if (textNormalized.present) {
      map['text_normalized'] = Variable<String>(textNormalized.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahTextTableCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('ayahText: $ayahText, ')
          ..write('textNormalized: $textNormalized')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RiwayaTableTable riwayaTable = $RiwayaTableTable(this);
  late final $SurahTableTable surahTable = $SurahTableTable(this);
  late final $PageAyahIndexTableTable pageAyahIndexTable =
      $PageAyahIndexTableTable(this);
  late final $GlyphTableTable glyphTable = $GlyphTableTable(this);
  late final $BookmarkTableTable bookmarkTable = $BookmarkTableTable(this);
  late final $ReadingSessionTableTable readingSessionTable =
      $ReadingSessionTableTable(this);
  late final $AyahTextTableTable ayahTextTable = $AyahTextTableTable(this);
  late final GlyphDao glyphDao = GlyphDao(this as AppDatabase);
  late final BookmarkDao bookmarkDao = BookmarkDao(this as AppDatabase);
  late final ReadingSessionDao readingSessionDao = ReadingSessionDao(
    this as AppDatabase,
  );
  late final SurahDao surahDao = SurahDao(this as AppDatabase);
  late final RiwayaDao riwayaDao = RiwayaDao(this as AppDatabase);
  late final PageAyahIndexDao pageAyahIndexDao = PageAyahIndexDao(
    this as AppDatabase,
  );
  late final AyahTextDao ayahTextDao = AyahTextDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    riwayaTable,
    surahTable,
    pageAyahIndexTable,
    glyphTable,
    bookmarkTable,
    readingSessionTable,
    ayahTextTable,
  ];
}

typedef $$RiwayaTableTableCreateCompanionBuilder =
    RiwayaTableCompanion Function({
      Value<int> id,
      required String key,
      required String displayName,
      Value<bool> isBundled,
      Value<bool> isDownloaded,
      Value<DateTime?> downloadedAt,
      Value<int> imageNativeWidth,
      Value<int> totalPages,
    });
typedef $$RiwayaTableTableUpdateCompanionBuilder =
    RiwayaTableCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> displayName,
      Value<bool> isBundled,
      Value<bool> isDownloaded,
      Value<DateTime?> downloadedAt,
      Value<int> imageNativeWidth,
      Value<int> totalPages,
    });

class $$RiwayaTableTableFilterComposer
    extends Composer<_$AppDatabase, $RiwayaTableTable> {
  $$RiwayaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBundled => $composableBuilder(
    column: $table.isBundled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageNativeWidth => $composableBuilder(
    column: $table.imageNativeWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RiwayaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RiwayaTableTable> {
  $$RiwayaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBundled => $composableBuilder(
    column: $table.isBundled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageNativeWidth => $composableBuilder(
    column: $table.imageNativeWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RiwayaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RiwayaTableTable> {
  $$RiwayaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBundled =>
      $composableBuilder(column: $table.isBundled, builder: (column) => column);

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imageNativeWidth => $composableBuilder(
    column: $table.imageNativeWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );
}

class $$RiwayaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RiwayaTableTable,
          RiwayaTableData,
          $$RiwayaTableTableFilterComposer,
          $$RiwayaTableTableOrderingComposer,
          $$RiwayaTableTableAnnotationComposer,
          $$RiwayaTableTableCreateCompanionBuilder,
          $$RiwayaTableTableUpdateCompanionBuilder,
          (
            RiwayaTableData,
            BaseReferences<_$AppDatabase, $RiwayaTableTable, RiwayaTableData>,
          ),
          RiwayaTableData,
          PrefetchHooks Function()
        > {
  $$RiwayaTableTableTableManager(_$AppDatabase db, $RiwayaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RiwayaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RiwayaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RiwayaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<bool> isBundled = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<int> imageNativeWidth = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
              }) => RiwayaTableCompanion(
                id: id,
                key: key,
                displayName: displayName,
                isBundled: isBundled,
                isDownloaded: isDownloaded,
                downloadedAt: downloadedAt,
                imageNativeWidth: imageNativeWidth,
                totalPages: totalPages,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String displayName,
                Value<bool> isBundled = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<int> imageNativeWidth = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
              }) => RiwayaTableCompanion.insert(
                id: id,
                key: key,
                displayName: displayName,
                isBundled: isBundled,
                isDownloaded: isDownloaded,
                downloadedAt: downloadedAt,
                imageNativeWidth: imageNativeWidth,
                totalPages: totalPages,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RiwayaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RiwayaTableTable,
      RiwayaTableData,
      $$RiwayaTableTableFilterComposer,
      $$RiwayaTableTableOrderingComposer,
      $$RiwayaTableTableAnnotationComposer,
      $$RiwayaTableTableCreateCompanionBuilder,
      $$RiwayaTableTableUpdateCompanionBuilder,
      (
        RiwayaTableData,
        BaseReferences<_$AppDatabase, $RiwayaTableTable, RiwayaTableData>,
      ),
      RiwayaTableData,
      PrefetchHooks Function()
    >;
typedef $$SurahTableTableCreateCompanionBuilder =
    SurahTableCompanion Function({
      Value<int> id,
      required String nameArabic,
      required String nameTransliterated,
      required int ayahCount,
    });
typedef $$SurahTableTableUpdateCompanionBuilder =
    SurahTableCompanion Function({
      Value<int> id,
      Value<String> nameArabic,
      Value<String> nameTransliterated,
      Value<int> ayahCount,
    });

class $$SurahTableTableFilterComposer
    extends Composer<_$AppDatabase, $SurahTableTable> {
  $$SurahTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameTransliterated => $composableBuilder(
    column: $table.nameTransliterated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SurahTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SurahTableTable> {
  $$SurahTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameTransliterated => $composableBuilder(
    column: $table.nameTransliterated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurahTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurahTableTable> {
  $$SurahTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameTransliterated => $composableBuilder(
    column: $table.nameTransliterated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahCount =>
      $composableBuilder(column: $table.ayahCount, builder: (column) => column);
}

class $$SurahTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SurahTableTable,
          SurahTableData,
          $$SurahTableTableFilterComposer,
          $$SurahTableTableOrderingComposer,
          $$SurahTableTableAnnotationComposer,
          $$SurahTableTableCreateCompanionBuilder,
          $$SurahTableTableUpdateCompanionBuilder,
          (
            SurahTableData,
            BaseReferences<_$AppDatabase, $SurahTableTable, SurahTableData>,
          ),
          SurahTableData,
          PrefetchHooks Function()
        > {
  $$SurahTableTableTableManager(_$AppDatabase db, $SurahTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameTransliterated = const Value.absent(),
                Value<int> ayahCount = const Value.absent(),
              }) => SurahTableCompanion(
                id: id,
                nameArabic: nameArabic,
                nameTransliterated: nameTransliterated,
                ayahCount: ayahCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nameArabic,
                required String nameTransliterated,
                required int ayahCount,
              }) => SurahTableCompanion.insert(
                id: id,
                nameArabic: nameArabic,
                nameTransliterated: nameTransliterated,
                ayahCount: ayahCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SurahTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SurahTableTable,
      SurahTableData,
      $$SurahTableTableFilterComposer,
      $$SurahTableTableOrderingComposer,
      $$SurahTableTableAnnotationComposer,
      $$SurahTableTableCreateCompanionBuilder,
      $$SurahTableTableUpdateCompanionBuilder,
      (
        SurahTableData,
        BaseReferences<_$AppDatabase, $SurahTableTable, SurahTableData>,
      ),
      SurahTableData,
      PrefetchHooks Function()
    >;
typedef $$PageAyahIndexTableTableCreateCompanionBuilder =
    PageAyahIndexTableCompanion Function({
      required int pageNumber,
      required int surahId,
      required int ayahNumber,
      required int riwayaId,
      Value<int> rowid,
    });
typedef $$PageAyahIndexTableTableUpdateCompanionBuilder =
    PageAyahIndexTableCompanion Function({
      Value<int> pageNumber,
      Value<int> surahId,
      Value<int> ayahNumber,
      Value<int> riwayaId,
      Value<int> rowid,
    });

class $$PageAyahIndexTableTableFilterComposer
    extends Composer<_$AppDatabase, $PageAyahIndexTableTable> {
  $$PageAyahIndexTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PageAyahIndexTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PageAyahIndexTableTable> {
  $$PageAyahIndexTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PageAyahIndexTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PageAyahIndexTableTable> {
  $$PageAyahIndexTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get riwayaId =>
      $composableBuilder(column: $table.riwayaId, builder: (column) => column);
}

class $$PageAyahIndexTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PageAyahIndexTableTable,
          PageAyahIndexTableData,
          $$PageAyahIndexTableTableFilterComposer,
          $$PageAyahIndexTableTableOrderingComposer,
          $$PageAyahIndexTableTableAnnotationComposer,
          $$PageAyahIndexTableTableCreateCompanionBuilder,
          $$PageAyahIndexTableTableUpdateCompanionBuilder,
          (
            PageAyahIndexTableData,
            BaseReferences<
              _$AppDatabase,
              $PageAyahIndexTableTable,
              PageAyahIndexTableData
            >,
          ),
          PageAyahIndexTableData,
          PrefetchHooks Function()
        > {
  $$PageAyahIndexTableTableTableManager(
    _$AppDatabase db,
    $PageAyahIndexTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PageAyahIndexTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PageAyahIndexTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PageAyahIndexTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pageNumber = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<int> riwayaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PageAyahIndexTableCompanion(
                pageNumber: pageNumber,
                surahId: surahId,
                ayahNumber: ayahNumber,
                riwayaId: riwayaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pageNumber,
                required int surahId,
                required int ayahNumber,
                required int riwayaId,
                Value<int> rowid = const Value.absent(),
              }) => PageAyahIndexTableCompanion.insert(
                pageNumber: pageNumber,
                surahId: surahId,
                ayahNumber: ayahNumber,
                riwayaId: riwayaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PageAyahIndexTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PageAyahIndexTableTable,
      PageAyahIndexTableData,
      $$PageAyahIndexTableTableFilterComposer,
      $$PageAyahIndexTableTableOrderingComposer,
      $$PageAyahIndexTableTableAnnotationComposer,
      $$PageAyahIndexTableTableCreateCompanionBuilder,
      $$PageAyahIndexTableTableUpdateCompanionBuilder,
      (
        PageAyahIndexTableData,
        BaseReferences<
          _$AppDatabase,
          $PageAyahIndexTableTable,
          PageAyahIndexTableData
        >,
      ),
      PageAyahIndexTableData,
      PrefetchHooks Function()
    >;
typedef $$GlyphTableTableCreateCompanionBuilder =
    GlyphTableCompanion Function({
      Value<int> id,
      required int pageNumber,
      required int lineNumber,
      required int surahId,
      required int ayahNumber,
      required int position,
      required int minX,
      required int maxX,
      required int minY,
      required int maxY,
      required int riwayaId,
    });
typedef $$GlyphTableTableUpdateCompanionBuilder =
    GlyphTableCompanion Function({
      Value<int> id,
      Value<int> pageNumber,
      Value<int> lineNumber,
      Value<int> surahId,
      Value<int> ayahNumber,
      Value<int> position,
      Value<int> minX,
      Value<int> maxX,
      Value<int> minY,
      Value<int> maxY,
      Value<int> riwayaId,
    });

class $$GlyphTableTableFilterComposer
    extends Composer<_$AppDatabase, $GlyphTableTable> {
  $$GlyphTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GlyphTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GlyphTableTable> {
  $$GlyphTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GlyphTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GlyphTableTable> {
  $$GlyphTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get minX =>
      $composableBuilder(column: $table.minX, builder: (column) => column);

  GeneratedColumn<int> get maxX =>
      $composableBuilder(column: $table.maxX, builder: (column) => column);

  GeneratedColumn<int> get minY =>
      $composableBuilder(column: $table.minY, builder: (column) => column);

  GeneratedColumn<int> get maxY =>
      $composableBuilder(column: $table.maxY, builder: (column) => column);

  GeneratedColumn<int> get riwayaId =>
      $composableBuilder(column: $table.riwayaId, builder: (column) => column);
}

class $$GlyphTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GlyphTableTable,
          GlyphTableData,
          $$GlyphTableTableFilterComposer,
          $$GlyphTableTableOrderingComposer,
          $$GlyphTableTableAnnotationComposer,
          $$GlyphTableTableCreateCompanionBuilder,
          $$GlyphTableTableUpdateCompanionBuilder,
          (
            GlyphTableData,
            BaseReferences<_$AppDatabase, $GlyphTableTable, GlyphTableData>,
          ),
          GlyphTableData,
          PrefetchHooks Function()
        > {
  $$GlyphTableTableTableManager(_$AppDatabase db, $GlyphTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlyphTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlyphTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlyphTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageNumber = const Value.absent(),
                Value<int> lineNumber = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> minX = const Value.absent(),
                Value<int> maxX = const Value.absent(),
                Value<int> minY = const Value.absent(),
                Value<int> maxY = const Value.absent(),
                Value<int> riwayaId = const Value.absent(),
              }) => GlyphTableCompanion(
                id: id,
                pageNumber: pageNumber,
                lineNumber: lineNumber,
                surahId: surahId,
                ayahNumber: ayahNumber,
                position: position,
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                riwayaId: riwayaId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageNumber,
                required int lineNumber,
                required int surahId,
                required int ayahNumber,
                required int position,
                required int minX,
                required int maxX,
                required int minY,
                required int maxY,
                required int riwayaId,
              }) => GlyphTableCompanion.insert(
                id: id,
                pageNumber: pageNumber,
                lineNumber: lineNumber,
                surahId: surahId,
                ayahNumber: ayahNumber,
                position: position,
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                riwayaId: riwayaId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GlyphTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GlyphTableTable,
      GlyphTableData,
      $$GlyphTableTableFilterComposer,
      $$GlyphTableTableOrderingComposer,
      $$GlyphTableTableAnnotationComposer,
      $$GlyphTableTableCreateCompanionBuilder,
      $$GlyphTableTableUpdateCompanionBuilder,
      (
        GlyphTableData,
        BaseReferences<_$AppDatabase, $GlyphTableTable, GlyphTableData>,
      ),
      GlyphTableData,
      PrefetchHooks Function()
    >;
typedef $$BookmarkTableTableCreateCompanionBuilder =
    BookmarkTableCompanion Function({
      Value<int> id,
      required int pageNumber,
      Value<int?> surahId,
      Value<int?> ayahNumber,
      required int riwayaId,
      required DateTime updatedAt,
    });
typedef $$BookmarkTableTableUpdateCompanionBuilder =
    BookmarkTableCompanion Function({
      Value<int> id,
      Value<int> pageNumber,
      Value<int?> surahId,
      Value<int?> ayahNumber,
      Value<int> riwayaId,
      Value<DateTime> updatedAt,
    });

class $$BookmarkTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkTableTable> {
  $$BookmarkTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarkTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkTableTable> {
  $$BookmarkTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarkTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkTableTable> {
  $$BookmarkTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get riwayaId =>
      $composableBuilder(column: $table.riwayaId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BookmarkTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarkTableTable,
          BookmarkTableData,
          $$BookmarkTableTableFilterComposer,
          $$BookmarkTableTableOrderingComposer,
          $$BookmarkTableTableAnnotationComposer,
          $$BookmarkTableTableCreateCompanionBuilder,
          $$BookmarkTableTableUpdateCompanionBuilder,
          (
            BookmarkTableData,
            BaseReferences<
              _$AppDatabase,
              $BookmarkTableTable,
              BookmarkTableData
            >,
          ),
          BookmarkTableData,
          PrefetchHooks Function()
        > {
  $$BookmarkTableTableTableManager(_$AppDatabase db, $BookmarkTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pageNumber = const Value.absent(),
                Value<int?> surahId = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<int> riwayaId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BookmarkTableCompanion(
                id: id,
                pageNumber: pageNumber,
                surahId: surahId,
                ayahNumber: ayahNumber,
                riwayaId: riwayaId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pageNumber,
                Value<int?> surahId = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                required int riwayaId,
                required DateTime updatedAt,
              }) => BookmarkTableCompanion.insert(
                id: id,
                pageNumber: pageNumber,
                surahId: surahId,
                ayahNumber: ayahNumber,
                riwayaId: riwayaId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarkTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarkTableTable,
      BookmarkTableData,
      $$BookmarkTableTableFilterComposer,
      $$BookmarkTableTableOrderingComposer,
      $$BookmarkTableTableAnnotationComposer,
      $$BookmarkTableTableCreateCompanionBuilder,
      $$BookmarkTableTableUpdateCompanionBuilder,
      (
        BookmarkTableData,
        BaseReferences<_$AppDatabase, $BookmarkTableTable, BookmarkTableData>,
      ),
      BookmarkTableData,
      PrefetchHooks Function()
    >;
typedef $$ReadingSessionTableTableCreateCompanionBuilder =
    ReadingSessionTableCompanion Function({
      Value<int> id,
      required DateTime date,
      required int startPage,
      required int endPage,
      required int pagesRead,
      required int riwayaId,
      required DateTime createdAt,
    });
typedef $$ReadingSessionTableTableUpdateCompanionBuilder =
    ReadingSessionTableCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> startPage,
      Value<int> endPage,
      Value<int> pagesRead,
      Value<int> riwayaId,
      Value<DateTime> createdAt,
    });

class $$ReadingSessionTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionTableTable> {
  $$ReadingSessionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingSessionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionTableTable> {
  $$ReadingSessionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get riwayaId => $composableBuilder(
    column: $table.riwayaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingSessionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionTableTable> {
  $$ReadingSessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get startPage =>
      $composableBuilder(column: $table.startPage, builder: (column) => column);

  GeneratedColumn<int> get endPage =>
      $composableBuilder(column: $table.endPage, builder: (column) => column);

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumn<int> get riwayaId =>
      $composableBuilder(column: $table.riwayaId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReadingSessionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingSessionTableTable,
          ReadingSessionTableData,
          $$ReadingSessionTableTableFilterComposer,
          $$ReadingSessionTableTableOrderingComposer,
          $$ReadingSessionTableTableAnnotationComposer,
          $$ReadingSessionTableTableCreateCompanionBuilder,
          $$ReadingSessionTableTableUpdateCompanionBuilder,
          (
            ReadingSessionTableData,
            BaseReferences<
              _$AppDatabase,
              $ReadingSessionTableTable,
              ReadingSessionTableData
            >,
          ),
          ReadingSessionTableData,
          PrefetchHooks Function()
        > {
  $$ReadingSessionTableTableTableManager(
    _$AppDatabase db,
    $ReadingSessionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingSessionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<int> endPage = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<int> riwayaId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReadingSessionTableCompanion(
                id: id,
                date: date,
                startPage: startPage,
                endPage: endPage,
                pagesRead: pagesRead,
                riwayaId: riwayaId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int startPage,
                required int endPage,
                required int pagesRead,
                required int riwayaId,
                required DateTime createdAt,
              }) => ReadingSessionTableCompanion.insert(
                id: id,
                date: date,
                startPage: startPage,
                endPage: endPage,
                pagesRead: pagesRead,
                riwayaId: riwayaId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingSessionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingSessionTableTable,
      ReadingSessionTableData,
      $$ReadingSessionTableTableFilterComposer,
      $$ReadingSessionTableTableOrderingComposer,
      $$ReadingSessionTableTableAnnotationComposer,
      $$ReadingSessionTableTableCreateCompanionBuilder,
      $$ReadingSessionTableTableUpdateCompanionBuilder,
      (
        ReadingSessionTableData,
        BaseReferences<
          _$AppDatabase,
          $ReadingSessionTableTable,
          ReadingSessionTableData
        >,
      ),
      ReadingSessionTableData,
      PrefetchHooks Function()
    >;
typedef $$AyahTextTableTableCreateCompanionBuilder =
    AyahTextTableCompanion Function({
      Value<int> id,
      required int surahId,
      required int ayahNumber,
      required int pageNumber,
      required String ayahText,
      Value<String> textNormalized,
    });
typedef $$AyahTextTableTableUpdateCompanionBuilder =
    AyahTextTableCompanion Function({
      Value<int> id,
      Value<int> surahId,
      Value<int> ayahNumber,
      Value<int> pageNumber,
      Value<String> ayahText,
      Value<String> textNormalized,
    });

class $$AyahTextTableTableFilterComposer
    extends Composer<_$AppDatabase, $AyahTextTableTable> {
  $$AyahTextTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ayahText => $composableBuilder(
    column: $table.ayahText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textNormalized => $composableBuilder(
    column: $table.textNormalized,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AyahTextTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AyahTextTableTable> {
  $$AyahTextTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ayahText => $composableBuilder(
    column: $table.ayahText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textNormalized => $composableBuilder(
    column: $table.textNormalized,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AyahTextTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AyahTextTableTable> {
  $$AyahTextTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ayahText =>
      $composableBuilder(column: $table.ayahText, builder: (column) => column);

  GeneratedColumn<String> get textNormalized => $composableBuilder(
    column: $table.textNormalized,
    builder: (column) => column,
  );
}

class $$AyahTextTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AyahTextTableTable,
          AyahTextTableData,
          $$AyahTextTableTableFilterComposer,
          $$AyahTextTableTableOrderingComposer,
          $$AyahTextTableTableAnnotationComposer,
          $$AyahTextTableTableCreateCompanionBuilder,
          $$AyahTextTableTableUpdateCompanionBuilder,
          (
            AyahTextTableData,
            BaseReferences<
              _$AppDatabase,
              $AyahTextTableTable,
              AyahTextTableData
            >,
          ),
          AyahTextTableData,
          PrefetchHooks Function()
        > {
  $$AyahTextTableTableTableManager(_$AppDatabase db, $AyahTextTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahTextTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahTextTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahTextTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<int> pageNumber = const Value.absent(),
                Value<String> ayahText = const Value.absent(),
                Value<String> textNormalized = const Value.absent(),
              }) => AyahTextTableCompanion(
                id: id,
                surahId: surahId,
                ayahNumber: ayahNumber,
                pageNumber: pageNumber,
                ayahText: ayahText,
                textNormalized: textNormalized,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahId,
                required int ayahNumber,
                required int pageNumber,
                required String ayahText,
                Value<String> textNormalized = const Value.absent(),
              }) => AyahTextTableCompanion.insert(
                id: id,
                surahId: surahId,
                ayahNumber: ayahNumber,
                pageNumber: pageNumber,
                ayahText: ayahText,
                textNormalized: textNormalized,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AyahTextTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AyahTextTableTable,
      AyahTextTableData,
      $$AyahTextTableTableFilterComposer,
      $$AyahTextTableTableOrderingComposer,
      $$AyahTextTableTableAnnotationComposer,
      $$AyahTextTableTableCreateCompanionBuilder,
      $$AyahTextTableTableUpdateCompanionBuilder,
      (
        AyahTextTableData,
        BaseReferences<_$AppDatabase, $AyahTextTableTable, AyahTextTableData>,
      ),
      AyahTextTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RiwayaTableTableTableManager get riwayaTable =>
      $$RiwayaTableTableTableManager(_db, _db.riwayaTable);
  $$SurahTableTableTableManager get surahTable =>
      $$SurahTableTableTableManager(_db, _db.surahTable);
  $$PageAyahIndexTableTableTableManager get pageAyahIndexTable =>
      $$PageAyahIndexTableTableTableManager(_db, _db.pageAyahIndexTable);
  $$GlyphTableTableTableManager get glyphTable =>
      $$GlyphTableTableTableManager(_db, _db.glyphTable);
  $$BookmarkTableTableTableManager get bookmarkTable =>
      $$BookmarkTableTableTableManager(_db, _db.bookmarkTable);
  $$ReadingSessionTableTableTableManager get readingSessionTable =>
      $$ReadingSessionTableTableTableManager(_db, _db.readingSessionTable);
  $$AyahTextTableTableTableManager get ayahTextTable =>
      $$AyahTextTableTableTableManager(_db, _db.ayahTextTable);
}
