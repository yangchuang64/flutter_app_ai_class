import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:bling_downloader/bling_downloader.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/screens/upgradeController/model/gray_upgrade.dart';
import 'package:flutter_app_ai_math/screens/upgradeController/update_dialog.dart';
import 'package:flutterblingaiplugin/screen/configs/const_keys.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/net_connect.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:blingabc_base/blingabc_base.dart' as Base;

///
/// app更新控制器
///
class UpgradeController {
  static UploadProgressController _progressController;
  static String _iosAppUrl =
      'https://itunes.apple.com/cn/app/id1512344433?l=zh&ls=1&mt=8';

  /// 检测更新
  static void checkUpgrade(BuildContext context, {bool showAlreadyUpdated = false}) async {
    if(showAlreadyUpdated){

      if (NetConnect.netConnectState == ConnectivityResult.none) {
        UiUtil.showToast('请检查网络~');
        return;
      }
      Base.showCoCoLoading(context);
    }
    String dateTime = DateTime.now().millisecondsSinceEpoch.toString();
    dateTime = dateTime.substring(0, 10);
    var params = {'appKey': 'xdf_ai_app', 'platform': Platform.isAndroid ? "1" : "2", "ts": dateTime};
    params = getRequestParams(params);
    BaseResp<GrayUpdateData> resp = await NetRequest.post(
      url: ApiConfigs.upgradeUrl,
      param: params,
      dateTypeInstance: GrayUpdateData(),
    );
    if (null == resp || !resp.result || resp.data == null) {
      if (showAlreadyUpdated){
        Base.hideCoCoLoading(context);
        if (NetConnect.netConnectState == ConnectivityResult.none) {
          UiUtil.showToast('请检查网络~');
        }else{
          UiUtil.showToast('已经是最新版本了~');
        }
      }
      return;
    }
    UpgradeInfo upgradeInfo = resp?.data?.upgradeInfo;
    if (null != upgradeInfo && upgradeInfo.isGray == 0) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int updateStatus = _compareVersion(packageInfo.version, upgradeInfo.version);
      if (showAlreadyUpdated)Base.hideCoCoLoading(context);
      if (updateStatus > 0) {
        _showNormalUpgradeDialog(context, upgradeInfo);
      }else{
        if (showAlreadyUpdated)UiUtil.showToast('已经是最新版本了~');
      }
    }
  }

  /// 本地版本和服务器版本比对
  static int _compareVersion(String localVersion, String serverVersion) {
    String _serverNumberString = serverVersion.replaceAll('.', '');
    String _localNumberString = localVersion.replaceAll('.', '');
    final minCount = min(_serverNumberString.length, _localNumberString.length);
    for (var i = 0; i < minCount; i++) {
      final l1 = _serverNumberString.codeUnitAt(i);
      final l2 = _localNumberString.codeUnitAt(i);
      if(l1>l2){
        return 1;
      }else if(l1<l2){
        return -1;
      }else{
        continue;
      }
    }
    if(_serverNumberString.length>_localNumberString.length){
      return 1;
    }else if(_serverNumberString.length<_localNumberString.length){
      return -1;
    }else{
      return 0;
    }
  }

  static void _showNormalUpgradeDialog(BuildContext context, UpgradeInfo info) {
    if (!ModalRoute.of(context).isCurrent) return;
    _progressController = UploadProgressController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateDialog(
          progressController: _progressController,
          tips: info.upgradeInstructions,
          forcedUpdate: info.forcedUpdate,
          updateCallback: () => _updateActionClick(info),
          refuseCallback: () {},
        );
      },
    ).then((_) {
      _progressController.dispose();
      _progressController = null;
    });
  }

  /// 立即升级按钮点击事件
  static void _updateActionClick(UpgradeInfo info){
    if (Platform.isAndroid) {
      _downloadApkSource(info);
    }else{
      InstallPlugin.gotoAppStore(_iosAppUrl);
    }
  }

  /// apk资源下载
  static void _downloadApkSource(UpgradeInfo info) async {
    var dir = await getExternalStorageDirectory();
    BlingDownloader.downloadFile(
      basePath: dir.path,
      fileUrl: info.downloadUrl,
      onFail: () => UiUtil.showToast("下载错误,请退出重试"),
      onSuccess: (Map<String, String> urlMap) async {
        String file = urlMap[info.downloadUrl];
//        debugPrint('file ${file}');
        PackageInfo packageInfo = await PackageInfo.fromPlatform();

        InstallPlugin.installApk(file, packageInfo.packageName).then((result) {
          UiUtil.showToast('安装状态$result');
        }).catchError((error) {
          UiUtil.showToast("安装失败");
        });
      },
      onProgress: (double current, double total, String speed) {
        Future.delayed(Duration(milliseconds: 10), () {
          _progressController.updateRate(current / total);
        });
      },
    );
  }

  /// 生成请求服务器需要的参数
  static Map<String, dynamic> getRequestParams(Map<String, String> params) {
    List<String> sortedKeys = params.keys.toList()..sort();
    String temp = '';
    int length = sortedKeys.length;
    for (int i = 0; i < length; i++) {
      temp += sortedKeys[i] + '=' + params[sortedKeys[i]] + '&';
    }
    temp += 'app_key=${UpgradeKeys.signAppKey}';
    var content = new Utf8Encoder().convert(temp);
    var digest = md5.convert(content);
    params.addAll({'sign': hex.encode(digest.bytes).toLowerCase()});
    return params;
  }
}
