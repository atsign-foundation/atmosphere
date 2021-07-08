import 'dart:convert';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/data_models/file_modal.dart';
import 'package:atsign_atmosphere_app/data_models/notification_payload.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_flushbar.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:provider/provider.dart';

class ReceiveFilesAlert extends StatefulWidget {
  final Function() onAccept;
  final String payload;
  final Function(bool) sharingStatus;
  const ReceiveFilesAlert(
      {Key key, this.onAccept, this.payload, this.sharingStatus})
      : super(key: key);

  @override
  _ReceiveFilesAlertState createState() => _ReceiveFilesAlertState();
}

class _ReceiveFilesAlertState extends State<ReceiveFilesAlert>
    with TickerProviderStateMixin {
  AnimationController progressController;
  NotificationPayload payload;
  bool status = false;
  BackendService backendService = BackendService.getInstance();
  ContactProvider contactProvider;
  Flushbar f;
  @override
  void initState() {
    Map<String, dynamic> test =
        jsonDecode(widget.payload) as Map<String, dynamic>;
    payload = NotificationPayload.fromJson(test);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (contactProvider == null) {
      contactProvider = Provider.of<ContactProvider>(context);
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print("payload => ${widget.payload}");
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.toWidth)),
      titlePadding: EdgeInsets.only(top: 10.toHeight, left: 10.toWidth),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 42.toHeight,
            width: 42.toWidth,
            child: Image.asset(ImageConstants.logoIcon),
          ),
          GestureDetector(
            onTap: () {
              contactProvider.blockUnblockContact(
                  contact: AtContact(atSign: payload.name), blockAction: true);
              status = false;
              NotificationService().cancelNotifications();
              widget.sharingStatus(status);
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: 15.toWidth),
              child: Text(
                TextStrings().blockUser,
                style: CustomTextStyles.blueMedium16,
              ),
            ),
          )
        ],
      ),
      content: Container(
        height: 180.toHeight,
        child: Column(
          children: [
            SizedBox(
              height: 21.toHeight,
            ),
            Center(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomCircleAvatar(
                      image: ImageConstants.imagePlaceholder,
                    ),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          // text: '@levinat',
                          text: payload.name,
                          style: CustomTextStyles.primaryBold14,
                          children: [
                            TextSpan(
                              text: TextStrings().acceptQuestion,
                              style: CustomTextStyles.primaryRegular16,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 13.toHeight,
            ),
            SizedBox(
              height: 13.toHeight,
            ),
            Text(payload.file),
            Container(
              width: 100.toWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            double.parse(payload.size.toString()) <=
                                    1048576 //1024 * 1024 bytes
                                ? '${(payload.size / 1024).toStringAsFixed(2)} Kb'
                                : '${(payload.size / 1048576).toStringAsFixed(2)} Mb',
                            style: CustomTextStyles.secondaryRegular14,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.only(left: 20, right: 20),
      actions: [
        SizedBox(
          width: SizeConfig().screenWidth,
          child: CustomButton(
            buttonText: TextStrings().accept,
            onPressed: () {
              progressController = AnimationController(vsync: this);
              backendService.controller = progressController;
              Provider.of<HistoryProvider>(context, listen: false)
                  .setFilesHistory(
                      atSignName: payload.name.toString(),
                      historyType: HistoryType.received,
                      files: [
                    FilesDetail(
                        filePath:
                            backendService.atClientPreference.downloadPath +
                                '/' +
                                payload.file,
                        size: payload.size,
                        fileName: payload.file,
                        type: payload.file
                            .substring(payload.file.lastIndexOf('.') + 1))
                  ]);

              status = true;
              widget.onAccept;
              NotificationService().cancelNotifications();
              Navigator.pop(context);
              widget.sharingStatus(status);
              f = CustomFlushBar().getFlushbar(
                TextStrings().receivingFile,
                progressController,
                shouldTimeout: false,
              );

              f.show(context);
            },
          ),
        ),
        SizedBox(
          height: 10.toHeight,
        ),
        SizedBox(
          width: SizeConfig().screenWidth,
          child: CustomButton(
            isInverted: true,
            buttonText: TextStrings().reject,
            onPressed: () {
              status = false;
              NotificationService().cancelNotifications();
              Navigator.pop(context);
              widget.sharingStatus(status);
            },
          ),
        ),
      ],
    );
  }
}
