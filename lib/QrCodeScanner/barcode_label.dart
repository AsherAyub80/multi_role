import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:multi_role/WebView/webview.dart';

class BarcodeLabelScreen extends StatelessWidget {
  final Stream<BarcodeCapture> barcodeData;

  const BarcodeLabelScreen({
    super.key,
    required this.barcodeData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Barcode'),
      ),
      body: StreamBuilder(
        stream: barcodeData,
        builder: (context, snapshot) {
          final scannedBarcodes = snapshot.data?.barcodes ?? [];

          if (scannedBarcodes.isEmpty) {
            return Center(
              child: const Text(
                'Nothing!',
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
                margin: EdgeInsets.zero, // Remove the default margin
                elevation: 4, // Adjust the elevation to your preference
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Fit to content size
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      scannedBarcodes.first.displayValue ?? 'No display value.',
                      overflow: TextOverflow.fade,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            highlightColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              Clipboard.setData(
                                      ClipboardData(text: displayValue))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Copied to clipboard!'),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: const [
                                  Icon(Icons.copy),
                                  SizedBox(width: 8.0),
                                  Text('Copy'),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            highlightColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Webview(url: displayValue)));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: const [
                                  Icon(Icons.directions),
                                  SizedBox(width: 8.0),
                                  Text('Redirect'),
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
