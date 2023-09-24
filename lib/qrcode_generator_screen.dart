import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGeneratorScreen extends StatefulWidget {
  const QrCodeGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<QrCodeGeneratorScreen> createState() => _QrCodeGeneratorScreenState();
}

class _QrCodeGeneratorScreenState extends State<QrCodeGeneratorScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            const Text(
              "QR Code Generator",
              //style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: QrImage(
                data: _controller.text,
                size: min(MediaQuery.of(context).size.width / 1.3,
                    MediaQuery.of(context).size.height / 1.3),
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            _buildTextFeild(context),

            // download button.
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      _qrDownload(_controller.text);
                    },
                    minWidth: 150.0,
                    height: 50,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    color: Colors.blue,
                    child: const Text(
                      "Download",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildTextFeild(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: _controller,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          decoration: InputDecoration(
              hintText: "Enter Data",
              hintStyle: const TextStyle(color: Colors.black38),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.indigo,
                  )),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.indigo,
                  )),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.done,
                  size: 30,
                ),
                color: Colors.indigo,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
              )),
        ),
      ),
    );
  }

  _qrCode(String _txt) async {
    final qrValidationResult = QrValidator.validate(
        data: _txt,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L);

    qrValidationResult..status = QrValidationStatus.valid;
    final QrCode = qrValidationResult.qrCode;

    final painter = QrPainter.withQr(
        qr: QrCode!,
        color: const Color(0xffffffff),
        embeddedImageStyle: null,
        emptyColor: Colors.black,
        gapless: true);

    Directory _tempDir = await getTemporaryDirectory();
    String _tempPath = _tempDir.path;

    final _time = DateTime.now().microsecondsSinceEpoch.toString();
    String _finalPath = '$_tempPath/$_time.png';

    final picDate =
        await painter.toImageData(2048, format: ImageByteFormat.png);

    await writeToFile(picDate!, _finalPath);

    return _finalPath;
  }

  Future<String?> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  _qrDownload(String _path) async {
    String _filePath = await _qrCode(_path);
    final _success = await GallerySaver.saveImage(_filePath);
    if (_success != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Download Successful!")));
    }
  }
}
