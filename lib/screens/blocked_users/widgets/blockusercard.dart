import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlockedUserCard extends StatefulWidget {
  final AtContact blockeduser;

  const BlockedUserCard({Key key, this.blockeduser}) : super(key: key);
  @override
  State<BlockedUserCard> createState() => _BlockedUserCardState();
}

class _BlockedUserCardState extends State<BlockedUserCard> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    Widget contactImage;
    if (widget.blockeduser.tags != null &&
        widget.blockeduser.tags['image'] != null) {
      List<int> intList = widget.blockeduser.tags['image'].cast<int>();
      Uint8List image = Uint8List.fromList(intList);
      contactImage = CustomCircleAvatar(
        byteImage: image,
        nonAsset: true,
      );
    } else {
      contactImage = CustomCircleAvatar(
        image: ImageConstants.imagePlaceholder,
      );
    }
    return ListTile(
      leading: contactImage,
      title: Container(
        width: 300.toWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.blockeduser.tags != null &&
                      widget.blockeduser.tags['name'] != null
                  ? widget.blockeduser.tags['name']
                  : widget.blockeduser.atSign.substring(1),
              style: CustomTextStyles.primaryRegular16,
            ),
            Text(
              widget.blockeduser.atSign.toString(),
              style: CustomTextStyles.secondaryRegular12,
            ),
          ],
        ),
      ),
      trailing: GestureDetector(
        onTap: () {
          Provider.of<ContactProvider>(context, listen: false)
              .blockUnblockContact(
                  contact: widget.blockeduser, blockAction: false);
        },
        child: Container(
          child: Text(
            'Unblock',
            style: CustomTextStyles.blueRegular14,
          ),
        ),
      ),
    );
  }
}
