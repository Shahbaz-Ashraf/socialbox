import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/api_post_response_model.dart';

class PostRemoteDataSource {
  PostRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<ApiPostResult> postToTwitter({
    required String accessToken,
    required String text,
  }) async {
    try {
      final dio = _dioClient.withBearerToken(accessToken);
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.twitterPostTweet,
        data: {'text': text},
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      final id = data?['id'] as String?;
      if (id == null || id.isEmpty) {
        throw NetworkException('Twitter API returned an invalid response.');
      }
      return ApiPostResult(
        externalPostId: id,
        externalPostUrl: 'https://twitter.com/i/web/status/$id',
      );
    } on DioException catch (e) {
      throw NetworkException(_dioMessage(e, 'Twitter posting failed'));
    }
  }

  Future<ApiPostResult> postToLinkedIn({
    required String accessToken,
    required String userId,
    required String text,
  }) async {
    try {
      final dio = _dioClient.withBearerToken(accessToken);
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.linkedinUgcPosts,
        data: {
          'author': 'urn:li:person:$userId',
          'lifecycleState': 'PUBLISHED',
          'specificContent': {
            'com.linkedin.ugc.ShareContent': {
              'shareCommentary': {'text': text},
              'shareMediaCategory': 'NONE',
            },
          },
          'visibility': {
            'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC',
          },
        },
        options: Options(
          headers: {'X-Restli-Protocol-Version': '2.0.0'},
        ),
      );
      final id = response.data?['id'] as String?;
      if (id == null || id.isEmpty) {
        throw NetworkException('LinkedIn API returned an invalid response.');
      }
      return ApiPostResult(
        externalPostId: id,
        externalPostUrl: 'https://www.linkedin.com/feed/update/$id',
      );
    } on DioException catch (e) {
      throw NetworkException(_dioMessage(e, 'LinkedIn posting failed'));
    }
  }

  Future<ApiPostResult> postToFacebook({
    required String pageId,
    required String pageAccessToken,
    required String message,
  }) async {
    try {
      final dio = _dioClient.dio;
      final response = await dio.post<Map<String, dynamic>>(
        '${ApiEndpoints.facebookGraphBase}/$pageId/feed',
        data: {
          'message': message,
          'access_token': pageAccessToken,
        },
      );
      final id = response.data?['id'] as String?;
      if (id == null || id.isEmpty) {
        throw NetworkException('Facebook API returned an invalid response.');
      }
      final postId = id.contains('_') ? id.split('_').last : id;
      return ApiPostResult(
        externalPostId: id,
        externalPostUrl: 'https://www.facebook.com/$pageId/posts/$postId',
      );
    } on DioException catch (e) {
      throw NetworkException(_dioMessage(e, 'Facebook posting failed'));
    }
  }

  String _dioMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'] as String?;
        if (message != null && message.isNotEmpty) return message;
      }
      final message = data['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
    }
    return e.message?.isNotEmpty == true ? e.message! : fallback;
  }
}