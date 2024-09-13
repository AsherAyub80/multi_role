import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class QRCodeGenerator extends StatefulWidget {
  QRCodeGenerator({super.key});

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  TextEditingController barController = TextEditingController();
  String qrValue = '';
  bool _isAdWatched = false;

  late BannerAd _bannerAd;
  bool _isBannerLoaded = false;

  late RewardedAd _rewardedAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();
    _loadRewardedAd();
  }

  void _initializeBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Test Banner Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerLoaded = true;
          });
          print('BannerAd loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            _isBannerLoaded = false;
          });
          print('BannerAd failed to load: $error');
        },
      ),
    );
    _bannerAd.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/5224354917', // Test Rewarded Ad Unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
          print('RewardedAd loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isAdLoaded) {
      _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _loadRewardedAd(); // Load a new ad for future use
          if (_isAdWatched) {
            _generateQRCode();
          }
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          _loadRewardedAd(); // Load a new ad for future use
        },
      );

      _rewardedAd.show(
        onUserEarnedReward: (ad, reward) {
          _generateQRCode();
        },
      );
    } else {
      print('RewardedAd is not loaded yet.');
    }
  }

  void _generateQRCode() {
    setState(() {
      qrValue = barController.text; // Update QR code value
      barController.clear(); // Clear the input field
      _isAdWatched = false; // Reset ad watch state for next use
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    if (_isAdLoaded) {
      _rewardedAd.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  if (qrValue.isNotEmpty)
                    Center(
                      child: SfBarcodeGenerator(
                        value: qrValue,
                        symbology: QRCode(),
                        showValue: true,
                      ),
                    ),
                  SizedBox(height: qrValue.isEmpty ? 350 : 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: barController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (barController.text.isNotEmpty) {
                        if (_isAdLoaded) {
                          _showRewardedAd();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Rewarded ad is not loaded yet. Please try again.'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter some text!'),
                          ),
                        );
                      }
                    },
                    child: Text('Generate QR Code'),
                  ),
                  SizedBox(height: 20), // Add spacing before the ad
                ],
              ),
            ),
          ),
          if (_isBannerLoaded)
            Container(
              color: Colors
                  .white, // Optional: Set background color to match your design
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }
}
