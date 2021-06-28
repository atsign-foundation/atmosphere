import 'dart:io';
import 'dart:typed_data';
import 'package:atsign_atmosphere_app/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/file_types.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SelectFileWidget extends StatefulWidget {
  final Function(bool) onUpdate;
  SelectFileWidget(this.onUpdate);
  @override
  _SelectFileWidgetState createState() => _SelectFileWidgetState();
}

class _SelectFileWidgetState extends State<SelectFileWidget> {
  bool isLoading = false;

  Uint8List videoThumbnail;
  FilePickerProvider filePickerProvider;
  Future videoThumbnailBuilder(String path) async {
    videoThumbnail = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          50, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return videoThumbnail;
  }

  @override
  void initState() {
    filePickerProvider =
        Provider.of<FilePickerProvider>(context, listen: false);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (filePickerProvider == null) {
      filePickerProvider =
          Provider.of<FilePickerProvider>(context, listen: false);
      await filePickerProvider.setFiles();
    }
    super.didChangeDependencies();
  }

  void _showFileChoice() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              height: 200.0.toHeight,
              width: 300.0.toWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  Text(
                    TextStrings().fileChoiceQuestion,
                    style: CustomTextStyles.primaryBold16,
                  ),
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        providerCallback<FilePickerProvider>(context,
                            task: (provider) =>
                                provider.pickFiles(provider.MEDIA),
                            taskName: (provider) => provider.PICK_FILES,
                            onSuccess: (provider) {},
                            onError: (err) => ErrorDialog()
                                .show(err.toString(), context: context));
                      },
                      child: Row(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 30.toWidth),
                          child: Icon(Icons.camera, size: 30),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 20.toWidth),
                            child: Text(
                              TextStrings().choice1,
                              style: CustomTextStyles.primaryBold14,
                            ))
                      ])),
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        providerCallback<FilePickerProvider>(context,
                            task: (provider) =>
                                provider.pickFiles(provider.FILES),
                            taskName: (provider) => provider.PICK_FILES,
                            onSuccess: (provider) {},
                            onError: (err) => ErrorDialog()
                                .show(err.toString(), context: context));
                      },
                      child: Row(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 30.toWidth),
                          child: Icon(Icons.file_copy, size: 30),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 20.toWidth),
                            child: Text(
                              TextStrings().choice2,
                              style: CustomTextStyles.primaryBold14,
                            ))
                      ]))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.toFont),
          color: ColorConstants.inputFieldColor,
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                filePickerProvider.selectedFiles.isEmpty
                    ? TextStrings().welcomeFilePlaceholder
                    : TextStrings().welcomeAddFilePlaceholder,
                style: TextStyle(
                  color: ColorConstants.fadedText,
                  fontSize: 14.toFont,
                ),
              ),
              subtitle: filePickerProvider.selectedFiles.isEmpty
                  ? null
                  : Text(
                      double.parse(filePickerProvider.totalSize.toString()) <=
                              1024
                          ? '${filePickerProvider.totalSize} Kb . ${filePickerProvider.selectedFiles?.length} file(s)'
                          : '${(filePickerProvider.totalSize / 1024).toStringAsFixed(2)} Mb . ${filePickerProvider.selectedFiles?.length} file(s)',
                      style: TextStyle(
                        color: ColorConstants.fadedText,
                        fontSize: 10.toFont,
                      ),
                    ),
              trailing: InkWell(
                onTap: () {
                  _showFileChoice();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15.toHeight),
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: filePickerProvider.selectedFiles.isNotEmpty
                  ? int.parse(
                      filePickerProvider.selectedFiles?.length?.toString())
                  : 0,
              itemBuilder: (c, index) {
                if (FileTypes.VIDEO_TYPES.contains(
                    filePickerProvider.selectedFiles[index].extension)) {
                  videoThumbnailBuilder(
                      filePickerProvider.selectedFiles[index].path);
                }
                return Consumer<FilePickerProvider>(
                    builder: (context, provider, _) {
                  print(
                      'CONSUMER FILES=======>${provider.selectedFiles.length}');
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ColorConstants.dividerColor.withOpacity(0.1),
                          width: 1.toHeight,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        provider.selectedFiles[index].name.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.toFont,
                        ),
                      ),
                      subtitle: Text(
                        double.parse(provider.selectedFiles[index].size
                                    .toString()) <=
                                1024
                            ? '${provider.selectedFiles[index].size} Kb' +
                                ' . ${provider.selectedFiles[index].extension}'
                            : '${(provider.selectedFiles[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb' +
                                ' . ${provider.selectedFiles[index].extension}',
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 14.toFont,
                        ),
                      ),
                      leading: thumbnail(
                          provider.selectedFiles[index].extension.toString(),
                          provider.selectedFiles[index].path.toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            provider.selectedFiles.removeAt(index);
                            provider.calculateSize();
                          });
                          if (provider.selectedFiles.isEmpty) {
                            widget.onUpdate(false);
                          }
                        },
                      ),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget thumbnail(String extension, String path) {
    return FileTypes.IMAGE_TYPES.contains(extension)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.toHeight),
            child: Container(
              height: 50.toHeight,
              width: 50.toWidth,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
            ),
          )
        : FileTypes.VIDEO_TYPES.contains(extension)
            ? FutureBuilder(
                future: videoThumbnailBuilder(path),
                builder: (context, snapshot) => (snapshot.data == null)
                    ? CircularProgressIndicator()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10.toHeight),
                        child: Container(
                          height: 50.toHeight,
                          width: 50.toWidth,
                          child: Image.memory(
                            videoThumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, o, ot) =>
                                CircularProgressIndicator(),
                          ),
                        ),
                      ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10.toHeight),
                child: Container(
                  height: 50.toHeight,
                  width: 50.toWidth,
                  child: Image.asset(
                    FileTypes.PDF_TYPES.contains(extension)
                        ? ImageConstants.pdfLogo
                        : FileTypes.AUDIO_TYPES.contains(extension)
                            ? ImageConstants.musicLogo
                            : FileTypes.WORD_TYPES.contains(extension)
                                ? ImageConstants.wordLogo
                                : FileTypes.EXEL_TYPES.contains(extension)
                                    ? ImageConstants.exelLogo
                                    : FileTypes.TEXT_TYPES.contains(extension)
                                        ? ImageConstants.txtLogo
                                        : ImageConstants.unknownLogo,
                    fit: BoxFit.cover,
                  ),
                ),
              );
  }
}
