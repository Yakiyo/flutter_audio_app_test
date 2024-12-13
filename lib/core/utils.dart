import 'package:get_it/get_it.dart';

T get<T extends Object>({String? instanceName}) =>
    GetIt.instance.get<T>(instanceName: instanceName);

extension Capitalize on String {
  String get capitalize => substring(0, 1).toUpperCase() + substring(1);
}
