import 'package:chito_chat/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
   var isLogin = true;
   final _formKey = GlobalKey<FormState>();
   var _userEmail = '';
   var _userPassword = '';
   var isLoading = false;
   File? _userImageFile;

   void submit() async{
      final isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();

      if(!isValid || (!isLogin && _userImageFile == null)) {
         ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(!isLogin && _userImageFile == null ? 'Please pick an image.' : 'Please enter valid credentials!' )),
          );
        return;
      }

      _formKey.currentState!.save();

    try {
      setState(() {
        isLoading = true;
      });

      if(isLogin) {
        await firebase.signInWithEmailAndPassword(email: _userEmail, password: _userPassword);
      } else {
          final userCredentials = await firebase.createUserWithEmailAndPassword(email: _userEmail, password: _userPassword);
          
          final imageRef = FirebaseStorage.instance.ref('user_images').
            child('${userCredentials.user!.uid}.jpg');

            await imageRef.putFile(_userImageFile!);
            final imageUrl = await imageRef.getDownloadURL();
            await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set({
              'username': _userEmail.split('@')[0],
              'email': _userEmail,
              'image_url': imageUrl,
            });
          }
        } on FirebaseAuthException catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'An error occurred, please check your credentials!' )),
          );
          setState(() {
            isLoading = false;
          });
        }
      
    }


  @override
  Widget build(BuildContext context) {

    
   

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30,
                  bottom: 20,
                ),
                width: 200,
                child: Image(image: AssetImage('assets/images/chat.png')),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(!isLogin) UserImagePicker(
                            onPickImage: (pickedImage) {
                              _userImageFile = pickedImage;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (value) {
                              _userEmail = value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            onSaved: (value) {
                              _userPassword = value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty || value.trim().length < 6) {
                                return 'Please enter a valid password (at least 6 characters).';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24),
                          if(isLoading) CircularProgressIndicator(),
                          if(!isLoading)
                            ElevatedButton(
                              onPressed: submit,
                              child: Text(isLogin ? 'Login' : 'Sign Up'),
                            ),
                          if(!isLoading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(
                                isLogin ? 'Create new account' : 'I already have an account'),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          
        )
      ),
    );
  }
}