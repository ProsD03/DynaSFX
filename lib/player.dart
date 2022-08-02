import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dynasfx/helpers.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);
  @override
  State<Player> createState() => PlayState();
}

class PlayState extends State<Player> {
  Screen screen = Screen(0,0);
  final player = AudioPlayer();
  PlayerStatus playerStatus = PlayerStatus();

  BoxDecoration decorations = BoxDecoration(
    color: Colors.white,
    //borderRadius: const BorderRadius.all(Radius.circular(5)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
  );
  Widget displayState = Container();

  @override
  void initState() {
    displayState = ElevatedButton(
        onPressed: () => loadFileAndStartPlayer(),
        child: const Text("Seleziona file"));

    player.onPlayerComplete.listen((event) {
      playerStatus.isAudioPlaying = false;
      log("finito");
      resetPlaybackStatus();
    });

    player.onDurationChanged.listen((Duration d) {
      playerStatus.isAudioPlaying = true;
      playerStatus.durationInSeconds = d.inSeconds;
      String mins = (playerStatus.durationInSeconds / 60).floor().toString();
      String secs = (playerStatus.durationInSeconds % 60).toString();
      if (secs.length == 1) {
        secs = "0$secs";
      }
      playerStatus.durationAsString = "$mins:$secs";
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
      playerStatus.timestampNowInSeconds = sec / playerStatus.durationInSeconds;
      playerStatus.timestampNowAsString = "$mins:$secs";
      if (playerStatus.isAudioPlaying && player.state.name == "playerStatus.isAudioPlaying") {
        updatePlaybackStatus();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screen = Screen(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height)
    ;
    return Row(
      children: [
        Column(
          children: [
            //File selections
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                height: screen.height * 0.90,
                width: screen.width * 1 / 3,
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
                  height: (screen.height * 1 / 3) - 20,
                  width: (screen.width * 2 / 3) - 20,
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
                            playerStatus.pathStatusText,
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
                  height: (screen.height * 0.90) - (screen.height * 1 / 3) + 10,
                  width: (screen.width * 2 / 3) - 20,
                  decoration: decorations,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Center(
                        child: ListView(
                      children: [
                        Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              leading: Icon(Icons.add),
                              title: Text("Aggiungi un nuovo loop"),
                              onTap: () {showDialog(context: context, builder: );},
                              hoverColor: Color.fromARGB(40, 0, 0, 0),
                            ))
                      ],
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
      playerStatus.pathStatusText = "Riproduzione in corso di $file";
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
              Text("$currentplayerStatus.timestampNowInSeconds/$playerStatus.durationAsString"),
              const SizedBox(
                width: 5,
                height: 1,
              ),
              Expanded(
                  child: LinearProgressIndicator(
                value: playerStatus.timestampNowInSeconds,
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
                    playerStatus.isAudioPlaying = false;
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
      playerStatus.reset();
      displayState = ElevatedButton(
          onPressed: () => loadFileAndStartPlayer(),
          child: const Text("Seleziona file"));
    });
  }
}
