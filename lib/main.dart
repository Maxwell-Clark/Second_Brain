import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:second_brain/colors.dart';
import 'package:second_brain/repository/auth_repository.dart';
import 'package:second_brain/router.dart';
import 'package:second_brain/screens/home_screen.dart';
import 'models/error_model.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
      const ProviderScope(child: MyApp())
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errorModel;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();

    if(errorModel!=null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    }
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: kGrayColor
      ),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        if(user!=null && user.token.isNotEmpty) {
          return loggedInRoute;
        } else {
          return loggedOutRoute;
        }

      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
