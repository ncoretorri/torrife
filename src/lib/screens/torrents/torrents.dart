import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torri/widgets/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/torrent_data.dart';
import 'package:torri/screens/torrents/torrent_card.dart';
import 'package:torri/states/ncore_state.dart';
import 'package:torri/states/torrents_state.dart';
import 'package:provider/provider.dart';
import 'package:torri/utils/backend.dart';

class Torrents extends StatefulWidget {
  const Torrents({super.key});

  @override
  State<Torrents> createState() => _TorrentsState();
}

class _TorrentsState extends State<Torrents> with WidgetsBindingObserver {
  late NcoreState _ncoreState;
  late TorrentsState _torrentsState;
  bool _loading = false;
  bool? _group = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _ncoreState = Provider.of<NcoreState>(context, listen: false);
    _torrentsState = Provider.of<TorrentsState>(context, listen: false);
    load();
    _timer = Timer(const Duration(seconds: 3), updateProgress);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _timer = Timer(const Duration(seconds: 3), updateProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Column(
            children: [
              Row(children: [
                Text("Csoportosítás"),
                Checkbox(
                    value: _group,
                    onChanged: (value) => setState(() {
                          _group = value;
                          _torrentsState.group(value == true);
                        })),
                Expanded(child: SizedBox()),
                ElevatedButton(onPressed: load, child: Icon(Icons.refresh))
              ]),
              Expanded(
                child: Consumer<TorrentsState>(
                  builder: (context, state, child) => ListView.separated(
                    itemBuilder: (ctx, index) {
                      var torrent = state.torrents[index];
                      if (torrent.children.length < 2) {
                        return createCard(torrent);
                      } else {
                        return ExpansionTile(
                            title: Text(torrent.displayName),
                            children: [
                              for (var child in torrent.children)
                                createCard(child)
                            ]);
                      }
                    },
                    separatorBuilder: (ctx, int index) => const Divider(),
                    itemCount: state.torrents.length,
                  ),
                ),
              ),
            ],
          );
  }

  TorrentCard createCard(TorrentData torrent) {
    var hnr = _ncoreState.hnrs
        .where((hnr) => hnr.externalId == torrent.externalId)
        .firstOrNull;

    return TorrentCard(torrent: torrent, hnr: hnr);
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    await _ncoreState.loadHnrs();
    await _torrentsState.load();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future updateProgress() async {
    var progresses = await getIt<Backend>().getProgresses();

    if (mounted) {
      setState(() {
        _torrentsState.updateProgresses(progresses);
      });

      _timer = Timer(const Duration(seconds: 3), updateProgress);
    }
  }
}
