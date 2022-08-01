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

  @override
  void initState() {
    player.onPlayerComplete.listen((event) {
      setState(() {
        status = "Nessun file in riproduzione";
        time = 0;
        currentTime = "0:00";
        maxTime = "-:--";
      });
    });

    player.onPlayerStateChanged.listen((state) {
      if (state != PlayerState.playing) {
        status = "Nessun file in riproduzione";
        time = 0;
        currentTime = "0:00";
        maxTime = "-:--";
      }
    });

    player.onDurationChanged.listen((Duration d) {
      maxSecs = d.inSeconds;
      String mins = (maxSecs / 60).floor().toString();
      String secs = (maxSecs % 60).toString();
      if (secs.length == 1) {
        secs = "0$secs";
      }
      setState(() {
        maxTime = "$mins:$secs";
      });
    });

    player.onPositionChanged.listen((Duration d) {
      int sec = d.inSeconds;
      //Qua ci va la gestione dei loop
      String mins = (sec / 60).floor().toString();
      String secs = (sec % 60).toString();
      if (secs.length == 1) {
        secs = "0$secs";
      }
      setState(() {
        currentTime = "$mins:$secs";
        time = sec / maxSecs;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    //Graficamente da rivedere
    return Card(
      child: Center(
          child: Column(
        children: [
          const Spacer(),
          /*LinearProgressIndicator(
            value: time,
          ),*/
          Text("$currentTime/$maxTime"),
          ElevatedButton(
              onPressed: () => loadFileAndStartPlayer(),
              child: const Text("Seleziona file")),
          Text(status),
          const Spacer()
        ],
      )),
    );
  }

  Future<void> loadFileAndStartPlayer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String file = result.files.single.path.toString();
      player.play(UrlSource(file));
      setState(() {
        status = "Riproduzione in corso di $file";
      });
    }
  }
}
