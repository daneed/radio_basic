import 'package:audio_service/audio_service.dart';
import 'package:flutter_radio/flutter_radio.dart';
import 'dart:async';

const streamUrl =
    'http://stm16.abcaudio.tv:25584/player.mp3';

bool buttonState = true;

CustomAudioPlayer player = CustomAudioPlayer();

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
    androidIcon: 'drawable/ic_action_stop',
    label: 'Stop',
    action: MediaAction.stop);

class Player {
  initPlaying() {
    connect();
    AudioService.start(
      backgroundTaskEntrypoint: _backgroundAudioPlayerTask,
      resumeOnClick: true,
      androidNotificationChannelName: 'ABC Rádio',
      notificationColor: 0x5E6263,
      androidNotificationIcon: 'mipmap/radio',
    );
  }
}

void connect() async {
  await AudioService.connect();
}

void _backgroundAudioPlayerTask() async {
  AudioServiceBackground.run(() => CustomAudioPlayer());
}

class CustomAudioPlayer extends BackgroundAudioTask {
  bool _playing;
  Completer _completer = Completer();
  MediaItem mediaItem = MediaItem(
      id: 'audio_1',
      album: 'ABC Radio',
      title: 'A rádio que não cansa vc');

  @override
  Future onStart() async {
    await AudioServiceBackground.setMediaItem(mediaItem);
    await audioStart();
    await onPlay();
    await _completer.future;
  }

  Future audioStart() async {
    await FlutterRadio.audioStart();
  }

  Future playPause() async {
    if (_playing)
      await onPause();
    else
      await onPlay();
  }

  @override
  Future onPlay() async {
    await FlutterRadio.play(url: streamUrl);
    _playing = true;
    await AudioServiceBackground.setState(
        controls: [pauseControl, stopControl],
        basicState: BasicPlaybackState.playing);
  }

  @override
  Future onPause() async {
    await FlutterRadio.playOrPause(url: streamUrl);
    await AudioServiceBackground.setState(
        controls: [playControl, stopControl],
        basicState: BasicPlaybackState.paused);
  }

  @override
  Future onStop() async {
    await FlutterRadio.stop();
    await AudioServiceBackground.setState(
        controls: [], basicState: BasicPlaybackState.stopped);
    _completer.complete();
  }
}
