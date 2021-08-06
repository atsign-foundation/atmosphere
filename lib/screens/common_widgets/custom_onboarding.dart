import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomOnboarding {
  static BackendService _backendService = BackendService.getInstance();

  static onboard(
      {String atSign, atClientPrefernce, Function showLoader}) async {
    await Onboarding(
        atsign: atSign,
        context: NavService.navKey.currentContext,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
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

          // resetting data before moving to welcome screen
          Provider.of<ContactProvider>(NavService.navKey.currentContext,
                  listen: false)
              .resetData();
          Provider.of<FilePickerProvider>(NavService.navKey.currentContext,
                  listen: false)
              .selectedFiles = [];

          await Navigator.pushNamedAndRemoveUntil(
              NavService.navKey.currentContext,
              Routes.WELCOME_SCREEN,
              (Route<dynamic> route) => false);
        },
        onError: (error) {
          print('Onboarding throws $error error');
        },
        appAPIKey: MixedConstants.ONBOARD_API_KEY);
  }
}
