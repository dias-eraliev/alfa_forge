import '../api/api_client.dart';
import '../models/api_models.dart';

class BrotherhoodService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<List<ApiBrotherhoodPost>>> getFeed() async {
    return _apiClient.get<List<ApiBrotherhoodPost>>(
      '/brotherhood/feed',
      fromJson: (json) {
        final List<dynamic> data = json['data'] ?? json as List<dynamic>;
        return data
            .map((e) => ApiBrotherhoodPost.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<List<ApiBrotherhoodPost>>> getTopic(String topic) async {
    return _apiClient.get<List<ApiBrotherhoodPost>>(
      '/brotherhood/topics',
      queryParams: {'topic': topic},
      fromJson: (json) {
        final List<dynamic> data = json['data'] ?? json as List<dynamic>;
        return data
            .map((e) => ApiBrotherhoodPost.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<List<ApiBrotherhoodPost>>> getMine() async {
    return _apiClient.get<List<ApiBrotherhoodPost>>(
      '/brotherhood/mine',
      fromJson: (json) {
        final List<dynamic> data = json['data'] ?? json as List<dynamic>;
        return data
            .map((e) => ApiBrotherhoodPost.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createPost(String text, {String? topic}) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/brotherhood/posts',
      body: {'text': text, if (topic != null && topic.isNotEmpty) 'topic': topic},
      fromJson: (json) => json['data'] ?? json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> replyToPost(String postId, String text) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/brotherhood/posts/$postId/replies',
      body: {'text': text},
      fromJson: (json) => json['data'] ?? json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleReaction(String postId, ApiReactionType type) async {
    final typeStr = type == ApiReactionType.FIRE ? 'FIRE' : 'THUMBS_UP';
    return _apiClient.post<Map<String, dynamic>>(
      '/brotherhood/posts/$postId/reactions/toggle',
      body: {'type': typeStr},
      fromJson: (json) => json['data'] ?? json,
    );
  }
}
