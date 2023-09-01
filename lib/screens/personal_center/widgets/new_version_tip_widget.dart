import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/screens/upgradeController/update_dialog.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/linear_percent_indicator.dart';



class NewVersionTip extends StatefulWidget {

  final String tipText;
  final int forcedUpdate;
  final Function updateCallBack;
  final Function cancelCallBack;
  final UploadProgressController progressController;

  NewVersionTip({this.progressController, this.tipText, this.forcedUpdate, this.updateCallBack, this.cancelCallBack});
  @override
  _NewVersionTipState createState() => _NewVersionTipState();
}

class _NewVersionTipState extends State<NewVersionTip> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.progressController.addListener((){
      if (mounted) {
        setState(() {});
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: px(335),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(px(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset("assets/ai_package/images/personalCenter/new_version_tip_bg.webp", height: px(131),),
              Container(
                padding: EdgeInsets.fromLTRB(px(23), px(10), px(23), px(10)),
                child: Text(widget.tipText, style: CustomTextStyle.fz().copyWith(fontSize: px(16), color: Color(0xFF666666)),),
              ),
              _buildProgressbar(),
              Container(
                padding: EdgeInsets.only(left: 0, right: 0, bottom: px(15), top: px(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _returnActionButtons(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressbar() {
    double rate = widget.progressController.value ?? 0.0;
    return Offstage(
      offstage: rate == 0.0,
      child: Container(
        width: px(300),
        child: Padding(
          padding: EdgeInsets.only(bottom: px(20), left: px(30), right: px(30)),
          child: Column(children: <Widget>[
            Text("下载进度:${(rate * 100).toStringAsFixed(2)}%", style: CustomTextStyle.fz().copyWith(fontSize:px(16), color: Color(0xFF999999)),),
            LinearPercentIndicator(
              linearGradient: LinearGradient(
                colors: [Color(0xFFFABE00), Color(0xFFFABE00)],
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

  Widget _nextButton(){
    return GestureDetector(
      onTap: (){
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        if (widget.cancelCallBack != null) widget.cancelCallBack();
      },
      child: Container(
        width: px(120),
        height: px(44),
        decoration: BoxDecoration(
          color: Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(px(22)),
        ),
        child: Center(
          child: Text("下次升级",style: CustomTextStyle.fz().copyWith(fontSize:px(16), color: Color(0xFF999999)),),
        ),
      ),
    );
  }

  Widget _updateButton(){
    return GestureDetector(
      onTap: (){
        if (widget.updateCallBack != null) widget.updateCallBack();
      },
      child: Container(
        width: px(120),
        height: px(44),
        decoration: BoxDecoration(
          color: Color(0xFFFABE00),
          borderRadius: BorderRadius.circular(px(22)),
          boxShadow: [BoxShadow(color: Color(0xFFFFAB00), offset: Offset(0, 7.0) , blurRadius: 7, spreadRadius: 1.0),],
        ),
        child: Center(
          child: Text("立即升级",style: CustomTextStyle.fz().copyWith(fontSize:px(16), color: Color(0xFFFFFFFF)),),
        ),
      ),
    );
  }


  List<Widget> _returnActionButtons(){
    List<Widget> children = [];
    if (widget.forcedUpdate != 1) {
      children.add(_nextButton());
    }
    children.add(_updateButton());
    return children;
  }
}
