import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:multi_role/Home/home_page.dart';

class BioMetric extends StatefulWidget {
  const BioMetric({super.key});

  @override
  State<BioMetric> createState() => _BioMetricState();
}

class _BioMetricState extends State<BioMetric> {
  late final LocalAuthentication myAuthentication;
  bool authState = false;

  @override
  void initState() {
    super.initState();

    myAuthentication = LocalAuthentication();
    myAuthentication.isDeviceSupported().then((bool myAuth) => setState(() {
          authState = myAuth;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Bio Metric'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: authenticate,
                child: Text('Authenticate')),
          ],
        ),
      ),
    );
  }

  Future<void> authenticate() async {
    try {
      bool isAuthenticate = await myAuthentication.authenticate(
          localizedReason: 'local authentication',
          options:
              AuthenticationOptions(stickyAuth: true, biometricOnly: true));

      if (isAuthenticate) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }

      print('authenticated status is $isAuthenticate');
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) {
      return;
    }
  }
}
