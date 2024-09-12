import 'package:flutter/material.dart';
import 'package:multi_role/QrCodeScanner/qr.dart';
import 'package:multi_role/QrCodeScanner/qr_code_scanner.dart';
import 'package:multi_role/WebView/web_view_page.dart';
import 'package:multi_role/docscanner/doc_scanner.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: GridView.builder(
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            return Card(
              child: _buildrole(
                context,
                _getTitle(index),
                _getNavigation(context, index),
              ),
            );
          },
        ),
      ),
    );
  }

  GestureDetector _buildrole(
    BuildContext context,
    String title,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.deepPurple,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Document Scanner';
      case 1:
        return 'WebView';
      case 2:
        return 'Scan QR Code';
      case 3:
        return 'Generate QR Code';
      default:
        return '';
    }
  }

  VoidCallback? _getNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        return () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocScanner()),
            );
      case 1:
        return () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(
                  url: 'https://pub.dev/packages/flutter_sales_graph',
                ),
              ),
            );
      case 2:
        return () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BarcodeScannerWithOverlay()),
            );
      case 3:
        return () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRCodeGenerator()),
            );
      default:
        return null;
    }
  }
}
