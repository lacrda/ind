import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ind/database_helpers.dart';
import 'package:ind/spotify.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_package_manager/flutter_package_manager.dart';
import 'package:ind/Result.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    var lista = _read();
    initPlatformState();
  }

  bool isSpotifyInstalled;

  _launchIntent(String url) async {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: url,
      arguments: {'extra_referrer': "android-app://lacrda.ind"},
    );
    await intent.launch();
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var value =
          await FlutterPackageManager.getPackageInfo("com.spotify.music");
      bool isInstalled = value != null ? true : false;
      print(isInstalled);
      setState(() {
        isSpotifyInstalled = isInstalled;
      });
    } catch (e) {
      print("erro");
      setState(() {
        isSpotifyInstalled = false;
      });
    }
  }

  _listarItens() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    List lista = [];
    List results = await helper.queryAllWords();
    for (var i = 0; i < results.length; i++) {
//      print(results[i]);
      Ind ind = Ind.fromMap(results[i]);
      lista.add(ind);
    }
    return lista;
  }

  getIcon(String type) {
    if (type == "song") {
      return Icon(Icons.queue_music);
    } else if (type == "movie") {
      return Icon(Icons.local_movies);
    } else if (type == "book") {
      return Icon(Icons.book);
    } else {
      return Icon(Icons.bookmark_border);
    }
  }

  int length(data) {
    List a = data;
    return a.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade500,
        title: Text('Lista de Indicações'),
      ),
      body: buildContainer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => (Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPage()),
        )),
      ),
    );
  }

  buildContainer() {
    return Container(
      child: FutureBuilder(
        future: _listarItens(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
                itemCount: length(snapshot.data),
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 6.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new ListTile(
                              dense: true,
                              leading: getIcon(snapshot.data[index].type),
                              title: Text(snapshot.data[index].name),
                              subtitle: Text(snapshot.data[index].url),
                              onTap: () {
                                List a = snapshot.data[index].url.split("?");
                                List b = a.first.split("/");
                                String objectId = b.last;
                                print(objectId);
                                _launchIntent(snapshot.data[index].url);
                              },
                              onLongPress: () {
                                print('long');
                              },
                              trailing: IconButton(
                                icon: Icon(Icons.play_circle_outline),
                                onPressed: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          } else {
            return Center(
              child: Text(
                  "Adicione músicas, artistas ou álbuns inserindo o link delas no Spotify."),
            );
          }
        },
      ),
    );
  }

  Future<String> _read() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 9;
    var results = await helper.queryWord(rowId);
//    print(results.name);
    return results.name;
  }

  _save({String name, String url, String type}) async {
    Ind ind = Ind();
    ind.name = name;
    ind.url = url;
    ind.type = type;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(ind);
//    print('inserted row: $id - $name - $url');
  }

  _saveAndUpdate() async {
    Ind ind = Ind();
    ind.name = 'Walk';
    ind.type = 'song';
    ind.url = 'spotify.com/Foo-Fighters';
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(ind);
//    print('inserted row: $id');

    List results = await helper.queryAllWords();
    for (var i = 0; i < results.length; i++) {
//      print(results[i]);
      Ind ind = Ind.fromMap(results[i]);
//      print('read row: ${ind.name} ${ind.url}');
    }
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  _save({String name, String url, String type}) async {
    Ind ind = Ind();
    ind.name = name;
    ind.url = url;
    ind.type = type;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(ind);
//    print('inserted row: $id - $name - $url - $type');
  }

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  Ind model = Ind();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Url',
                        ),
                        onSaved: (String value) {
                          model.url = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: RaisedButton(
                  elevation: 3.0,
                  color: Colors.teal,
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Result(model: this.model)));
//                      _save(name: model.name, url: model.url, type: model.type);
                    }
                  },
                  child: Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo item"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MyCustomForm(),
        ],
      ),
    );
  }
}
