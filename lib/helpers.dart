class Screen {
  double width = 0;
  double height = 0;
  Screen(double w, double h) {
    width = w;
    height = h;
  }
}

class PlayerStatus {
  int durationInSeconds = 0;
  double timestampNowInSeconds = 0;
  String pathStatusText = "No file playing";
  String durationAsString = "-:--";
  String timestampNowAsString = "0:00";
  bool isAudioPlaying = false;

  void reset() {
    durationInSeconds = 0;
    timestampNowInSeconds = 0;
    pathStatusText = "No file playing";
    durationAsString = "-:--";
    timestampNowAsString = "0:00";
    isAudioPlaying = false;
  }
}
