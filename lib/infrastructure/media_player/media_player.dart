import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/model/playing_info_m.dart';

abstract class MediaPlayer {
  Stream<bool> get playingStream;

  Stream<Duration> get positionStream;

  Stream<Duration> get durationStream;

  Stream<bool> get bufferingStream;

  bool get isPlaying;

  bool get isBuffering;

  Duration get currentPosition;

  Duration get currentDuration;

  double get aspectRatio;

  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> playOrPause();

  Future<void> setVolume(double volume);

  Widget buildVideoView();

  Future<PlayingInfoM> getPlayingInfo();

  Future<void> dispose();
}
