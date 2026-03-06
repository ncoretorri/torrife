import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torri/main.dart';
import 'package:torri/models/sysinfo.dart';
import 'package:torri/utils/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torri/utils/utils.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final _backendUrl = TextEditingController();
  SysInfo? _info;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _backendUrl,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Cím',
          ),
        ),
        SizedBox(
          height: 12,
        ),
        ElevatedButton(
          onPressed: save,
          child: Text("Mentés"),
        ),
        ElevatedButton(
          onPressed: loadInfo,
          child: Text("Betöltés"),
        ),
        SizedBox(
          height: 12,
        ),
        if (_info != null)
          for (var storage in _info!.storages)
            Text(
                "${storage.name}: ${Utils.formatBytes(storage.freeSpace)}/${Utils.formatBytes(storage.totalSize)}"),
      ],
    );
  }

  Future load() async {
    final prefs = await SharedPreferences.getInstance();
    var backendUrl = prefs.getString('backendUrl') ?? '';
    _backendUrl.text = backendUrl;
  }

  Future save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('backendUrl', _backendUrl.text);
  }

  Future loadInfo() async {
    var info = await getIt<Backend>().info();
    if (mounted) {
      setState(() {
        _info = info;
      });
    }
  }
}
