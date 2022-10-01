import 'package:flutter/material.dart';

class BaseModel with ChangeNotifier {
  Map<String, Status> status = {'main': Status.idle};
  Map<String, String> error = {};
  setStatus(String function, Status status) {
    this.status[function] = status;
    notifyListeners();
  }

  setError(String function, String localError, [Status localStatus]) {
    if (localError != null) {
      error[function] = localError;
      status[function] = Status.error;
    } else {
      error[function] = null;
      status[function] = localStatus ?? Status.idle;
    }
    notifyListeners();
  }

  reset(String function) {
    data?.remove(function);
    error?.remove(function);
    status?.remove(function);
  }

  // used while fetching the count
  bool isCountLoading = true;
  // used for pagination calculation
  int pageNumber;
  // used while fetching next page
  bool isNextPageLoading = true;
  // used for storing the response body
  Map<String, dynamic> data;
  // used for displaying the exceptions during API calls
  String errorMessage;
  // for search screen loader
  // bool isPostLoading = true;
  // bool isUserLoading = true;
  // bool hasError = false;
  // bool netwotkIssue = false;
}

enum Status { loading, done, error, idle }
