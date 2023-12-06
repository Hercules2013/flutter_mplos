import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLoading extends ConsumerWidget {
  const AppLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
        child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: CircularProgressIndicator(),
    ));
  }
}
