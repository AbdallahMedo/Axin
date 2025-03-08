import 'package:flutter/material.dart';

class SecurityButton extends StatefulWidget {
  final String text;
  final VoidCallback? onActivated;
  final VoidCallback? onDeactivated;

  const SecurityButton({
    Key? key,
    required this.text,
    this.onActivated,
    this.onDeactivated,
  }) : super(key: key);

  @override
  _SecurityButtonState createState() => _SecurityButtonState();
}

class _SecurityButtonState extends State<SecurityButton> {
  bool isActive = false;

  void toggleButton() {
    setState(() {
      isActive = !isActive;
    });
    if (isActive) {
      widget.onActivated?.call();
      showAlert("Your Home Secure", Colors.green, Icons.check);
    } else {
      widget.onDeactivated?.call();
      showAlert("Your Home is Not Secures", Colors.red, Icons.close);
    }
  }

  void showAlert(String message, Color color, IconData icon) {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          backgroundColor: color.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 50),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: toggleButton,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(widget.text, style: const TextStyle(fontSize: 16)),
    );
  }
}
