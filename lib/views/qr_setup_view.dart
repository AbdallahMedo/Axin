import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axin/views/home_view.dart';
import 'package:axin/views/qr_scanner_view.dart';

class QRSetupView extends StatefulWidget {
  const QRSetupView({super.key});

  @override
  State<QRSetupView> createState() => _QRSetupViewState();
}

class _QRSetupViewState extends State<QRSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _tokenController = TextEditingController();
  final _clientNameController = TextEditingController();
  bool _isLoading = false;
  GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff160E33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Setup Connection',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerView()),
              );
            },
            tooltip: 'Scan QR Code',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xff6C4EFF),
                    size: 80,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter Your Home Assistant Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fill in your Raspberry Pi connection details',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _clientNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter client name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ipController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'IP Address',
                    hintText: '192.168.1.5 or domain.com',
                    prefixIcon: Icon(Icons.dns, color: Colors.grey),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter IP address' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _tokenController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Long Lived Access Token',
                    hintText: 'Enter your HA token',
                    prefixIcon: Icon(Icons.vpn_key, color: Colors.grey),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter token' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateQR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6C4EFF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Generate QR Code',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                if (_ipController.text.isNotEmpty &&
                    _tokenController.text.isNotEmpty &&
                    _clientNameController.text.isNotEmpty)
                  const SizedBox(height: 30),
                if (_ipController.text.isNotEmpty &&
                    _tokenController.text.isNotEmpty &&
                    _clientNameController.text.isNotEmpty)
                  _buildQRCode(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    final data =
        '${_ipController.text}|${_tokenController.text}|${_clientNameController.text}';
    return Column(
      children: [
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          'Your QR Code',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 20),
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _saveQRCode,
              icon: const Icon(Icons.save_alt),
              label: const Text('Save to Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff6C4EFF),
                side: const BorderSide(color: Color(0xff6C4EFF)),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: _connect,
              icon: const Icon(Icons.check),
              label: const Text('Connect Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6C4EFF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _generateQR() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveQRCode() async {
    try {
      final boundary =
      _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/axin_qr_${_clientNameController.text}.png';

      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      final result = await GallerySaver.saveImage(file.path);

      if (result == true || result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code saved to gallery'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save QR Code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _connect() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ha_ip', _ipController.text);
      await prefs.setString('ha_token', _tokenController.text);
      await prefs.setString('client_name', _clientNameController.text);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(
              ip: _ipController.text,
              token: _tokenController.text,
              clientName: _clientNameController.text,
            ),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _tokenController.dispose();
    _clientNameController.dispose();
    super.dispose();
  }
}