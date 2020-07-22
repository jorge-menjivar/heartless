part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class GetProfile extends ProfileEvent {
  final String alias;

  const GetProfile({this.alias});

  @override
  List<Object> get props => [alias];
}
