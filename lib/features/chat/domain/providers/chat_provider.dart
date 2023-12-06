import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/chat/data/datasource/chat_data_source.dart';
import 'package:mplos_chat/features/chat/data/datasource/user_data_source.dart';
import 'package:mplos_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mplos_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:mplos_chat/shared/data/remote/network_service.dart';
import 'package:mplos_chat/shared/domain/providers/dio_network_service_provider.dart';

final userDataSourceProvider = Provider.family<UserDataSource, NetworkService>(
    (_, networkService) => UserDataSource(networkService));
final chatDataSourceProvider = Provider((ref) => ChatDataSource());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final networkService = ref.watch(netwokServiceProvider);
  final userDataSource = ref.watch(userDataSourceProvider(networkService));
  final chatDataSource = ref.watch(chatDataSourceProvider);

  return ChatRepositoryImpl(userDataSource, chatDataSource);
});
