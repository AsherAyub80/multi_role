import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:multi_role/docscanner/full_image.dart';
import 'package:multi_role/docscanner/filter_preview.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart'; // Importing gal package

class DocScanner extends StatefulWidget {
  const DocScanner({Key? key}) : super(key: key);

  @override
  _DocScannerState createState() => _DocScannerState();
}

class _DocScannerState extends State<DocScanner> {
  final List<String> _pictures = [];
  bool _isLoading = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadStoredPictures();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          setState(() {
            _isInterstitialAdLoaded = false;
          });
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
    }
  }

  Future<void> _fetchPictures() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newPictures = await CunningDocumentScanner.getPictures();
      if (newPictures != null) {
        setState(() {
          _pictures.addAll(newPictures);
        });
        _storage.write('pictures', _pictures);
        _showInterstitialAd();
      } else {
        _showSnackbar('No pictures returned');
      }
    } catch (exception) {
      _showSnackbar('Error scanning documents: $exception');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadStoredPictures() {
    final storedPictures = _storage.read('pictures') as List<dynamic>?;
    final picturesList =
        storedPictures?.map((e) => e.toString()).toList() ?? [];
    setState(() {
      _pictures.addAll(picturesList);
    });
  }

  Future<void> _openFullScreenImageViewer(int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imagePaths: _pictures,
          initialIndex: index,
        ),
      ),
    );
  }

  Future<void> _navigateToFilterScreen(String imagePath) async {
    final updatedImagePath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilterPreviewScreen(imagePath: imagePath),
      ),
    ) as String?;

    if (updatedImagePath != null) {
      setState(() {
        final index = _pictures.indexOf(imagePath);
        if (index != -1) {
          _pictures[index] = updatedImagePath;
          _storage.write('pictures', _pictures);
        }
      });
    }
  }

  Future<void> _saveImage(String imagePath) async {
    try {
      await Gal.putImage(imagePath);
      _showSnackbar('Image saved to gallery!');
      print(imagePath);
    } catch (e) {
      _showSnackbar('Failed to save image: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showFilterDialog(String imagePath, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('applyFilter'.tr),
        content: Text('chooseFilter'.tr),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showInterstitialAd();
              _navigateToFilterScreen(imagePath);
            },
            child: Text('applyFilter'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pictures.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text('delete'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveImage(imagePath); // Save image to gallery
            },
            child: Text('saveToGallery'.tr),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('documentScanner'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchPictures,
            icon: Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/scan.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('scanning'.tr,
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : _pictures.isEmpty
              ? Center(child: Text('noPicturesFound'.tr))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _pictures.length,
                  itemBuilder: (context, index) {
                    final picture = _pictures[index];
                    return GestureDetector(
                      onTap: () => _openFullScreenImageViewer(index),
                      onLongPress: () => _showFilterDialog(picture, index),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(picture),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
