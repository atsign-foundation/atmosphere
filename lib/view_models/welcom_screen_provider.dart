import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class WelcomeScreenProvider extends BaseModel {
  WelcomeScreenProvider._();
  static WelcomeScreenProvider _instance = WelcomeScreenProvider._();
  factory WelcomeScreenProvider() => _instance;

  String updateContacts = 'update_contacts';
  String onboard = 'onboard';
  String selectGroupContacts = 'select_group_contacts';

  bool authenticating = false;
  onboardingLoad({String atSign}) async {
    try {
      authenticating = true;

      setStatus(onboard, Status.Loading);
      await BackendService.getInstance()
          .checkToOnboard(atSignToOnboard: atSign);

      authenticating = false;

      setStatus(onboard, Status.Done);
    } catch (error) {
      authenticating = false;
      setError(onboard, error.toString());
    }
  }
}
