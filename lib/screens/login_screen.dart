import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:second_brain/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/repository/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);
  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.push('/');
    } else {
      sMessenger
          .showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
            onPressed: () => signInWithGoogle(ref, context),
            icon: Image.asset(
              '../assets/images/google.png',
              height: 20,
            ),
            label: const Text('Sign in with Google',
                style: TextStyle(color: kBlackColor)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 50),
              primary: kWhiteColor,
            )),
      ),
    );
  }
}
