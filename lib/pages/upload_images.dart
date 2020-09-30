import 'package:cached_network_image/cached_network_image.dart';
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

  List<String> _profilePicImageLink = List<String>(5);

  List<StorageReference> _storageReference = List<StorageReference>(5);

  // List of 5 bool set to true
  List<bool> _pictureMissing = List.filled(5, true);

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
      _storageReference[0] = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic1.jpg');
      _profilePicImageLink[0] = await _storageReference[0].getDownloadURL();
      _pictureMissing[0] = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference[1] = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic2.jpg');
      _profilePicImageLink[1] = await _storageReference[1].getDownloadURL();
      _pictureMissing[1] = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference[2] = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic3.jpg');
      _profilePicImageLink[2] = await _storageReference[2].getDownloadURL();
      _pictureMissing[2] = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference[3] = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic4.jpg');
      _profilePicImageLink[3] = await _storageReference[3].getDownloadURL();
      _pictureMissing[3] = false;
    } catch (e) {
      print(e);
    }
    try {
      _storageReference[4] = FirebaseStorage().ref().child('users/${alias}/profile_pictures/pic5.jpg');
      _profilePicImageLink[4] = await _storageReference[4].getDownloadURL();
      _pictureMissing[4] = false;
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
            padding: EdgeInsets.all(0),
            child: SizedBox(
              width: mainPicSize,
              height: mainPicSize,
              child: _imageOrPlaceHolder(_pictureMissing[0], _profilePicImageLink[0], 0),
            ),
          ),
        ),
        Divider(color: Colors.transparent),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(2, (index) {
            var i = index + 1;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: (Theme.of(context).brightness == Brightness.light) ? Colors.black12 : Colors.white12,
              ),
              padding: EdgeInsets.all(0),
              child: SizedBox(
                width: secondaryPicSize,
                height: secondaryPicSize,
                child: _imageOrPlaceHolder(_pictureMissing[i], _profilePicImageLink[i], i),
              ),
            );
          }),
        ),
        Divider(color: Colors.transparent),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(2, (index) {
            var i = index + 3;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: (Theme.of(context).brightness == Brightness.light) ? Colors.black12 : Colors.white12,
              ),
              padding: EdgeInsets.all(0),
              child: SizedBox(
                width: secondaryPicSize,
                height: secondaryPicSize,
                child: _imageOrPlaceHolder(_pictureMissing[i], _profilePicImageLink[i], i),
              ),
            );
          }),
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
    reference = _storageReference[pictureNumber];

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

    _profilePicImageLink[pictureNumber] = link;
    _pictureMissing[pictureNumber] = false;

    // Update the image widget
    setState(() {
      print('updating state');
    });
  }

  Widget _imageOrPlaceHolder(bool pictureMissing, String imageLink, int location) {
    return pictureMissing
        ? placeholder
        : ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: RawMaterialButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        imageLink,
                      ),
                      fit: BoxFit.fitWidth),
                ),
              ),
              onLongPress: () {},
              onPressed: () {
                getImageFromGallery(location);
              },
            ),
          );
  }
}
