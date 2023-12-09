import '../uid/id.dart';

class StoreRecord {
  DateTime timestamp = DateTime.utc(1970);
  ID id = ID();
  String type = "";
  String payload = "";

  StoreRecord(this.id, {this.type = "", this.payload = ""});
  StoreRecord.empty();

  factory StoreRecord.fromJson(Map<String, dynamic> data) {
    StoreRecord r = StoreRecord.empty();
    r.timestamp = DateTime.parse(data['timestamp'] as String);
    r.type = data['type'] as String;
    r.id = ID(data['id'] as String);
    r.payload = data['payload'] as String;
    return r;
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'id': id.toString(),
      'payload': payload,
    };
  }
}

class StoreObject {
  Map<ID, StoreRecord> records = {};

  StoreObject();

  factory StoreObject.fromJson(List<dynamic> records) {
    StoreObject obj = StoreObject();
    for (var rd in records) {
      var r = StoreRecord.fromJson(rd as Map<String, dynamic>);
      obj.records[r.id] = r;
    }
    return obj;
  }

  List<dynamic> toJson() {
    return records.values.map((e) => e.toJson()).toList();
  }
}
