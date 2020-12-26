import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:lise/bloc/profile_bloc.dart';
import 'package:lise/pages/profile/dev_settings.dart';
import 'package:lise/pages/profile/personal_information_screen.dart';
import 'package:lise/pages/profile/profile_pictures_screen.dart';
import 'package:lise/pages/profile/search_information_screen.dart';
import 'package:lise/pages/profile/settings.dart';
import 'package:lise/pages/profile/wol_screen.dart';
import 'package:lise/widgets/loading_progress_indicator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../localizations.dart';
import '../../main.dart';

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
  final FirebaseUser user;
  final String alias;

  ProfileScreen({
    Key key,
    @required this.user,
    @required this.alias,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState(user: this.user, alias: this.alias);
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  final FirebaseUser user;
  final String alias;

  _ProfileScreenState({
    @required this.user,
    @required this.alias,
  });

  var dataLoaded = false;
  var picturesLoaded = false;

  final _listTitleStyle = const TextStyle(fontWeight: FontWeight.w800);
  final _biggerFont = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600);
  final _subFont = const TextStyle(fontSize: 14.0);
  final _trailFont = const TextStyle(fontSize: 14.0);

  final double _profilePicSize = 280;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      children: <Widget>[
        ListTile(
          leading: Text(
            AppLocalizations.of(context).translate('PROFILE'),
            textAlign: TextAlign.left,
            style: _listTitleStyle,
          ),
        ),
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return emptyPlaceHolder();
            } else if (state is ProfileLoaded) {
              final profilePicture = NetworkImage(state.profile.profilePictureURL);
              final name = state.profile.name;
              final email = state.profile.email;

              return Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: _profilePicSize,
                      height: _profilePicSize,
                      child: RawMaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: profilePicture,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePicturesScreen(
                                alias: alias,
                              ),
                            ),
                          ).then(
                            (value) => BlocProvider.of<ProfileBloc>(context)
                              ..add(
                                GetProfile(user: user, alias: alias),
                              ),
                          );
                        },
                      ),
                    ),
                  ),
                  Divider(color: Colors.transparent),
                  Container(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              );
            }
            return emptyPlaceHolder();
          },
        ),
        Divider(),
        Divider(color: Colors.transparent),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: Icon(
              FrinoIcons.f_user,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
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
            leading: Icon(
              FrinoIcons.f_search,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
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
            leading: Icon(
              FrinoIcons.f_pulse,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
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
            leading: Icon(
              FrinoIcons.f_settings,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  user: user,
                ),
              ),
            ),
          ),
        ),
        Divider(color: Colors.transparent),
        Divider(),
        Divider(color: Colors.transparent),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: Icon(
              FrinoIcons.f_code,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Text(
              'Developer Settings',
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DevSettings(
                    user: user,
                  ),
                ),
              );
            },
          ),
        ),
        Divider(color: Colors.transparent),
        Divider(),
        Divider(color: Colors.transparent),
        Container(
          decoration: BoxDecoration(),
          child: ListTile(
            dense: true,
            leading: Icon(
              FrinoIcons.f_logout,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            title: Text(
              AppLocalizations.of(context).translate('Log_Out'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            onTap: () {
              signOut().then((success) {
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoadingPage(),
                    ),
                  );
                } else {
                  //TODO
                }
              });
            },
          ),
        ),
        Divider(color: Colors.transparent),
      ],
    );
  }

  /// Returns true if successfully removed all user information.
  Future<bool> signOut() async {
    try {
      //TODO dispose of listeners

      // Get a location using path_provider
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'convos', 'messages');
      await deleteDatabase(path);

      await FirebaseAuth.instance.signOut();

      return true;
    } catch (e) {
      print('ERROR ON SIGN OUT:\n${e.toString()}');
      return false;
    }
  }

  /// An empty placeholder to keep the screen from loosing posture
  Widget emptyPlaceHolder() {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: _profilePicSize,
            height: _profilePicSize,
            child: loading_progress_indicator(),
          ),
        ),
        Divider(color: Colors.transparent),
        Container(
          child: Text(
            ' ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        Container(
          child: Text(
            ' ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
