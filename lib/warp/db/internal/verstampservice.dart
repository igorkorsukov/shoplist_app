import '../iverstampservice.dart';

export '../iverstampservice.dart';

class VerstampService extends IVerstampService {
  final int _startTS = DateTime(2022, 12, 22).millisecondsSinceEpoch;

  @override
  int verstamp() {
    return (DateTime.now().millisecondsSinceEpoch - _startTS);
  }
}
