import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lise/data/models/profile_model.dart';
import 'package:lise/data/user_data.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserData userData;

  ProfileBloc({@required this.userData}) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    yield ProfileLoading();
    if (event is GetProfile) {
      try {
        final profile = await userData.fetchProfile(user: event.user, alias: event.alias);
        yield ProfileLoaded(profile);
      } catch (e) {
        print('PROFILE BLOC: ' + e.toString());
        yield ProfileError("Could not fetch profile");
      }
    }
  }
}
