import 'package:chatapp_trial/services/app_methods.dart';
import 'package:chatapp_trial/services/auth_service.dart';
import 'package:chatapp_trial/services/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'login.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  final _controllerEmail = TextEditingController();
  final _controllerPass1 = TextEditingController();
  final _controllerPass2 = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _controllerPass1.clear();
    _controllerPass2.clear();
    _controllerEmail.clear();
    _controllerPass1.dispose();
    _controllerPass2.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Email is required*';
                      else
                        return null;
                    },
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        hintText: 'Enter Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Password is required*';
                      else
                        return null;
                    },
                    controller: _controllerPass1,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        hintText: 'Enter Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Password is required*';
                      else
                        return null;
                    },
                    controller: _controllerPass2,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 46,
                    child: !_isLoading
                        // ignore: deprecated_member_use
                        ? RaisedButton(
                            shape: StadiumBorder(),
                            color: Colors.purple,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                setState(() => _isLoading = true);
                                if (_controllerPass1.text !=
                                    _controllerPass2.text) {
                                  Get.rawSnackbar(
                                      message: 'Password does not match');
                                  setState(() => _isLoading = false);
                                } else {
                                  Provider.of<AuthService>(context,
                                          listen: false)
                                      .normalSignup(_controllerEmail.text,
                                          _controllerPass1.text)
                                      .then((value) {
                                    setState(() => _isLoading = false);
                                    if (value) {
                                      Get.off(Home());
                                      Preferences().setLogin();
                                    }
                                  });
                                }
                              }
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                              textScaleFactor: 1.5,
                            ))
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'OR',
                    textScaleFactor: 1.5,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 46,
                    // ignore: deprecated_member_use
                    child: RaisedButton(
                        shape: StadiumBorder(),
                        color: Colors.indigo,
                        onPressed: () async {
                          AppMethods.showBusy(context, true);
                          await Provider.of<AuthService>(context, listen: false)
                              .loginWithGoogle();
                          AppMethods.showBusy(context, false);
                          if (Provider.of<AuthService>(context, listen: false)
                                  .userData
                                  .user
                                  .displayName !=
                              null) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(Provider.of<AuthService>(context)
                                    .userData
                                    .user
                                    .email)
                                .set({
                              'email': Provider.of<AuthService>(context)
                                  .userData
                                  .user
                                  .email,
                              'uid': Provider.of<AuthService>(context)
                                  .userData
                                  .user
                                  .uid
                            });
                            Get.off(Home());
                            Preferences().setLogin();
                          } else {
                            Get.rawSnackbar(message: 'SomeError Occurred');
                          }
                        },
                        child: Text(
                          'Sign up with Google',
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: 1.5,
                        )),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text('Already a User?'),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: Text(
                          'Login',
                          textScaleFactor: 1.2,
                        ),
                        textColor: Colors.purple,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
