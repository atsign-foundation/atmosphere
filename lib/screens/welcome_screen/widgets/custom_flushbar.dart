import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';

class CustomFlushBar extends StatefulWidget {
  final String message;
  final Widget status;

  const CustomFlushBar({
    Key key,
    this.message,
    this.status,
  }) : super(key: key);
  @override
  _CustomFlushBarState createState() => _CustomFlushBarState();
}

class _CustomFlushBarState extends State<CustomFlushBar>
    with TickerProviderStateMixin {
  AnimationController flushbarController;
  @override
  void initState() {
    flushbarController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flushbar(
      title: widget.message,
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
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      progressIndicatorController: flushbarController,
      mainButton: FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "Dismiss",
          style: TextStyle(color: ColorConstants.fontPrimary),
        ),
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Row(
        children: <Widget>[
          widget.status,
          Padding(
            padding: EdgeInsets.only(
              left: 5.toWidth,
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                  color: ColorConstants.fadedText, fontSize: 10.toFont),
            ),
          )
        ],
      ),
    );
  }
}
