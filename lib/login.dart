import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:petronas/home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _canBiometric = false;

  _checkBiometricAuthAvailable() async {
    _canBiometric = await _auth.canCheckBiometrics;
  }

  _biometricScan() async {
    log("Biometric Scan Initiated");
    if (_canBiometric) {
      List<BiometricType> _availableBiometrics =
          await _auth.getAvailableBiometrics();
      log(_availableBiometrics.toString());
      bool _isFingerprintAvailable =
          _availableBiometrics.contains(BiometricType.weak);
      bool _isFaceIdAvailable =
          _availableBiometrics.contains(BiometricType.strong);
      bool _authenticated = false;
      if (_isFingerprintAvailable || _isFaceIdAvailable) {
        _authenticated = await _auth.authenticate(
          localizedReason: "Scan you fingerprint to login",
          options: const AuthenticationOptions(
            biometricOnly: true,
            useErrorDialogs: true,
          ),
        );
      } else {
        log("Fingerprint or Face biometric hardware not available");
      }
      if (_authenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  Home(),
          ),
        );
      } else {
        log("Authentication failed");
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>  Home(),
        //   ),
        // );
      }
    } else {
      log("No authentication hardware available");
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await _checkBiometricAuthAvailable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _biometricScan();
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
