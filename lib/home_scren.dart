import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrcodescan/qrcode_generator_screen.dart';
import 'package:qrcodescan/qrcode_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
            child: Text("QR Code Scanner & Generator",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))),
        leading: Center(
          child: Image.asset(
            "assets/images/qr-code.png",
            width: 45.0,
            height: 45.0,
          ),
        ),
      ),
      body: Container(
          color: const Color(0xffEEEEEE),
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 75,
                child: ElevatedButton(
                  child: Text("Scan QR Code",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25.0)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QrCodeScannerScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    shadowColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 300,
                height: 75,
                child: ElevatedButton(
                  child: Text("Genarate QR Code",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25.0)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QrCodeGeneratorScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    textStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    shadowColor: Colors.blue,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
