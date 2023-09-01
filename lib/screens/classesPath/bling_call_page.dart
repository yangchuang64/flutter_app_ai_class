import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bling_downloader/bling_downloader.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/bling_call_model.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/camera_widget.dart';
import 'package:provider/provider.dart';

enum BlingCallState {
  calling,
  callFail,
  playing,
  loading,
}

class BlingCallPage extends StatefulWidget {
  LessonResourceContentModel model;

  BlingCallPage({this.model});

  @override
  _BlingCallPageState createState() => _BlingCallPageState();
}

class _BlingCallPageState extends State<BlingCallPage> with SingleTickerProviderStateMixin {
  BlingCallState _state = BlingCallState.calling;

  FijkPlayer _fijkPlayer = FijkPlayer();
  String _localVideoPath;

  bool showCamera = false;

  bool _isDisposed = false;

  Animation<double> _doubleAnim;
  AnimationController _animationController;

  final ValueNotifier<double> _animationNotifier = ValueNotifier(0);
  AudioPlayer _ringAudioPlayer;

  @override
  void initState() {
    super.initState();
    UiUtil.setPortraitUpMode();

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _doubleAnim = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        // print('ai_log _doubleAnim.value.toString() ${_doubleAnim.value.toString()}');
        // setState(() {});
        _animationNotifier.value = _doubleAnim.value;
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.forward(from: 0.0);
        }
      });
    _animationController.forward(from: 0.0);

    downloadSource();

    _fijkPlayer.addListener(_playerListener);
    AudioCache().loop('ai_package/audio/BiingCall_bgm.mp3').then((value) => _ringAudioPlayer = value);
  }

  void downloadSource() async {
    String downloadUrl = widget.model.contentUrl ?? "";
    if (BlingDownloader.resMap != null && BlingDownloader.resMap.keys.contains(downloadUrl)) {
      Future.delayed(Duration(seconds: 10), () async {
        if (_isDisposed) return;
        ConnectivityResult result = await Connectivity().checkConnectivity();
        if (result == ConnectivityResult.none) {
          _state = BlingCallState.callFail;
          _ringAudioPlayer?.stop();
          if (mounted) setState(() {});
        } else {
          _localVideoPath = BlingDownloader.resMap[downloadUrl];
          _startPlayLocalVideo();
        }
      });
      return;
    }
    BlingDownloader.downloadFile(
      fileUrl: downloadUrl,
      onProgress: (current, total, speed) {
        // print("---------------------------${current}   ${total}---${speed}-------");
      },
      onFail: () {
        if (_isDisposed) return;
        _state = BlingCallState.callFail;
        _ringAudioPlayer?.stop();
        if (mounted) setState(() {});
      },
      onSuccess: (Map<String, String> urlMap) {
        if (_isDisposed) return;
        String file = urlMap[downloadUrl];
        _localVideoPath = file;
        _startPlayLocalVideo();
      },
    );
  }

  void _playerListener() {
    if (_fijkPlayer.state == FijkState.completed) {
      _didClickHangUpButton();
    } else if (_fijkPlayer.state == FijkState.prepared) {
      if (_isDisposed) return;
      showCamera = true;
      if (mounted) setState(() {});

      Future.delayed(Duration(milliseconds: 2000), () {
        _fijkPlayer.start();
        _ringAudioPlayer?.stop();
      });
    } else if (_fijkPlayer.state == FijkState.started) {
      _state = BlingCallState.playing;
      _animationController.stop(canceled: true);
      if (mounted) setState(() {});
    }
  }

  void _startPlayLocalVideo() {
    _fijkPlayer.setDataSource(_localVideoPath, showCover: true);
  }

  void _didClickHangUpButton() {
    _isDisposed = true;
    _fijkPlayer.removeListener(_playerListener);
    _fijkPlayer.pause();
    _fijkPlayer.stop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _didClickHangUpButton();
        return true;
      },
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: _buildContentWidget(),
                  color: Color(0xFF7357FF),
                ),
              ),
              _buildHungUpWidget(),
            ],
          ),
          _buildCameraWidget(),
        ],
      ),
    );
  }

  Widget _buildCameraWidget() {
    return Positioned(
      left: px(0),
      bottom: px(60),
      width: px(169),
      height: px(95),
      child: Visibility(
        visible: showCamera,
        child: Transform.rotate(
          angle: pi / 2.0,
          child: Camera(),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    Widget _callingWidget() {
      return Column(
        children: <Widget>[
          SizedBox(
            height: px(50),
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: px(30),
              ),
              Container(
                width: px(70),
                height: px(70),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(px(35))),
                ),
                child: Center(
                  child: Container(
                    width: px(66),
                    height: px(66),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(px(33)),
                      child: Image.network(
                        widget.model.teacherImage,
                        width: px(66),
                        height: px(66),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: px(20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.model.teacherName,
                    style: CustomTextStyle.fz(fontSize: px(24), color: Color(0xFFFFFFFF)),
                  ),
                  SizedBox(
                    height: px(5),
                    child: Container(),
                  ),
                  Text(
                    "waiting for answer",
                    style: CustomTextStyle.fz(fontSize: px(14), color: Color(0xFFFFFFFF).withOpacity(0.7)),
                  )
                ],
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Container(
                width: px(331),
                height: px(183),
//                color: Colors.orange,
                child: Stack(
                  overflow: Overflow.visible,
                  alignment: Alignment.center,
                  children: <Widget>[
//                    Image.asset(
//                      "assets/ai_package/images/path/blingcall_calling_bg.webp",
//                      width: px(331),
//                      height: px(183),
//                    ),
                    //RingWidget(),
                    ValueListenableProvider.value(
                      value: _animationNotifier,
                      child: Consumer<double>(builder: (context, value, child) {
                        return Opacity(
                          opacity: 1 - value,
                          child: Image.asset(
                            "assets/ai_package/images/path/blingcall_calling_bg.webp",
                            width: px(331 * value),
                            height: px(183 * value),
                            gaplessPlayback: true,
                          ),
                        );
                      }),
                    ),
                    ValueListenableProvider.value(
                      value: _animationNotifier,
                      child: Consumer<double>(builder: (context, value, child) {
                        String image;
                        if (value < 0.3) {
                          image = "assets/ai_package/images/path/blingcall_message_1.webp";
                        } else if (value < 0.6) {
                          image = "assets/ai_package/images/path/blingcall_message_2.webp";
                        } else {
                          image = "assets/ai_package/images/path/blingcall_message_3.webp";
                        }

                        return Positioned(
                          left: px(64),
                          top: px(-16),
                          width: px(38),
                          height: px(49),
                          child: Image.asset(image, gaplessPlayback: true),
                        );
                      }),
                    ),
                    Positioned(
                      top: px(49),
                      width: px(163),
                      height: px(100),
                      child: Image.asset(
                        "assets/ai_package/images/path/blingcall_iphone_bg.webp",
                      ),
                    ),
                    Positioned(
                      top: px(0),
                      width: px(182),
                      height: px(121),
                      child: Image.asset(
                        "assets/ai_package/images/path/blingcall_iphone.webp",
                      ),
                    ),
                    Positioned(
                      bottom: px(35),
                      right: px(40),
                      width: px(39),
                      height: px(32),
                      child: Image.asset(
                        "assets/ai_package/images/path/blingcall_heart_bg.webp",
                      ),
                    ),
                    Positioned(
                      bottom: px(51),
                      right: px(36),
                      width: px(48),
                      height: px(39),
                      child: Image.asset(
                        "assets/ai_package/images/path/blingcall_heart.webp",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _playerWidget() {
      if (_fijkPlayer == null) return Container();
      return FijkView(
        color: Color.fromARGB(255, 10, 10, 10),
        fit: FijkFit.contain,
        player: _fijkPlayer,
        panelBuilder: (a, b, c, d, rect) {
          return Container();
        },
      );
    }

    Widget _callFailWidget() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/ai_package/images/path/blingcall_load_fail.webp",
            width: px(140),
            height: px(140),
          ),
          SizedBox(
            height: px(15),
          ),
          Text(
            "无法接通${widget.model.teacherName} Call",
            style: CustomTextStyle.fz(fontSize: px(18), color: Color(0xFFFFFFFF)),
          ),
          SizedBox(
            height: px(10),
          ),
          Text(
            "请检查网络设置",
            style: CustomTextStyle.fz(fontSize: px(14), color: Color(0xFFFFFFFF).withOpacity(0.7)),
          ),
        ],
      );
    }

    switch (_state) {
      case BlingCallState.calling:
        return _callingWidget();
        break;
      case BlingCallState.callFail:
        return _callFailWidget();
        break;
      case BlingCallState.playing:
        return _playerWidget();
        break;
    }
  }

  Widget _buildHungUpWidget() {
    return Container(
      height: px(124),
      color: Colors.white,
      child: Center(
        child: GestureDetector(
          onTap: _didClickHangUpButton,
          child: Container(
            width: px(64),
            height: px(64),
            child: Image.asset("assets/ai_package/images/path/blingcall_hangup.webp"),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
    _fijkPlayer.dispose();
    _ringAudioPlayer?.stop();
    _animationController?.dispose();
  }
}
