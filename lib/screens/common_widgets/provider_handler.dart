/// This is a custom widget to handle states from view models
/// This takes in a [functionName] as a String to render only function which is called,
/// a [successBuilder] which tells what to render is status is [Status.done]
/// [Status.loading] renders a CircularProgressIndicator whereas
/// [Status.error] renders [errorBuilder]
import 'package:atsign_atmosphere_app/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class ProviderHandler<T extends BaseModel> extends StatelessWidget {
  final Widget Function(T) successBuilder;
  final Widget Function(T) errorBuilder;
  final String functionName;
  final bool showError;
  final Function(T) load;

  const ProviderHandler(
      {Key key,
      this.successBuilder,
      this.errorBuilder,
      this.functionName,
      this.showError = false,
      this.load})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, provider, __) {
      //  String _statusString = functionName(_provider);
      print(
          '_provider?.status[functionName]=====>${provider?.status[functionName]}========>$functionName=======>before');
      if (provider?.status[functionName] == Status.loading) {
        return Center(
          child: Container(
            height: 50.toHeight,
            width: 50.toHeight,
            child: CircularProgressIndicator(),
          ),
        );
      } else if (provider?.status[functionName] == Status.error) {
        print(
            '_provider?.status[functionName]=====>${provider?.status[functionName]}========>$functionName');
        if (showError) {
          print('IN SHOW ERROR');
          ErrorDialog()
              .show(provider.error[functionName].toString(), context: context);
          provider.reset(functionName);
          return SizedBox();
        } else {
          provider.reset(functionName);
          return errorBuilder(provider);
        }
      } else if (provider?.status[functionName] == Status.done) {
        return successBuilder(provider);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await load(provider);
        });
        return Center(
          child: Container(
            height: 50.toHeight,
            width: 50.toHeight,
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }
}
