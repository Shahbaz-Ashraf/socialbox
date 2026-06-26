class ApiEndpoints {
  ApiEndpoints._();

  // Twitter / X API v2
  static const String twitterAuthUrl = 'https://twitter.com/i/oauth2/authorize';
  static const String twitterTokenUrl = 'https://api.twitter.com/2/oauth2/token';
  static const String twitterApiBase = 'https://api.twitter.com/2';
  static const String twitterPostTweet = '$twitterApiBase/tweets';
  static const String twitterUserMe = '$twitterApiBase/users/me';
  static const List<String> twitterScopes = [
    'tweet.write',
    'users.read',
    'offline.access',
  ];

  // LinkedIn API
  static const String linkedinAuthUrl = 'https://www.linkedin.com/oauth/v2/authorization';
  static const String linkedinTokenUrl = 'https://www.linkedin.com/oauth/v2/accessToken';
  static const String linkedinApiBase = 'https://api.linkedin.com/v2';
  static const String linkedinMe = '$linkedinApiBase/me';
  static const String linkedinUgcPosts = '$linkedinApiBase/ugcPosts';
  static const List<String> linkedinScopes = [
    'w_member_social',
    'r_liteprofile',
  ];

  // Facebook Graph API
  static const String facebookAuthUrl = 'https://www.facebook.com/dialog/oauth';
  static const String facebookTokenUrl = 'https://graph.facebook.com/oauth/access_token';
  static const String facebookGraphBase = 'https://graph.facebook.com/v20.0';
  static const String facebookMeAccounts = '$facebookGraphBase/me/accounts';
  static const List<String> facebookScopes = [
    'pages_manage_posts',
    'pages_read_engagement',
  ];
}
