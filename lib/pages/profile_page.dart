import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/bloc/profile_bloc.dart';
import 'package:lise/user_profile/personal_information_screen.dart';
import 'package:lise/user_profile/profile_pictures_screen.dart';
import 'package:lise/user_profile/search_information_screen.dart';
import 'package:lise/user_profile/wol_screen.dart';

import '../localizations.dart';
import '../main.dart';

Map<int, Color> color = {
  50: Color.fromRGBO(0, 0, 0, .1),
  100: Color.fromRGBO(0, 0, 0, .2),
  200: Color.fromRGBO(0, 0, 0, .3),
  300: Color.fromRGBO(0, 0, 0, .4),
  400: Color.fromRGBO(0, 0, 0, .5),
  500: Color.fromRGBO(0, 0, 0, .6),
  600: Color.fromRGBO(0, 0, 0, .7),
  700: Color.fromRGBO(0, 0, 0, .8),
  800: Color.fromRGBO(0, 0, 0, .9),
  900: Color.fromRGBO(0, 0, 0, 1),
};
MaterialColor black = MaterialColor(0xFF000000, color);
MaterialColor white = MaterialColor(0xFFFFFFFF, color);

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key, @required this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _ProfileScreenState createState() => _ProfileScreenState(user: this.user);
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  _ProfileScreenState({@required this.user});

  final user;

  var dataLoaded = false;
  var picturesLoaded = false;

  final _biggerFont = const TextStyle(fontSize: 18.0, color: Colors.black);
  final _subFont = const TextStyle(color: Colors.black);
  final _listTitleStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

  Color _pictureCardColor = Colors.white;

  final double _profilePicSize = 280;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(1),
      children: <Widget>[
        ListTile(
          leading: Text(
            AppLocalizations.of(context).translate('PROFILE'),
            textAlign: TextAlign.left,
            style: _listTitleStyle,
          ),
        ),
        SizedBox(
          height: _profilePicSize + 40,
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(0, 0.9),
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment(0, -0.9),
                  end: Alignment.topCenter,
                  colors: [Colors.white, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(12),
                primary: false,
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Center(
                    child: Card(
                      color: _pictureCardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(1000))),
                      child: SizedBox(
                        width: _profilePicSize,
                        height: _profilePicSize,
                        child: RawMaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          padding: EdgeInsets.all(12),
                          child: BlocListener<ProfileBloc, ProfileState>(
                            listener: (context, state) {
                              if (state is ProfileError) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                  ),
                                );
                              }
                            },
                            child: BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, state) {
                                if (state is ProfileLoading) {
                                  return CircularProgressIndicator();
                                } else if (state is ProfileLoaded) {
                                  final profilePicture = NetworkImage(state.profile.profilePictureURL);
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: profilePicture,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                } else if (state is ProfileError) {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePicturesScreen(
                                  user: user,
                                ),
                              ),
                            ); //TODO  .then((value) => _loadProfilePictures());
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(),
        Divider(color: Colors.transparent),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: FaIcon(
              FontAwesomeIcons.userAlt,
              color: black,
            ),
            title: Text(
              AppLocalizations.of(context).translate('Personal_Information_title'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              AppLocalizations.of(context).translate('Personal_Information_subtitle'),
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalInformationScreen(
                    user: user,
                  ),
                ),
              );
            },
          ),
        ),
        Divider(color: Colors.transparent),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: FaIcon(
              FontAwesomeIcons.search,
              color: black,
            ),
            title: Text(
              AppLocalizations.of(context).translate('I_am_looking_for_title'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              AppLocalizations.of(context).translate('I_am_looking_for_subtitle'),
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchInformationScreen(
                    user: user,
                  ),
                ),
              );
            },
          ),
        ),
        Divider(color: Colors.transparent),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: FaIcon(
              FontAwesomeIcons.snowboarding,
              color: black,
            ),
            title: Text(
              AppLocalizations.of(context).translate('My_way_of_living_title'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              AppLocalizations.of(context).translate('My_way_of_living_subtitle'),
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WayOfLivingScreen(
                    user: user,
                  ),
                ),
              );
            },
          ),
        ),
        Divider(color: Colors.transparent),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: FaIcon(
              FontAwesomeIcons.wrench,
              color: black,
            ),
            title: Text(
              AppLocalizations.of(context).translate('Settings_title'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              AppLocalizations.of(context).translate('Settings_subtitle'),
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            onTap: () {
              setState(() {});
            },
          ),
        ),
        Divider(color: Colors.transparent),
        Divider(),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: FaIcon(
              FontAwesomeIcons.signOutAlt,
              color: black,
            ),
            title: Text(
              AppLocalizations.of(context).translate('Log_Out'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoadingPage(),
                ),
              );
            },
          ),
        ),
        Divider(color: Colors.transparent),
      ],
    );
  }
}
