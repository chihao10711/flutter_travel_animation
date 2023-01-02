import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'features/event/bloc/bloc.dart';
import 'features/features.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel animation',
      initialRoute: "event_home_screen",
      home: ChangeNotifierProvider(
        create: (_) => FloatAddButtonNotifier(),
        builder: (context, child) {
          return BlocProvider(
            create: (_) => ListEventBloc(context),
            child: const EventHomeScreen(),
          );
        },
      ),
    );
  }
}
