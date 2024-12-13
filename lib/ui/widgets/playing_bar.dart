import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:melody/core/utils.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../core/audio_track.dart';

class PlayingBar extends StatefulWidget {
  const PlayingBar({super.key});

  @override
  State<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends State<PlayingBar> {
  Uint8List? imgData;
  final audioHandler = get<AudioHandler>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data as MediaItem;
        print(audioHandler.queue.value.map((x) => x.title).toList());
        final future = getDominantColor(AudioTrack.fromMediaItem(data));
        return FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            final palette = snapshot.data as PaletteGenerator;
            final textStyle = Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.mutedColor?.bodyTextColor);
            return Container(
              padding: const EdgeInsets.only(bottom: 4, right: 4, left: 4),
              color: Theme.of(context).colorScheme.secondary,
              child: Container(
                decoration: BoxDecoration(
                    color: palette.mutedColor?.color,
                    borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (imgData != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.memory(
                            imgData!,
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 40,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: data.title.length > 20
                                  ? Marquee(
                                      velocity: 30,
                                      pauseAfterRound:
                                          const Duration(seconds: 1),
                                      blankSpace: 30,
                                      scrollAxis: Axis.horizontal,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      text: data.title,
                                      style: textStyle,
                                    )
                                  : Text(
                                      data.title,
                                      style: textStyle,
                                    ),
                            ),
                            Expanded(
                              child: (data.artist ?? "").length > 20
                                  ? Marquee(
                                      velocity: 30,
                                      pauseAfterRound:
                                          const Duration(seconds: 1),
                                      blankSpace: 30,
                                      text: data.artist ?? "",
                                      style: textStyle?.copyWith(fontSize: 12),
                                    )
                                  : Text(
                                      data.artist ?? "",
                                      style: textStyle?.copyWith(fontSize: 12),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: MediaButtons(
                          iconColor: palette.mutedColor?.bodyTextColor,
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<PaletteGenerator> getDominantColor(AudioTrack track) async {
    final img = await get<OnAudioQuery>()
        .queryArtwork(int.parse(track.id), ArtworkType.AUDIO);
    imgData = img;
    return PaletteGenerator.fromImageProvider(Image.memory(img!).image);
  }
}

class MediaButtons extends StatefulWidget {
  final Color? iconColor;
  const MediaButtons({super.key, required this.iconColor});

  @override
  State<MediaButtons> createState() => _MediaButtonsState();
}

class _MediaButtonsState extends State<MediaButtons> {
  final audioHandler = get<AudioHandler>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: audioHandler.skipToPrevious,
              child: Container(
                padding: const EdgeInsets.all(0),
                width: 20,
                height: 20,
                child: Icon(
                  Icons.skip_previous,
                  color: widget.iconColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if ((data?.playing ?? false) && data?.processingState == AudioProcessingState.ready) {
                  audioHandler.pause();
                } else {
                  audioHandler.play();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(0),
                width: 20,
                height: 20,
                child: (data?.playing ?? false) == true
                    ? Icon(Icons.pause, color: widget.iconColor)
                    : switch (data?.processingState) {
                        AudioProcessingState.loading =>
                          const CircularProgressIndicator(),
                        AudioProcessingState.buffering =>
                          const CircularProgressIndicator(),
                        AudioProcessingState.error =>
                          Icon(Icons.error, color: widget.iconColor),
                        _ => Icon(Icons.play_arrow, color: widget.iconColor),
                      },
              ),
            ),
            GestureDetector(
              onTap: audioHandler.skipToNext,
              child: Container(
                padding: const EdgeInsets.all(0),
                width: 20,
                height: 20,
                child: Icon(
                  Icons.skip_next,
                  color: widget.iconColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
