part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class GetProfile extends ProfileEvent {
  final FirebaseUser user;
  final String alias;

  const GetProfile({
    this.user,
    this.alias,
  });

  @override
  List<Object> get props => [user, alias];
}
