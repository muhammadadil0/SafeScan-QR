class SecurityConstants {
  static const List<String> phishingKeywords = [
    'login',
    'verify',
    'reset',
    'password',
    'free',
    'prize',
    'support',
    'urgent',
    'confirm',
    'gift',
    'bank',
    'secure',
    'account',
    'update',
    'signin',
    'giveaway',
    'bonus',
    'claim',
    'winner',
  ];

  static const List<String> suspiciousDomains = [
    '000webhost',
    'infinityfree',
    'weebly',
    'blogspot',
    'wixsite',
    'wordpress',
    'freehost',
    'xyz', // .xyz is often used for spam, though not always
    'top',
    'gq',
    'cf',
    'tk',
    'ml',
    'ga',
  ];

  static const List<String> legitimateDomains = [
    'google.com',
    'facebook.com',
    'amazon.com',
    'paypal.com',
    'apple.com',
    'microsoft.com',
    'netflix.com',
    'instagram.com',
    'twitter.com',
    'linkedin.com',
  ];
}
