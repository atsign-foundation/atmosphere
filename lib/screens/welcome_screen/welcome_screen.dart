import 'package:atsign_atmosphere_app/data_models/file_modal.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_app/screens/welcome_screen/widgets/select_file_widget.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/hive/hive_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'widgets/select_contact_widget.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isContactSelected;
  bool isFileSelected;
  ContactProvider contactProvider;
  BackendService backendService = BackendService.getInstance();
  HistoryProvider historyProvider;

  bool isDisposed = false;

  // 0-Sending, 1-Success, 2-Error
  List<Widget> transferStatus = [
    SizedBox(),
    Icon(
      Icons.check_circle,
      size: 13.toFont,
      color: ColorConstants.successColor,
    ),
    Icon(
      Icons.cancel,
      size: 13.toFont,
      color: ColorConstants.redText,
    )
  ];
  List<String> transferMessages = [
    'Sending file ...',
    'Sent the file',
    'Oops! something went wrong'
  ];

  @override
  void initState() {
    isContactSelected = false;
    isFileSelected = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      contactProvider?.getContacts();
      contactProvider?.fetchBlockContactList();
      historyProvider?.getSentHistory();
      historyProvider?.getRecievedHistory();
    });

    getCurrentAtSign();
    HiveService().init();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (contactProvider == null) {
      contactProvider = Provider.of<ContactProvider>(context);

      if (historyProvider != null) {
        historyProvider = Provider.of<HistoryProvider>(context);
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        contactProvider?.getContacts();
        contactProvider?.fetchBlockContactList();
        historyProvider?.getSentHistory();
        historyProvider?.getRecievedHistory();
      });
    }
    getCurrentAtSign();

    super.didChangeDependencies();
  }

  String currentAtsign;
  getCurrentAtSign() async {
    currentAtsign = await BackendService.getInstance().getAtSign();

    setState(() {});
  }

  Flushbar sendingFlushbar;
  _showScaffold({int status = 0}) {
    return Flushbar(
      title: transferMessages[status],
      message: 'hello',
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: ColorConstants.scaffoldColor,
      boxShadows: [
        BoxShadow(
            color: Colors.black, offset: Offset(0.0, 2.0), blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: Duration(seconds: 3),
      icon: Container(
        height: 40.toWidth,
        width: 40.toWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImageConstants.imagePlaceholder),
              fit: BoxFit.cover),
          shape: BoxShape.circle,
        ),
      ),

      mainButton: FlatButton(
        onPressed: () {
          sendingFlushbar.dismiss();
        },
        child: Text(
          TextStrings().buttonDismiss,
          style: TextStyle(color: ColorConstants.fontPrimary),
        ),
      ),
      // showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Row(
        children: <Widget>[
          transferStatus[status],
          Padding(
            padding: EdgeInsets.only(
              left: 5.toWidth,
            ),
            child: Text(
              transferMessages[status],
              style: TextStyle(
                  color: ColorConstants.fadedText, fontSize: 10.toFont),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filePickerModel = Provider.of<FilePickerProvider>(context);
    final contactPickerModel = Provider.of<ContactProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        showLeadingicon: true,
      ),
      endDrawer: SideBarWidget(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 26.toWidth, vertical: 20.toHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TextStrings().welcomeUser(currentAtsign),
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(
                    fontSize: 28.toFont,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(
                height: 10.toHeight,
              ),
              Text(
                TextStrings().welcomeRecipient,
                style: TextStyle(
                  color: ColorConstants.fadedText,
                  fontSize: 13.toFont,
                ),
              ),
              SizedBox(
                height: 67.toHeight,
              ),
              Text(
                TextStrings().welcomeSendFilesTo,
                style: TextStyle(
                  color: ColorConstants.fadedText,
                  fontSize: 12.toFont,
                ),
              ),
              SizedBox(
                height: 20.toHeight,
              ),
              SelectContactWidget(
                (b) {
                  setState(() {
                    isContactSelected = b;
                  });
                },
              ),
              SizedBox(
                height: 40.toHeight,
              ),
              SelectFileWidget(
                (b) {
                  setState(() {
                    isFileSelected = b;
                  });
                },
              ),
              SizedBox(
                height: 60.toHeight,
              ),
              if (contactProvider.selectedAtsign != null &&
                  filePickerModel.selectedFiles.isNotEmpty) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: CommonButton(
                    TextStrings().buttonSend,
                    () async {
                      // progressController = AnimationController(vsync: this);
                      sendingFlushbar = _showScaffold(status: 0);
                      await sendingFlushbar.show(context);
                      bool response = await backendService.sendFile(
                          contactPickerModel.selectedAtsign,
                          filePickerModel.selectedFiles[0].path);
                      print('RESPOSNE====>$response');

                      if (response == true) {
                        await sendingFlushbar.dismiss();

                        Provider.of<HistoryProvider>(context, listen: false)
                            .setFilesHistory(
                                atSignName: contactProvider.selectedAtsign,
                                historyType: HistoryType.send,
                                files: [
                              FilesDetail(
                                  filePath:
                                      filePickerModel.selectedFiles[0].path,
                                  size: filePickerModel.totalSize,
                                  fileName: filePickerModel.result.files[0].name
                                      .toString(),
                                  type: filePickerModel
                                      .selectedFiles[0].extension
                                      .toString())
                            ]);
                        sendingFlushbar = _showScaffold(status: 1);
                        await sendingFlushbar.show(context);
                      } else {
                        sendingFlushbar = _showScaffold(status: 2);
                        await sendingFlushbar.show(context);
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 60.toHeight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
