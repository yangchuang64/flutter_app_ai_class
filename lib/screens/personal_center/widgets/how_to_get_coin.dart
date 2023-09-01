import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/dialogs.dart';
import 'package:flutterblingaiplugin/screen/widgets/feedback_animated_widget.dart';

Future<void> showHowToGetCoinDialog(BuildContext context) async {
  FeedbackWidgetController _controller = FeedbackWidgetController();
  await showAppDialog(
    context: context,
    builder: (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.trigger());
      return FeedbackAnimatedWidget(
        controller: _controller,
        child: Material(
          color: Colors.black.withOpacity(0.6),
          child: HowToGetCoinWidget(),
        ),
      );
    },
  );
  _controller.dispose();
  return;
}

class HowToGetCoinWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.transparent,
      child: Center(
        child: Stack(
          children: <Widget>[
//            Container(
//              width: px(320),
//              height: px(218),
//            ),
//            Positioned(
//              bottom: 0,
//              child: ,
//            ),
            Container(
              padding: EdgeInsets.only(top: px(50)),
              child: Container(
                margin: EdgeInsets.only(left: px(30), right: px(30)),
                padding: EdgeInsets.only(left: px(20), right: px(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(px(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: px(30),
                    ),
                    Text(
                      "怎样获得智慧币？",
                      style: CustomTextStyle.fz(
                        color: Color(0xFF333333),
                        fontSize: fontSizeWithPad(18.0),
                      ),
                    ),
                    SizedBox(
                      height: px(21),
                    ),
                    Text(
                      "上课奖励：第一次学习课程时，会获得相应的奖励",
                      style: CustomTextStyle.fz(
                        color: Color(0xFF666666),
                        fontSize: fontSizeWithPad(16.0),
                      ),
                    ),
                    SizedBox(
                      height: px(29),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: px(40),
                        margin: EdgeInsets.symmetric(horizontal: px(10)),
                        decoration: BoxDecoration(
                          color: Color(0xFFFABE00),
                          borderRadius: BorderRadius.circular(px(20)),
                        ),
                        child: Center(
                          child: Text(
                            "知道了",
                            style: CustomTextStyle.fz(
                              color: Color(0xFFFFFFFF),
                              fontSize: fontSizeWithPad(16.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: px(30),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image(
                image: AssetImage('assets/ai_package/images/path/image_coco_poptitle@3x.webp'),
                height: px(60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
