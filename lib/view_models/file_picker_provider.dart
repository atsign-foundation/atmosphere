import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' show basename;

class FilePickerProvider extends BaseModel {
  FilePickerProvider._();
  static final FilePickerProvider _instance = FilePickerProvider._();
  factory FilePickerProvider() => _instance;
  String pickFilesString = 'pick_files';
  String videoThumbnailString = 'video_thumbnail';
  String acceptFilesString = 'accept_files';
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  FilePickerResult result;
  PlatformFile file;
  static List<PlatformFile> appClosedSharedFiles = [];
  List<PlatformFile> selectedFiles = [];
  Uint8List videoThumbnail;
  double totalSize = 0;
  final String mediaString = 'MEDIA';
  final String filesString = 'FILES';

  @override
  void dispose() {
    super.dispose();
    _intentDataStreamSubscription.cancel();
  }

  setFiles() async {
    setStatus(pickFilesString, Status.loading);
    try {
      selectedFiles = [];
      totalSize = 0;
      if (appClosedSharedFiles.isNotEmpty) {
        print('IN ! HERE');
        for (var element in appClosedSharedFiles) {
          print('IN HERE @');
          selectedFiles.add(element);
        }
        calculateSize();
      }
      appClosedSharedFiles = [];
      setStatus(pickFilesString, Status.done);
    } catch (error) {
      setError(pickFilesString, error.toString());
    }
  }

  pickFiles(String choice) async {
    setStatus(pickFilesString, Status.loading);
    try {
      List<PlatformFile> tempList = [];
      if (selectedFiles.isNotEmpty) {
        tempList = selectedFiles;
      }
      selectedFiles = [];

      totalSize = 0;

      result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: choice == mediaString ? FileType.media : FileType.any,
          allowCompression: true,
          withData: true);

      if (result?.files != null) {
        selectedFiles = tempList;
        tempList = [];
        selectedFiles = [];
        for (var element in result.files) {
          selectedFiles.add(element);
        }
        if (appClosedSharedFiles.isNotEmpty) {
          for (var element in appClosedSharedFiles) {
            selectedFiles.add(element);
          }
        }
      }

      calculateSize();

      setStatus(pickFilesString, Status.done);
    } catch (error) {
      setError(pickFilesString, error.toString());
    }
  }

  calculateSize() async {
    totalSize = 0;
    for (var element in selectedFiles) {
      totalSize += element.size;
    }
  }

  void acceptFiles() async {
    setStatus(acceptFilesString, Status.loading);
    try {
      _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
          .listen((List<SharedMediaFile> value) async {
        _sharedFiles = value;

        if (value.isNotEmpty) {
          for (var element in value) {
            File file = File(element.path);
            double length = await file.length() / 1024;
            selectedFiles.add(PlatformFile(
                name: basename(file.path),
                path: file.path,
                size: length.round(),
                bytes: await file.readAsBytes()));
            await calculateSize();
          }

          print("Shared:${_sharedFiles?.map((f) => f.path)?.join(",") ?? ""}");
        }
      }, onError: (err) {
        print("getIntentDataStream error: $err");
      });

      // For sharing images coming from outside the app while the app is closed
      await ReceiveSharingIntent.getInitialMedia()
          .then((List<SharedMediaFile> value) async {
        _sharedFiles = value;
        if (_sharedFiles != null && _sharedFiles.isNotEmpty) {
          for (var element in _sharedFiles) {
            var test = File(element.path);
            var length = await test.length() / 1024;
            selectedFiles.add(PlatformFile(
                name: basename(test.path),
                path: test.path,
                size: length.round(),
                bytes: await test.readAsBytes()));
            await calculateSize();
          }
          print("Shared:${_sharedFiles?.map((f) => f.path)?.join(",") ?? ""}");
          BuildContext c = NavService.navKey.currentContext;
          Navigator.pushReplacementNamed(c, Routes.welcomeScreen);
        }
      });
      setStatus(acceptFilesString, Status.done);
    } catch (error) {
      setError(acceptFilesString, error.toString());
    }
  }
}
