import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockmanager/presentation/blocs/theme_bloc.dart';
import 'package:stockmanager/presentation/blocs/theme_state.dart';
import 'package:stockmanager/presentation/interfaces/creation_compte_page.dart';
import 'package:stockmanager/presentation/interfaces/welcome_page.dart';

// import 'database/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DBHelper().database;

  runApp(
    BlocProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Stock App',
          theme: state.themeData,
          home:  WelcomePage(),
          routes: {
            '/creation': (_) =>  CreationComptePage(),
          },
        );
      },
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      child: const MyApp(), // ici, le provider englobe MyApp ET MaterialApp
    );
  }
}




