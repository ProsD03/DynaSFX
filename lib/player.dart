import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);
  @override
  State<Player> createState() => PlayState();
}

class PlayState extends State<Player> {
  double? screenWidth;
  double? screenHeight;
  final player = AudioPlayer();
  String status = "Nessun file in riproduzione";
  double time = 0;
  String currentTime = "0:00";
  String maxTime = "-:--";
  int maxSecs = 0;
  bool playing = true;

  BoxDecoration decorations = BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(5)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
  );

  Text timeRemaining = const Text("prova prova");

  Widget displayState = Container();

  @override
  void didUpdateWidget(covariant Player oldWidget) {
    log("fatto");
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    timeRemaining = Text("$currentTime/$maxTime");

    displayState = ElevatedButton(
        onPressed: () => loadFileAndStartPlayer(),
        child: const Text("Seleziona file"));

    player.onPlayerComplete.listen((event) {
      playing = false;
      log("finito");
      resetPlaybackStatus();
    });

    player.onDurationChanged.listen((Duration d) {
      playing = true;
      maxSecs = d.inSeconds;
      String mins = (maxSecs / 60).floor().toString();
      String secs = (maxSecs % 60).toString();
      if (secs.length == 1) {
        secs = "0$secs";
      }
      maxTime = "$mins:$secs";
      updatePlaybackStatus();
    });

    player.onPositionChanged.listen((Duration d) {
      log(player.state.name);
      int sec = d.inSeconds;
      //Qua ci va la gestione dei loop
      String mins = (sec / 60).floor().toString();
      String secs = (sec % 60).toString();
      if (secs.length == 1) {
        secs = "0$secs";
      }
      time = sec / maxSecs;
      currentTime = "$mins:$secs";
      if (playing && player.state.name == "playing") {
        updatePlaybackStatus();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    //Graficamente da rivedere
    return Row(
      children: [
        Column(
          children: [
            //File selections
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                height: screenHeight! * 0.90,
                width: screenWidth! * 1 / 3,
                decoration: decorations,
              ),
            )
          ],
        ),
        Column(
          children: [
            //Playback screen
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, top: 10), //fromLTRB(10, 10, 15, 5),
              child: Container(
                  height: (screenHeight! * 1 / 3) - 20,
                  width: (screenWidth! * 2 / 3) - 20,
                  decoration: decorations,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Center(
                        child: Column(
                      children: [
                        const Spacer(),
                        displayState,
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            status,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer()
                      ],
                    )),
                  )),
            ),

            //Loop Screen
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, top: 10), //fromLTRB(10, 10, 15, 5),
              child: Container(
                  height: (screenHeight! * 0.90) - (screenHeight! * 1 / 3) + 10,
                  width: (screenWidth! * 2 / 3) - 20,
                  decoration: decorations,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Center(
                        child: Column(
                      children: [],
                    )),
                  )),
            )
          ],
        )
      ],
    );
  }

  Future<void> loadFileAndStartPlayer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String file = result.files.single.path.toString();
      status = "Riproduzione in corso di $file";
      player.play(UrlSource(file));
      updatePlaybackStatus();
    }
  }

  void updatePlaybackStatus() {
    setState(() {
      displayState = Padding(
          padding: const EdgeInsets.all(0),
          child: Center(
            child: Row(children: [
              const Spacer(),
              Text("$currentTime/$maxTime"),
              const SizedBox(
                width: 5,
                height: 1,
              ),
              Expanded(
                  child: LinearProgressIndicator(
                value: time,
              )),
              IconButton(
                  onPressed: () {
                    player.resume();
                  },
                  icon: const Icon(Icons.play_arrow)),
              IconButton(
                  onPressed: () {
                    player.pause();
                  },
                  icon: const Icon(Icons.pause)),
              IconButton(
                  onPressed: () {
                    player.stop();
                    playing = false;
                    resetPlaybackStatus();
                  },
                  icon: const Icon(Icons.stop)),
              const Spacer()
            ]),
          ));
    });
  }

  void resetPlaybackStatus() {
    setState(() {
      status = "Nessun file in riproduzione";
      time = 0;
      currentTime = "0:00";
      maxTime = "-:--";
      displayState = ElevatedButton(
          onPressed: () => loadFileAndStartPlayer(),
          child: const Text("Seleziona file"));
      timeRemaining = Text("$currentTime/$maxTime");
    });
  }
}
