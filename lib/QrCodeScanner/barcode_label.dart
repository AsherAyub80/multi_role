import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:multi_role/WebView/webview.dart';
import 'package:get/get.dart';

class BarcodeLabelScreen extends StatelessWidget {
  final Stream<BarcodeCapture> barcodeData;

  const BarcodeLabelScreen({
    Key? key,
    required this.barcodeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scannedBarcode'.tr), // Localized title
      ),
      body: StreamBuilder<BarcodeCapture>(
        stream: barcodeData,
        builder: (context, snapshot) {
          final scannedBarcodes = snapshot.data?.barcodes ?? [];

          if (scannedBarcodes.isEmpty) {
            return Center(
              child: Text(
                'nothing'.tr, // Localized message
                overflow: TextOverflow.fade,
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          final displayValue =
              scannedBarcodes.first.displayValue ?? 'No display value.';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      displayValue,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                      ClipboardData(text: displayValue))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('copiedToClipboard'
                                        .tr), // Localized message
                                  ),
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.copy),
                                  SizedBox(width: 8.0),
                                  Text('copy'.tr), // Localized button text
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Webview(url: displayValue),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.directions),
                                  SizedBox(width: 8.0),
                                  Text('redirect'.tr), // Localized button text
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
