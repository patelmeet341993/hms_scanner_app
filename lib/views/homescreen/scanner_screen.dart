import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      allowDuplicates: false,
      onDetect: (Barcode barcode, MobileScannerArguments? args) {
        if (barcode.rawValue == null) {
          debugPrint('Failed to scan Barcode');
        }
        else {
          final String code = barcode.rawValue!;
          debugPrint('Barcode found! $code');

          Navigator.pop(context, code);
        }
      },
    );
  }
}
