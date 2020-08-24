import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/log.dart';
import 'package:flutter_ffmpeg/log_level.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:flutter_ffmpeg_example/flutter_ffmpeg_api_wrapper.dart';
import 'package:flutter_ffmpeg_example/popup.dart';
import 'package:flutter_ffmpeg_example/tooltip.dart';

import 'util.dart';

class SubtitleTab {
  List<DropdownMenuItem<String>> _codecDropDownMenuItems;
  String _currentCodec;
  String _commandOutput;

  void init(State state) {
    _codecDropDownMenuItems = _getCodecDropDownMenuItems();
    _currentCodec = _codecDropDownMenuItems[0].value;
    _commandOutput = "";
  }

  void setActive() {
    print("Subtitle Tab Activated");
    enableLogCallback(logCallback);
    enableStatisticsCallback(statisticsCallback);
    showPopup(SUBTITLE_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    if (log.level != LogLevel.AV_LOG_STDERR) {
      _commandOutput += log.message;
    }
  }

  void statisticsCallback(Statistics statistics) {
    ffprint("Statistics: "
        "executionId: ${statistics.executionId}, "
        "time: ${statistics.time}, "
        "size: ${statistics.size}, "
        "bitrate: ${statistics.bitrate}, "
        "speed: ${statistics.speed}, "
        "videoFrameNumber: ${statistics.videoFrameNumber}, "
        "videoQuality: ${statistics.videoQuality}, "
        "videoFps: ${statistics.videoFps}");
  }

  void clearLog() {
    _commandOutput = "";
  }

  void testEncodeVideo() {
    ffprint("Testing VIDEO.");
  }

  String getFFmpegCodecName() {
    String ffmpegCodec = _currentCodec;

    // VIDEO CODEC MENU HAS BASIC NAMES, FFMPEG NEEDS LONGER LIBRARY NAMES.
    if (ffmpegCodec == "x264") {
      ffmpegCodec = "libx264";
    } else if (ffmpegCodec == "x265") {
      ffmpegCodec = "libx265";
    } else if (ffmpegCodec == "xvid") {
      ffmpegCodec = "libxvid";
    } else if (ffmpegCodec == "vp8") {
      ffmpegCodec = "libvpx";
    } else if (ffmpegCodec == "vp9") {
      ffmpegCodec = "libvpx-vp9";
    }

    return ffmpegCodec;
  }

  String getVideoPath() {
    String ffmpegCodec = _currentCodec;

    String videoPath;
    if ((ffmpegCodec == "vp8") || (ffmpegCodec == "vp9")) {
      videoPath = "video.webm";
    } else {
      // mpeg4, x264, x265, xvid
      videoPath = "video.mp4";
    }

    return videoPath;
  }

  String getCustomEncodingOptions() {
    String videoCodec = _currentCodec;

    if (videoCodec == "x265") {
      return "-crf 28 -preset fast ";
    } else if (videoCodec == "vp8") {
      return "-b:v 1M -crf 10 ";
    } else if (videoCodec == "vp9") {
      return "-b:v 2M ";
    } else {
      return "";
    }
  }

  List<DropdownMenuItem<String>> _getCodecDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();

    items.add(new DropdownMenuItem(value: "mpeg4", child: new Text("mpeg4")));
    items.add(new DropdownMenuItem(value: "x264", child: new Text("x264")));
    items.add(new DropdownMenuItem(value: "x265", child: new Text("x265")));
    items.add(new DropdownMenuItem(value: "xvid", child: new Text("xvid")));
    items.add(new DropdownMenuItem(value: "vp8", child: new Text("vp8")));
    items.add(new DropdownMenuItem(value: "vp9", child: new Text("vp9")));

    return items;
  }

  void _changedCodec(String selectedCodec) {
    _currentCodec = selectedCodec;
  }
}
