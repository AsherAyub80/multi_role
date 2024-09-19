import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
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
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            _isBannerLoaded = false;
          });
        },
      ),
    );
    _bannerAd.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isAdLoaded) {
      _rewardedAd.show(onUserEarnedReward: (ad, reward) {
        _generateQRCode();
      });
    }
  }

  void _generateQRCode() {
    setState(() {
      qrValue = barController.text;
      barController.clear();
      _isAdWatched = false;
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
        title: Text('qrCodeGenerator'.tr), // Localized title
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (qrValue.isNotEmpty)
                    SfBarcodeGenerator(
                      value: qrValue,
                      symbology: QRCode(),
                      showValue: true,
                    ),
                  
                    SizedBox(
                          height: qrValue.isEmpty ? 350 : 0,
                        ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: barController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (barController.text.isNotEmpty) {
                        _showRewardedAd();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('pleaseEnterText'.tr)),
                        );
                      }
                    },
                    child: Text('generateQRCode'.tr), // Localized button text
                  ),
                ],
              ),
            ),
          ),
          if (_isBannerLoaded)
            Container(
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }
}
