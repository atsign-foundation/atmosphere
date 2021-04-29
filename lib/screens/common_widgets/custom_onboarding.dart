import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';

class CustomOnboarding {
  static BackendService _backendService = BackendService.getInstance();
  static onboard({String atSign, atClientPrefernce, Function onTap}) async {
    await Onboarding(
      atsign: atSign,
      context: NavService.navKey.currentContext,
      atClientPreference: atClientPrefernce,
      domain: MixedConstants.ROOT_DOMAIN,
      appColor: Color.fromARGB(255, 240, 94, 62),
      onboard: (value, atsign) async {
        _backendService.atClientServiceMap = value;

        String atSign = await _backendService
            .atClientServiceMap[atsign].atClient.currentAtSign;

        await _backendService.atClientServiceMap[atSign]
            .makeAtSignPrimary(atSign);
        await _backendService.startMonitor(atsign: atsign, value: value);
        _backendService.initBackendService();
        await ContactProvider().initContactImpl();

        await Navigator.pushNamedAndRemoveUntil(
            NavService.navKey.currentContext,
            Routes.WELCOME_SCREEN,
            (Route<dynamic> route) => false);
      },
      onError: (error) {
        print('Onboarding throws $error error');
      },
    );
  }
}
