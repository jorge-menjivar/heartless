import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lise/utils/format_image.dart';

class UploadImagesPage extends StatefulWidget {
  UploadImagesPage({@required this.alias, @required this.placeholder});

  final String alias;
  final Widget placeholder;

  @override
  _UploadImagesPageState createState() => _UploadImagesPageState(alias: this.alias, placeholder: this.placeholder);
}

class _UploadImagesPageState extends State<UploadImagesPage> {
  _UploadImagesPageState({@required this.alias, @required this.placeholder});

  final String alias;
  final Widget placeholder;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  String _profilePicImageLink1;
  String _profilePicImageLink2;
  String _profilePicImageLink3;
  String _profilePicImageLink4;
  String _profilePicImageLink5;

  StorageReference _storageReference1;
  StorageReference _storageReference2;
  StorageReference _storageReference3;
  StorageReference _storageReference4;
  StorageReference _storageReference5;

  bool _pictureMissing1 = true;
  bool _pictureMissing2 = true;
  bool _pictureMissing3 = true;
  bool _pictureMissing4 = true;
  bool _pictureMissing5 = true;

  double mainPicSize;
  double secondaryPicSize;

  @override
  void initState() {
    super.initState();

    _loadProfilePictures();
    _scrollController = ScrollController();
    mainPicSize = 200;
    secondaryPicSize = 160;
  }

  void _loadProfilePictures() async {
    try {
      _storageReference1 = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic1.jpg');
      _profilePicImageLink1 = await _storageReference1.getDownloadURL();
      _pictureMissing1 = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference2 = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic2.jpg');
      _profilePicImageLink2 = await _storageReference2.getDownloadURL();
      _pictureMissing2 = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference3 = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic3.jpg');
      _profilePicImageLink3 = await _storageReference3.getDownloadURL();
      _pictureMissing3 = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference4 = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic4.jpg');
      _profilePicImageLink4 = await _storageReference4.getDownloadURL();
      _pictureMissing4 = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference5 = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic5.jpg');
      _profilePicImageLink5 = await _storageReference5.getDownloadURL();
      _pictureMissing5 = false;
    } catch (e) {
      print(e);
    }

    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Divider(color: Colors.transparent),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: (Theme.of(context).brightness == Brightness.light) ? Colors.black12 : Colors.white12,
            ),
            padding: EdgeInsets.all(6),
            child: SizedBox(
              width: mainPicSize,
              height: mainPicSize,
              child: RawMaterialButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                child: _imageOrPlaceHolder(_pictureMissing1, _profilePicImageLink1),
                onLongPress: () {},
                onPressed: () {
                  getImageFromGallery(1);
                },
              ),
            ),
          ),
        ),
        Divider(color: Colors.transparent),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: (Theme.of(context).brightness == Brightness.light) ? Colors.black12 : Colors.white12,
              ),
              padding: EdgeInsets.all(6),
              child: SizedBox(
                width: secondaryPicSize,
                height: secondaryPicSize,
                child: RawMaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: _imageOrPlaceHolder(_pictureMissing2, _profilePicImageLink2),
                  onLongPress: () {},
                  onPressed: () {
                    getImageFromGallery(2);
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: (Theme.of(context).brightness == Brightness.light) ? Colors.black12 : Colors.white12,
              ),
              padding: EdgeInsets.all(6),
              child: SizedBox(
                width: secondaryPicSize,
                height: secondaryPicSize,
                child: RawMaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: _imageOrPlaceHolder(_pictureMissing3, _profilePicImageLink3),
                  onLongPress: () {},
                  onPressed: () {
                    getImageFromGallery(3);
                  },
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.transparent),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: (Theme.of(context).brightness == Brightness.light) ? Colors.black12 : Colors.white12,
              ),
              padding: EdgeInsets.all(6),
              child: SizedBox(
                width: secondaryPicSize,
                height: secondaryPicSize,
                child: RawMaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: _imageOrPlaceHolder(_pictureMissing4, _profilePicImageLink4),
                  onLongPress: () {},
                  onPressed: () {
                    getImageFromGallery(4);
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: (Theme.of(context).brightness == Brightness.light) ? Colors.black12 : Colors.white12,
              ),
              padding: EdgeInsets.all(6),
              child: SizedBox(
                width: secondaryPicSize,
                height: secondaryPicSize,
                child: RawMaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: _imageOrPlaceHolder(_pictureMissing5, _profilePicImageLink5),
                  onLongPress: () {},
                  onPressed: () {
                    getImageFromGallery(5);
                  },
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.transparent),
      ],
    );
  }

  /// Gets image from gallery and uploads it to firebase storage.
  /// [pictureNumber] represent the number of the card of where the picture is at.
  Future getImageFromGallery(int pictureNumber) async {
    // Open gallery to select picture
    final imagePicker = ImagePicker();
    var image = await imagePicker.getImage(source: ImageSource.gallery);

    // making sure a picture was selected from the gallery
    if (image == null) {
      return;
    }

    // Deciding where to upload the picture to
    StorageReference reference;
    switch (pictureNumber) {
      case 1:
        reference = _storageReference1;
        break;

      case 2:
        reference = _storageReference2;
        break;

      case 3:
        reference = _storageReference3;
        break;

      case 4:
        reference = _storageReference4;
        break;

      case 5:
        reference = _storageReference5;
        break;
    }

    final compressedCroppedResizedFile = await formatFile(image: image);

    if (compressedCroppedResizedFile == null) {
      // TODO
      print('Image is too small');
      return;
    }

    // Uploading picture to the storage reference
    final uploadTask = reference.putFile(compressedCroppedResizedFile);

    // Wait until has been completely uploaded
    await uploadTask.onComplete;
    print('image uploaded');

    // Get the link to the picture we just uploaded
    var link = await reference.getDownloadURL();

    // Update the link in global variable
    switch (pictureNumber) {
      case 1:
        _profilePicImageLink1 = link;
        _pictureMissing1 = false;
        break;

      case 2:
        _profilePicImageLink2 = link;
        _pictureMissing2 = false;
        break;

      case 3:
        _profilePicImageLink3 = link;
        _pictureMissing3 = false;
        break;

      case 4:
        _profilePicImageLink4 = link;
        _pictureMissing4 = false;
        break;

      case 5:
        _profilePicImageLink5 = link;
        _pictureMissing5 = false;
        break;
    }

    // Update the image widget
    setState(() {
      print('updating state');
    });
  }

  Widget _imageOrPlaceHolder(bool pictureMissing, String imageLink) {
    return pictureMissing
        ? placeholder
        : ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Image.network(
              imageLink,
              fit: BoxFit.contain,
            ),
          );
  }
}
