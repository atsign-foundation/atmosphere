import 'package:atsign_atmosphere_app/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/loading_widget.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future providerCallback<T extends BaseModel>(BuildContext context,
    {@required final Function(T) task,
    @required final String Function(T) taskName,
    @required Function(T) onSuccess,
    bool showDialog = true,
    bool showLoader = true,
    Function onErrorHandeling,
    Function onError}) async {
  final T provider = Provider.of<T>(context, listen: false);
  String localTaskName = taskName(provider);

  if (showLoader) LoadingDialog().show();
  await Future.microtask(() => task(provider));
  if (showLoader) LoadingDialog().hide();
  print(
      'status before=====>_provider.status[_taskName]====>${provider.status[localTaskName]}');
  if (provider.status[localTaskName] == Status.error) {
    if (showDialog) {
      ErrorDialog().show(
        provider.error[localTaskName].toString(),
        context: context,
        onButtonPressed: onErrorHandeling,
      );
    }

    if (onError != null) onError(provider);

    provider.reset(localTaskName);
    print(
        'status before=====>_provider.status[_taskName]====>${provider.status[localTaskName]}');
  } else if (provider.status[localTaskName] == Status.done) {
    onSuccess(provider);
  }
}
