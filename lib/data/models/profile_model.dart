import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String profilePictureURL;

  Profile({
    @required this.profilePictureURL,
  });

  @override
  List<Object> get props => [profilePictureURL];
}
