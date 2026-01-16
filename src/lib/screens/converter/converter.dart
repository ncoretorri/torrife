import 'package:flutter/material.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/sysinfo.dart';
import 'package:torri/screens/converter/storage_lister.dart';
import 'package:torri/utils/backend.dart';

class Converter extends StatefulWidget {
  const Converter({super.key});

  @override
  State<Converter> createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {
  bool _loading = false;
  List<Storage> _storages = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : ListView.builder(
            itemCount: _storages.length,
            itemBuilder: (context, index) {
              var storage = _storages[index];
              return ListTile(
                title: Text(storage.name),
                onTap: () => openStorage(storage.name),
              );
            },
          );
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    var response = await getIt<Backend>().info();

    if (mounted) {
      setState(() {
        _storages = response.storages;
        _loading = false;
      });
    }
  }

  void openStorage(String storageName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorageLister(
          storageName: storageName,
          relativePath: "",
        ),
      ),
    );
  }
}
