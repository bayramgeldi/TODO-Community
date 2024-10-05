import 'dart:async';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:todo_community_ai_app/model/task.dart';

class NewTaskPage extends StatefulWidget {
  final User user;

  NewTaskPage({required Key key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  TextEditingController listNameController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Color pickerColor = Color(0xff6633ff);
  Color currentColor = Color(0xff6633ff);

  late ValueChanged<Color> onColorChanged;

  bool _saving = false;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Future<Null> initConnectivity() async {
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

  void addToFirebase() async {
    setState(() {
      _saving = true;
    });

    print(_connectionStatus);

    if (_connectionStatus == "ConnectivityResult.none") {
      showInSnackBar("No internet connection currently available");
      setState(() {
        _saving = false;
      });
    } else {
      bool isExist = false;

      QuerySnapshot query =
          await FirebaseFirestore.instance.collection(widget.user.uid).get();

      query.docs.forEach((doc) {
        if (listNameController.text.toString() == doc.id) {
          isExist = true;
        }
      });

      if (isExist == false && listNameController.text.isNotEmpty) {
        var task = Task(
            title: listNameController.text.toString().trim(),
            description: "",
            color: currentColor.value.toString(),
            date: DateTime.now(),
            elements: []);
        await FirebaseFirestore.instance
            .collection(widget.user.uid)
            .doc(listNameController.text.toString().trim())
            .set(task.toJson());

        if (isExist == true) {
          showInSnackBar("This list already exists");
          setState(() {
            _saving = false;
          });
        }
        if (listNameController.text.isEmpty) {
          showInSnackBar("Please enter a name");
          setState(() {
            _saving = false;
          });
        }

        listNameController.clear();

        pickerColor = Color(0xff6633ff);
        currentColor = Color(0xff6633ff);

        Navigator.of(context).pop();
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
          child: new Stack(
            children: <Widget>[
              _getToolbar(context),
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 100.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'New',
                                    style: new TextStyle(
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'List',
                                    style: new TextStyle(
                                        fontSize: 28.0, color: Colors.grey),
                                  )
                                ],
                              )),
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                      child: new Column(
                        children: <Widget>[
                          new TextFormField(
                            decoration: InputDecoration(
                                border: new OutlineInputBorder(),
                                labelText: "List name",
                                contentPadding: EdgeInsets.only(
                                    left: 16.0,
                                    top: 20.0,
                                    right: 16.0,
                                    bottom: 5.0)),
                            controller: listNameController,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 20,
                          ),
                          new Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                          ),
                          ButtonTheme(
                            minWidth: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                pickerColor = currentColor;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick a color!'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          enableAlpha: false,
                                          paletteType: PaletteType.hueWheel,
                                          pickerColor: pickerColor,
                                          onColorChanged: changeColor,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Got it'),
                                          onPressed: () {
                                            setState(() =>
                                                currentColor = pickerColor);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Card color'),
                              //color: currentColor,
                              //textColor: const Color(0xffffffff),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: new Column(
                        children: <Widget>[
                          new ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: currentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text('Add'),
                            //color: Colors.blue,
                            //elevation: 4.0,
                            //splashColor: Colors.deepPurple,
                            onPressed: addToFirebase,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          inAsyncCall: _saving),
    );
  }

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        _connectionStatus = results.first.toString();
      });
    });
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value, textAlign: TextAlign.center),
      backgroundColor: currentColor,
      duration: Duration(seconds: 3),
    ));
  }

  Container _getToolbar(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.only(left: 10.0, top: 40.0),
      child: new BackButton(color: Colors.black),
    );
  }
}
