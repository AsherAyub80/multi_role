import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:get/get.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  late StreamSubscription<bool> _playingSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;

  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();

    _player = Player(
      configuration: PlayerConfiguration(
        title: 'Media Application',
        ready: () {
          print('The initialization is complete.');
        },
      ),
    );

    _controller = VideoController(_player);

    final playlist = Playlist(
      [
        Media(
            'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373709-603a7a89-2105-4e1b-a5a5-a6c3567c9a59.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373716-76da0a4e-225a-44e4-9ee7-3e9006dbc3e3.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373718-86ce5e1d-d195-45d5-baa6-ef94041d0b90.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373720-14d69157-1a56-4a78-a2f4-d7a134d7c3e9.mp4'),
      ],
      index: 0,
    );

    _player.open(playlist);

    _playingSubscription = _player.stream.playing.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
    });

    _positionSubscription = _player.stream.position.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _playingSubscription.cancel();
    _positionSubscription.cancel();
    _player.dispose();
    super.dispose();
  }

  void _playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _stop() async {
    await _player.stop();
  }

  void _seek(Duration duration) async {
    await _player.seek(_currentPosition + duration);
  }

  void _nextVideo() async {
    await _player.next();
  }

  void _previousVideo() async {
    await _player.previous();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('videoPlayerTitle'.tr)),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 200,
                    color: Colors.black,
                    child: Video(
                      controller: _controller,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'position'.tr +
                        ([
                          '${_currentPosition.inMinutes}:${_currentPosition.inSeconds.remainder(60)}'
                        ]).toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _playPause,
                        child: Text(_isPlaying ? 'pause'.tr : 'play'.tr),
                      ),
                      ElevatedButton(
                        onPressed: _stop,
                        child: Text('stop'.tr),
                      ),
                      ElevatedButton(
                        onPressed: () => _seek(const Duration(
                            seconds: -10)), // Backward 10 seconds
                        child: Text('backward10s'.tr),
                      ),
                      ElevatedButton(
                        onPressed: () => _seek(
                            const Duration(seconds: 10)), // Forward 10 seconds
                        child: Text('forward10s'.tr),
                      ),
                      ElevatedButton(
                        onPressed: _nextVideo,
                        child: Text('next'.tr),
                      ),
                      ElevatedButton(
                        onPressed: _previousVideo,
                        child: Text('previous'.tr),
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
