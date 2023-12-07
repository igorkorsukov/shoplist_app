class StoreRecord {
  DateTime timestamp = DateTime.utc(1970);
  String key = "";
  String value = "";

  StoreRecord({this.key = "", this.value = ""});

  factory StoreRecord.fromJson(Map<String, dynamic> data) {
    StoreRecord r = StoreRecord();
    r.key = data['key'] as String;
    r.timestamp = DateTime.parse(data['timestamp'] as String);
    r.value = data['key'] as String;
    return r;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'timestamp': timestamp.toIso8601String(),
      'value': value,
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
