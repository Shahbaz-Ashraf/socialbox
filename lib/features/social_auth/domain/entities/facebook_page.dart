import 'package:equatable/equatable.dart';

class FacebookPage extends Equatable {
  const FacebookPage({
    required this.id,
    required this.name,
    required this.accessToken,
  });

  final String id;
  final String name;
  final String accessToken;

  @override
  List<Object?> get props => [id, name, accessToken];
}