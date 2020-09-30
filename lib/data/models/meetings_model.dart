import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Meetings extends Equatable {
  final List list;

  Meetings({
    @required this.list,
  });

  @override
  List<Object> get props => [list];
}
