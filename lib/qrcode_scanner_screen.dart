import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  late Size size;

  final GlobalKey _qrKey = GlobalKey(debugLabel: "QR");

  QRViewController? _controller;
  Barcode? result;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    _controller?.pauseCamera();
    _controller?.resumeCamera();

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Center(
                  child: Image.asset(
                    "assets/images/qr-code.png",
                    width: 45.0,
                    height: 45.0,
                  ),
                ),
              ),
              const Text("QR Code Scanner",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Container(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(flex: 10, child: _buildQrView(context)),
            Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xffe3dfdf),
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _controller?.toggleFlash();
                        },
                        child: const Icon(Icons.flash_on,
                            size: 30, color: Colors.blueAccent),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _controller?.flipCamera();
                        },
                        child: const Icon(Icons.flip_camera_ios,
                            size: 30, color: Colors.blueAccent),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = 250.0;

    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
      onPermissionSet: (ctrl, p) => onPermissionSet(context, ctrl, p),
      overlay: QrScannerOverlayShape(
        cutOutSize: scanArea,
        borderWidth: 10,
        borderLength: 40,
        borderRadius: 5.0,
        borderColor: const Color.fromARGB(255, 12, 82, 233),
      ),
    );
  }

  void _onQRViewCreated(QRViewController _qrController) {
    setState(
      () {
        this._controller = _qrController;
      },
    );

    _controller?.scannedDataStream.listen((event) {
      setState(
        () {
          result = event;
          _controller?.pauseCamera();
        },
      );

      if (result?.code != null) {
        print("QR code Scanned and showing Result");
        _showResult();
      }
    });
  }

  void onPermissionSet(
      BuildContext context, QRViewController _ctrl, bool _permission) {
    if (!_permission) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No Permission!")));
    }
  }

//Creating a result View
  Widget _showResult() {
    // check if it is url or not, if url then launch it.
    bool _validURL = Uri.parse(result!.code.toString()).isAbsolute;

    return Center(
      child: FutureBuilder<dynamic>(
          future: showDialog(
              context: context,
              builder: (BuildContext context) {
                return WillPopScope(
                  child: AlertDialog(
                    title: const Text(
                      "Scan Result!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ),
                    ),
                    content: SizedBox(
                      height: 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _validURL
                              ? SelectableText.rich(
                                  TextSpan(
                                      text: result!.code.toString(),
                                      style: const TextStyle(
                                          color: Colors.blueAccent),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchUrl(Uri.parse(
                                              result!.code.toString()));
                                        }),
                                )
                              : Text(
                                  result!.code.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _controller?.resumeCamera();
                            },
                            child: Text("Close"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                              shape: const BeveledRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                              shadowColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onWillPop: () async => false,
                );
              }),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            throw UnimplementedError;
          }),
    );
  }
}
