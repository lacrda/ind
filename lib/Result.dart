import 'package:ind/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ind/database_helpers.dart';
import 'package:ind/spotify.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_package_manager/flutter_package_manager.dart';
import 'package:ind/Result.dart';

class Result extends StatefulWidget {
  final Ind model;

  Result({this.model});

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Ind model2 = Ind();

  _save({String name, String url, String type}) async {
    Ind ind = Ind();
    ind.name = name;
    ind.url = url;
    ind.type = type;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(ind);
//    print('inserted row: $id - $name - $url - $type');
  }

  void setModel({String name, String type}) {
    setState(() {
      model2.name = name;
      model2.type = type;
    });
  }

  getInfo(String url) async {
    List ids = url.split("?");
    List ids2 = ids[0].split("/");
    String id = ids2.last;
    List b = await getSpotifyApi(id);
//    setModel(name: b[0].toString(), type: b[1].toString());
    return b;
  }

  buildContainer2(String url) {
    print(widget.model.url);
    return Container(
        child: FutureBuilder(
            future: getInfo(url),
            builder: (context2, snapshot) {
              if (snapshot.hasData) {
                return Container(
                    child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 25.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  snapshot.data[0],
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  snapshot.data[1],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.teal,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 30.0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: RaisedButton(
                                        child: Text(
                                          "Salvar",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color: Colors.teal,
                                        onPressed: () {
                                          _save(
                                              name: snapshot.data[0],
                                              url: url,
                                              type: snapshot.data[1]);
                                          Navigator.popUntil(context,
                                              ModalRoute.withName('/'));
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (Scaffold(
      appBar: AppBar(title: Text("Adicionando")),
      body: Container(
          child: Column(
        children: <Widget>[
          buildContainer2(widget.model.url.toString()),
        ],
      )),
    ));
  }
}
