import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lise/app_variables.dart';
import 'package:lise/bloc/conversation_bloc.dart';
import 'package:lise/bloc/matches_bloc.dart';
import 'package:lise/messages/m_matches_screen.dart';
import 'package:lise/utils/convert_match_time.dart';
import 'package:lise/utils/delete_match.dart';
import 'package:lise/widgets/delete_dialog.dart';
import 'package:sqflite/sqflite.dart';

import '../localizations.dart';

class MatchesScreen extends StatefulWidget {
  final Database db;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseUser user;
  final String alias;
  final AppVariables appVariables;

  MatchesScreen({
    Key key,
    @required this.scaffoldKey,
    @required this.user,
    @required this.alias,
    @required this.db,
    @required this.appVariables,
  }) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState(
        scaffoldKey: this.scaffoldKey,
        user: this.user,
        alias: this.alias,
        db: this.db,
        appVariables: this.appVariables,
      );
}

class _MatchesScreenState extends State<MatchesScreen> with AutomaticKeepAliveClientMixin {
  final scaffoldKey;
  final user;
  final alias;
  final db;
  final AppVariables appVariables;

  _MatchesScreenState({
    @required this.scaffoldKey,
    @required this.user,
    @required this.alias,
    @required this.db,
    @required this.appVariables,
  });

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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        if (state is MatchesLoaded) {
          _list = state.matches.list;
        }
        return builder(context, _list);
      },
    );
  }

  Widget builder(BuildContext context, List matchesList) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      controller: _scrollController,
      itemCount: matchesList.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return ListTile(
            leading: Text(AppLocalizations.of(context).translate('MATCHES'),
                textAlign: TextAlign.left, style: _listTitleStyle),
          );
        }

        final match = matchesList[i - 1];
        var lastMessage;
        var time;
        if (matchesList.isNotEmpty) {
          time = match['last_message_time'];
        }
        if (matchesList.isNotEmpty && time > 0) {
          if (match['last_message_from'] == user.uid) {
            lastMessage = 'You: ${match['last_message']}';
          } else {
            lastMessage = match['last_message'];
          }
        } else {
          lastMessage = AppLocalizations.of(context).translate('Start_Conversation');
        }
        return ListTile(
          leading: Container(
            decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AdvancedNetworkImage(
                      match['imageLink'],
                      useDiskCache: true,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            match['otherUser'],
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
            (matchesList.isNotEmpty && time > 0) ? convertMatchTime(context, time) : '',
            style: _trailFont,
            textAlign: TextAlign.left,
          ),
          onTap: () {
            appVariables.convoOpen[match['room']] = true;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (childContext) => BlocProvider.value(
                  value: BlocProvider.of<ConversationBloc>(context),
                  child: MatchedConversationScreen(
                    imageLink: match['imageLink'],
                    alias: this.alias,
                    matchName: match['otherUser'],
                    otherUserId: match['otherUserId'],
                    username: user.displayName,
                    room: match['room'],
                    db: this.db,
                    appVariables: this.appVariables,
                  ),
                ),
              ),
            ).then((value) {
              appVariables.convoRowCount = AppVariables.DEFAULT_ROW_COUNT;
            });
          },
          onLongPress: () {
            setState(() {
              showDeleteDialog(context, match['otherUser'], 'match').then((v) {
                if (v) {
                  deleteMatch(
                    db,
                    int.parse(match['key']),
                    match['room'],
                    scaffoldKey,
                  );
                }
              });
            });
          },
        );
      },
    );
  }
}
