import 'package:atsign_atmosphere_app/screens/common_widgets/custom_popup_route.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  LoadingDialog._();

  static final LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  show() {
    if (!_showing) {
      // isLoading = true;
      _showing = true;
      NavService.navKey.currentState
          .push(CustomPopupRoutes(
              pageBuilder: (_, __, ___) {
                print("building loader");
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              barrierDismissible: false))
          .then((_) {
//        _showing = false;
      });
    }
  }

  hide() {
    print("hide called");
    if (_showing) {
      // isLoading = false;
      NavService.navKey.currentState.pop();
      _showing = false;
    }
  }
}
