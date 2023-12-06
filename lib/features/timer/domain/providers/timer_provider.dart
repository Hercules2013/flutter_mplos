import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/timer/data/datasource/timer_remote_data_source.dart';
import 'package:mplos_chat/features/timer/data/datasource/timer_local_data_source.dart';
import 'package:mplos_chat/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:mplos_chat/features/timer/domain/repositories/timer_repository.dart';
import 'package:mplos_chat/shared/data/local/shared_prefs_storage_service.dart';
import 'package:mplos_chat/shared/data/remote/network_service.dart';
import 'package:mplos_chat/shared/domain/providers/dio_network_service_provider.dart';
import 'package:mplos_chat/shared/domain/providers/sharedpreferences_storage_service_provider.dart';

final localDataSourceProvider =
    Provider.family<TimerLocalDataSource, SharedPrefsService>(
        (_, storageService) => TimerLocalDataSource(storageService));
final remoteDataSourceProvider =
    Provider.family<TimerDataSource, NetworkService>(
        (_, networkService) => TimerDataSource(networkService));

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final networkService = ref.watch(netwokServiceProvider);

  final localSource = ref.watch(localDataSourceProvider(storageService));
  final remoteSource = ref.watch(remoteDataSourceProvider(networkService));

  return TimerRepositoryImpl(localSource, remoteSource);
});
