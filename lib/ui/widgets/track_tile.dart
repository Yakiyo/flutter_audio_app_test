import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../core/audio_track.dart';

class TrackTile extends StatelessWidget {
  final AudioTrack track;
  final void Function(AudioTrack) onTrackPress;
  const TrackTile({super.key, required this.track, required this.onTrackPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: QueryArtworkWidget(
          id: int.parse(track.id),
          type: ArtworkType.AUDIO,
          artworkBorder: BorderRadius.circular(10),
        ),
        title: Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(track.artist ?? "Unknown Artist"),
              if (track.album != null) const Text(" | "),
              if (track.album != null) Text(track.album!),
            ],
          ),
        ),
        trailing: IconButton(
            onPressed: () {
              showAlignedDialog(
                targetAnchor: Alignment.centerRight,
                avoidOverflow: true,
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () {},
                            child: const Text("Add to queue")),
                        TextButton(
                            onPressed: () {},
                            child: const Text("Track Details")),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.more_vert)),
        onTap: () => onTrackPress(track),
      ),
    );
  }
}
