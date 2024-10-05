
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_community_ai_app/model/element.dart';
import 'package:todo_community_ai_app/model/task.dart';
import 'package:todo_community_ai_app/utils/diamond_fab.dart';

class DetailPage extends StatefulWidget {
  final User user;
  final int i;
  final Task task;
  final Map<String, List<ElementTask>> currentList;
  final String color;

  DetailPage(
      {required Key key,
      required this.user,
      required this.i,
      required this.task,
      required this.currentList,
      required this.color})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController itemController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: new Stack(
        children: <Widget>[
          _getToolbar(context),
          Container(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return false;
              },
              child: new StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(widget.user.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return new Center(
                          child: CircularProgressIndicator(
                        backgroundColor: currentColor,
                      ));
                    return new Container(
                      child: getExpenseItems(snapshot),
                    );
                  }),
            ),
          ),
        ],
      ),
      floatingActionButton: DiamondFab(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                  children: <Widget>[
                    Expanded(
                      child: new TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(),
                            focusColor: currentColor,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: currentColor),
                            ),
                            labelText: "Item",
                            labelStyle: TextStyle(color: currentColor),
                            hintText: "Item",
                            contentPadding: EdgeInsets.only(
                                left: 16.0,
                                top: 20.0,
                                right: 16.0,
                                bottom: 5.0)),
                        controller: itemController,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  ButtonTheme(
                    //minWidth: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (itemController.text.isNotEmpty &&
                            !widget.currentList.values
                                .contains(itemController.text.toString())) {
                          //add new item to the task
                          var taskElements = widget.task.elements;
                          //get the current task elements
                          final dataSnapshot = await FirebaseFirestore.instance.collection(widget.user.uid).doc(widget.currentList.keys.elementAt(widget.i)).get().then((value) => value.data()!["elements"]);
                          taskElements = dataSnapshot.map<ElementTask>((e) => ElementTask.fromJson(e)).toList();
                          taskElements.add(ElementTask(name: itemController.text.toString(), isDone: false));
                          widget.task.elements = taskElements;
                          FirebaseFirestore.instance.collection(widget.user.uid).doc(widget.currentList.keys.elementAt(widget.i)).update({"elements": taskElements.map((e) => e.toJson()).toList()});

                          itemController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Add'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: currentColor,
                        disabledForegroundColor: Colors.grey.withOpacity(0.38),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: currentColor,
        foregroundColor: Colors.white,
        tooltip: 'Add new item',
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ElementTask> listElement = [];
    int nbIsDone = 0;

    if (widget.user.uid.isNotEmpty) {
      snapshot.data!.docs.map((QueryDocumentSnapshot f) {
        if (f.id == widget.currentList.keys.elementAt(widget.i)) {
          var task = Task.fromQueryDocumentSnapshot(f);
          listElement = task.elements;
        }
      }).toList();

      listElement.forEach((i) {
        if (i.isDone) {
          nbIsDone++;
        }
      });

      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 150.0),
            child: new Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5.0, left: 50.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          widget.currentList.keys.elementAt(widget.i),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35.0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return new AlertDialog(
                                title: Text("Delete: " +
                                    widget.currentList.keys
                                        .elementAt(widget.i)
                                        .toString()),
                                content: Text(
                                  "Are you sure you want to delete this list?",
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                actions: <Widget>[
                                  ButtonTheme(
                                    //minWidth: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No'),
                                      //color: currentColor,
                                      //textColor: const Color(0xffffffff),
                                    ),
                                  ),
                                  ButtonTheme(
                                    //minWidth: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection(widget.user.uid)
                                            .doc(widget.currentList.keys
                                                .elementAt(widget.i))
                                            .delete();
                                        Navigator.pop(context);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('YES'),
                                      //color: currentColor,
                                      //textColor: const Color(0xffffffff),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(
                          FontAwesomeIcons.trash,
                          size: 25.0,
                          color: currentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, left: 50.0),
                  child: Row(
                    children: <Widget>[
                      CircularProgressIndicator(
                        value: listElement.length == 0 ? 0.0 : nbIsDone / listElement.length,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(currentColor),
                        color: currentColor,
                      ),
                      Padding(padding: EdgeInsets.only(left: 10.0)),
                      new Text(
                        nbIsDone.toString() +
                            " of " +
                            listElement.length.toString() +
                            " tasks",
                        style: TextStyle(fontSize: 18.0, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(left: 50.0),
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Color(0xFFFCFCFC),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 350,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: listElement.length,
                              itemBuilder: (BuildContext ctxt, int i) {
                                return new Slidable(
                                  child: GestureDetector(
                                    onTap: () {
                                      var taskElement = listElement.elementAt(i);
                                      taskElement.isDone = !taskElement.isDone;
                                      listElement[i] = taskElement;
                                      FirebaseFirestore.instance
                                          .collection(widget.user.uid)
                                          .doc(widget.currentList.keys
                                              .elementAt(widget.i))
                                          .update({"elements": listElement.map((e) => e.toJson()).toList()});
                                    },
                                    child: Container(
                                      height: 50.0,
                                      color: listElement.elementAt(i).isDone
                                          ? Color(0xFFF0F0F0)
                                          : Color(0xFFFCFCFC),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 50.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              listElement.elementAt(i).isDone
                                                  ? FontAwesomeIcons.squareCheck
                                                  : FontAwesomeIcons.square,
                                              color: listElement
                                                      .elementAt(i)
                                                      .isDone
                                                  ? currentColor
                                                  : Colors.black,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 30.0),
                                            ),
                                            Flexible(
                                              child: Text(
                                                listElement.elementAt(i).name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: listElement
                                                        .elementAt(i)
                                                        .isDone
                                                    ? TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: currentColor,
                                                        fontSize: 27.0,
                                                      )
                                                    : TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 27.0,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  endActionPane: ActionPane(
                                    motion: ScrollMotion(),
                                    children: <Widget>[
                                      SlidableAction(
                                        flex: 1,
                                        autoClose: true,
                                        onPressed: (context) {
                                          listElement.removeAt(i);
                                          FirebaseFirestore.instance
                                              .collection(widget.user.uid)
                                              .doc(widget.currentList.keys
                                                  .elementAt(widget.i))
                                              .update({"elements": listElement.map((e) => e.toJson()).toList()});
                                        },
                                        foregroundColor: Colors.red,
                                        backgroundColor: Colors.red.withOpacity(0.1),
                                        icon: Icons.delete,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    pickerColor = Color(int.parse(widget.color));
    currentColor = Color(int.parse(widget.color));
  }

  late Color pickerColor;
  late Color currentColor;

  late ValueChanged<Color> onColorChanged;

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Padding _getToolbar(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 12.0),
      child:
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        new Image(
            width: 35.0,
            height: 35.0,
            fit: BoxFit.cover,
            image: new AssetImage('assets/list.png')),
        ElevatedButton(
          onPressed: () {
            pickerColor = currentColor;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pick a color!'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: changeColor,
                      enableAlpha: false,
                      paletteType: PaletteType.hueWheel,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Got it'),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection(widget.user.uid)
                            .doc(widget.currentList.keys.elementAt(widget.i))
                            .update({"color": pickerColor.value.toString()});

                        setState(() => currentColor = pickerColor);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Color'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: currentColor,
            disabledForegroundColor: Colors.grey.withOpacity(0.38),
            disabledBackgroundColor: Colors.grey.withOpacity(0.12),
          ),
          //color: currentColor,
          //textColor: const Color(0xffffffff),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: new Icon(
            Icons.close,
            size: 40.0,
            color: currentColor,
          ),
        ),
      ]),
    );
  }
}
