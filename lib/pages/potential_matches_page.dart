import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lise/bloc/p_matches_bloc.dart';
import 'package:lise/convo_completion/select_matches_screen.dart';
import 'package:lise/messages/m_p_matches_screen.dart';
import 'package:lise/utils/convert_p_match_time.dart';
import 'package:lise/utils/delete_p_match.dart';
import 'package:lise/utils/delete_request.dart';
import 'package:lise/utils/send_p_match_request.dart';
import 'package:lise/widgets/delete_dialog.dart';

import '../localizations.dart';

class PotentialMatchesScreen extends StatefulWidget {
  PotentialMatchesScreen({
    Key key,
    @required this.scaffoldKey,
    @required this.user,
    @required this.alias,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;
  final String alias;

  @override
  _PotentialMatchesScreenState createState() => _PotentialMatchesScreenState(
        scaffoldKey: this.scaffoldKey,
        user: this.user,
        alias: this.alias,
      );
}

class _PotentialMatchesScreenState extends State<PotentialMatchesScreen> with AutomaticKeepAliveClientMixin {
  _PotentialMatchesScreenState({
    @required this.scaffoldKey,
    @required this.user,
    @required this.alias,
  });

  final scaffoldKey;
  final user;
  final alias;

  ScrollController _scrollController;

  final _listTitleStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
  final _biggerFont = const TextStyle(fontSize: 18.0, color: Colors.black);
  final _subFont = const TextStyle(color: Colors.black);
  final _trailFont = const TextStyle(color: Colors.black);

  var variablesInitialized = false;

  var _list = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  Widget builder(BuildContext context, List pMatchesList) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      controller: _scrollController,
      itemCount: pMatchesList.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) {
          return ListTile(
            leading: Text(
              AppLocalizations.of(context).translate('POTENTIAL_MATCHES'),
              textAlign: TextAlign.left,
              style: _listTitleStyle,
            ),
          );
        }

        if (i == pMatchesList.length + 1) {
          return ListTile(
            title: Text(
              AppLocalizations.of(context).translate('Find_someone_new'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.userPlus,
              color: Colors.black,
            ),
            onTap: () {
              sendPotentialMatchRequest(scaffoldKey);
            },
          );
        }

        final pMatch = pMatchesList[i - 1];
        var lastMessage;
        var time;

        if (pMatch['pending'] == true) {
          return ListTile(
            title: Text(
              AppLocalizations.of(context).translate('Searching_the_world_title'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              AppLocalizations.of(context).translate('Searching_the_world_subtitle'),
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            trailing: FaIcon(
              FontAwesomeIcons.clock,
              color: Colors.black,
            ),
            onTap: () {},
            onLongPress: () {
              showDeleteDialog(context, 'request', 'request').then((v) {
                if (v) {
                  deleteRequest(pMatch['key'], scaffoldKey);
                }
              });
              setState(() {});
            },
          );
        } else {
          if (pMatchesList.isNotEmpty && pMatch['last_message_time'] != null) {
            time = pMatch['last_message_time'];
          }
          if (pMatchesList.isNotEmpty && pMatch['last_message_time'] != null && time > 0) {
            if (pMatch['last_message_from'] == user.uid) {
              lastMessage = 'You: ${pMatch['last_message']}';
            } else {
              lastMessage = pMatch['last_message'];
            }
          } else {
            lastMessage = AppLocalizations.of(context).translate('Start_Conversation');
          }
          return ListTile(
            leading: CircleAvatar(child: Text(pMatch['otherUser'].toUpperCase()[0])),
            title: Text(
              pMatch['otherUser'],
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              lastMessage,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: _subFont,
              textAlign: TextAlign.left,
            ),
            trailing: Text(
              convertPMatchTime(
                context: context,
                userID: user.uid,
                time: int.parse(pMatch['key']),
                roomKey: pMatch['key'],
              ),
              style: _trailFont,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              // If the conversation is not finished go to chat, otherwise go to select connections screen
              (convertPMatchTime(
                        context: context,
                        userID: user.uid,
                        time: int.parse(pMatch['key']),
                        roomKey: pMatch['key'],
                      ) !=
                      AppLocalizations.of(context).translate('COMPLETED'))
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PMConversationScreen(
                          alias: alias,
                          matchName: pMatch['otherUser'],
                          username: user.displayName,
                          room: pMatch['room'],
                        ),
                      ),
                    ).then((value) {
                      //TODO_loadPMatchesData();
                    })
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectMatchesScreen(
                          user: user,
                          room: pMatch['room'],
                          roomKey: pMatch['key'],
                        ),
                      ),
                    );
            },
            onLongPress: () {
              setState(() {
                showDeleteDialog(context, pMatch['otherUser'], 'pMatch').then((v) {
                  if (v) {
                    deletePotentialMatch(int.parse(pMatch['key']), pMatch['room'], scaffoldKey);
                  }
                });
              });
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<PMatchesBloc, PMatchesState>(
      builder: (context, state) {
        if (state is PMatchesLoaded) {
          _list = state.pMatches.list;
        }
        return builder(context, _list);
      },
    );
  }
}