import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../core/audio_track.dart';
import '../../core/utils.dart';
import '../widgets/my_fab.dart';
import '../widgets/my_future_builder.dart';
import '../widgets/persisting_tab.dart';
import '../widgets/playing_bar.dart';
import '../widgets/tracks_view.dart';
import 'queue.dart';
import 'search.dart';
import 'settings.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final Future<List<SongModel>> tracks;
  late final Future<List<AlbumModel>> albums;
  late final Future<List<ArtistModel>> artists;
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    final query = get<OnAudioQuery>();
    tracks = query.querySongs(sortType: SongSortType.DATE_ADDED);
    albums = query.queryAlbums(sortType: AlbumSortType.ARTIST);
    artists = query.queryArtists(sortType: ArtistSortType.ARTIST);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Melody",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SearchPage()));
              },
              icon: const Icon(Ionicons.search)),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsPage()));
              },
              icon: const Icon(Ionicons.settings_outline)),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [
          Text("Tracks"),
          Text("Albums"),
          Text("Artists"),
          Text("Playlists"),
          Text("Queue"),
        ]),
      ),
      floatingActionButton: const MyFab(),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
          child: TabBarView(controller: _tabController, children: [
            MyFutureBuilder(
              builder: (data) => PersistingTab(
                  child: TracksView(
                      tracks: data.map(AudioTrack.fromSongModel).toList())),
              future: tracks,
            ),
            const PersistingTab(child: AlbumsView()),
            const Text("In Artists Page"),
            const Text("In Playlists Page"),
            const QueuePage(),
          ]),
        ),
      ),
      bottomNavigationBar: const PlayingBar(),
    );
  }
}

class AlbumsView extends StatelessWidget {
  const AlbumsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          children: [
            Expanded(
              child: Marquee(
                  text:
                      "Hello World here i come valorant sucks riot bad im bronze"),
            ),
          ],
        ),
      ),
    );
  }

  _showAlignedDialog(BuildContext context) {
    showAlignedDialog(
      context: context,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text("Hello World"),
        );
      },
      followerAnchor: Alignment.bottomRight,
      avoidOverflow: true,
    );
  }
}
