import 'package:collection/collection.dart';
import 'package:shoplist/warp/uid/uid.dart';

class StoreRecord {
  Uid id = Uid.invalid;
  String type = "";
  int verstamp = 0;
  bool deleted = false;
  String payload = "";

  StoreRecord(this.id, {this.type = "", this.payload = "", this.deleted = false});
  StoreRecord.empty();

  @override
  bool operator ==(Object other) {
    return other is StoreRecord &&
        id == other.id &&
        type == other.type &&
        verstamp == other.verstamp &&
        deleted == other.deleted &&
        payload == other.payload;
  }

  @override
  int get hashCode => Object.hash(id, type, verstamp, deleted, payload);

  factory StoreRecord.fromJson(Map<String, dynamic> data) {
    StoreRecord r = StoreRecord.empty();
    r.id = Uid.fromString(data['id'] as String);
    r.type = data['type'] as String;
    r.verstamp = data['verstamp'] as int;
    r.deleted = data['deleted'] as bool;
    r.payload = data['payload'] as String;
    return r;
  }

  Map<String, dynamic> toJson() {
    return {'id': id.toString(), 'type': type, 'verstamp': verstamp, 'deleted': deleted, 'payload': payload};
  }
}

class StoreObject {
  String name;
  Map<Uid, StoreRecord> records = {};

  StoreObject(this.name);

  @override
  bool operator ==(Object other) {
    return other is StoreObject && name == other.name && const MapEquality().equals(records, other.records);
  }

  @override
  int get hashCode => Object.hash(name.hashCode, const MapEquality().hash(records));

  void add(StoreRecord r) {
    records[r.id] = r;
  }

  factory StoreObject.fromJson(String name, List<dynamic> records, {bool includeDeletedRecs = false}) {
    StoreObject obj = StoreObject(name);
    for (var rd in records) {
      var r = StoreRecord.fromJson(rd as Map<String, dynamic>);
      if (!includeDeletedRecs && r.deleted) {
        continue;
      }
      obj.records[r.id] = r;
    }
    return obj;
  }

  List<dynamic> toJson() {
    return records.values.map((e) => e.toJson()).toList();
  }
}
