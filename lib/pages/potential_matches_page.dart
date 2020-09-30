import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:lise/app_variables.dart';
import 'package:lise/bloc/conversation_bloc.dart';
import 'package:lise/bloc/p_matches_bloc.dart';
import 'package:lise/convo_completion/select_matches_screen.dart';
import 'package:lise/messages/m_p_matches_screen.dart';
import 'package:lise/utils/convert_p_match_time.dart';
import 'package:lise/utils/delete_p_match.dart';
import 'package:lise/utils/delete_request.dart';
import 'package:lise/utils/send_p_match_request.dart';
import 'package:lise/widgets/advertisements.dart';
import 'package:lise/widgets/delete_dialog.dart';
import 'package:sqflite/sqflite.dart';

import '../localizations.dart';

class PotentialMatchesScreen extends StatefulWidget {
  final Database db;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;
  final AppVariables appVariables;

  PotentialMatchesScreen({
    Key key,
    @required this.db,
    @required this.scaffoldKey,
    @required this.user,
    @required this.appVariables,
  }) : super(key: key);

  @override
  _PotentialMatchesScreenState createState() => _PotentialMatchesScreenState(
        db: this.db,
        scaffoldKey: this.scaffoldKey,
        user: this.user,
        appVariables: this.appVariables,
      );
}

class _PotentialMatchesScreenState extends State<PotentialMatchesScreen> with AutomaticKeepAliveClientMixin {
  final Database db;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;
  final AppVariables appVariables;

  _PotentialMatchesScreenState({
    @required this.db,
    @required this.scaffoldKey,
    @required this.user,
    @required this.appVariables,
  });

  ScrollController _scrollController;

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
    _scrollController = ScrollController();
    _ads.start();
  }

  Widget builder(BuildContext context, List pMatchesList) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      controller: _scrollController,
      itemCount: pMatchesList.length + 2,
      itemBuilder: (itemBuilderContext, i) {
        if (i == 0) {
          return ListTile(
            leading: Text(
              AppLocalizations.of(itemBuilderContext).translate('POTENTIAL_MATCHES'),
              textAlign: TextAlign.left,
              style: _listTitleStyle,
            ),
          );
        }

        if (i == 1) {
          return ListTile(
            title: Text(
              AppLocalizations.of(itemBuilderContext).translate('Find_someone_new'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            trailing: Icon(
              FrinoIcons.f_user_add,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            onTap: () async {
              sendPotentialMatchRequest(context, scaffoldKey);
            },
          );
        }

        final pMatch = pMatchesList[i - 2];
        var lastMessage;
        var time;

        if (pMatch['room'] == null) {
          return ListTile(
            title: Text(
              AppLocalizations.of(itemBuilderContext).translate('Searching_the_world_title'),
              textAlign: TextAlign.left,
              style: _biggerFont,
            ),
            subtitle: Text(
              AppLocalizations.of(itemBuilderContext).translate('Searching_the_world_subtitle'),
              style: _subFont,
              textAlign: TextAlign.left,
              maxLines: 1,
            ),
            trailing: Icon(
              FrinoIcons.f_clock,
              color: IconTheme.of(context).color,
              size: IconTheme.of(context).size,
            ),
            onTap: () {},
            onLongPress: () {
              showDeleteDialog(itemBuilderContext, 'request', 'request').then((v) {
                if (v) {
                  deleteRequest(context, pMatch['key'], scaffoldKey);
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
            lastMessage = AppLocalizations.of(itemBuilderContext).translate('Start_Conversation');
          }
          return ListTile(
            leading: CircleAvatar(
              child: Text(pMatch['otherUser'].toUpperCase()[0]),
            ),
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
                context: itemBuilderContext,
                userID: user.uid,
                time: int.parse(pMatch['key']),
                roomKey: pMatch['key'],
              ),
              style: _trailFont,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              _ads.interstitial(tapsInBetween: 2);
              appVariables.convoOpen[pMatch['room']] = true;
              // If the conversation is not finished go to chat, otherwise go to select connections screen

              if (convertPMatchTime(
                    context: itemBuilderContext,
                    userID: user.uid,
                    time: int.parse(pMatch['key']),
                    roomKey: pMatch['key'],
                  ) ==
                  AppLocalizations.of(itemBuilderContext).translate('COMPLETED')) {
                Navigator.push(
                  itemBuilderContext,
                  MaterialPageRoute(
                    builder: (context) => SelectMatchesScreen(
                      user: user,
                      room: pMatch['room'],
                      roomKey: pMatch['key'],
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  itemBuilderContext,
                  MaterialPageRoute(
                    builder: (childContext) => BlocProvider.value(
                      value: BlocProvider.of<ConversationBloc>(itemBuilderContext),
                      child: PMatchesConversationScreen(
                        matchName: pMatch['otherUser'],
                        username: user.uid,
                        room: pMatch['room'],
                        db: this.db,
                        appVariables: this.appVariables,
                      ),
                    ),
                  ),
                ).then((value) {
                  appVariables.convoRowCount = AppVariables.DEFAULT_ROW_COUNT;
                });
              }
            },
            onLongPress: () {
              setState(() {
                showDeleteDialog(itemBuilderContext, pMatch['otherUser'], 'pMatch').then((v) {
                  if (v) {
                    deletePotentialMatch(context, int.parse(pMatch['key']), pMatch['room'], scaffoldKey);
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
