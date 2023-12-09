class StoreRecord {
  DateTime timestamp = DateTime.utc(1970);
  String type = "";
  String id = "";
  String payload = "";

  StoreRecord({this.type = "", this.id = "", this.payload = ""});

  factory StoreRecord.fromJson(Map<String, dynamic> data) {
    StoreRecord r = StoreRecord();
    r.timestamp = DateTime.parse(data['timestamp'] as String);
    r.type = data['type'] as String;
    r.id = data['id'] as String;
    r.payload = data['payload'] as String;
    return r;
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'id': id,
      'payload': payload,
    };
  }
}

class StoreObject {
  List<StoreRecord> resords = [];

  StoreObject();

  factory StoreObject.fromJson(List<dynamic> data) {
    StoreObject obj = StoreObject();
    obj.resords = data.map((rdata) => StoreRecord.fromJson(rdata as Map<String, dynamic>)).toList();
    return obj;
  }

  List<dynamic> toJson() {
    return resords.map((r) => r.toJson()).toList();
  }
}
