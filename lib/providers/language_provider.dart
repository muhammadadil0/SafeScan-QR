import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_name': 'SafeScan QR',
      'safe': 'Safe',
      'suspicious': 'Suspicious',
      'dangerous': 'Dangerous',
      'cancel': 'Cancel',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      
      // Onboarding
      'welcome': 'Welcome to SafeScan QR',
      'onboarding_title_1': 'Scan QR Codes Safely',
      'onboarding_desc_1': 'Detect malicious QR codes before they harm you',
      'onboarding_title_2': 'Advanced Security',
      'onboarding_desc_2': 'AI-powered threat detection and analysis',
      'onboarding_title_3': 'Stay Protected',
      'onboarding_desc_3': 'Real-time protection against phishing and malware',
      'get_started': 'Get Started',
      'skip': 'Skip',
      
      // Auth
      'welcome_back': 'Welcome Back',
      'sign_in_continue': 'Sign in to continue',
      'email': 'Email Address',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'sign_in': 'Sign In',
      'dont_have_account': "Don't have an account?",
      'sign_up': 'Sign Up',
      'create_account': 'Create Account',
      'join_safescan': 'Join SafeScan QR today',
      'full_name': 'Full Name',
      'already_have_account': 'Already have an account?',
      'terms_agreement': 'By signing up, you agree to our Terms & Privacy Policy',
      
      // Dashboard
      'hello_user': 'Hello, User 👋',
      'stay_safe': 'Stay safe online',
      'protection_status': 'Protection Status',
      'fully_protected': 'Fully Protected',
      'scans': 'Scans',
      'blocked': 'Blocked',
      'quick_actions': 'Quick Actions',
      'scan_qr': 'Scan QR',
      'upload_image': 'Upload Image',
      'check_url': 'Check URL',
      'history': 'History',
      'recent_activity': 'Recent Activity',
      'no_recent_activity': 'No recent activity',
      'start_scanning': 'Start scanning to see your history',
      
      // Scanner
      'scan_qr_code': 'Scan QR Code',
      'point_camera': 'Point your camera at a QR code',
      'toggle_flash': 'Toggle Flash',
      'upload_from_gallery': 'Upload from Gallery',
      
      // Results
      'scan_result': 'Scan Result',
      'risk_score': 'Risk Score',
      'high_risk': 'High Risk',
      'medium_risk': 'Medium Risk',
      'low_risk': 'Low Risk',
      'scanned_content': 'Scanned Content',
      'analysis_details': 'Analysis Details',
      'additional_info': 'Additional Information',
      'open_safe_browser': 'Open in Safe Browser',
      'open_anyway': 'Open Anyway (Unsafe)',
      'report_qr': 'Report This QR',
      'danger_warning': 'Danger Warning',
      'high_risk_warning': 'This URL is flagged as DANGEROUS with a high risk score. Opening it may compromise your security. Are you absolutely sure?',
      'proceed_anyway': 'Proceed Anyway',
      
      // Settings
      'settings': 'Settings',
      'profile': 'Profile',
      'manage_account': 'Manage your account',
      'scan_history': 'Scan History',
      'view_all_scans': 'View all your scans',
      'security': 'Security',
      'privacy_settings': 'Privacy & security settings',
      'help_support': 'Help & Support',
      'get_help': 'Get help and contact us',
      'logout': 'Logout',
      'sign_out': 'Sign out of your account',
      'language': 'Language',
      'choose_language': 'Choose your language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'child_mode': 'Child Mode',
      'simple_interface': 'Simple interface for children',
      
      // URL Checker
      'url_checker': 'URL Security Checker',
      'enter_url': 'Enter any URL to check its safety instantly',
      'url_placeholder': 'https://example.com',
      'analyze_url': 'Analyze URL',
      
      // Content Types
      'wifi_detected': 'WiFi credentials detected',
      'email_detected': 'Email address detected',
      'phone_detected': 'Phone number detected',
      'payment_detected': 'Payment link detected',
      'contact_detected': 'Contact information detected',
      'text_detected': 'Plain text content',
      
      // Warnings
      'wifi_warning': 'Only connect if you trust the source',
      'payment_warning': 'Verify recipient before paying',
      'verify_before_call': 'Verify before calling',
      'generally_safe': 'Generally safe',
      
      // Report
      'report_dangerous_qr': 'Report Dangerous QR',
      'help_improve': 'Help us improve by reporting this QR code:',
      'reason_optional': 'Reason (optional)',
      'why_dangerous': 'Why is this dangerous?',
      'report': 'Report',
      'reported_successfully': 'QR code reported successfully',
    },
    'ur': {
      // Common (Urdu)
      'app_name': 'سیف سکین کیو آر',
      'safe': 'محفوظ',
      'suspicious': 'مشکوک',
      'dangerous': 'خطرناک',
      'cancel': 'منسوخ',
      'ok': 'ٹھیک ہے',
      'yes': 'ہاں',
      'no': 'نہیں',
      
      // Onboarding
      'welcome': 'سیف سکین کیو آر میں خوش آمدید',
      'onboarding_title_1': 'کیو آر کوڈز کو محفوظ طریقے سے سکین کریں',
      'onboarding_desc_1': 'نقصان دہ کیو آر کوڈز کو پہلے سے پہچانیں',
      'onboarding_title_2': 'جدید سیکیورٹی',
      'onboarding_desc_2': 'اے آئی سے چلنے والی خطرات کی شناخت',
      'onboarding_title_3': 'محفوظ رہیں',
      'onboarding_desc_3': 'فشنگ اور میلویئر سے حقیقی وقت میں تحفظ',
      'get_started': 'شروع کریں',
      'skip': 'چھوڑیں',
      
      // Auth
      'welcome_back': 'خوش آمدید',
      'sign_in_continue': 'جاری رکھنے کے لیے سائن ان کریں',
      'email': 'ای میل ایڈریس',
      'password': 'پاس ورڈ',
      'forgot_password': 'پاس ورڈ بھول گئے؟',
      'sign_in': 'سائن ان',
      'dont_have_account': 'اکاؤنٹ نہیں ہے؟',
      'sign_up': 'سائن اپ',
      'create_account': 'اکاؤنٹ بنائیں',
      'join_safescan': 'آج ہی سیف سکین میں شامل ہوں',
      'full_name': 'پورا نام',
      'already_have_account': 'پہلے سے اکاؤنٹ ہے؟',
      'terms_agreement': 'سائن اپ کر کے، آپ ہماری شرائط اور رازداری کی پالیسی سے اتفاق کرتے ہیں',
      
      // Dashboard
      'hello_user': 'السلام علیکم 👋',
      'stay_safe': 'آن لائن محفوظ رہیں',
      'protection_status': 'تحفظ کی حیثیت',
      'fully_protected': 'مکمل طور پر محفوظ',
      'scans': 'سکینز',
      'blocked': 'بلاک شدہ',
      'quick_actions': 'فوری اقدامات',
      'scan_qr': 'کیو آر سکین',
      'upload_image': 'تصویر اپ لوڈ',
      'check_url': 'یو آر ایل چیک',
      'history': 'تاریخ',
      'recent_activity': 'حالیہ سرگرمی',
      'no_recent_activity': 'کوئی حالیہ سرگرمی نہیں',
      'start_scanning': 'اپنی تاریخ دیکھنے کے لیے سکیننگ شروع کریں',
      
      // Scanner
      'scan_qr_code': 'کیو آر کوڈ سکین کریں',
      'point_camera': 'اپنے کیمرے کو کیو آر کوڈ پر رکھیں',
      'toggle_flash': 'فلیش آن/آف',
      'upload_from_gallery': 'گیلری سے اپ لوڈ',
      
      // Results
      'scan_result': 'سکین کا نتیجہ',
      'risk_score': 'خطرے کا سکور',
      'high_risk': 'زیادہ خطرہ',
      'medium_risk': 'درمیانی خطرہ',
      'low_risk': 'کم خطرہ',
      'scanned_content': 'سکین شدہ مواد',
      'analysis_details': 'تجزیہ کی تفصیلات',
      'additional_info': 'اضافی معلومات',
      'open_safe_browser': 'محفوظ براؤزر میں کھولیں',
      'open_anyway': 'پھر بھی کھولیں (غیر محفوظ)',
      'report_qr': 'اس کیو آر کی اطلاع دیں',
      'danger_warning': 'خطرے کی وارننگ',
      'high_risk_warning': 'یہ یو آر ایل خطرناک ہے۔ اسے کھولنا آپ کی سیکیورٹی کو خطرے میں ڈال سکتا ہے۔ کیا آپ واقعی یقین رکھتے ہیں؟',
      'proceed_anyway': 'پھر بھی جاری رکھیں',
      
      // Settings
      'settings': 'ترتیبات',
      'profile': 'پروفائل',
      'manage_account': 'اپنے اکاؤنٹ کا نظم کریں',
      'scan_history': 'سکین کی تاریخ',
      'view_all_scans': 'اپنے تمام سکینز دیکھیں',
      'security': 'سیکیورٹی',
      'privacy_settings': 'رازداری اور سیکیورٹی کی ترتیبات',
      'help_support': 'مدد اور سپورٹ',
      'get_help': 'مدد حاصل کریں اور ہم سے رابطہ کریں',
      'logout': 'لاگ آؤٹ',
      'sign_out': 'اپنے اکاؤنٹ سے سائن آؤٹ کریں',
      'language': 'زبان',
      'choose_language': 'اپنی زبان منتخب کریں',
      'theme': 'تھیم',
      'dark_mode': 'ڈارک موڈ',
      'child_mode': 'بچوں کا موڈ',
      'simple_interface': 'بچوں کے لیے آسان انٹرفیس',
      
      // URL Checker
      'url_checker': 'یو آر ایل سیکیورٹی چیکر',
      'enter_url': 'فوری طور پر حفاظت کی جانچ کے لیے کوئی بھی یو آر ایل درج کریں',
      'url_placeholder': 'https://example.com',
      'analyze_url': 'یو آر ایل کا تجزیہ کریں',
      
      // Content Types
      'wifi_detected': 'وائی فائی کی معلومات ملی',
      'email_detected': 'ای میل ایڈریس ملا',
      'phone_detected': 'فون نمبر ملا',
      'payment_detected': 'ادائیگی کا لنک ملا',
      'contact_detected': 'رابطے کی معلومات ملی',
      'text_detected': 'سادہ متن',
      
      // Warnings
      'wifi_warning': 'صرف اس صورت میں جڑیں جب آپ ذریعہ پر بھروسہ کرتے ہوں',
      'payment_warning': 'ادائیگی سے پہلے وصول کنندہ کی تصدیق کریں',
      'verify_before_call': 'کال کرنے سے پہلے تصدیق کریں',
      'generally_safe': 'عام طور پر محفوظ',
      
      // Report
      'report_dangerous_qr': 'خطرناک کیو آر کی اطلاع دیں',
      'help_improve': 'اس کیو آر کوڈ کی اطلاع دے کر ہماری بہتری میں مدد کریں:',
      'reason_optional': 'وجہ (اختیاری)',
      'why_dangerous': 'یہ کیوں خطرناک ہے؟',
      'report': 'اطلاع دیں',
      'reported_successfully': 'کیو آر کوڈ کی کامیابی سے اطلاع دی گئی',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Shorthand method
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ur'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
