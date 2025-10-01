import 'package:app/screens/reset_password_screen.dart';
import 'package:app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => __ForgetPasswordState();
}

  

class __ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  @override
  void dispose (){
    _emailController.dispose();
    super.dispose();
  }
void _submit() async {
  if(_formKey.currentState!.validate()) {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('DEBUG: Received data: $data'); 
          print('DEBUG: Token: ${data['token']}');
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Password reset link sent to your email'))
  );
        
        // For testing, navigate to reset screen with token
        // In production, users would click the email link
        if (data['token'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: _emailController.text.trim(),
                token: data['token'],
              ),
            ),
          );
        } else {
          Navigator.pop(context); // Go back to login
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to send reset link';
        if (errorData['email'] != null) {
          errorMessage = errorData['email'][0];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding:const EdgeInsets.all(24.0),
       child:Form(
        key: _formKey,
        child:Column(
          crossAxisAlignment:CrossAxisAlignment.center,
          children: [
            const SizedBox(height:60),
            const Text(
              'Forgot Password',
              style:TextStyle(
                fontSize:30,
                fontWeight:FontWeight.bold,
                color:Colors.white,
              ),
            ),
            const SizedBox(height:20),
            const Text(
              'Enter your registered email address to receive password reset instructions',
              style:TextStyle(fontSize:16,color:Colors.white70),
              textAlign:TextAlign.center,
            ),
            const SizedBox(height:40),
            TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                          r'^[^@]+@[^@]+\.[^@]+'); // Simple yet effective email validation regex
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
            const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Reset Password'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        )
       )
      )
    );
  }
}