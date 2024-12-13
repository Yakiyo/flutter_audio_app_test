import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:melody/core/audio_track.dart';
import 'package:melody/core/utils.dart';
import 'package:melody/ui/widgets/track_tile.dart';

class TracksView extends StatelessWidget {
  final List<AudioTrack> tracks;
  const TracksView({super.key, required this.tracks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        indent: 20,
        endIndent: 20,
      ),
      itemCount: tracks.length,
      itemBuilder: (context, index) => TrackTile(
        track: tracks[index],
        onTrackPress: _onTrackPress,
      ),
    );
  }

  void _onTrackPress(AudioTrack track) {
    final index = tracks.indexWhere((item) => item.id == track.id);
    if (index < 0) {
      get<Logger>().e("Unable to find track. ${track.id}");
      return;
    }
    final mediaItems =
        tracks.skip(index).map((track) => track.toMediaItem()).toList();
    get<AudioHandler>().updateQueue(mediaItems);
    // print("adding items to queue ${mediaItems.map((x) => x.title).join(", ")}");
    // mediaItems.forEach((item) => print(item.extras!['path']!));
  }
}
