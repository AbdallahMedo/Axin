import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axin/views/home_view.dart';
import 'package:axin/views/qr_setup_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ha_ip');
    final token = prefs.getString('ha_token');
    final clientName = prefs.getString('client_name');

    if (ip != null && token != null && clientName != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(
              ip: ip,
              token: token,
              clientName: clientName,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QRSetupView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/5.png',height: 150,width: 150,color: Colors.white,),
            const SizedBox(height: 20),
            const Text(
              'AXIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'BankGothic',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Smart Home Controller',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff6C4EFF)),
            ),
          ],
        ),
      ),
    );
  }
}