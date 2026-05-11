import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Remote data source for Reqres API user operations.
class UserRemoteSource {
  final DioClient _client;

  UserRemoteSource(this._client);

  /// Fetch paginated users from Reqres.
  Future<UsersResponse> getUsers({required int page}) async {
    final response = await _client.get(
      '/users',
      baseUrl: ApiConstants.reqresBaseUrl,
      queryParameters: {'page': page},
    );

    return UsersResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a new user on Reqres.
  Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String movieTaste,
  }) async {
    final response = await _client.post(
      '/users',
      baseUrl: ApiConstants.reqresBaseUrl,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'job': movieTaste,
      },
    );

    return response.data as Map<String, dynamic>;
  }
}
