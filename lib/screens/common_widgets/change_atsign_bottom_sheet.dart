import 'dart:math';

import 'package:atsign_atmosphere_app/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String> atSignList;
  final Function showLoader;
  AtSignBottomSheet({Key key, this.atSignList, this.showLoader})
      : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  BackendService backendService = BackendService.getInstance();
  bool isLoading = false;
  var atClientPreferenceLocal;
  @override
  Widget build(BuildContext context) {
    backendService
        .getAtClientPreference()
        .then((value) => atClientPreferenceLocal = value);
    Random r = Random();
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: BottomSheet(
            onClosing: () {},
            backgroundColor: Colors.transparent,
            builder: (context) => ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Container(
                height: 100,
                width: SizeConfig().screenWidth,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.atSignList.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: isLoading
                            ? () {}
                            : () async {
                                if (mounted) {
                                  setState(() {
                                    isLoading = true;
                                    Navigator.pop(context);
                                  });
                                }
                                await CustomOnboarding.onboard(
                                    atSign: widget.atSignList[index],
                                    atClientPrefernce: atClientPreferenceLocal,
                                    showLoader: widget.showLoader);

                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: Column(
                            children: [
                              ContactInitial(
                                initials: widget.atSignList[index],
                              ),
                              Text(widget.atSignList[index])
                            ],
                          ),
                        ),
                      ),
                    )),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                          // Navigator.pop(context);
                        });
                        await CustomOnboarding.onboard(
                            atSign: "",
                            atClientPrefernce: atClientPreferenceLocal,
                            showLoader: widget.showLoader);

                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.orange,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        isLoading
            ? Center(
                child: Column(
                  children: [
                    Text(
                      'Switching atsign...',
                      style: CustomTextStyles.orangeMedium16,
                    ),
                    SizedBox(height: 10),
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ColorConstants.redText)),
                  ],
                ),
              )
            : SizedBox(
                height: 100,
              ),
      ],
    );
  }
}
