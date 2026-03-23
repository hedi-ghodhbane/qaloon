// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khatmah_dao.dart';

// ignore_for_file: type=lint
mixin _$KhatmahDaoMixin on DatabaseAccessor<AppDatabase> {
  $KhatmahTableTable get khatmahTable => attachedDatabase.khatmahTable;
  $KhatmahDayTableTable get khatmahDayTable => attachedDatabase.khatmahDayTable;
  KhatmahDaoManager get managers => KhatmahDaoManager(this);
}

class KhatmahDaoManager {
  final _$KhatmahDaoMixin _db;
  KhatmahDaoManager(this._db);
  $$KhatmahTableTableTableManager get khatmahTable =>
      $$KhatmahTableTableTableManager(_db.attachedDatabase, _db.khatmahTable);
  $$KhatmahDayTableTableTableManager get khatmahDayTable =>
      $$KhatmahDayTableTableTableManager(
        _db.attachedDatabase,
        _db.khatmahDayTable,
      );
}
