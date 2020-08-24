import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/log.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:flutter_ffmpeg_example/abstract.dart';
import 'package:flutter_ffmpeg_example/popup.dart';
import 'package:flutter_ffmpeg_example/tooltip.dart';
import 'package:flutter_ffmpeg_example/util.dart';
import 'package:flutter_ffmpeg_example/video_util.dart';
import 'package:video_player/video_player.dart';

import 'flutter_ffmpeg_api_wrapper.dart';

class VideoTab {
  RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;
  String _selectedCodec;
  Statistics _statistics;

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    List<DropdownMenuItem<String>> videoCodecList = getVideoCodecList();
    _selectedCodec = videoCodecList[0].value;
    _statistics = null;
  }

  void setActive() {
    print("Video Tab Activated");
    enableLogCallback(logCallback);
    enableStatisticsCallback(statisticsCallback);
    showPopup(VIDEO_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    ffprint(log.message);
    _refreshablePlayerDialogFactory.refresh();
  }

  void statisticsCallback(Statistics statistics) {
    this._statistics = statistics;
    updateProgressDialog();
  }

  void encodeVideo(VideoPlayerController videoController) {
    VideoUtil.assetPath(VideoUtil.ASSET_1).then((image1Path) {
      VideoUtil.assetPath(VideoUtil.ASSET_2).then((image2Path) {
        VideoUtil.assetPath(VideoUtil.ASSET_3).then((image3Path) {
          getVideoFile().then((videoFile) {
            // ALWAYS STOP VIDEO PLAYBACK
            videoController.pause();

            videoFile.delete();

            final String videoCodec = getSelectedVideoCodec();

            ffprint("Testing VIDEO encoding with '$videoCodec' codec");

            showProgressDialog();

            final ffmpegCommand = VideoUtil.generateEncodeVideoScript(
                image1Path,
                image2Path,
                image3Path,
                videoFile.path,
                videoCodec,
                getCustomOptions());

            ffprint(
                "FFmpeg process started with arguments\n\'$ffmpegCommand\'.");

            executeAsyncFFmpeg(ffmpegCommand,
                (int executionId, int returnCode) {
              ffprint("FFmpeg process exited with rc $returnCode.");

              ffprint("FFmpeg process output:");

              getLastCommandOutput().then((output) => ffprint(output));

              hideProgressDialog();

              if (returnCode == 0) {
                ffprint("Encode completed successfully; playing video.");
                _refreshablePlayerDialogFactory.playInVideoTab(videoFile.path);
              } else {
                showPopup("Encode failed. Please check log for the details.");
                ffprint("Encode failed with rc=$returnCode.");
              }
            }).then((executionId) => ffprint(
                "Async FFmpeg process started with executionId $executionId."));
          });
        });
      });
    });
  }

  String getSelectedVideoCodec() {
    String videoCodec = _selectedCodec;

    // VIDEO CODEC MENU HAS BASIC NAMES, FFMPEG NEEDS LONGER LIBRARY NAMES.
    // APPLYING NECESSARY TRANSFORMATION HERE
    switch (videoCodec) {
      case "x264":
        videoCodec = "libx264";
        break;
      case "openh264":
        videoCodec = "libopenh264";
        break;
      case "x265":
        videoCodec = "libx265";
        break;
      case "xvid":
        videoCodec = "libxvid";
        break;
      case "vp8":
        videoCodec = "libvpx";
        break;
      case "vp9":
        videoCodec = "libvpx-vp9";
        break;
      case "aom":
        videoCodec = "libaom-av1";
        break;
      case "kvazaar":
        videoCodec = "libkvazaar";
        break;
      case "theora":
        videoCodec = "libtheora";
        break;
    }

    return videoCodec;
  }

  Future<File> getVideoFile() async {
    String videoCodec = _selectedCodec;

    String extension;
    switch (videoCodec) {
      case "vp8":
      case "vp9":
        extension = "webm";
        break;
      case "aom":
        extension = "mkv";
        break;
      case "theora":
        extension = "ogv";
        break;
      case "hap":
        extension = "mov";
        break;
      default:
        // mpeg4, x264, x265, xvid, kvazaar
        extension = "mp4";
        break;
    }

    final String video = "video." + extension;
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  String getCustomOptions() {
    String videoCodec = _selectedCodec;

    switch (videoCodec) {
      case "x265":
        return "-crf 28 -preset fast ";
      case "vp8":
        return "-b:v 1M -crf 10 ";
      case "vp9":
        return "-b:v 2M ";
      case "aom":
        return "-crf 30 -strict experimental ";
      case "theora":
        return "-qscale:v 7 ";
      case "hap":
        return "-format hap_q ";
      default:
        // kvazaar, mpeg4, x264, xvid
        return "";
    }
  }

  List<DropdownMenuItem<String>> getVideoCodecList() {
    List<DropdownMenuItem<String>> list = new List();

    list.add(new DropdownMenuItem(
        value: "mpeg4",
        child: SizedBox(width: 100, child: Center(child: new Text("mpeg4")))));
    list.add(new DropdownMenuItem(
        value: "x264",
        child: SizedBox(width: 100, child: Center(child: new Text("x264")))));
    list.add(new DropdownMenuItem(
        value: "openh264",
        child:
            SizedBox(width: 100, child: Center(child: new Text("openh264")))));
    list.add(new DropdownMenuItem(
        value: "x265",
        child: SizedBox(width: 100, child: Center(child: new Text("x265")))));
    list.add(new DropdownMenuItem(
        value: "xvid",
        child: SizedBox(width: 100, child: Center(child: new Text("xvid")))));
    list.add(new DropdownMenuItem(
        value: "vp8",
        child: SizedBox(width: 100, child: Center(child: new Text("vp8")))));
    list.add(new DropdownMenuItem(
        value: "vp9",
        child: SizedBox(width: 100, child: Center(child: new Text("vp9")))));
    list.add(new DropdownMenuItem(
        value: "aom",
        child: SizedBox(width: 100, child: Center(child: new Text("aom")))));
    list.add(new DropdownMenuItem(
        value: "kvazaar",
        child:
            SizedBox(width: 100, child: Center(child: new Text("kvazaar")))));
    list.add(new DropdownMenuItem(
        value: "theora",
        child: SizedBox(width: 100, child: Center(child: new Text("theora")))));
    list.add(new DropdownMenuItem(
        value: "hap",
        child: SizedBox(width: 100, child: Center(child: new Text("hap")))));

    return list;
  }

  void showProgressDialog() {
    _statistics = null;
    resetStatistics();
    _refreshablePlayerDialogFactory.dialogShow("Encoding video");
  }

  void updateProgressDialog() {
    if (_statistics == null) {
      return;
    }

    int timeInMilliseconds = this._statistics.time;
    if (timeInMilliseconds > 0) {
      int totalVideoDuration = 9000;

      int completePercentage = (timeInMilliseconds * 100) ~/ totalVideoDuration;

      _refreshablePlayerDialogFactory
          .dialogUpdate("Encoding video % $completePercentage");
      _refreshablePlayerDialogFactory.refresh();
    }
  }

  void hideProgressDialog() {
    _refreshablePlayerDialogFactory.dialogHide();
  }

  void changedVideoCodec(String selectedCodec) {
    _selectedCodec = selectedCodec;
  }

  String getSelectedCodec() => _selectedCodec;
}
