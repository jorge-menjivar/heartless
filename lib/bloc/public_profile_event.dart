part of 'public_profile_bloc.dart';

abstract class PublicProfileEvent extends Equatable {
  const PublicProfileEvent();
}

class GetPublicProfile extends PublicProfileEvent {
  final String alias;

  const GetPublicProfile({
    this.alias,
  });

  @override
  List<Object> get props => [alias];
}
