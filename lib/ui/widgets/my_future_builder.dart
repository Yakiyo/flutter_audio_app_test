import 'package:flutter/material.dart';

class MyFutureBuilder<T extends Object> extends StatelessWidget {
  final Widget Function(T data) builder;
  final Future<T> future;
  final Widget Function(Object? error)? onError;
  final Widget onLoading;
  
  const MyFutureBuilder(
      {super.key,
      required this.builder,
      required this.future,
      this.onError,
      this.onLoading = const Center(child: CircularProgressIndicator())});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return builder(snapshot.data!);
        }

        if (snapshot.hasError) {
          return onError?.call(snapshot.error) ??
              Center(
                child: Text(snapshot.error.toString()),
              );
        }

        return onLoading;
      },
    );
  }
}
