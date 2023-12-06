import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/log/data/datasource/log_local_datasource.dart';
import 'package:mplos_chat/features/log/data/datasource/log_remote_datasource.dart';
import 'package:mplos_chat/features/log/data/repositories/log_repository_impl.dart';
import 'package:mplos_chat/features/log/domain/repositories/log_repository.dart';
import 'package:mplos_chat/shared/data/local/shared_prefs_storage_service.dart';
import 'package:mplos_chat/shared/data/remote/network_service.dart';
import 'package:mplos_chat/shared/domain/providers/dio_network_service_provider.dart';
import 'package:mplos_chat/shared/domain/providers/sharedpreferences_storage_service_provider.dart';

final localDataSourceProvider =
    Provider.family<LogLocalDataSource, SharedPrefsService>(
        (_, storageService) => LogLocalDataSource(storageService));
final remoteDataSourceProvider =
    Provider.family<LogRemoteDataSource, NetworkService>(
        (_, networkService) => LogRemoteDataSource(networkService));

final logRepositoryProvider = Provider<LogRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final networkService = ref.watch(netwokServiceProvider);

  final localSource = ref.watch(localDataSourceProvider(storageService));
  final remoteSource = ref.watch(remoteDataSourceProvider(networkService));

  return LogRepositoryImpl(localSource, remoteSource);
});
