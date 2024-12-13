// conversions between different audio classes
// AudioTrack => MediaItem
// SongModel => AudioTrack
// SongModel => MediaItem

import 'dart:convert';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'utils.dart';

class AudioTrack {
  /// the media's id
  final String id;

  /// the media's title
  final String title;

  /// the media's artist
  final String? artist;

  /// the media's album
  final String? album;

  /// the media's content uri, this is received from [SongModel.uri]
  final String? contentUri;

  /// the media file's path
  final String path;

  late final Duration duration;

  AudioTrack(
      {required this.id,
      required this.title,
      required this.path,
      this.artist,
      this.album,
      this.contentUri,
      int duration = 0}) {
    this.duration = Duration(milliseconds: duration);
  }

  Future<Uint8List?> artwork() async {
    final logger = get<Logger>();
    final idInt = int.tryParse(id);
    if (idInt == null) {
      logger.w("Unable to convert $id to int");
      return null;
    }
    return await get<OnAudioQuery>()
        .queryArtwork(idInt, ArtworkType.AUDIO)
        .catchError((error) {
      logger.e("Failed to get artwork for $title ($id)", error: error);
      return null;
    });
  }

  MediaItem toMediaItem() => MediaItem(
        id: id,
        title: title,
        album: album,
        artist: artist,
        duration: duration,
        extras: {"path": path, "contentUri": contentUri},
      );

  factory AudioTrack.fromSongModel(SongModel song) => AudioTrack(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        path: song.data,
      );

  factory AudioTrack.fromMediaItem(MediaItem item) => AudioTrack(
      id: item.id,
      title: item.title,
      path: item.extras?['path'],
      album: item.album,
      artist: item.artist,
      duration: item.duration?.inMilliseconds ?? 0,
      contentUri: item.extras?['contentUri']);

  factory AudioTrack.fromJson(Map<String, String> json) => AudioTrack(
        id: json['id']!,
        title: json['title']!,
        path: json['path']!,
        album: json['album'],
        artist: json['artist'],
        duration: int.tryParse(json['duration'] ?? '0') ?? 0,
        contentUri: json['contentUri'],
      );

  Map<String, String?> toJson() => {
        "id": id,
        "title": title,
        "artist": artist,
        "album": album,
        "path": path,
        "duration": "${duration.inMilliseconds}",
        "contentUri": contentUri
      };

  @override
  String toString() => jsonEncode(toJson());
}

extension ToAudioServiceRepeatMode on LoopMode {
  AudioServiceRepeatMode toAudioServiceRepeatMode() {
    switch (this) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }
}

extension ToMediaItem on SongModel {
  MediaItem toMediaItem() {
    return MediaItem(
        id: "$id",
        album: album,
        title: title,
        artist: artist,
        genre: genre,
        duration: Duration(milliseconds: duration ?? 0),
        artUri: uri != null ? Uri.parse(uri!) : null,
        extras: {
          "path": data,
          "contentUri": uri,
        });
  }
}

extension ToAudioSource on MediaItem {
  AudioSource toAudioSource() =>
      AudioSource.uri(Uri.parse(extras?["path"]!), tag: id);
}
