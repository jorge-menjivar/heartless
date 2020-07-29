import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Matches extends Equatable {
  final List list;

  Matches({
    @required this.list,
  });

  @override
  List<Object> get props => [list];
}
