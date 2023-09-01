import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/screens/personal_center/widgets/new_version_tip_widget.dart';
import 'package:flutterblingaiplugin/screen/configs/img_source_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/linear_percent_indicator.dart';


/// Date: 2019-07-23 10:56
/// Author: Liusilong
/// Description: 新版的更新弹窗
/// 是否强制更新：
///   1 - 强制更新（不显示 下次升级 文字）
///   2 - 非强制更新（显示 下次升级 文字）
class UpdateDialog extends Dialog {
  final String tips;
  final int forcedUpdate;
  final VoidCallback updateCallback;
  final VoidCallback refuseCallback;

  /// 进度控制器
  final UploadProgressController progressController;

  UpdateDialog({
    this.tips,
    this.forcedUpdate,
    this.updateCallback,
    this.refuseCallback,
    this.progressController,
  });

  @override
  Widget build(BuildContext context) {
    return NewVersionTip(
      tipText: this.tips,
      forcedUpdate: this.forcedUpdate,
      updateCallBack: this.updateCallback,
      cancelCallBack: this.refuseCallback,
      progressController: this.progressController,
    );
  }
}

/// ======================================================================
class UploadProgressController extends ValueNotifier<double> {
  UploadProgressController() : super(0.0);

  void updateRate(double rate) {
    if (rate < 0) rate = 0;
    if (rate > 1) rate = 1;
    this.value = rate;
    print("=================");
  }
}

class UploadWidget extends StatefulWidget {
  final String tips;
  final int forcedUpdate;
  final VoidCallback updateCallback;
  final VoidCallback refuseCallback;
  final UploadProgressController progressController;

  UploadWidget({
    this.tips,
    this.forcedUpdate,
    this.updateCallback,
    this.refuseCallback,
    this.progressController,
  });

  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  @override
  void initState() {
    super.initState();
    widget.progressController?.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              // 背景
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Image.asset(
                  PathImg.pathUpdate,
                  fit: BoxFit.contain,
                ),
              ),
              // 火箭
              _buildRocket(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //进度条
                  _buildProgressbar(),

                  // 立即升级
                  GestureDetector(
                    onTap: () {
//                      Navigator.of(context).pop();
                      if (null != widget.updateCallback) {
                        widget.updateCallback();
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [const Color(0xff7357FF), const Color(0xffC86DD7)],
                        ),
                      ),
                      child: Align(
                        child: Text(
                          '立即升级',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: widget.forcedUpdate == 2,
                    child: GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        if (widget.refuseCallback != null) widget.refuseCallback();
                      },
                      child: Text(
                        '下次升级',
                        style: TextStyle(color: const Color(0xff9B9B9B), fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressbar() {
    double rate = widget.progressController?.value ?? 0;
    return Offstage(
      offstage: rate == 0.0,
      child: Container(
        width: 220,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
          child: Column(children: <Widget>[
            Text("下载进度:${(rate * 100).toStringAsFixed(2)}%"),
            LinearPercentIndicator(
              linearGradient: LinearGradient(
                colors: [Color(0xFFAB90FF), Color(0xFF7357FF)],
              ),
              lineHeight: remH(phone: 9, pad: 13.5),
              percent: rate,
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Colors.grey,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildRocket() {
    return Positioned(
      top: -30,
      right: 0,
      child: Image.asset(
        PathImg.pathUpdateRocket,
        width: 60,
        height: 80,
      ),
    );
  }
}
