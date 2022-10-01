import 'dart:async';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  List<AtContact> contactList = [];
  List<AtContact> blockedContactList = [];
  List<String> allContactsList = [];
  String selectedAtsign;
  BackendService backendService = BackendService.getInstance();

  String contactsString = 'contacts';
  String addContactsString = 'add_contacts';
  String getContactsString = 'get_contacts';
  String deleteContactsString = 'delete_contacts';
  String blockedContactsString = 'blocked_contacts';

  ContactProvider() {
    initContactImpl();
  }
  // static ContactProvider _instance = ContactProvider._();
  Completer completer;

  initContactImpl() async {
    try {
      setStatus(contactsString, Status.loading);
      completer = Completer();
      String currentAtsign = await BackendService.getInstance().getAtSign();
      print('CURRENT ASTSINg-==>$currentAtsign');
      atContact = await AtContactsImpl.getInstance(currentAtsign);
      if (!completer.isCompleted) {
        completer.complete(true);
      }
      setStatus(contactsString, Status.done);
    } catch (error) {
      print("error =>  $error");
      setError(contactsString, error.toString());
    }
  }

  resetContactImpl() async {
    try {
      reset(contactsString);
      String currentAtsign = await BackendService.getInstance().getAtSign();
      atContact = await AtContactsImpl.getInstance(currentAtsign);
      await getContacts();
    } catch (error) {
      print("error =>  $error");
      setError(contactsString, error.toString());
    }
  }
  // factory ContactProvider() => _instance;

  List<Map<String, dynamic>> contacts = [];
  static AtContactsImpl atContact;

  Future getContacts() async {
    Completer c = Completer();
    try {
      setStatus(getContactsString, Status.loading);
      contactList = [];
      allContactsList = [];
      await completer.future;
      contactList = await atContact.listContacts();
      List<AtContact> tempContactList = [...contactList];
      print("list =>  $contactList");
      int range = contactList.length;

      for (int i = 0; i < range; i++) {
        print("is blocked => ${contactList[i].blocked}");
        allContactsList.add(contactList[i].atSign);
        if (contactList[i].blocked) {
          tempContactList.remove(contactList[i]);
        }
      }
      contactList = tempContactList;
      contactList.sort(
          (a, b) => a.atSign.substring(1).compareTo(b.atSign.substring(1)));
      print("list =>  $contactList");
      setStatus(getContactsString, Status.done);
      c.complete(true);
    } catch (e) {
      print("error here => $e");
      setStatus(getContactsString, Status.error);
      c.complete(true);
    }
    return c.future;
  }

  blockUnblockContact({AtContact contact, bool blockAction}) async {
    try {
      setStatus(blockedContactsString, Status.loading);
      contact.blocked = blockAction;
      await atContact.update(contact);
      fetchBlockContactList();
      await getContacts();
    } catch (error) {
      setError(blockedContactsString, error.toString());
    }
  }

  fetchBlockContactList() async {
    try {
      setStatus(blockedContactsString, Status.loading);
      atContact ??=
          await AtContactsImpl.getInstance(backendService.currentAtsign);
      blockedContactList = await atContact.listBlockedContacts();
      print("block contact list => $blockedContactList");
      setStatus(blockedContactsString, Status.done);
    } catch (error) {
      setError(blockedContactsString, error.toString());
    }
  }

  deleteAtsignContact({String atSign}) async {
    try {
      setStatus(deleteContactsString, Status.loading);
      var result = await atContact.delete(atSign);
      print("delete result => $result");
      await getContacts();
      setStatus(deleteContactsString, Status.done);
    } catch (error) {
      setError(deleteContactsString, error.toString());
    }
  }

  bool isContactPresent = false;
  bool isLoading = false;
  String getAtSignError = '';
  bool checkAtSign;

  Future addContact({String atSign}) async {
    if (atSign == null || atSign == '') {
      getAtSignError = TextStrings().emptyAtsign;
      setError(addContactsString, '_error');
      isLoading = false;
      return true;
    } else if (atSign[0] != '@') {
      atSign = '@$atSign';
    }
    Completer c = Completer();
    try {
      isContactPresent = false;
      isLoading = true;
      getAtSignError = '';
      AtContact contact = AtContact();
      setStatus(addContactsString, Status.loading);

      checkAtSign = await backendService.checkAtsign(atSign);
      if (!checkAtSign) {
        getAtSignError = TextStrings().unknownAtsign(atSign);
        setError(addContactsString, '_error');
        isLoading = false;
      } else {
        for (var element in contactList) {
          if (element.atSign == atSign) {
            getAtSignError = TextStrings().atsignExists(atSign);
            isContactPresent = true;
            continue;
          }
          isLoading = false;
        }
      }
      if (!isContactPresent && checkAtSign) {
        var details = await backendService.getContactDetails(atSign);
        contact = AtContact(
          atSign: atSign,
          tags: details,
        );
        var result = await atContact.add(contact).catchError(
          (e) async {
            print('error to add contact => $e');
            return false;
          },
        );
        print(result);
        isLoading = false;
        Navigator.pop(NavService.navKey.currentContext);
        await getContacts();
      }
      c.complete(true);
      isLoading = false;
      setStatus(addContactsString, Status.done);
    } catch (e) {
      c.complete(true);
      setStatus(addContactsString, Status.error);
    }
    return c.future;
  }
}
