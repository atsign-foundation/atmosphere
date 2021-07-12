/// This widgets pops up when a contact is added it takes [name]
/// [handle] to display the name and the handle of the user and an
/// onTap function named as [onYesTap] for on press of [Yes] button of the dialog

import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:provider/provider.dart';

class AddHistoryContactDialog extends StatefulWidget {
  final String atSignName;
  final ContactProvider contactProvider;

  const AddHistoryContactDialog(
      {Key key, this.atSignName, this.contactProvider})
      : super(key: key);

  @override
  _AddHistoryContactDialogState createState() =>
      _AddHistoryContactDialogState();
}

class _AddHistoryContactDialogState extends State<AddHistoryContactDialog> {
  bool isContactAdding = false;

  addtoContact(context) async {
    await widget.contactProvider.addContact(atSign: widget.atSignName);
    Provider.of<HistoryProvider>(context, listen: false).notify();
    setState(() {
      isContactAdding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<ContactProvider>(
      functionName: widget.contactProvider.Contacts,
      errorBuilder: (provider) => Center(
        child: Text('Some error occured'),
      ),
      load: (provider) {},
      successBuilder: (provider) {
        return Container(
          height: 100,
          width: 100,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth)),
            titlePadding: EdgeInsets.only(
                top: 20.toHeight, left: 25.toWidth, right: 25.toWidth),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    TextStrings().addContactHeading,
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.secondaryRegular16,
                  ),
                )
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 190.toHeight),
              child: Column(
                children: [
                  SizedBox(
                    height: 21.toHeight,
                  ),
                  CustomCircleAvatar(
                    image: ImageConstants.imagePlaceholder,
                    size: 75,
                  ),
                  SizedBox(
                    height: 10.toHeight,
                  ),
                  Text(
                    widget.atSignName ?? 'Unknown',
                    style: CustomTextStyles.primaryBold16,
                  ),
                  SizedBox(
                    height: 2.toHeight,
                  ),
                  Text(
                    (widget.atSignName ?? ''),
                    style: CustomTextStyles.secondaryRegular16,
                  ),
                ],
              ),
            ),
            actionsPadding: EdgeInsets.only(left: 20, right: 20),
            actions: [
              isContactAdding
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      width: SizeConfig().screenWidth,
                      child: CustomButton(
                        buttonText: TextStrings().yes,
                        onPressed: () {
                          setState(() {
                            isContactAdding = true;
                          });
                          return addtoContact(context);
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
                    buttonText: TextStrings().no,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}
