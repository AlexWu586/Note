import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/Hints.dart';
import '../models/Note.dart';
import '../models/Storage.dart';

class AppState extends ChangeNotifier {
  var index = 0;
  void changeIndex(int n) {
    index = n;
    notifyListeners();
  }

  String hint = Hints.hints[Random().nextInt(5)];
  void changeHint() {
    hint = Hints.hints[Random().nextInt(5)];
    notifyListeners();
  }

  List<Note> notes = [];
  void addNewNote(Note note) {
    notes.add(note);
    notes.sort((a, b) =>
        int.parse(a.date + a.time).compareTo(int.parse(b.date + b.time)));
    notifyListeners();
  }

  void deleteCurrentNote(int index) {
    notes.removeAt(index);
    notes.sort((a, b) =>
        int.parse(a.date + a.time).compareTo(int.parse(b.date + b.time)));
    notifyListeners();
  }

  bool isRead = false;
  void readData() async {
    String data = await Storage().readData();
    List<String> splitData = data.split('\n');
    for (int i = 0; i < splitData.length; i++) {
      List<String> eachData = splitData[i].split(',');
      if (eachData.length == 4) {
        addNewNote(Note(
          title: eachData[0],
          description: eachData[1],
          date: eachData[2],
          time: eachData[3],
        ));
      }
    }
  }

  void writeData() async {
    String data = "";
    for (int i = 0; i < notes.length; i++) {
      data +=
          "${notes[i].title},${notes[i].description},${notes[i].date},${notes[i].time}\n";
    }
    Storage().writeData(data);
  }

  var title = TextEditingController();
  var description = TextEditingController();
  var date = TextEditingController();
  var time = TextEditingController();

  void reset() {
    title.text = "";
    description.text = "";
    date.text = "";
    time.text = "";
  }

