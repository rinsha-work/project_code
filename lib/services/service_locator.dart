import 'package:get_it/get_it.dart';
import 'package:mynewapp/data/local_storage/shared_preference.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPreferencesService = await SharedPreferencesService.getInstance();
  serviceLocator.registerSingleton(sharedPreferencesService);
}
