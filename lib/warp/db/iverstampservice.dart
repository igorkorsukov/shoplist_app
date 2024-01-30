import 'package:shoplist/warp/modularity/injectable.dart';

abstract class IVerstampService with Injectable {
  @override
  String interfaceId() => "IVerstampService";

  int verstamp();
}
