import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:torri/screens/converter/converter.dart';
import 'package:torri/screens/info/info.dart';
import 'package:torri/screens/search/search.dart';
import 'package:torri/screens/settings/settings.dart';
import 'package:torri/screens/torrents/torrents.dart';
import 'package:torri/states/ncore_state.dart';
import 'package:torri/states/torrents_state.dart';
import 'package:torri/utils/backend.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

GetIt getIt = GetIt.instance;

void main() {
  getIt.registerSingleton<Backend>(Backend());

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NcoreState()),
          ChangeNotifierProvider(create: (context) => TorrentsState()),
        ],
        child: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          },
          child: const MyApp(),
        )),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Torri',
      theme: ThemeData(brightness: Brightness.dark),
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late NcoreState _ncoreState;
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Info(),
    Torrents(),
    Search(),
    Settings(),
    Converter()
  ];

  static const List<String> _titles = <String>[
    "Info",
    "Torrentek",
    "Keresés",
    "Beállítások",
    "Konvertáló"
  ];

  @override
  void initState() {
    super.initState();
    _ncoreState = Provider.of<NcoreState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(_titles.elementAt(_selectedIndex)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 130.0,
              child: const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menü'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: const Text('Info'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: const Text('Torrentek'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: const Text('Keresés'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Beállítások'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.cached),
              title: const Text('Konvertáló'),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),

            // ListTile(
            //   leading: Icon(Icons.upload),
            //   title: const Text('Feltöltés'),
            //   onTap: () {
            //     // Update the state of the app.
            //     // ...
            //   },
            // ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ExcludeFocus(
            child: WebViewWidget(controller: _ncoreState.controller),
          ),
          Consumer<NcoreState>(
            builder: (context, state, child) => Visibility(
                visible: state.loggedIn,
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  color: Colors.black,
                  child: _pages.elementAt(_selectedIndex),
                )),
          ),
        ],
      ),
    );
  }
}
