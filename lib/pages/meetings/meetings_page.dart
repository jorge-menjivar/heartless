import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:lise/app_variables.dart';
import 'package:lise/bloc/meetings_bloc.dart';
import 'package:lise/pages/meetings/meeting_selected.dart';
import 'package:lise/pages/meetings/new_meeting_page.dart';
import 'package:lise/utils/create_meeting.dart';
import 'package:lise/utils/get_meetings_from_server.dart';
import 'package:lise/utils/send_p_match_request.dart';
import 'package:lise/widgets/advertisements.dart';
import 'package:sqflite/sqflite.dart';

import '../../localizations.dart';

class MeetingsScreen extends StatefulWidget {
  final Database db;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;
  final AppVariables appVariables;

  MeetingsScreen({
    Key key,
    @required this.db,
    @required this.scaffoldKey,
    @required this.user,
    @required this.appVariables,
  }) : super(key: key);

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState(
        db: this.db,
        scaffoldKey: this.scaffoldKey,
        user: this.user,
        appVariables: this.appVariables,
      );
}

class _MeetingsScreenState extends State<MeetingsScreen> with AutomaticKeepAliveClientMixin {
  final Database db;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;
  final AppVariables appVariables;

  _MeetingsScreenState({
    @required this.db,
    @required this.scaffoldKey,
    @required this.user,
    @required this.appVariables,
  });

  final _listTitleStyle = const TextStyle(fontWeight: FontWeight.w800);
  final _biggerFont = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600);
  final _subFont = const TextStyle(fontSize: 14.0);
  final _trailFont = const TextStyle(fontSize: 14.0);

  var variablesInitialized = false;

  var _list = [];

  final _ads = Advertisements();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ads.start();
  }

  Widget builder(BuildContext context, List meetingsList) {
    return RefreshIndicator(
      child: ListView.builder(
        padding: const EdgeInsets.all(1),
        itemCount: meetingsList.length + 2,
        itemBuilder: (itemBuilderContext, i) {
          if (i == 0) {
            return ListTile(
              leading: Text(
                'MEETINGS',
                textAlign: TextAlign.left,
                style: _listTitleStyle,
              ),
            );
          }

          if (i == 1) {
            return ListTile(
              title: Text(
                'Create a New Meeting',
                textAlign: TextAlign.left,
                style: _biggerFont,
              ),
              trailing: Icon(
                FrinoIcons.f_cutlery,
                color: IconTheme.of(context).color,
                size: IconTheme.of(context).size,
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewMeetingScreen(
                      user: user,
                    ),
                  ),
                ).then((value) => initMeetingsBloc());
              },
            );
          }

          final meet = meetingsList[i - 2];

          var payingColor = (Theme.of(context).brightness == Brightness.light)
              ? Color.fromRGBO(222, 255, 176, 1)
              : Color.fromRGBO(49, 84, 0, 1);

          var attributes = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&';

          var miles = (meet['distance'] / 1609.34).toStringAsFixed(1);
          var km = (meet['distance'] / 1000).toStringAsFixed(1);

          var time = DateTime.fromMillisecondsSinceEpoch(meet['date_time']).toString();

          return CupertinoButton(
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              color: meet['paying'] ? payingColor : null,
              child: Column(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            '${attributes}photoreference=${meet['photo_ref']}&key=${AppVariables.MAPS_KEY}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color.fromRGBO(
                                255,
                                21 + (200 * meet['rating'] * .1).round(),
                                100 - (100 * meet['rating'] * .1).round(),
                                1,
                              ),
                              foregroundColor: Colors.white,
                              radius: 25,
                              child: Text(
                                meet['rating'].toString(),
                                style: _biggerFont,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    meet['location_name'],
                                    textAlign: TextAlign.left,
                                    style: _biggerFont,
                                  ),
                                  Text(
                                    time,
                                    textAlign: TextAlign.left,
                                    style: _biggerFont,
                                  ),
                                  Text(
                                    '${meet['age'].toString()} years old',
                                    textAlign: TextAlign.left,
                                    style: _subFont,
                                  ),
                                  Text(
                                    meet['gender'],
                                    textAlign: TextAlign.left,
                                    style: _subFont,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$miles miles',
                                style: _trailFont,
                                textAlign: TextAlign.right,
                              ),
                              meet['paying']
                                  ? Text(
                                      'paying',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.end,
                                    )
                                  : Text(''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeetingSelectedScreen(
                    user: user,
                    dateEpoch: meet['date_time'],
                    latitude: meet['latitude'],
                    longitude: meet['longitude'],
                    paying: meet['paying'],
                    photoRef: meet['photo_ref'],
                    placeAddress: meet['location_address'],
                    placeName: meet['location_name'],
                  ),
                ),
              ).then((value) => initMeetingsBloc());
            },
          );
        },
      ),
      onRefresh: () {
        return initMeetingsBloc();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<MeetingsBloc, MeetingsState>(
      builder: (context, state) {
        if (state is MeetingsLoaded) {
          _list = state.meetings.list;
        }
        return builder(context, _list);
      },
    );
  }

  Future<void> initMeetingsBloc() async {
    // Starting meetings bloc
    BlocProvider.of<MeetingsBloc>(context)
      ..add(GetMeetings(
        meetingsDocs: await getMeetings(),
      ));
  }
}
