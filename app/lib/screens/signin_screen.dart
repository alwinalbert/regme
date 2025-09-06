import 'package:app/screens/signup_screen.dart';
import 'package:app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  Future<void> _launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
  final _formSignInKey = GlobalKey<FormState>();
  bool remeberPassword = true;
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
     child:Column(
      children:[
      const Expanded(
        flex:1,
        child:SizedBox(
          height:10,
        ),
      ),
      Expanded(
        flex:7,
        child:Container(
          padding:EdgeInsets.fromLTRB(25, 50, 25, 20),
          decoration:const BoxDecoration(
            color:Colors.white,
            borderRadius:BorderRadius.only(
              topLeft:Radius.circular(40),
              topRight:Radius.circular(40),
            ),
          ),
          child:Form(
            key: _formSignInKey,
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height:40),
                Text(
                  'Welcome back',
                  style:TextStyle(
                    fontSize:30,
                    fontWeight:FontWeight.bold,
                    color:Colors.black,
                  ),
                ),
                const SizedBox(height:20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                   label:const Text('Email'),
                    prefixIcon:const Icon(Icons.email),
                    hintText:'Enter email',
                    hintStyle: const TextStyle(
                      color:Colors.black26
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color:Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),  
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color:Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ), 
                  ),
                ),
                const SizedBox(height:20),
                TextFormField(
                  obscureText: true,
                  obscuringCharacter: '*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                   label:const Text('Password'),
                    prefixIcon:const Icon(Icons.lock),
                    hintText:'Enter password',
                    hintStyle: const TextStyle(
                      color:Colors.black26
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color:Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),  
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color:Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ), 
                  ),
                ),
                const SizedBox(height:30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Checkbox(
                      value: remeberPassword,
                      onChanged: (bool? value) {
                        setState(() {
                          remeberPassword = value!;
                        });
                      },
                      activeColor: Colors.black,
                    ),
                    const Text(
                      'show password',
                      style:TextStyle(
                        color:Colors.black54,
                        fontWeight:FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Forgot password?',
                      style:TextStyle(
                        color:Colors.black,
                        fontWeight:FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:30),
                SizedBox(
                  width:double.infinity,
                  child:ElevatedButton(
                    onPressed: () {
                      if (_formSignInKey.currentState!.validate() &&
                       remeberPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Processing Data')),
                        );
                       }
                        else if(!remeberPassword){
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please agree to remember password')),
                        );
                        }
                    },
                     child: const Text(
                      'Log In',
                      style:TextStyle(
                        fontSize:18,
                        fontWeight:FontWeight.bold,
                        color:Colors.black,
                      ),
                     ),
                  ),
                ),
                const SizedBox(height:40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Expanded(
                      child:Divider(
                        color:Colors.black12,
                        thickness:0.7,
                      ),
                    ),
                    const Padding(
                      padding:EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal:10,
                        ),
                        child:Text(
                          'LogIn with',
                          style:TextStyle(
                            color:Colors.black54,
                            fontWeight:FontWeight.bold,
                          ),
                        )
                      
                    ),
                    Expanded(
                      child:Divider(
                        color:Colors.black12,
                        thickness:0.7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    GestureDetector(
                      onTap: () async {
                        try {
                          await _launchURL('https://accounts.google.com/signin');
                        } catch (e) {
                          debugPrint('Failed to launch URL: $e');
                        }
                      },
                      child: Logo(Logos.google, size: 40),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          await _launchURL('https://www.facebook.com/login.php');
                        } catch (e) {
                          debugPrint('Failed to launch URL: $e');
                        }
                      },
                      child: Logo(Logos.facebook_f, size: 40),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          await _launchURL('https://www.apple.com/id/login');
                        } catch (e) {
                          debugPrint('Failed to launch URL: $e');
                        }
                      },
                      child: Logo(Logos.apple, size: 40),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          await _launchURL('https://twitter.com/login');
                        } catch (e) {
                          debugPrint('Failed to launch URL: $e');
                        }
                      },
                      child: Logo(Logos.twitter, size: 40),
                    ),
                    ],
                ),
                const SizedBox(height:20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    const Text(
                      'Don\'t have an account? ',
                      style:TextStyle(
                        color:Colors.black54,
                        fontWeight:FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                          MaterialPageRoute(
                            builder: (e) => const SignUpScreen(),
                            ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style:TextStyle(
                          color:Colors.black,
                          fontWeight:FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ),
      ],
     ),
    );
  }
}