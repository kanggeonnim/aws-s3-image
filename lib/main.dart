import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test1/generate_image_url.dart';
import 'package:test1/upload_file.dart';
import 'dart:io';
import 'CustomDialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'galleyItem.dart';
const Color kErrorRed = Colors.redAccent;
const Color kDarkGray = Color(0xFFA3A3A3);
const Color kLightGray = Color(0xFFF1F0F5);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

enum PhotoSource { FILE, NETWORK }

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImagePickerWidget();
  }
}

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final List<XFile> _photos = <XFile>[];
  final List<String> _photosUrls = <String>[];
  final List<PhotoSource> _photosSources = <PhotoSource>[];
  final List<GalleryItem> _galleryItems = <GalleryItem>[];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddPhoto();
                }
                XFile image = _photos[index - 1];
                PhotoSource source = _photosSources[index - 1];
                File file = File(image.path);
                return Stack(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        height: 100,
                        width: 100,
                        color: kLightGray,
                        child: source == PhotoSource.FILE
                            ? Image.file(file)
                            : Image.network(_photosUrls[index - 1]),
                      ),
                    ),

                  ],
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: const Text('Save'),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }


  _buildAddPhoto() {
    return InkWell(
      onTap: () => _onAddPhotoClicked(context),
      child: Container(
        margin: const EdgeInsets.all(5),
        height: 100,
        width: 100,
        color: kDarkGray,
        child: const Center(
          child: Icon(
            Icons.add_to_photos,
            color: kLightGray,
          ),
        ),
      ),
    );
  }

  _onAddPhotoClicked(context) async {
    Permission permission;

    if (Platform.isIOS) {
      Permission.photos.request();
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    PermissionStatus permissionStatus =  await permission.status; // await permission.location.request();

    print(permissionStatus);

    if (permissionStatus == PermissionStatus.restricted) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      //_showOpenAppSettingsDialog(context);
      openAppSettings();

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await permission.request();

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
        _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      print('Permission granted');
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        String fileExtension = p.extension(image.path);

        _galleryItems.add(
          GalleryItem(
            id: const Uuid().v1(),
            resource: image.path,
            isSvg: fileExtension.toLowerCase() == ".svg",
          ),
        );

        setState(() {
          _photos.add(image);
          _photosSources.add(PhotoSource.FILE);
        });

        //Changes started
        GenerateImageUrl generateImageUrl = GenerateImageUrl();
        print("@@@ generateURL생성");
        await generateImageUrl.call(fileExtension);
        print("URL 생성 완료");
        String uploadUrl;
        if (generateImageUrl.isGenerated != null &&
            generateImageUrl.isGenerated) {
          uploadUrl = generateImageUrl.uploadUrl;
        } else {
          throw generateImageUrl.message;
        }

        bool isUploaded = await uploadFile(context, uploadUrl, File(image.path));
        if (isUploaded) {
          setState(() {
            _photosUrls.add(generateImageUrl.downloadUrl);
          });
        }
        //Changes Ended
      }
    }
  }

  Future<bool> uploadFile(context, String url, File image) async {
    try {
      UploadFile uploadFile = UploadFile();
      await uploadFile.call(url, image);

      if (uploadFile.isUploaded != null && uploadFile.isUploaded) {
        return true;
      } else {
        throw uploadFile.message;
      }
    } catch (e) {
      throw e;
    }
  }
  _showOpenAppSettingsDialog(context) {
    return CustomDialog.show(
      context,
      'Permission needed',
      'Photos permission is needed to select photos',
      'Open settings',
      openAppSettings,
    );
  }
}




