import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/screens/search/torrent_list.dart';
import 'package:torri/states/ncore_state.dart';
import 'package:provider/provider.dart';
import 'package:torri/states/torrents_state.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class OrderOption {
  final String label;
  final String value;

  const OrderOption(this.label, this.value);
}

const List<OrderOption> orderOptions = <OrderOption>[
  OrderOption('Seed', 'seeders'),
  OrderOption('Leech', 'leechers'),
  OrderOption('Feltöltve', 'ctime'),
  OrderOption('Letöltések', 'times_completed'),
];

typedef MenuEntry = DropdownMenuEntry<OrderOption>;

class _SearchState extends State<Search> {
  final FocusNode _focusNode = FocusNode();
  late NcoreState _ncoreState;
  late TorrentsState _torrentsState;
  bool _loading = false;
  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    orderOptions.map<MenuEntry>(
        (OrderOption option) => MenuEntry(value: option, label: option.label)),
  );
  OrderOption orderBy = orderOptions.first;
  String _initValue = "";

  @override
  void initState() {
    super.initState();
    _ncoreState = Provider.of<NcoreState>(context, listen: false);
    _torrentsState = Provider.of<TorrentsState>(context, listen: false);
    _focusNode.requestFocus();

    _ncoreState.addListener(listener);
  }

  @override
  void dispose() {
    _ncoreState.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 150.0,
                    child: DropdownMenu<OrderOption>(
                      initialSelection: orderOptions.first,
                      label: const Text("Rendezés"),
                      onSelected: (OrderOption? value) {
                        setState(() {
                          orderBy = value!;
                        });
                      },
                      dropdownMenuEntries: menuEntries,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      focusNode: _focusNode,
                      onFieldSubmitted: (t) => startSearch(t),
                      initialValue: _initValue,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Keresés',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              TorrentList(),
            ],
          );
  }

  Future startSearch(String text) async {
    setState(() {
      _loading = true;
    });

    _initValue = text;

    await _torrentsState.load();
    await _ncoreState.startSearch(text, orderBy.value);
  }

  void listener() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}
