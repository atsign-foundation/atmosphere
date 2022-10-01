import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class AddContactProvider extends BaseModel {
  AddContactProvider._();
  static final AddContactProvider _instance = AddContactProvider._();
  factory AddContactProvider() => _instance;
  String addContactsString = 'addContacts';
  List<Map<String, dynamic>> addContacts = [];

  getAddContacts() async {
    setStatus(addContactsString, Status.loading);
    try {
      await Future.delayed(Duration(seconds: 1), () {
        addContacts = [];
        for (int i = 0; i < 10; i++) {
          addContacts.add({
            'name': 'User $i',
          });
        }
      });
      setStatus(addContactsString, Status.done);
    } catch (error) {
      setError(addContactsString, error.toString());
    }
  }
}
