import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_flushbar.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:atsign_atmosphere_app/data_models/file_modal.dart';
import 'package:atsign_atmosphere_app/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_app/screens/receive_files/receive_files_alert.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:at_commons/at_commons.dart';
import 'navigation_service.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  String atSign;
  Function ask_user_acceptance;
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  final String AUTH_SUCCESS = "Authentication successful";

  String get currentAtsign => atSign;

  OutboundConnection monitorConnection;
  Directory downloadDirectory;
  double bytesReceived = 0.0;
  AnimationController controller;
  Map<String, AtClientService> atClientServiceMap = {};
  onboard({String atsign, atClientPreference, atClientServiceInstance}) async {
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    if (atClientServiceMap[atsign] == null) {
      final appSupportDirectory =
          await path_provider.getApplicationSupportDirectory();
      print("paths => $downloadDirectory $appSupportDirectory");
    }
    await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference, atsign: atsign);
    atClientInstance = atClientServiceInstance.atClient;
  }

  Future<AtClientPreference> getAtClientPreference() async {
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..downloadPath = downloadDirectory.path
      ..namespace = MixedConstants.appNamespace
      ..syncStrategy = SyncStrategy.IMMEDIATE
      ..syncRegex = MixedConstants.regex
      ..rootDomain = MixedConstants.ROOT_DOMAIN
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    await getAtClientPreference().then((value) {
      return atClientPreference = value;
    });

    atClientServiceInstance = AtClientService();

    return await atClientServiceInstance.getAtSign();
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await atClientServiceInstance.getPublicKey(atsign);
  }

  Future<String> getAESKey(String atsign) async {
    return await atClientServiceInstance.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    return await atClientServiceInstance.getEncryptedKeys(atsign);
  }

  AtClientImpl getAtClientForAtsign({String atsign}) {
    atsign ??= atSign;

    if (atClientServiceMap.containsKey(atsign)) {
      atClientInstance = atClientServiceMap[atsign].atClient;
      return atClientServiceMap[atsign].atClient;
    }

    return null;
  }

  // startMonitor needs to be c`alled at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor({value, atsign}) async {
    if (value != null && value.containsKey(atsign)) {
      atSign = atsign;
      atClientServiceMap = value;
      atClientInstance = value[atsign].atClient;
      atClientServiceInstance = value[atsign];
    }

    await atClientServiceMap[atsign].makeAtSignPrimary(atsign);
    await Provider.of<ContactProvider>(NavService.navKey.currentContext,
            listen: false)
        .initContactImpl();
    String privateKey = await getPrivateKey(atsign);

    await atClientInstance.startMonitor(privateKey, _notificationCallBack);

    return true;
  }

  var fileLength;
  var userResponse = false;
  Future<void> _notificationCallBack(var response) async {
    print('response => $response');
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var notificationKey = responseJson['key'];
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    atKey = atKey.replaceFirst(fromAtSign, '');
    atKey = atKey.trim();
    if (atKey == 'stream_id') {
      var valueObject = responseJson['value'];
      var streamId = valueObject.split(':')[0];
      var fileName = valueObject.split(':')[1];
      fileLength = valueObject.split(':')[2];
      fileName = utf8.decode(base64.decode(fileName));
      userResponse = await acceptStream(fromAtSign, fileName, fileLength);
      if (userResponse == true) {
        await atClientInstance.sendStreamAck(
            streamId,
            fileName,
            int.parse(fileLength),
            fromAtSign,
            _streamCompletionCallBack,
            _streamReceiveCallBack);
      }
    }
  }

  Flushbar receivingFlushbar;
  void _streamCompletionCallBack(var streamId) {
    receivingFlushbar =
        CustomFlushBar().getFlushbar(TextStrings().fileReceived, null);

    receivingFlushbar.show(NavService.navKey.currentContext);
  }

  void _streamReceiveCallBack(var bytesReceived) {
    if (controller != null) {
      controller.value = bytesReceived / double.parse(fileLength.toString());

      if (controller.value == 1) {
        if (Navigator.canPop(NavService.navKey.currentContext)) {
          Navigator.pop(NavService.navKey.currentContext);
        }
      }
    }
  }

  // send a file
  Future<bool> sendFile(String atSign, String filePath) async {
    if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    print("Sending file => $atSign $filePath");
    var result = await atClientInstance.stream(atSign, filePath);
    print("sendfile result => $result");
    if (result.status.toString() == 'AtStreamStatus.COMPLETE') {
      return true;
    } else {
      return false;
    }
  }

  void downloadCompletionCallback({bool downloadCompleted, filePath}) {}

  // acknowledge file transfer
  Future<bool> acceptStream(
      String atsign, String filename, String filesize) async {
    print("from:$atsign file:$filename size:$filesize");
    if (atsign != atSign) {
      BuildContext context = NavService.navKey.currentContext;
      ContactProvider contactProvider =
          Provider.of<ContactProvider>(context, listen: false);

      for (AtContact blockeduser in contactProvider.blockedContactList) {
        if (atsign == blockeduser.atSign) {
          return false;
        }
      }

      if (!autoAcceptFiles &&
          app_lifecycle_state != null &&
          app_lifecycle_state != AppLifecycleState.resumed.toString()) {
        print("app not active $app_lifecycle_state");
        await NotificationService()
            .showNotification(atsign, filename, filesize);
      }
      NotificationPayload payload = NotificationPayload(
          file: filename, name: atsign, size: double.parse(filesize));

      bool userAcceptance;
      if (autoAcceptFiles) {
        Provider.of<HistoryProvider>(context, listen: false).setFilesHistory(
            atSignName: payload.name.toString(),
            historyType: HistoryType.received,
            files: [
              FilesDetail(
                  filePath:
                      atClientPreference.downloadPath + '/' + payload.file,
                  size: payload.size,
                  fileName: payload.file,
                  type:
                      payload.file.substring(payload.file.lastIndexOf('.') + 1))
            ]);
        userAcceptance = true;
      } else {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ReceiveFilesAlert(
            payload: jsonEncode(payload),
            sharingStatus: (s) {
              userAcceptance = s;
              print('STATUS====>$s');
            },
          ),
        );
      }
      return userAcceptance;
    }
  }

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  Future<List<String>> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList;
  }

  deleteAtSignFromKeyChain(String atsign) async {
    List<String> atSignList = await getAtsignList();
    await atClientServiceMap[atsign]?.deleteAtSignFromKeychain(atsign);
    atSignList.removeWhere((element) => element == atsign);

    var atClientPrefernce;
    await getAtClientPreference().then((value) => atClientPrefernce = value);

    if (atSignList.isNotEmpty) {
      await CustomOnboarding.onboard(
          atSign: atSignList.first, atClientPrefernce: atClientPrefernce);
    }
  }

  Future<bool> checkAtsign(String atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var checkPresence = await AtLookupImpl.findSecondary(
        atSign, MixedConstants.ROOT_DOMAIN, AtClientPreference().rootPort);
    return checkPresence != null;
  }

  Future<Map<String, dynamic>> getContactDetails(String atSign) async {
    Map<String, dynamic> contactDetails = {};
    if (atSign == null) {
      return contactDetails;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var metadata = Metadata();
    metadata.isPublic = true;
    metadata.namespaceAware = false;
    AtKey key = AtKey();
    key.sharedBy = atSign;
    key.metadata = metadata;
    List contactFields = TextStrings().contactFields;

    try {
      // firstname
      key.key = contactFields[0];
      var result = await atClientInstance
          .get(key)
          .catchError((e) => print("error in get ${e.toString()}"));
      var firstname = result.value;

      // lastname
      key.key = contactFields[1];
      result = await atClientInstance.get(key);
      var lastname = result.value;

      var name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
      if (name.length == 0) {
        name = atSign.substring(1);
      }

      // image
      key.metadata.isBinary = true;
      key.key = contactFields[2];
      result = await atClientInstance.get(key);
      var image = result.value;
      contactDetails['name'] = name;
      contactDetails['image'] = image;
    } catch (e) {
      contactDetails['name'] = null;
      contactDetails['image'] = null;
    }
    return contactDetails;
  }

  String state;
  NotificationService _notificationService;
  void initBackendService() async {
    _notificationService = NotificationService();
    _notificationService.cancelNotifications();
    _notificationService.setOnNotificationClick(onNotificationClick);

    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('set message handler');
      state = msg;
      debugPrint('SystemChannels> $msg');
      app_lifecycle_state = msg;

      return null;
    });
  }

  onNotificationClick(String payload) async {}
}
