import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutterblingaiplugin/screen/configs/img_source_config.dart';
import 'package:flutterblingaiplugin/screen/configs/umeng_count_keys.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/storage.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/uitils/umeng_action_count.dart';
import 'package:flutterblingaiplugin/screen/widgets/dialogs.dart';

///
///  ai 课结束页面
///
class FinishPage extends StatefulWidget {
  final int aiLessonId;
  final int classLessonId;
  final int subjectCode;
  final int oldAiId;

  FinishPage(this.aiLessonId, this.subjectCode, this.classLessonId, this.oldAiId);

  @override
  _FinishPageState createState() => _FinishPageState();
}

enum _ViewType { loading, loadError, evaluate, none }

class _FinishPageState extends State<FinishPage> {
  int _numberOfEvaluation; // 评价次数
  _ViewType _viewType = _ViewType.loading;
  bool _showRibbon = true;

  @override
  void initState() {
    Storage.setBool(StorageKey.custom(key: widget.aiLessonId?.toString() ?? "", valueType: bool), true);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getEvaluateCount());
  }

  Future<void> _getEvaluateCount() async {
    if (widget.oldAiId != null) {
      if (mounted)
        setState(() {
          _viewType = _ViewType.none;
          _numberOfEvaluation = 100;
        });
      return;
    }
    if (mounted) setState(() => _viewType = _ViewType.loading);
    BaseResp baseResp = await NetRequest.post(url: ApiConfigs.lessonLikeCount, param: {
      "aiLessonId": widget.aiLessonId?.toString(),
      "classLessonId": widget.classLessonId,
      "stuNum": LoginUserInfo.getInstance(null)?.selectedStudent?.stuNum,
    });
    _numberOfEvaluation = baseResp.data?.originValue ?? 0;
    if (baseResp?.result == false) {
      UiUtil.showToast(baseResp?.msg ?? "网络错误");
      _viewType = _ViewType.loadError;
    } else {
      if (_numberOfEvaluation < 2) {
        _viewType = _ViewType.evaluate;
      } else {
        _viewType = _ViewType.none;
      }
    }
    if (mounted) setState(() {});
   Future.delayed(Duration(seconds: 3), () {
     if (mounted) setState(() => _showRibbon = false);
    });
  }

  /// 点击完成并返回
  void onCompletionActionClick() {
    UmengCounter.count(widget.aiLessonId == 1 ? UmengCountKeys.lesson1_click : UmengCountKeys.lesson2_click);
    Navigator.of(context).pop();
  }

  void _likeOrDislikeAction(bool isLike) {
    _showEvaluateCover(context, isLike: isLike);
    NetRequest.post(url: ApiConfigs.saveLikeState, param: {
      "stuNum": LoginUserInfo.getInstance(null)?.selectedStudent?.stuNum,
      "aiLessonId": widget.aiLessonId?.toString(),
      "classLessonId": widget.classLessonId,
      "courseLike": isLike == true ? 1 : 0,
    });
  }

  /// AiClassImg.finishRibbon 彩色丝带
  /// AiClassImg.finishCard   背景
  /// AiClassImg.finishBtn   完成按钮背景
  /// AiClassImg.finishBg   数学课背景

  @override
  Widget build(BuildContext context) {
    String imagePath = AiClassImg.finishBg;
    if (widget.subjectCode != null) {
      if (widget.subjectCode == 40) {
        imagePath = AiClassImg.finishChineseBg;
      } else if (widget.subjectCode == 10) {
        imagePath = AiClassImg.ipadEnglishBg;
      }
    }
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        ),
        child: () {
          if (_viewType == _ViewType.loading) return Center(child: _creatEvaluateLoadingContent());
          if (_viewType == _ViewType.loadError) return Center(child: _creatEvaluateLoadingErrorContent());
          if (_viewType == _ViewType.evaluate) return Center(child: _creatNeedEvaluateContent());
          if (_viewType == _ViewType.none) return Center(child: _creatNotNeedEvaluateContent());
          return Container();
        }(),
      ),
    );
  }

  /// 评价页面
  Widget _creatNeedEvaluateContent() {
    return Stack(overflow: Overflow.visible, alignment: Alignment.center, children: <Widget>[
      _creatCardBgWidget(),
      Positioned(
        top: px(-80),
        child: _creatRibbonWidget(),
      ),
      _createPopButton(),
      Positioned(
        top: px(8),
        child: _creatTitleWidget("课时结束"),
      ),
      Positioned(
        top: px(60),
        child: _creatTipTextWidget("您喜欢这节课吗?", myColor: Colors.black),
      ),
      Positioned(
        top: px(100),
        child: Row(children: <Widget>[
          GestureDetector(
            onTap: () => _likeOrDislikeAction(false),
            child: Column(children: <Widget>[
              Image.asset("assets/ai_package/images/utils/icon_dislike@3x.webp", width: px(80), height: px(70)),
              Container(height: 8),
              Text("不喜欢", style: CustomTextStyle.fz(color: Color(0xFF666666), fontSize: px(15))),
            ]),
          ),
          Container(width: px(60)),
          GestureDetector(
            onTap: () => _likeOrDislikeAction(true),
            child: Column(children: <Widget>[
              Image.asset("assets/ai_package/images/utils/icon_like@3x.webp", width: px(80), height: px(70)),
              Container(height: 8),
              Text("喜欢", style: CustomTextStyle.fz(color: Color(0xFF666666), fontSize: px(15))),
            ]),
          ),
        ]),
      ),
    ]);
  }

  /// // 加载中
  Widget _creatEvaluateLoadingContent() {
    return Stack(overflow: Overflow.visible, alignment: Alignment.center, children: <Widget>[
      _creatCardBgWidget(),
      Positioned(
        top: px(-80),
        child: _creatRibbonWidget(),
      ),
      _createPopButton(),
      Positioned(
        top: px(6),
        child: _creatTitleWidget("课时结束"),
      ),
      Positioned(
        top: px(70),
        child: Column(children: <Widget>[
          Image.asset("assets/ai_package/images/utils/loading_coco.gif", width: 100),
          Container(height: 8),
          Text("加载中...", style: TextStyle(color: Colors.black)),
        ]),
      ),
    ]);
  }

  /// // 加载失败
  Widget _creatEvaluateLoadingErrorContent() {
    return Stack(overflow: Overflow.visible, alignment: Alignment.center, children: <Widget>[
      _creatCardBgWidget(),
      Positioned(
        top: px(-80),
        child: _creatRibbonWidget(),
      ),
      _createPopButton(),
      Positioned(
        top: px(6),
        child: _creatTitleWidget("课时结束"),
      ),
      Positioned(
        top: px(70),
        child: Column(children: <Widget>[
          Image.asset("assets/ai_package/images/utils/loadError.webp", width: 100),
          Container(height: 8),
          Text("加载失败", style: TextStyle(color: Colors.black)),
          FlatButton(
            onPressed: () => _getEvaluateCount(),
            child: Stack(alignment: AlignmentDirectional.center, children: <Widget>[
              Image.asset("assets/ai_package/images/utils/button_bg.webp", width: 100),
              Text("重新加载", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ]),
          ),
        ]),
      ),
    ]);
  }

  /// 需要评价
  Widget _creatNotNeedEvaluateContent() {
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.center,
      children: <Widget>[
        _creatCardBgWidget(),
        Positioned(
          top: pxh(-80),
          child: _creatRibbonWidget(),
        ),
        _createPopButton(),
        Positioned(
          top: px(6),
          child: _creatTitleWidget("闯关成功"),
        ),
        _creatTipTextWidget("恭喜你，完成学习!"),
        Positioned(
          bottom: px(31),
          child: _creatFinishButton(),
        ),
      ],
    );
  }

  /// 提示文本
  Widget _creatTipTextWidget(String tips, {Color myColor}) {
    Color textColor = Color(0xFFFF6700);
    if (widget.subjectCode == 40) textColor = Color(0xFF666666);
    return Text(
      tips,
      style: CustomTextStyle.fz().copyWith(
        fontSize: px(16), //字体大小
        color: myColor ?? textColor, //文字颜色
      ),
    );
  }

  /// 标题
  Widget _creatTitleWidget(String title) {
    return Text(
      title,
      style: CustomTextStyle.fz().copyWith(
        fontSize: px(20), //字体大小
        color: Colors.white, //文字颜色
      ),
    );
  }

  /// 彩带
  Widget _creatRibbonWidget() {
    return Visibility(
      visible: _showRibbon,
      child: Image.asset(AiClassImg.finishRibbon, width: px(650)),
    );
  }

  /// 卡片背景
  Widget _creatCardBgWidget() {
    String imagePath = AiClassImg.finishCard;
//    if (widget.subjectCode == 40) imagePath = AiClassImg.finishChineseCard;
//    if (widget.subjectCode == 10) imagePath = AiClassImg.finishEnglishCard;
    imagePath = AiClassImg.finishEnglishCard;

    return IntrinsicWidth(
      child: Row(children: <Widget>[
        Container(width: px(50), height: 1),
        Image.asset(
          imagePath,
          width: px(366),
          height: px(234),
        ),
        Container(width: px(50), height: 1),
      ]),
    );
  }

  /// 退出按钮
  Widget _createPopButton() {
    return Positioned(
      top: px(20),
      right: px(20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Image.asset("assets/ai_package/images/utils/close_small.webp", width: 25),
      ),
    );
  }

  /// 完成按钮
  Widget _creatFinishButton() {
    return GestureDetector(
      onTap: onCompletionActionClick,
      child: Container(
        alignment: Alignment.center,
        width: px(94),
        height: px(35),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AiClassImg.finishBtn),
            fit: BoxFit.contain,
          ),
        ),
        child: Text(
          'OK',
          style: CustomTextStyle.fz().copyWith(
            fontSize: px(16), //字体大小
            color: Colors.white, //文字颜色
          ),
        ),
      ),
    );
  }
}

Future<void> _showEvaluateCover(BuildContext context, {bool isLike = true}) {
  return showAppDialog(
    context: context,
    builder: (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(seconds: 3));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
      return Material(
        color: Colors.black.withOpacity(0.6),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Image.asset(isLike == true ? "assets/ai_package/images/aiMath/happy.gif" : "assets/ai_package/images/aiMath/sad_arrow.gif", width: px(220)),
//            Padding(
//              padding: EdgeInsets.only(left: px(140), bottom: px(140)),
//              child: GestureDetector(
//                onTap: () {
//                  Navigator.of(context).pop();
//                  Navigator.of(context).pop();
//                },
//                child: Image.asset("assets/ai_package/images/utils/close_small.webp", width: 25),
//              ),
//            ),
          ],
        ),
      );
    },
  );
}
