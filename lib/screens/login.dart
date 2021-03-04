import 'package:chatapp_trial/screens/home.dart';
import 'package:chatapp_trial/screens/signup.dart';
import 'package:chatapp_trial/services/app_methods.dart';
import 'package:chatapp_trial/services/auth_service.dart';
import 'package:chatapp_trial/services/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _key = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerPass = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _controllerPass.clear();
    _controllerEmail.clear();
    _controllerPass.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  bool showPass = true;
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
                    style: TextStyle(
                      fontSize: 18,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _controllerEmail,
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
                        return 'Password is required';
                      else
                        return null;
                    },
                    controller: _controllerPass,
                    style: TextStyle(
                      fontSize: 18,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    obscureText: showPass,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                            splashColor: Colors.transparent,
                            splashRadius: 1,
                            tooltip: 'Show Passsword',
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: () =>
                                setState(() => showPass = !showPass)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        hintText: 'Enter Password',
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
                                Provider.of<AuthService>(context, listen: false)
                                    .normalLogin(_controllerEmail.text,
                                        _controllerPass.text)
                                    .then((value) {
                                  setState(() => _isLoading = false);
                                  if (value) {
                                    Get.off(Home());
                                    Preferences().setLogin();
                                  }
                                });
                              }
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                              textScaleFactor: 1.5,
                            ),
                          )
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
                          Get.off(Home());
                          Preferences().setLogin();
                        } else {
                          Get.rawSnackbar(message: 'SomeError Occurred');
                        }
                      },
                      child: Text(
                        'Login with Google',
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text('New User?'),
                      // ignore: deprecated_member_use
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RegistrationScreen()));
                        },
                        child: Text(
                          'Sign UP',
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
