import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/log_level.dart';
import 'package:flutter_ffmpeg_example/abstract.dart';
import 'package:flutter_ffmpeg_example/audio_tab.dart';
import 'package:flutter_ffmpeg_example/command_tab.dart';
import 'package:flutter_ffmpeg_example/concurrent_execution_tab.dart';
import 'package:flutter_ffmpeg_example/decoration.dart';
import 'package:flutter_ffmpeg_example/flutter_ffmpeg_api_wrapper.dart';
import 'package:flutter_ffmpeg_example/https_tab.dart';
import 'package:flutter_ffmpeg_example/pipe_tab.dart';
import 'package:flutter_ffmpeg_example/progress_modal.dart';
import 'package:flutter_ffmpeg_example/subtitle_tab.dart';
import 'package:flutter_ffmpeg_example/test.dart';
import 'package:flutter_ffmpeg_example/util.dart';
import 'package:flutter_ffmpeg_example/vid_stab_tab.dart';
import 'package:flutter_ffmpeg_example/video_tab.dart';
import 'package:flutter_ffmpeg_example/video_util.dart';
import 'package:video_player/video_player.dart';

GlobalKey _globalKey = GlobalKey();

void main() => runApp(FlutterFFmpegExampleApp());

class FlutterFFmpegExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appThemeData,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  FlutterFFmpegExampleAppState createState() =>
      new FlutterFFmpegExampleAppState();
}

class DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  DecoratedTabBar({@required this.tabBar, @required this.decoration});

  final TabBar tabBar;
  final BoxDecoration decoration;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: decoration)),
        tabBar,
      ],
    );
  }
}

