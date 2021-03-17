import 'dart:async';
import 'dart:io';
import 'package:atsign_atmosphere_app/screens/common_widgets/change_atsign_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/welcome_screen/welcome_screen.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show basename;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  NotificationService _notificationService;
  bool onboardSuccess = false;
  bool sharingStatus = false;
  BackendService backendService;
  var atClientPrefernce;

  // bool userAcceptance;
  final Permission _cameraPermission = Permission.camera;
  final Permission _storagePermission = Permission.storage;
  Completer c = Completer();
  bool authenticating = false;
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  FilePickerProvider filePickerProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    filePickerProvider =
        Provider.of<FilePickerProvider>(context, listen: false);
    _notificationService = NotificationService();
    backendService = BackendService.getInstance();

    backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    _checkToOnboard();
    // });
    acceptFiles();

    _checkForPermissionStatus();
  }

  void acceptFiles() async {
    _intentDataStreamSubscription = await ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) async {
      _sharedFiles = value;

      if (value.isNotEmpty) {
        value.forEach((element) async {
          File file = File(element.path);
          double length = await file.length() / 1024;
          await FilePickerProvider.appClosedSharedFiles.add(PlatformFile(
              name: basename(file.path),
              path: file.path,
              size: length.round(),
              bytes: await file.readAsBytes()));
          await filePickerProvider.setFiles();
        });

        print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        // check to see if atsign is paired
        var atsign = await backendService.currentAtsign;
        if (atsign != null) {
          BuildContext c = NavService.navKey.currentContext;
          await Navigator.pushNamedAndRemoveUntil(
              c, Routes.WELCOME_SCREEN, (route) => false);
        }
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    await ReceiveSharingIntent.getInitialMedia().then(
        (List<SharedMediaFile> value) async {
      _sharedFiles = value;
      if (_sharedFiles != null && _sharedFiles.isNotEmpty) {
        _sharedFiles.forEach((element) async {
          File file = File(element.path);
          var length = await file.length() / 1024;
          PlatformFile fileToBeAdded = PlatformFile(
              name: basename(file.path),
              path: file.path,
              size: length.round(),
              bytes: await file.readAsBytes());
          FilePickerProvider.appClosedSharedFiles.add(fileToBeAdded);
          filePickerProvider.setFiles();
        });

        print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
      }
    }, onError: (error) {
      print('ERROR IS HERE=========>$error');
    });
  }

  String state;
  void _initBackendService() async {
    backendService = BackendService.getInstance();
    _notificationService.setOnNotificationClick(onNotificationClick);

    await backendService.getAtClientForAtsign(
        atsign: await backendService.getAtSign());

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      state = msg;

      debugPrint('SystemChannels> $msg');
      backendService.app_lifecycle_state = msg;
    });
  }

  void _checkToOnboard() async {
    authenticating = true;
    String currentatSign = await backendService.getAtSign();

    if (currentatSign == null || currentatSign == '') {
    } else {
      await Onboarding(
        atsign: currentatSign,
        context: context,
        atClientPreference: atClientPrefernce,
        domain: MixedConstants.ROOT_DOMAIN,
        appColor: Color.fromARGB(255, 240, 94, 62),
        onboard: (value, atsign) async {
          await backendService.startMonitor(atsign: atsign, value: value);
          _initBackendService();
          authenticating = false;
          setState(() {});

          await Navigator.pushNamedAndRemoveUntil(
              context, Routes.WELCOME_SCREEN, (Route<dynamic> route) => false);
        },
        onError: (error) {
          print('Onboarding throws $error error');
        },
        // nextScreen: WelcomeScreen(),
      );
    }
  }

  void _checkForPermissionStatus() async {
    final existingCameraStatus = await _cameraPermission.status;
    if (existingCameraStatus != PermissionStatus.granted) {
      await _cameraPermission.request();
    }
    final existingStorageStatus = await _storagePermission.status;
    if (existingStorageStatus != PermissionStatus.granted) {
      await _storagePermission.request();
    }
  }

  onNotificationClick(String payload) async {
    // this popup added to accept stream to await answer
    // BuildContext c = NavService.navKey.currentContext;
    // print('Payload $payload');
    // bool userAcceptance = null;
    // await showDialog(
    //   context: c,
    //   builder: (c) => ReceiveFilesAlert(
    //     payload: payload,
    //     sharingStatus: (s) {
    //       // sharingStatus = s;
    //       userAcceptance = s;
    //       print('STATUS====>$s');
    //     },
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // bottomSheet: AtSignBottomSheet(),
      body: Stack(
        children: [
          Container(
            width: SizeConfig().screenWidth,
            height: SizeConfig().screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.welcomeBackground,
                ),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 10.toWidth,
                          top: 10.toHeight,
                        ),
                        child: Image.asset(
                          ImageConstants.logoIcon,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 36.toWidth,
                        vertical: 10.toHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text(
                              TextStrings().homeFileTransferItsSafe,
                              style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                  fontSize: 38.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text.rich(
                              TextSpan(
                                text: TextStrings().homeHassleFree,
                                style: TextStyle(
                                  fontSize: 15.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: TextStrings().homeWeWillSetupAccount,
                                    style: TextStyle(
                                      color: ColorConstants.fadedText,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: CustomButton(
                                buttonText: TextStrings().buttonStart,
                                onPressed: authenticating
                                    ? () {}
                                    : () async {
                                        authenticating = true;

                                        await Onboarding(
                                          atsign:
                                              await backendService.getAtSign(),
                                          context: context,
                                          atClientPreference: atClientPrefernce,
                                          domain: MixedConstants.ROOT_DOMAIN,
                                          appColor:
                                              Color.fromARGB(255, 240, 94, 62),
                                          onboard: (value, atsign) async {
                                            await backendService.startMonitor(
                                                atsign: atsign, value: value);
                                            authenticating = false;
                                            setState(() {});
                                            await Navigator
                                                .pushNamedAndRemoveUntil(
                                                    context,
                                                    Routes.WELCOME_SCREEN,
                                                    (Route<dynamic> route) =>
                                                        false);
                                          },
                                          onError: (error) {
                                            print(
                                                'Onboarding throws $error error');
                                          },
                                          // nextScreen: WelcomeScreen(),
                                        );
                                        setState(() {});
                                      },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          authenticating
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.redText)),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
