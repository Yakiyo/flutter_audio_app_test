import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:melody/core/audio_track.dart';
import 'package:melody/core/utils.dart';
import 'package:melody/ui/widgets/tracks_view.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioHandler = get<AudioHandler>();
    return StreamBuilder(
      stream: audioHandler.queue,
      initialData: const <MediaItem>[],
      builder: (context, snapshot) {
        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(
            child: Text("No music added to queue"),
          );
        }
        final tracks =
            data.map((item) => AudioTrack.fromMediaItem(item)).toList();
        return TracksView(tracks: tracks);
      },
    );
  }
}

// void _something(AudioTrack track) async {
//   print(track.title);
//   final img = await get<OnAudioQuery>().queryArtwork(
//     int.parse(track.id),
//     ArtworkType.AUDIO,
//   );
//   print(img?.length);
//   assert(img != null);
//   final d = await PaletteGenerator.fromImageProvider(Image.memory(img!).image)
//       .then((value) => value.dominantColor?.color);
//   print(d);
// }
