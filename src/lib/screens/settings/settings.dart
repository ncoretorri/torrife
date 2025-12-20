import 'package:flutter/material.dart';
import 'package:torri/components/loading.dart';
import 'package:torri/main.dart';
import 'package:torri/models/mono_settings.dart';
import 'package:torri/utils/backend.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _maximumConnectionsController = TextEditingController();
  final _maximumDownloadRateController = TextEditingController();
  final _diskCacheBytesController = TextEditingController();
  final _maximumDiskReadRateController = TextEditingController();
  final _maximumDiskWriteRateController = TextEditingController();
  final _maximumHalfOpenConnectionsController = TextEditingController();
  final _maximumOpenFilesController = TextEditingController();
  final _maximumUploadRateController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    _maximumConnectionsController.dispose();
    _maximumDownloadRateController.dispose();
    _diskCacheBytesController.dispose();
    _maximumDiskReadRateController.dispose();
    _maximumDiskWriteRateController.dispose();
    _maximumHalfOpenConnectionsController.dispose();
    _maximumOpenFilesController.dispose();
    _maximumUploadRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Column(
            children: [
              TextField(
                keyboardType: TextInputType.number,
                controller: _maximumConnectionsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Maximum Connections',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _maximumDownloadRateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Maximum Download Rate (Mb/s)',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _maximumUploadRateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Maximum Upload Rate (Mb/s)',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _diskCacheBytesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Disk Cache Bytes',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _maximumDiskReadRateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Maximum Disk Read Rate (Mb/s)',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _maximumDiskWriteRateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Maximum Disk Write Rate (Mb/s)',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _maximumHalfOpenConnectionsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Maximum Half Open Connections',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _maximumOpenFilesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Maximum Open Files',
                ),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: save,
                child: Text("Mentés"),
              ),
            ],
          );
  }

  Future load() async {
    setState(() {
      _loading = true;
    });

    var settings = await getIt<Backend>().getMonoSettings();
    if (mounted) {
      setState(() {
        _maximumConnectionsController.text =
            settings.maximumConnections.toString();
        _maximumDownloadRateController.text =
            (settings.maximumDownloadRate / 1024 / 1024).toStringAsFixed(0);
        _diskCacheBytesController.text = settings.diskCacheBytes.toString();
        _maximumDiskReadRateController.text =
            (settings.maximumDiskReadRate / 1024 / 1024).toStringAsFixed(0);
        _maximumDiskWriteRateController.text =
            (settings.maximumDiskWriteRate / 1024 / 1024).toStringAsFixed(0);
        _maximumHalfOpenConnectionsController.text =
            settings.maximumHalfOpenConnections.toString();
        _maximumOpenFilesController.text = settings.maximumOpenFiles.toString();
        _maximumUploadRateController.text =
            (settings.maximumUploadRate / 1024 / 1024).toStringAsFixed(0);
        _loading = false;
      });
    }
  }

  Future save() async {
    setState(() {
      _loading = true;
    });

    await getIt<Backend>().updateSettings(MonoSettings(
      maximumConnections: int.parse(_maximumConnectionsController.text),
      maximumDownloadRate:
          int.parse(_maximumDownloadRateController.text) * 1024 * 1024,
      diskCacheBytes: int.parse(_diskCacheBytesController.text),
      maximumDiskReadRate:
          int.parse(_maximumDiskReadRateController.text) * 1024 * 1024,
      maximumDiskWriteRate:
          int.parse(_maximumDiskWriteRateController.text) * 1024 * 1024,
      maximumHalfOpenConnections:
          int.parse(_maximumHalfOpenConnectionsController.text),
      maximumOpenFiles: int.parse(_maximumOpenFilesController.text),
      maximumUploadRate:
          int.parse(_maximumUploadRateController.text) * 1024 * 1024,
    ));

    setState(() {
      _loading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mentve!'),
          backgroundColor: Colors.green,
          showCloseIcon: true,
        ),
      );
    }
  }
}
