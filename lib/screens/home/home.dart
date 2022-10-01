import 'dart:async';
import 'dart:io';
import 'package:at_client/at_client.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';

import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' show basename;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool onboardSuccess = false;
  bool sharingStatus = false;
  BackendService backendService;
  AtClientPreference atClientPreference;

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

    backendService = BackendService.getInstance();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    _checkToOnboard();
    // });
    acceptFiles();

    _checkForPermissionStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _intentDataStreamSubscription.cancel();
  }

  void acceptFiles() async {
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) async {
      _sharedFiles = value;

      if (value.isNotEmpty) {
        for (var element in value) {
          File file = File(element.path);
          double length = await file.length() / 1024;
          FilePickerProvider.appClosedSharedFiles.add(PlatformFile(
              name: basename(file.path),
              path: file.path,
              size: length.round(),
              bytes: await file.readAsBytes()));
          await filePickerProvider.setFiles();
        }

        print("Shared:${_sharedFiles?.map((f) => f.path)?.join(",") ?? ""}");
        // check to see if atsign is paired
        var atsign = backendService.currentAtsign;
        if (atsign != null) {
          BuildContext c = NavService.navKey.currentContext;
          await Navigator.pushNamedAndRemoveUntil(
              c, Routes.welcomeScreen, (route) => false);
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
        for (var element in _sharedFiles) {
          File file = File(element.path);
          var length = await file.length() / 1024;
          PlatformFile fileToBeAdded = PlatformFile(
              name: basename(file.path),
              path: file.path,
              size: length.round(),
              bytes: await file.readAsBytes());
          FilePickerProvider.appClosedSharedFiles.add(fileToBeAdded);
          filePickerProvider.setFiles();
        }

        print("Shared:${_sharedFiles?.map((f) => f.path)?.join(",") ?? ""}");
      }
    }, onError: (error) {
      print('ERROR IS HERE=========>$error');
    });
  }

  void showLoader(bool loaderState) {
    setState(() {
      authenticating = loaderState;
    });
  }

  void _checkToOnboard() async {
    String currentatSign = await backendService.getAtSign();
    await backendService
        .getAtClientPreference()
        .then((value) => atClientPreference = value)
        .catchError((e) async {
      print(e);
      return atClientPreference;
    });

    if (currentatSign != null && currentatSign != '') {
      await CustomOnboarding.onboard(
          atSign: currentatSign,
          atClientPreference: atClientPreference,
          showLoader: showLoader);
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
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
                                        setState(() {});

                                        await CustomOnboarding.onboard(
                                            atSign: "",
                                            atClientPreference:
                                                atClientPreference,
                                            showLoader: showLoader);
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
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorConstants.redText)),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Logging in',
                            style: CustomTextStyles.orangeMedium16,
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : SizedBox()
        ],
      ),
    );
  }
}
