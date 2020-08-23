part of 'public_profile_bloc.dart';

abstract class PublicProfileState extends Equatable {
  const PublicProfileState();
}

class PublicProfileInitial extends PublicProfileState {
  @override
  List<Object> get props => [];
}

class PublicProfileLoading extends PublicProfileState {
  const PublicProfileLoading();
  @override
  List<Object> get props => [];
}

class PublicProfileLoaded extends PublicProfileState {
  final PublicProfile publicProfile;
  const PublicProfileLoaded(this.publicProfile);
  @override
  List<Object> get props => [publicProfile];
}

class PublicProfileError extends PublicProfileState {
  final String message;
  const PublicProfileError(this.message);
  @override
  List<Object> get props => [message];
}
