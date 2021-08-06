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

  String Contacts = 'contacts';
  String AddContacts = 'add_contacts';
  String GetContacts = 'get_contacts';
  String DeleteContacts = 'delete_contacts';
  String BlockedContacts = 'blocked_contacts';

  ContactProvider() {
    initContactImpl();
  }
  // static ContactProvider _instance = ContactProvider._();
  Completer completer;

  initContactImpl() async {
    try {
      completer = Completer();
      String currentAtsign = await BackendService.getInstance().getAtSign();
      print('CURRENT ASTSINg-==>$currentAtsign');
      atContact = await AtContactsImpl.getInstance(currentAtsign);
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    } catch (e) {
      print("error =>  $error");
      if (e.toString() != null) {
        error[Contacts] = e.toString();
        status[Contacts] = Status.Error;
      }
    }
  }

  resetContactImpl() async {
    try {
      reset(Contacts);
      String currentAtsign = await BackendService.getInstance().getAtSign();
      atContact = await AtContactsImpl.getInstance(currentAtsign);
      await getContacts();
    } catch (error) {
      print("error =>  $error");
      setError(Contacts, error.toString());
    }
  }
  // factory ContactProvider() => _instance;

  resetData() {
    contactList = [];
    blockedContactList = [];
    allContactsList = [];
    selectedAtsign = null;
  }

  List<Map<String, dynamic>> contacts = [];
  static AtContactsImpl atContact;

  Future getContacts() async {
    Completer c = Completer();
    try {
      setStatus(GetContacts, Status.Loading);
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
      setStatus(GetContacts, Status.Done);
      c.complete(true);
    } catch (e) {
      print("error here => $e");
      setStatus(GetContacts, Status.Error);
      c.complete(true);
    }
    return c.future;
  }

  blockUnblockContact({AtContact contact, bool blockAction}) async {
    try {
      setStatus(BlockedContacts, Status.Loading);
      contact.blocked = blockAction;
      await atContact.update(contact);
      fetchBlockContactList();
      await getContacts();
    } catch (error) {
      setError(BlockedContacts, error.toString());
    }
  }

  fetchBlockContactList() async {
    try {
      setStatus(BlockedContacts, Status.Loading);
      if (atContact == null) {
        atContact =
            await AtContactsImpl.getInstance(backendService.currentAtsign);
      }
      blockedContactList = await atContact.listBlockedContacts();
      print("block contact list => $blockedContactList");
      setStatus(BlockedContacts, Status.Done);
    } catch (error) {
      setError(BlockedContacts, error.toString());
    }
  }

  deleteAtsignContact({String atSign}) async {
    try {
      setStatus(DeleteContacts, Status.Loading);
      var result = await atContact.delete(atSign);
      print("delete result => $result");
      await getContacts();
      setStatus(DeleteContacts, Status.Done);
    } catch (error) {
      setError(DeleteContacts, error.toString());
    }
  }

  bool isContactPresent = false;
  bool isLoading = false;
  String getAtSignError = '';
  bool checkAtSign;

  Future addContact({String atSign}) async {
    if (atSign == null || atSign == '') {
      getAtSignError = TextStrings().emptyAtsign;
      setError(AddContacts, '_error');
      isLoading = false;
      return true;
    } else if (atSign[0] != '@') {
      atSign = '@' + atSign;
    }
    Completer c = Completer();
    try {
      isContactPresent = false;
      isLoading = true;
      getAtSignError = '';
      AtContact contact = AtContact();
      setStatus(AddContacts, Status.Loading);

      checkAtSign = await backendService.checkAtsign(atSign);
      if (!checkAtSign) {
        getAtSignError = TextStrings().unknownAtsign(atSign);
        setError(AddContacts, '_error');
        isLoading = false;
      } else {
        contactList.forEach((element) async {
          if (element.atSign == atSign) {
            getAtSignError = TextStrings().atsignExists(atSign);
            isContactPresent = true;
            return true;
          }
          isLoading = false;
        });
      }
      if (!isContactPresent && checkAtSign) {
        var details = await backendService.getContactDetails(atSign);
        contact = AtContact(
          atSign: atSign,
          tags: details,
        );
        var result = await atContact
            .add(contact)
            .catchError((e) => print('error to add contact => $e'));
        print(result);
        isLoading = false;
        Navigator.pop(NavService.navKey.currentContext);
        await getContacts();
      }
      c.complete(true);
      isLoading = false;
      setStatus(AddContacts, Status.Done);
    } catch (e) {
      c.complete(true);
      setStatus(AddContacts, Status.Error);
    }
    return c.future;
  }
}
