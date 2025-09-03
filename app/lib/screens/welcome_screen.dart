import 'package:app/screens/signin_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/widgets/custom_scaffold.dart';
import 'package:app/widgets/welcome_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex:8,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'HI!\n',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Welcome to Hall Booking MEC enter your details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Flexible(
            flex:1,
                child:Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      Expanded(
                        child: WelcomeButton(
                          buttonText: 'LogIn',
                          textColor:Colors.white,
                          onTap:SigninScreen(),
                          color:Colors.transparent,
                        ),
                      ),
                      Expanded(
                        child: WelcomeButton(
                          buttonText:'SignUp',
                          onTap: SignUpScreen(),
                          color:Colors.white,
                          textColor:Colors.black,
                        ),
                      ),
                  ],),
                )
              ),
        ],
      ),
    );
  }
}