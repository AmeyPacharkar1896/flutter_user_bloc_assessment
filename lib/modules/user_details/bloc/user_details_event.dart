part of 'user_details_bloc.dart';

class UserDetailsEvent extends Equatable {
  const UserDetailsEvent();

  @override
  List<Object?> get props => [];
}

class UserDetailsEventFetchAllDetails extends UserDetailsEvent {
  final int userId;
  final User? initialUser;

  const UserDetailsEventFetchAllDetails({
    required this.userId,
    this.initialUser,
  });

  @override
  List<Object?> get props => [userId, initialUser];
}
