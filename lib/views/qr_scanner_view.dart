import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:axin/views/home_view.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      // ✅ لما بياخد البريميشن بيفتح الكاميرا أوتوماتيك
      setState(() {
        _hasPermission = true;
      });
      await cameraController.start();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan QR codes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: _hasPermission
                ? MobileScanner(
              controller: cameraController,
              onDetect: (capture) async {
                if (_isProcessing) return;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final code = barcode.rawValue;
                  print('QR RAW VALUE: $code');
                  if (code != null && code.contains('|')) {
                    _isProcessing = true;
                    await _processQRCode(code);
                    break;
                  }
                }
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt,
                      color: Colors.grey, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Camera permission required',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // ✅ زر لو رفض البريميشن يفتح الإعدادات
                  ElevatedButton(
                    onPressed: () async {
                      await openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Scan the QR code from your Home Assistant setup',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      floatingActionButton: _hasPermission
          ? FloatingActionButton(
        onPressed: () {
          cameraController.toggleTorch();
        },
        backgroundColor: const Color(0xff6C4EFF),
        child: const Icon(Icons.flash_on, color: Colors.white),
      )
          : null,
    );
  }

  Future<void> _processQRCode(String data) async {
    final parts = data.split('|');
    if (parts.length == 3) {
      // ✅ شيل الـ prefix من كل جزء
      final clientName = parts[0].replaceFirst('CLIENT:', '').trim();
      final ip = parts[1].replaceFirst('IP:', '').trim();
      final token = parts[2].replaceFirst('TOKEN:', '').trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ha_ip', ip);
      await prefs.setString('ha_token', token);
      await prefs.setString('client_name', clientName);

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR Code format'),
            backgroundColor: Colors.red,
          ),
        );
        _isProcessing = false;
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}