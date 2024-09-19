import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:async';
import 'package:get/get.dart';

class AudioPlayer extends StatefulWidget {
  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  late Player _player;
  late List<Map<String, dynamic>> _tracks;
  int _currentIndex = 0;
  late Media _currentMedia;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  late StreamSubscription<bool> _playingSubscription;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _initializeBannerAd();

    _tracks = [
      {
        'title': 'Mera Dil Badal Dy',
        'artist': 'Junaid Jamshed',
        'releaseDate': '2010-01-01',
        'url': 'https://humariweb.com/naats/jj/mera-dil-badal-da-(Hamariweb.com).mp3',
      },
      {
        'title': 'Faaslon Ko Takalluf',
        'artist': 'Waheed Zafar Qasmi',
        'releaseDate': '2001-06-01',
        'url': 'https://humariweb.com/naats/22-10/faaslon~ko~takalluf-(hamariweb.com).mp3',
      },
    ];

    _player = Player();
    _currentMedia = Media(_tracks[_currentIndex]['url']);
    _player.open(_currentMedia);

    _positionSubscription = _player.stream.position.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _durationSubscription = _player.stream.duration.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _playingSubscription = _player.stream.playing.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _playingSubscription.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _interstitialAd?.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  void _playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _stop() {
    _player.stop();
  }

  void _nextTrack() {
    _showInterstitialAd();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _tracks.length;
      _currentMedia = Media(_tracks[_currentIndex]['url']);
      _player.open(_currentMedia);
    });
  }

  void _previousTrack() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _tracks.length) % _tracks.length;
      _currentMedia = Media(_tracks[_currentIndex]['url']);
      _player.open(_currentMedia);
    });
  }

  void _seek(Duration offset) async {
    final newPosition = _position + offset;
    if (newPosition < Duration.zero) {
      await _player.seek(Duration.zero);
    } else if (newPosition > _duration) {
      await _player.seek(_duration);
    } else {
      await _player.seek(newPosition);
    }
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
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );
    _bannerAd.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ad unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
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
          _loadInterstitialAd(); // Load a new ad for future use
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _loadInterstitialAd(); // Load a new ad for future use
        },
      );
      _interstitialAd!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('audioPlayerTitle'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'trackTitle'.tr +([_tracks[_currentIndex]['title']]).toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('trackArtist'.tr +([_tracks[_currentIndex]['artist']]).toString()),
                  Text('trackReleaseDate'.tr + ([_tracks[_currentIndex]['releaseDate']]).toString()),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 5,
                    color: Colors.grey[300],
                    child: Stack(
                      children: [
                        Container(
                          width: (MediaQuery.of(context).size.width - 32) *
                              (_position.inMilliseconds /
                                  (_duration.inMilliseconds == 0 ? 1 : _duration.inMilliseconds)),
                          height: 5,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${_position.toString().split('.').first} / ${_duration.toString().split('.').first}'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _playPause,
                        child: Text(_isPlaying ? 'pause'.tr : 'play'.tr),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _stop,
                        child: Text('stop'.tr),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousTrack,
                        child: Text('previous'.tr),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _nextTrack,
                        child: Text('next'.tr),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _seek(Duration(seconds: -10)), // Backward 10 seconds
                        child: Text('backward10s'.tr),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _seek(Duration(seconds: 10)), // Forward 10 seconds
                        child: Text('forward10s'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isAdLoaded)
              Container(
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }
}
