import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late ThemeData themeData;
  late MobileScannerController mobileScannerController;

  @override
  void initState() {
    mobileScannerController = MobileScannerController(
      torchEnabled: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    double sizeValue = 100, percentage = 0.6;
    Size size = MediaQuery.of(context).size;
    if(size.aspectRatio > 1) {
      sizeValue = size.height * percentage;
    }
    else {
      sizeValue = size.width * percentage;
    }

    return Scaffold(
      appBar: getAppBar(),
      body: Stack(
        children: [
          MobileScanner(
            controller: mobileScannerController,
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
          ),
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              foregroundPainter: BorderPainter(borderColor: themeData.colorScheme.onPrimary),
              child: Container(
                width: sizeValue,
                height: sizeValue,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<TorchState>(
                    valueListenable: mobileScannerController.torchState,
                    builder: (BuildContext context, TorchState state, Widget? child) {
                      return getButton(
                        iconData: state == TorchState.on ? Icons.flash_off_sharp : Icons.flash_on,
                        onTap: () {
                          mobileScannerController.toggleTorch();
                        }
                      );
                    },
                  ),
                  getButton(
                    iconData: Icons.cameraswitch,
                    onTap: () {
                      mobileScannerController.switchCamera();
                    }
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text("Scan QR"),
    );
  }


  Widget getButton({required IconData iconData, required Function() onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: themeData.colorScheme.onPrimary.withOpacity(0.2),
          ),
          child: Icon(iconData),
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  final Color? borderColor;

  const BorderPainter({this.borderColor}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height; // for convenient shortage
    double sw = size.width; // for convenient shortage
    double cornerSide = sh * 0.2; // desirable value for corners side

    Paint paint = Paint()
      ..color = borderColor ?? Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path()
      ..moveTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..moveTo(0, sh - cornerSide)
      ..quadraticBezierTo(0, sh, cornerSide, sh)
      ..moveTo(sw - cornerSide, sh)
      ..quadraticBezierTo(sw, sh, sw, sh - cornerSide)
      ..moveTo(sw, cornerSide)
      ..quadraticBezierTo(sw, 0, sw - cornerSide, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}