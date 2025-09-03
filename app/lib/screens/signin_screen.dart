import 'package:app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Text(
        'SignIn Screen'
      )
    );
  }
}