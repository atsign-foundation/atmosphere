import 'package:atsign_atmosphere_app/screens/blocked_users/widgets/blockusercard.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';

class BlockedUsers extends StatefulWidget {
  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  ContactProvider contactProvider;

  @override
  void initState() {
    super.initState();
    contactProvider = ContactProvider();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      contactProvider.fetchBlockContactList();
    });
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldColor,
      appBar: CustomAppBar(
        showBackButton: true,
        showTitle: true,
        title: 'Blocked User',
      ),
      body: RefreshIndicator(
        color: Colors.transparent,
        strokeWidth: 0,
        backgroundColor: Colors.transparent,
        onRefresh: () async {
          await providerCallback<ContactProvider>(context,
              task: (provider) => provider.fetchBlockContactList(),
              taskName: (provider) => provider.BlockedContacts,
              onSuccess: (provider) => print('object'),
              onErrorHandeling: () {
                //Navigator.pushNamed(context, Routes.WELCOME_SCREEN);
              },
              onError: (err) =>
                  ErrorDialog().show(err.toString(), context: context));
        },
        child: Container(
          color: ColorConstants.appBarColor,
          child: ProviderHandler<ContactProvider>(
            functionName: 'blocked_contacts',
            load: (provider) => provider.fetchBlockContactList(),
            showError: true,
            successBuilder: (provider) {
              return (provider.blockedContactList.isEmpty)
                  ? Center(
                      child: Container(
                        child: Text(
                          'No blocked users',
                          style: CustomTextStyles.blueRegular16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding:
                                EdgeInsets.symmetric(vertical: 40.toHeight),
                            itemCount: provider.blockedContactList.length,
                            separatorBuilder: (context, index) => Divider(
                              indent: 16.toWidth,
                            ),
                            itemBuilder: (context, index) => BlockedUserCard(
                                blockeduser:
                                    provider.blockedContactList[index]),
                          ),
                        ),
                      ],
                    );
            },
            errorBuilder: (provider) => Center(
              child: Text('Some error occured'),
            ),
          ),
        ),
      ),
    );
  }
}
