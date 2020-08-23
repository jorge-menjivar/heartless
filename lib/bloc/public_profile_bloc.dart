import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lise/data/models/public_profile_model.dart';
import 'package:lise/data/public_data.dart';

part 'public_profile_event.dart';
part 'public_profile_state.dart';

class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {
  final PublicData publicData;

  PublicProfileBloc({@required this.publicData}) : super(PublicProfileInitial());

  @override
  Stream<PublicProfileState> mapEventToState(
    PublicProfileEvent event,
  ) async* {
    yield PublicProfileLoading();
    if (event is GetPublicProfile) {
      try {
        final publicProfile = await publicData.fetchProfile(alias: event.alias);
        yield PublicProfileLoaded(publicProfile);
      } catch (e) {
        print('public profile bloc: ' + e);
        yield PublicProfileError("Could not fetch profile");
      }
    }
  }
}