class FlutterFFmpegExampleAppState extends State<MainPage>
    with TickerProviderStateMixin
    implements RefreshablePlayerDialogFactory {
  // COMMON COMPONENTS
  TabController _controller;
  ProgressModal progressModal;

  // COMMAND TAB COMPONENTS
  CommandTab commandTab = new CommandTab();

  // VIDEO TAB COMPONENTS
  VideoTab videoTab = new VideoTab();
  VideoPlayerController _videoTabVideoController;
  Future<void> _videoTabVideoControllerVideoPlayerFuture;

  // HTTPS TAB COMPONENTS
  HttpsTab httpsTab = new HttpsTab();

  // AUDIO TAB COMPONENTS
  AudioTab audioTab = new AudioTab();

  // SUBTITLE TAB COMPONENTS
  SubtitleTab subtitleTab = new SubtitleTab();

  // VIDSTAB TAB COMPONENTS
  VidStabTab vidStabTab = new VidStabTab();

  // PIPE TAB COMPONENTS
  PipeTab pipeTab = new PipeTab();

  // CONCURRENT EXECUTION TAB COMPONENTS
  ConcurrentExecutionTab concurrentExecutionTab = new ConcurrentExecutionTab();

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    commandTab.init(this);

    videoTab.init(this);

    _videoTabVideoController = VideoPlayerController.asset('assets/test.mp4');
    _videoTabVideoControllerVideoPlayerFuture =
        _videoTabVideoController.initialize();
    _videoTabVideoController.setLooping(false);

    httpsTab.init(this);
    audioTab.init(this);
    subtitleTab.init(this);
    vidStabTab.init(this);
    pipeTab.init(this);
    concurrentExecutionTab.init(this);

    _controller = TabController(length: 8, vsync: this);
    _controller.addListener(() {
      if (_controller.indexIsChanging) {
        switch (_controller.index) {
          case 0:
            commandTab.setActive();
            break;
          case 1:
            videoTab.setActive();
            break;
          case 2:
            httpsTab.setActive();
            break;
          case 3:
            audioTab.setActive();
            break;
          case 4:
            subtitleTab.setActive();
            break;
          case 5:
            vidStabTab.setActive();
            break;
          case 6:
            pipeTab.setActive();
            break;
          case 7:
            concurrentExecutionTab.setActive();
            break;
        }
      }
    });

    testCommonApiMethods();
    testParseArguments();

    VideoUtil.prepareAssets();

    registerAppFont();

    setLogLevel(LogLevel.AV_LOG_INFO);
  }

  void registerAppFont() {
    VideoUtil.tempDirectory.then((tempDirectory) {
      setFontDirectory(tempDirectory.path, Map());
      setEnvironmentVariable(
          "FFREPORT",
          "file=" +
              new File(tempDirectory.path + "/" + today() + "-ffreport.txt")
                  .path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _globalKey,
        appBar: AppBar(
          title: Text('FlutterFFmpeg Test'),
          centerTitle: true,
        ),
        bottomNavigationBar: Material(
          child: DecoratedTabBar(
            tabBar: TabBar(
              isScrollable: true,
              tabs: <Tab>[
                Tab(text: "COMMAND"),
                Tab(text: "VIDEO"),
                Tab(text: "HTTPS"),
                Tab(text: "AUDIO"),
                Tab(text: "SUBTITLE"),
                Tab(text: "VID.STAB"),
                Tab(text: "PIPE"),
                Tab(text: "CONCURRENT EXECUTION")
              ],
              controller: _controller,
              labelColor: selectedTabColor,
              unselectedLabelColor: unSelectedTabColor,
            ),
            decoration: tabBarDecoration,
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                  child: TextField(
                    controller: commandTab.getCommandText(),
                    decoration: inputDecoration('Enter command'),
                    style: textFieldStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: new InkWell(
                    onTap: () => commandTab.runFFmpeg(),
                    child: new Container(
                      width: 130,
                      height: 38,
                      decoration: buttonDecoration,
                      child: new Center(
                        child: new Text(
                          'RUN FFMPEG',
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: new InkWell(
                    onTap: () => commandTab.runFFprobe(),
                    child: new Container(
                      width: 130,
                      height: 38,
                      decoration: buttonDecoration,
                      child: new Center(
                        child: new Text(
                          'RUN FFPROBE',
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                      alignment: Alignment(-1.0, -1.0),
                      margin: EdgeInsets.all(20.0),
                      padding: EdgeInsets.all(4.0),
                      decoration: outputDecoration,
                      child: SingleChildScrollView(
                          reverse: true,
                          child: Text(commandTab.getOutputText()))),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    child: Container(
                      width: 200,
                      alignment: Alignment.center,
                      decoration: dropdownButtonDecoration,
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                        style: dropdownButtonTextStyle,
                        value: videoTab.getSelectedCodec(),
                        items: videoTab.getVideoCodecList(),
                        onChanged: videoTab.changedVideoCodec,
                        iconSize: 0,
                        isExpanded: false,
                      )),
                    )),
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: new InkWell(
                    onTap: () => videoTab.encodeVideo(_videoTabVideoController),
                    child: new Container(
                      width: 100,
                      height: 38,
                      decoration: buttonDecoration,
                      child: new Center(
                        child: new Text(
                          'ENCODE',
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(20.0),
                    padding: EdgeInsets.all(4.0),
                    child: FutureBuilder(
                      future: _videoTabVideoControllerVideoPlayerFuture,
                      builder: (context, snapshot) {
                        return AspectRatio(
                          aspectRatio:
                              _videoTabVideoController.value.aspectRatio,
                          child: Stack(
                            children: <Widget>[
                              VideoPlayer(_videoTabVideoController),
                              Container(
                                alignment: Alignment(0.0, 0.0),
                                // decoration: videoPlayerFrameDecoration,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Column(),
            Column(),
            Column(),
            Column(),
            Column(),
            Column()
          ],
          controller: _controller,
        ));
  }

  @override
  void dialogHide() {
    progressModal.hide();
  }

  @override
  void dialogShowCancellable(String message, Function cancelFunction) {
    progressModal = new ProgressModal(_globalKey.currentContext);
    progressModal.show(message, cancelFunction: cancelFunction);
  }

  @override
  void dialogShow(String message) {
    progressModal = new ProgressModal(_globalKey.currentContext);
    progressModal.show(message);
  }

  @override
  void dialogUpdate(String message) {
    progressModal.update(message: message);
  }

  @override
  void dispose() {
    commandTab.dispose();
    _videoTabVideoControllerVideoPlayerFuture = null;
    _videoTabVideoController?.pause()?.then((_) {
      _videoTabVideoController.dispose();
    });
    super.dispose();
  }

  static Future<bool> _clearPreviousPlayerController(
      VideoPlayerController _controller) async {
    await _controller?.pause();
    return true;
  }

  Future<void> _initializePlayerInVideoTab(String videoPath) async {
    _videoTabVideoController = VideoPlayerController.network(videoPath);
    _controller.addListener(() {
      setState(() {});
    });
    _videoTabVideoControllerVideoPlayerFuture =
        _videoTabVideoController.initialize().then((_) {
      _videoTabVideoController.play();
    });
  }

  Future<void> playInVideoTab(String videoPath) async {
    setState(() {
      _videoTabVideoControllerVideoPlayerFuture = null;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPreviousPlayerController(_videoTabVideoController).then((_) {
        _initializePlayerInVideoTab(videoPath);
      });
    });
  }
}
