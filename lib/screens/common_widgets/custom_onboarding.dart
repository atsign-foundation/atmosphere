import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';

class CustomOnboarding {
  static final BackendService _backendService = BackendService.getInstance();

  static onboard(
      {String atSign, atClientPreference, Function showLoader}) async {
    Onboarding(
      atsign: atSign,
      context: NavService.navKey.currentContext,
      atClientPreference: atClientPreference,
      domain: MixedConstants.rootDomain,
      appColor: Color.fromARGB(255, 240, 94, 62),
      onboard: (value, atsign) async {
        if (showLoader != null) {
          showLoader(true);
        }
        _backendService.atClientServiceMap = value;

        await _backendService.atClientServiceMap[atsign]
            .makeAtSignPrimary(atsign);
        await _backendService.startMonitor(atsign: atsign, value: value);
        _backendService.initBackendService();
        await ContactProvider().initContactImpl();
        if (showLoader != null) {
          showLoader(false);
        }
        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext,
            Routes.welcomeScreen,
            (Route<dynamic> route) => false);
      },
      onError: (error) {
        print('Onboarding throws $error error');
      },
    );
  }
}
