import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:starter/app/data/models/response/app_config_response.dart';
import 'package:starter/app/data/values/env.dart';
import 'package:starter/app/data/values/strings.dart';

import 'package:starter/app/routes/app_pages.dart';
import 'package:starter/utils/storage/storage_utils.dart';
import 'package:starter/widgets/buttons/primary_filled_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startOnboarding();
  }

  _startOnboarding() async {
    AppConfig? appConfig;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localBuildNumber = packageInfo.buildNumber;
    if (Storage.isAppConfigExists()) {
      appConfig = Storage.getAppConfig();
    }
    String remoteBuildNumber = appConfig?.buildNumber ?? "1111";
    if (int.parse(localBuildNumber) < int.parse(remoteBuildNumber)) {
      _launchUpdate();
    } else {
      _launchPage();
    }
  }

  _launchUpdate() async {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => exit(0),
        child: const AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          title: Text(Strings.updateApp),
          content: Text(Strings.updateAvailable),
          actions: <Widget>[
            PrimaryFilledButton(
              text: Strings.update,
              onTap: _launchStore,
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  _launchPage() async {
    if (Storage.isUserExists()) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.AUTH_LOGIN);
    }
  }
}

_launchStore() async {
  if (Platform.isAndroid) {
    if (!await launch(Env.playStoreLink)) {
      throw 'Could not launch ${Env.playStoreLink}';
    }
  } else if (Platform.isIOS) {
    if (!await launch(Env.appStoreLink)) {
      throw 'Could not launch ${Env.appStoreLink}';
    }
  }
}
