import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:multi_role/QrCodeScanner/qr.dart';
import 'package:multi_role/QrCodeScanner/qr_code_genrator.dart';
import 'package:multi_role/WebView/web_view_page.dart';
import 'package:multi_role/docscanner/doc_scanner.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();
  }

  void _initializeBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('BannerAd loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
          print('BannerAd failed to load: $error');
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return Card(
                  child: _buildRoleTile(
                    context,
                    _getTitle(index),
                    _getNavigation(context, index),
                  ),
                );
              },
            ),
          ),
          if (_isAdLoaded)
            Container(
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }

  GestureDetector _buildRoleTile(
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
