import 'package:collection/collection.dart';
import '../uid/id.dart';

class StoreRecord {
  int verstamp = 0;
  Id id = Id();
  String type = "";
  String payload = "";
  bool deleted = false;

  StoreRecord(this.id, {this.type = "", this.payload = "", this.deleted = false});
  StoreRecord.empty();

  @override
  bool operator ==(Object other) {
    return other is StoreRecord &&
        verstamp == other.verstamp &&
        id == other.id &&
        type == other.type &&
        payload == other.payload &&
        deleted == other.deleted;
  }

  @override
  int get hashCode => Object.hash(verstamp, id, type, payload, deleted);

  factory StoreRecord.fromJson(Map<String, dynamic> data) {
    StoreRecord r = StoreRecord.empty();
    r.verstamp = data['verstamp'] as int;
    r.type = data['type'] as String;
    r.id = Id(data['id'] as String);
    r.payload = data['payload'] as String;
    r.deleted = data['deleted'] as bool;
    return r;
  }

  Map<String, dynamic> toJson() {
    return {
      'verstamp': verstamp,
      'type': type,
      'id': id.toString(),
      'payload': payload,
      'deleted': deleted,
    };
  }
}

class StoreObject {
  Id id = Id();
  Map<Id, StoreRecord> records = {};

  StoreObject(this.id);

  @override
  bool operator ==(Object other) {
    return other is StoreObject && id == other.id && const MapEquality().equals(records, other.records);
  }

  @override
  int get hashCode => Object.hash(id.hashCode, const MapEquality().hash(records));

  void add(StoreRecord r) {
    records[r.id] = r;
  }

  factory StoreObject.fromJson(Id objId, List<dynamic> records, {bool deleted = false}) {
    StoreObject obj = StoreObject(objId);
    for (var rd in records) {
      var r = StoreRecord.fromJson(rd as Map<String, dynamic>);
      if (!deleted && r.deleted) {
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
