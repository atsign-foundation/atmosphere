import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';

class CustomFlushBar {
  CustomFlushBar._();

  static CustomFlushBar _instance = CustomFlushBar._();

  factory CustomFlushBar() => _instance;

  Flushbar f;
  AnimationController currentController;
  BackendService backendService = BackendService.getInstance();

  Flushbar getFlushbar(
      String displayMessage, AnimationController progressController,
      {bool shouldTimeout = true}) {
    if (currentController == null) {
      currentController = progressController;
    } else {
      f?.dismiss();
    }
    f = Flushbar(
      title: displayMessage,
      message: 'hello',
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: ColorConstants.scaffoldColor,
      boxShadows: [
        BoxShadow(
            color: Colors.black, offset: Offset(0.0, 2.0), blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: shouldTimeout ? Duration(seconds: 5) : null,
      icon: Container(
        height: 40.toWidth,
        width: 40.toWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImageConstants.imagePlaceholder),
              fit: BoxFit.cover),
          shape: BoxShape.circle,
        ),
      ),
      mainButton: FlatButton(
        onPressed: () {
          if (f.isShowing()) {
            f.dismiss();
          }
        },
        child: Text(
          TextStrings().buttonDismiss,
          style: TextStyle(color: ColorConstants.fontPrimary),
        ),
      ),
      onStatusChanged: (status) {
        if (status == FlushbarStatus.DISMISSED) {
          backendService.controller = null;
        }
      },
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Column(
        children: [
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: displayMessage == TextStrings().fileReceived
                    ? Icon(
                        Icons.check_circle,
                        size: 13.toFont,
                        color: ColorConstants.successColor,
                      )
                    : SizedBox(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.toWidth, top: 15),
                child: Text(
                  displayMessage,
                  style: TextStyle(
                      color: ColorConstants.fadedText, fontSize: 15.toFont),
                ),
              )
            ],
          ),
        ],
      ),
    );
    return f;
  }
}
