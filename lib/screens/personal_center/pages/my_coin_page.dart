import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/screens/personal_center/widgets/how_to_get_coin.dart';
import 'package:flutter_app_ai_math/widgets/rect_with_circle.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyCoinPage extends StatefulWidget {
  @override
  _MyCoinPageState createState() => _MyCoinPageState();
}

class _MyCoinPageState extends State<MyCoinPage> {
  int _coinCount = 0;
  int _page = 1;
  int _size = 14;
  String _stuNum = "";

  int total = 0;

  List<CoinDetailModel> _modelArr = [];

  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    UiUtil.setPortraitUpMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });

    _stuNum = LoginUserInfo.getInstance(null)?.selectedStudent?.stuNum;
    _getWalnutTotalCount();
    _firstGetData();
  }

  void _didClickRightButton() async {
    showHowToGetCoinDialog(context);
  }

  /// 获取当前智慧币总数
  void _getWalnutTotalCount() async {
    BaseResp baseResp = await NetRequest.get(url: ApiConfigs.getWalnutTotal, param: {"stuNum": _stuNum});
    if (baseResp.result == true && baseResp.data != null) {
      BaseRespData respData = baseResp.data;
      if (respData.originValue is int) _coinCount = respData.originValue;
      if (respData.originValue is String) _coinCount = respData.originValue as int;
      if (mounted) setState(() {});
    }
  }

  /// 首次加载
  void _firstGetData() async {
    _page = 1;
    BaseResp<CoinDetailListModel> baseResp = await NetRequest.get<CoinDetailListModel>(
        url: ApiConfigs.getWalnutDetail,
        param: {
          "page": _page,
          "size": _size,
          "stuNum": _stuNum,
        },
        dateTypeInstance: CoinDetailListModel());

    if (baseResp.result == true && baseResp.data != null) {
      CoinDetailListModel listModel = baseResp.data;

      total = listModel.size;
      _isEmpty = (listModel.list == null || listModel.list.length == 0);
      _modelArr = listModel.list;
      if (mounted) setState(() {});
    }

    _refreshController.refreshCompleted();
  }

  void loadMoreData() async {
    print("------------start load--${_page}-----------");
    if (_page * _size >= total) {
      UiUtil.showToast("没有更多的数据了");
      _refreshController.loadNoData();
      return;
    }
    BaseResp<CoinDetailListModel> baseResp = await NetRequest.get<CoinDetailListModel>(
        url: ApiConfigs.getWalnutDetail,
        param: {
          "page": _page + 1,
          "size": _size,
          "stuNum": _stuNum,
        },
        dateTypeInstance: CoinDetailListModel());
    _refreshController.loadComplete();
    if (baseResp.result == true && baseResp.data != null) {
      CoinDetailListModel listModel = baseResp.data;
      if (listModel.list.length > 0) {
        _page += 1;
      } else {
        UiUtil.showToast("没有更多的数据了");
      }
      _modelArr.addAll(listModel.list);
      if (mounted) setState(() {});
    }
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return Scaffold(
        appBar: CommonPreferredSize(text: '我的智慧币'),
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/ai_package/images/path/image_empty@3x.webp", width: px(112), height: px(79)),
                SizedBox(
                  height: px(20),
                ),
                Text(
                  "还没有获得金币奖励，赶快学习吧！",
                  style: CustomTextStyle.fz(
                    color: Color(0xFF666666),
                    fontSize: fontSizeWithPad(14.0),
                  ),
                ),
                SizedBox(
                  height: px(20),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Color(0xffF4F4F4),
          ),
//          Container(
//            height: 200,
//            decoration: BoxDecoration(
//              color: Color(0xFFFABE00),
//              borderRadius: BorderRadius.only(
//                bottomLeft: Radius.circular(px(20)),
//                bottomRight: Radius.circular(px(20)),
//              ),
//            ),
//          ),
          Container(
            width: window.physicalSize.width,
            height: px(140),
            child: RectWithCircleWidget(color: Color(0xFFFABE00)),
          ),
          _buildNavigationBar(),
          Container(
            color: Colors.white,
            margin: EdgeInsets.fromLTRB(px(15), MediaQuery.of(context).padding.top + 44 + px(214), px(15), 0),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(px(15), MediaQuery.of(context).padding.top + 44, px(15), 0),
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: MaterialClassicHeader(),
              footer: ClassicFooter(noDataText: '没有更多数据'),
              controller: _refreshController,
              onRefresh: _firstGetData,
              onLoading: loadMoreData,
              child: ListView.builder(
                itemCount: _modelArr.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _buildListHeader();
                  } else if (index == 1) {
                    return _buildSectionHeader();
                  } else {
                    return _buildListCell(index - 2);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: 44,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            width: px(60),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "我的智慧币",
                style: CustomTextStyle.fz(
                  color: Colors.white,
                  fontSize: fontSizeWithPad(16.0),
                ),
              ),
            ),
          ),
          Container(
            width: px(60),
            child: GestureDetector(
              onTap: _didClickRightButton,
              child: Center(
                child: Text(
                  "说明",
                  style: CustomTextStyle.fz(
                    color: Colors.white,
                    fontSize: fontSizeWithPad(16.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: px(15)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(px(12)),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: px(20),
          ),
          Text(
            "智慧币奖励",
            style: CustomTextStyle.fz(
              color: Color(0xFF333333),
              fontSize: fontSizeWithPad(16.0),
            ),
          ),
          SizedBox(height: px(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "${_coinCount}",
                style: CustomTextStyle.fz(
                  color: Color(0xFFFABE00),
                  fontSize: fontSizeWithPad(26.0),
                ),
              ),
              SizedBox(
                width: px(5),
                height: px(41),
              ),
              Image.asset("assets/ai_package/images/path/icon_gold@3x.webp", width: px(28), height: px(31)),
            ],
          ),
          SizedBox(height: px(20)),
//          Text(
//            "每天6点更新至昨日的智慧币获取记录",
//            style: CustomTextStyle.fz(
//              color: Color(0xFF999999),
//              fontSize: fontSizeWithPad(12.0),
//            ),
//          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      height: px(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(px(12)), topRight: Radius.circular(px(12))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: px(15),
            child: Container(
              child: Text(
                "智慧币明细",
                style: CustomTextStyle.fz(
                  color: Color(0xFF333333),
                  fontSize: fontSizeWithPad(16.0),
                ),
              ),
            ),
          ),
          Positioned(
            left: px(15),
            right: px(15),
            bottom: 0,
            height: 1,
            child: Container(
              color: Color(0xFFEBEBEB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCell(int index) {
    if (_modelArr.length <= index) return Container();
    CoinDetailModel model = _modelArr[index];
    return Container(
      height: px(58),
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: px(15)),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model.classLessonName ?? "",
                    style: CustomTextStyle.fz(
                      color: Color(0xFF333333),
                      fontSize: fontSizeWithPad(14.0),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    model.gmtCreate ?? "",
                    style: CustomTextStyle.fz(
                      color: Color(0xFF333333),
                      fontSize: fontSizeWithPad(12.0),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(),
              ),
              Text(
                "+${model.walnutCoin}",
                style: CustomTextStyle.fz(
                  color: Color(0xFFFABE00),
                  fontSize: fontSizeWithPad(16.0),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 1,
            child: Container(
              color: Color(0xFFEBEBEB),
            ),
          ),
        ],
      ),
    );
  }
}

class CoinDetailListModel extends BaseRespData {
  int size;
  List<CoinDetailModel> list;

  CoinDetailListModel();

  CoinDetailListModel.fromJson(Map<String, dynamic> json) {
    list = (json["list"] as List)?.map((i) {
      return CoinDetailModel.fromJson(i);
    })?.toList();
    size = (json["total"] ?? 0) ~/ 1 as int;
  }

  @override
  BaseRespData translateData(dynamic data) {
    return CoinDetailListModel.fromJson(data);
  }
}

class CoinDetailModel extends BaseRespData {
  String stuNum;
  int classId;
  int classLessonId;
  int actionType; //行为类型 获得或消耗类型,10-获得, 20- 消耗
  String classLessonName; // 课程名字
  String expendDesc; // 核桃比 消耗描述
  int walnutCoin; //核桃币
  String gmtCreate; //创建时间

  CoinDetailModel.fromJson(Map<String, dynamic> json) {
    stuNum = json['stuNum'];
    classId = (json["classId"] ?? 0) ~/ 1 as int;
    classLessonId = (json["classLessonId"] ?? 0) ~/ 1 as int;
    actionType = (json["actionType"] ?? 0) ~/ 1 as int;
    classLessonName = json['classLessonName'];
    expendDesc = json['expendDesc'];
    walnutCoin = (json["walnutCoin"] ?? 0) ~/ 1 as int;
    if (json["gmtCreate"] is String) {
      gmtCreate = json["gmtCreate"];
    } else {
      gmtCreate = " ";
    }
  }

  @override
  BaseRespData translateData(dynamic data) {
    return CoinDetailModel.fromJson(data);
  }
}
