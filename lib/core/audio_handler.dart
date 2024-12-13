import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melody/core/audio_track.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
      androidNotificationChannelName: 'Melody Music',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayer get player => _player;

  MyAudioHandler() {
    _player.setAudioSource(_playlist);
    _broadcastPlaybackState();
    _broadcastMediaItemChanges();
    _listenToPlaybackOptionChanges();

    _player.playbackEventStream.listen((e) {
      print(e.processingState);
    });
    _player.playingStream.listen(print);
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToQueueItem(int index) =>
      _player.seek(Duration.zero, index: index);

  @override
  Future<void> skipToPrevious() async {
    int? index;
    if (_player.position.inSeconds < 5) {
      // it will be null if there is no previous index, so we dont need to check
      index = _player.previousIndex;
    }

    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) return _player.seekToNext();
  }

  Future<void> updatePlaylist(List<MediaItem> mediaItems,
      [bool clear = false]) async {
    if (clear) await _playlist.clear();
    await _playlist
        .addAll(mediaItems.map((item) => item.toAudioSource()).toList());
    final newQueue = (clear ? <MediaItem>[] : queue.value) + mediaItems;
    queue.add(newQueue);
    mediaItem.add(newQueue.firstOrNull);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    return updatePlaylist(queue, true);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) {
    return updatePlaylist(mediaItems);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) {
    return addQueueItems([mediaItem]);
  }

  // TODO: need to update [queue]
  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) {
    return _playlist.insert(index, mediaItem.toAudioSource());
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    await _player.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _player.setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
  }

  void _broadcastMediaItemChanges() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) {
        mediaItem.add(null);
        return;
      }
      final current = sequenceState.currentSource;
      if (current == null) {
        mediaItem.add(null);
        return;
      }

      if (current.tag != null && queue.hasValue) {
        try {
          final entry =
              queue.value.firstWhere((item) => item.id == current.tag);
          mediaItem.add(entry);
        } catch (_) {}
      }
    });
  }

  void _broadcastPlaybackState() {
    _player.playbackEventStream.listen((event) {
      final isPlaying = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: isPlaying,
        updatePosition: _player.position,
        queueIndex: _player.currentIndex,
      ));
    });
  }

  void _listenToPlaybackOptionChanges() {
    final box = Hive.box("settings");
    // initializes the repeat and shuffle mode
    () async {
      final repeatMode = switch (box.get("repeat", defaultValue: "none")) {
        "none" => AudioServiceRepeatMode.none,
        "one" => AudioServiceRepeatMode.one,
        "all" => AudioServiceRepeatMode.all,
        _ => throw ArgumentError.value("repeat", "not one of none/one/all"),
      };

      setRepeatMode(repeatMode);
      final shuffle = box.get("shuffle", defaultValue: false) as bool;

      setShuffleMode(
          shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
    };
    _player.loopModeStream.listen((event) {
      box.put("repeat", event.name);
    });
    _player.shuffleModeEnabledStream.listen((event) {
      box.put("shuffle", event);
    });
  }
}