  String errorMsg = "";
  void msg(String t) {
    errorMsg = t;
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    if (!appState.isRead) {
      appState.readData();
      appState.isRead = true;
    }
    Widget page;
    switch (appState.index) {
      case 0:
        page = const ShowNotes();
        break;
      case 1:
        page = const AddNote();
      default:
        throw UnimplementedError('no widget for ${appState.index}');
    }
    return Container(
      color: const Color.fromRGBO(225, 225, 225, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          const AppBar(),
          const Divider(),
          Expanded(
            child: Container(
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBar extends StatefulWidget {
  const AppBar({super.key});
  @override
  State<AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  var isTimeIcon = true;
  String date = DateFormat('yyyy/MM/dd').format(DateTime.now());
  String time = DateFormat('HH:mm:ss').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        date = DateFormat('yyyy/MM/dd').format(DateTime.now());
        time = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.01,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(190, 215, 225, 1),
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.075),
      ),
      height: MediaQuery.of(context).size.height * 0.1,
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  isTimeIcon = !isTimeIcon;
                });
              },
              icon: isTimeIcon
                  ? SvgPicture.asset(
                      "assets/icons/time.svg",
                      width: MediaQuery.of(context).size.height * 0.05,
                      height: MediaQuery.of(context).size.height * 0.05,
                    )
                  : SvgPicture.asset(
                      "assets/icons/date.svg",
                      width: MediaQuery.of(context).size.height * 0.05,
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1 * 0.7,
                alignment: Alignment.center,
                child: FittedBox(
                  child: isTimeIcon
                      ? Text(
                          time,
                          style: const TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          date,
                          style: const TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                appState.reset();
                appState.errorMsg = "";
                appState.changeHint();
                appState.changeIndex(1);
              },
              icon: Icon(
                Icons.add,
                size: MediaQuery.of(context).size.height * 0.05,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Divider extends StatelessWidget {
  const Divider({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return Row(
      children: [
        Expanded(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.005,
            color: const Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.005),
          child: Text(
            appState.hint,
            style: TextStyle(
              color: const Color.fromRGBO(0, 0, 0, 0.5),
              fontSize: MediaQuery.of(context).size.height * 0.015,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.005,
            color: const Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
      ],
    );
  }
}

class ShowNotes extends StatelessWidget {
  const ShowNotes({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    String dateFormat(String date) =>
        "${date[0]}${date[1]}${date[2]}${date[3]}/${date[4]}${date[5]}/${date[6]}${date[7]}";
    String timeFormat(String time) =>
        "${time[0]}${time[1]}:${time[2]}${time[3]}";
    if (appState.notes.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "還沒有任何備忘錄喔~",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.7 / 10,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                child: IconButton(
                  onPressed: () {
                    exit(0);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/leave.svg",
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.height * 0.05,
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        side: BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    }
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: appState.notes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01,
                      right: MediaQuery.of(context).size.width * 0.01,
                      top: MediaQuery.of(context).size.height * 0.005,
                      bottom: MediaQuery.of(context).size.height * 0.005,
                    ),
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: Color.fromRGBO(Random().nextInt(255),
                        Random().nextInt(255), Random().nextInt(255), 0.15),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              appState.title.text = appState.notes[index].title;
                              appState.description.text =
                                  appState.notes[index].description;
                              appState.date.text = appState.notes[index].date;
                              appState.time.text = appState.notes[index].time;
                              appState.changeHint();
                              appState.changeIndex(1);
                            },
                            icon: Icon(
                              Icons.edit_note_outlined,
                              size: MediaQuery.of(context).size.height * 0.05,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.1 *
                                      0.6,
                                  child: FittedBox(
                                    child: Text(
                                      appState.notes[index].title,
                                      style: TextStyle(
                                        color: (int.parse(DateFormat(
                                                        'yyyyMMddHHmm')
                                                    .format(DateTime.now())) <
                                                int.parse(appState
                                                        .notes[index].date +
                                                    appState.notes[index].time))
                                            ? Colors.black
                                            : Colors.grey.shade500,
                                        decoration: (int.parse(DateFormat(
                                                        'yyyyMMddHHmm')
                                                    .format(DateTime.now())) <
                                                int.parse(appState
                                                        .notes[index].date +
                                                    appState.notes[index].time))
                                            ? TextDecoration.none
                                            : TextDecoration.lineThrough,
                                        decorationColor: Colors.blue.shade900,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.1 *
                                      0.3,
                                  child: FittedBox(
                                    child: Text(
                                      "${dateFormat(appState.notes[index].date)} ${timeFormat(appState.notes[index].time)}",
                                      style: TextStyle(
                                        color: (int.parse(DateFormat(
                                                        'yyyyMMddHHmm')
                                                    .format(DateTime.now())) <
                                                int.parse(appState
                                                        .notes[index].date +
                                                    appState.notes[index].time))
                                            ? Colors.black
                                            : Colors.grey.shade500,
                                        decoration: (int.parse(DateFormat(
                                                        'yyyyMMddHHmm')
                                                    .format(DateTime.now())) <
                                                int.parse(appState
                                                        .notes[index].date +
                                                    appState.notes[index].time))
                                            ? TextDecoration.none
                                            : TextDecoration.lineThrough,
                                        decorationColor: Colors.blue.shade900,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              appState.deleteCurrentNote(index);
                              appState.writeData();
                            },
                            icon: Icon(
                              Icons.delete_outline_outlined,
                              size: MediaQuery.of(context).size.height * 0.05,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: IconButton(
                    onPressed: () {
                      exit(0);
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/leave.svg",
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.height * 0.05,
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AddNote extends StatelessWidget {
  const AddNote({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    TextStyle titleStyle = TextStyle(
      color: const Color.fromRGBO(35, 70, 175, 1),
      decoration: TextDecoration.none,
      fontSize: MediaQuery.of(context).size.height * 0.15 / 3 * 0.75,
      fontWeight: FontWeight.bold,
    );
    TextStyle hintStyle = const TextStyle(
      color: Color.fromRGBO(150, 150, 150, 1),
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold,
    );
    TextStyle inputStyle = TextStyle(
      color: Colors.black,
      decoration: TextDecoration.none,
      fontSize: MediaQuery.of(context).size.height * 0.15 / 3 * 0.5,
      fontWeight: FontWeight.bold,
    );
    TextStyle errorStyle = const TextStyle(
      color: Colors.red,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold,
    );
    TextStyle shortcutKeyStyle = const TextStyle(
      color: Color.fromRGBO(35, 125, 35, 1),
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold,
    );
    TextStyle buttonStyle = TextStyle(
      color: const Color.fromRGBO(35, 70, 175, 1),
      decoration: TextDecoration.none,
      fontSize: MediaQuery.of(context).size.height * 0.15 / 3,
      fontWeight: FontWeight.bold,
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  height: MediaQuery.of(context).size.height * 0.15 / 3,
                  width: MediaQuery.of(context).size.width * (0.3),
                  child: FittedBox(
                    child: Text(
                      "事件",
                      textAlign: TextAlign.start,
                      style: titleStyle,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3 * 2,
                  width: MediaQuery.of(context).size.width * (1 - 0.06),
                  child: Material(
                    color: Colors.white.withOpacity(0),
                    child: TextField(
                      style: inputStyle,
                      controller: appState.title,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: "請輸入事件",
                        hintStyle: hintStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  height: MediaQuery.of(context).size.height * 0.15 / 3,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: FittedBox(
                    child: Text(
                      "描述",
                      textAlign: TextAlign.start,
                      style: titleStyle,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3 * 2,
                  width: MediaQuery.of(context).size.width * (1 - 0.06),
                  child: Material(
                    color: Colors.white.withOpacity(0),
                    child: TextField(
                      style: inputStyle,
                      controller: appState.description,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: "請描述事件",
                        hintStyle: hintStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3,
                  width: MediaQuery.of(context).size.width * (1 - 0.06),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: FittedBox(
                          child: Text(
                            "日期",
                            textAlign: TextAlign.start,
                            style: titleStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            appState.date.text =
                                DateFormat('yyyyMMdd').format(DateTime.now());
                          },
                          child: FittedBox(
                            child: Text(
                              "今天",
                              style: shortcutKeyStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            appState.date.text = DateFormat('yyyyMMdd').format(
                                DateTime.now().add(const Duration(days: 1)));
                          },
                          child: FittedBox(
                            child: Text(
                              "明天",
                              style: shortcutKeyStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            appState.date.text = DateFormat('yyyyMMdd').format(
                                DateTime.now().add(const Duration(days: 2)));
                          },
                          child: FittedBox(
                            child: Text(
                              "後天",
                              style: shortcutKeyStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3 * 2,
                  child: Material(
                    color: Colors.white.withOpacity(0),
                    child: TextField(
                      style: inputStyle,
                      controller: appState.date,
                      decoration: InputDecoration(
                        filled: false,
                        hintText:
                            "請輸入日期(如:${DateFormat('yyyyMMdd').format(DateTime.now())})",
                        hintStyle: hintStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3,
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: FittedBox(
                          child: Text(
                            "時間",
                            textAlign: TextAlign.start,
                            style: titleStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            appState.time.text = DateFormat('HHmm').format(
                                DateTime.now()
                                    .add(const Duration(minutes: 10)));
                          },
                          child: FittedBox(
                            child: Text(
                              "十分鐘",
                              style: shortcutKeyStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            appState.time.text = DateFormat('HHmm').format(
                                DateTime.now()
                                    .add(const Duration(minutes: 30)));
                          },
                          child: FittedBox(
                            child: Text(
                              "半小時",
                              style: shortcutKeyStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15 / 3,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            appState.time.text = DateFormat('HHmm').format(
                                DateTime.now()
                                    .add(const Duration(minutes: 60)));
                          },
                          child: FittedBox(
                            child: Text(
                              "一小時",
                              style: shortcutKeyStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3 * 2,
                  child: Material(
                    color: Colors.white.withOpacity(0),
                    child: TextField(
                      style: inputStyle,
                      controller: appState.time,
                      decoration: InputDecoration(
                        filled: false,
                        hintText:
                            "請輸入時間(如:${DateFormat('HHmm').format(DateTime.now())})",
                        hintStyle: hintStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * (1 - 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3,
                  width: MediaQuery.of(context).size.width * (1 - 0.06),
                  child: FittedBox(
                    child: Text(
                      appState.errorMsg,
                      textAlign: TextAlign.center,
                      style: errorStyle,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 / 3 * 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.15 / 3 * 2,
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            appState.reset();
                            appState.changeIndex(0);
                          },
                          child: FittedBox(
                            child: Text(
                              "   取  消   ",
                              style: buttonStyle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.15 / 3 * 2,
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(0)),
                          ),
                          onPressed: () {
                            if (appState.title.text == "" ||
                                appState.date.text == "" ||
                                appState.time.text == "") {
                              appState.msg("請輸入事件、日期與時間");
                            } else if (int.tryParse(appState.date.text) ==
                                    null ||
                                int.tryParse(appState.time.text) == null ||
                                appState.date.text.length != 8 ||
                                appState.time.text.length != 4) {
                              appState.msg("時間或日期格式不符");
                            } else {
                              appState.msg("");
                              appState.addNewNote(Note(
                                title: appState.title.text,
                                description: appState.description.text,
                                date: appState.date.text,
                                time: appState.time.text,
                              ));
                              appState.reset();
                              appState.writeData();
                              appState.changeIndex(0);
                            }
                          },
                          child: FittedBox(
                            child: Text(
                              "   儲  存   ",
                              style: buttonStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
