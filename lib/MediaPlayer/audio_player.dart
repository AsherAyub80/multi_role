import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:async';

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

  InterstitialAd? _interstitialAd; // Change to nullable type
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
        'url':
            'https://humariweb.com/naats/jj/mera-dil-badal-da-(Hamariweb.com).mp3',
      },
      {
        'title': 'Faaslon Ko Takalluf',
        'artist': 'Waheed Zafar Qasmi',
        'releaseDate': '2001-06-01',
        'url':
            'https://humariweb.com/naats/22-10/faaslon~ko~takalluf-(hamariweb.com).mp3',
      },
      // Add more tracks here
    ];

    _player = Player();
    _currentMedia = Media(_tracks[_currentIndex]['url']);
    _player.open(_currentMedia);

    // Subscribe to the position and duration updates
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
      _showInterstitialAd();
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
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Test Banner Ad Unit ID
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
          print('InterstitialAd loaded.');
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
          _loadInterstitialAd(); // Load a new ad for future use
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _loadInterstitialAd(); // Load a new ad for future use
        },
      );
      _interstitialAd!.show();
    } else {
      print('InterstitialAd is not loaded yet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Player')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Title: ${_tracks[_currentIndex]['title']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('Artist: ${_tracks[_currentIndex]['artist']}'),
                  Text(
                      'Release Date: ${_tracks[_currentIndex]['releaseDate']}'),
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
                                  (_duration.inMilliseconds == 0
                                      ? 1
                                      : _duration.inMilliseconds)),
                          height: 5,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                      '${_position.toString().split('.').first} / ${_duration.toString().split('.').first}'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _playPause,
                        child: Text(_isPlaying ? 'Pause' : 'Play'),
                      ),
                      SizedBox(width: 10),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _stop,
                        child: Text('Stop'),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousTrack,
                        child: Text('Previous'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _nextTrack,
                        child: Text('Next'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _seek(
                            Duration(seconds: -10)), // Backward 10 seconds
                        child: Text('Backward 10s'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () =>
                            _seek(Duration(seconds: 10)), // Forward 10 seconds
                        child: Text('Forward 10s'),
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
