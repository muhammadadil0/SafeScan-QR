import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/browser_tracking_service.dart';
import '../../models/browser_history_item.dart';
import '../../models/form_data_item.dart';
import '../../models/password_entry.dart';
import 'browser_analytics_screen.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  final BrowserTrackingService _trackingService = BrowserTrackingService();

  String _currentUrl = 'https://www.google.com';
  String _currentTitle = 'Google';
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;
  int _loadingProgress = 0;
  DateTime? _pageStartTime;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _urlController.text = _currentUrl;

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    // Periodically check for form data
    Future.delayed(const Duration(seconds: 3), () {
      _startPeriodicFormCheck();
    });
  }

  @override
  void dispose() {
    // Restore system UI when leaving browser
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _urlController.dispose();
    super.dispose();
  }

  void _startPeriodicFormCheck() {
    // Check every 3 seconds for new form data
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkForStoredFormData();
        _startPeriodicFormCheck();
      }
    });
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
              _urlController.text = url;
              _pageStartTime = DateTime.now();
            });
          },
          onPageFinished: (url) async {
            setState(() {
              _isLoading = false;
            });

            // Get page title
            final title = await _controller.getTitle() ?? 'Untitled';
            setState(() {
              _currentTitle = title;
            });

            // Track page visit
            final timeSpent = _pageStartTime != null
                ? DateTime.now().difference(_pageStartTime!)
                : Duration.zero;

            await _trackingService.saveHistory(
              BrowserHistoryItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                url: url,
                title: title,
                timestamp: DateTime.now(),
                timeSpent: timeSpent,
              ),
            );

            // Update navigation buttons
            _updateNavigationState();

            // Inject form tracking script
            _injectFormTracker();
          },
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onWebResourceError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  void _injectFormTracker() {
    // Enhanced JavaScript to track form submissions and passwords
    _controller.runJavaScript('''
      (function() {
        console.log('Form tracker initialized');
        
        // Store for tracking input changes
        let formInputs = {};
        let passwordData = {};
        
        // Function to get all form inputs
        function captureFormData() {
          const forms = document.querySelectorAll('form');
          forms.forEach(form => {
            const inputs = form.querySelectorAll('input, textarea, select');
            inputs.forEach(input => {
              if (input.name || input.id) {
                const key = input.name || input.id;
                
                // Track input changes
                input.addEventListener('change', function() {
                  const type = input.type || 'text';
                  
                  if (type === 'password') {
                    // Store password info
                    passwordData[key] = {
                      hasPassword: true,
                      field: key
                    };
                  } else if (type === 'email' || type === 'text') {
                    formInputs[key] = input.value;
                  }
                });
                
                input.addEventListener('blur', function() {
                  const type = input.type || 'text';
                  if (type === 'email' || type === 'text') {
                    formInputs[key] = input.value;
                  }
                });
              }
            });
          });
        }
        
        // Track form submissions
        document.addEventListener('submit', function(e) {
          console.log('Form submitted');
          const form = e.target;
          const inputs = form.querySelectorAll('input, textarea, select');
          const data = {};
          let hasPassword = false;
          let username = '';
          let password = '';
          
          inputs.forEach(input => {
            const key = input.name || input.id || 'field_' + Math.random();
            const type = input.type || 'text';
            
            if (type === 'password') {
              hasPassword = true;
              password = input.value;
              data[key] = '***HIDDEN***';
            } else if (type === 'email') {
              username = input.value;
              data[key] = input.value;
            } else if (type === 'text' && !username) {
              username = input.value;
              data[key] = input.value;
            } else {
              data[key] = input.value;
            }
          });
          
          // Store in localStorage for Flutter to read
          const formDataToSave = {
            url: window.location.href,
            domain: window.location.hostname,
            fields: data,
            hasPassword: hasPassword,
            username: username,
            password: hasPassword ? 'STORED' : '',
            timestamp: new Date().toISOString()
          };
          
          localStorage.setItem('lastFormSubmit', JSON.stringify(formDataToSave));
          console.log('Form data saved to localStorage');
        }, true);
        
        // Track password field changes
        function trackPasswordFields() {
          const passwordFields = document.querySelectorAll('input[type="password"]');
          passwordFields.forEach(field => {
            field.addEventListener('change', function() {
              console.log('Password field changed');
              const form = this.closest('form');
              if (form) {
                const emailField = form.querySelector('input[type="email"]');
                const textFields = form.querySelectorAll('input[type="text"]');
                let username = '';
                
                if (emailField && emailField.value) {
                  username = emailField.value;
                } else if (textFields.length > 0) {
                  for (let i = 0; i < textFields.length; i++) {
                    if (textFields[i].value) {
                      username = textFields[i].value;
                      break;
                    }
                  }
                }
                
                if (username) {
                  const passwordInfo = {
                    url: window.location.href,
                    domain: window.location.hostname,
                    username: username,
                    timestamp: new Date().toISOString()
                  };
                  localStorage.setItem('lastPasswordEntry', JSON.stringify(passwordInfo));
                  console.log('Password entry saved');
                }
              }
            });
          });
        }
        
        // Initialize tracking
        captureFormData();
        trackPasswordFields();
        
        // Re-track on DOM changes (for dynamic forms like Google)
        const observer = new MutationObserver(function(mutations) {
          captureFormData();
          trackPasswordFields();
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
        
        console.log('Form tracker ready');
      })();
    ''');

    // Check for stored form data after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _checkForStoredFormData();
    });
  }

  Future<void> _checkForStoredFormData() async {
    try {
      // Check for form submission
      final formDataJson = await _controller.runJavaScriptReturningResult(
          "localStorage.getItem('lastFormSubmit')") as String?;

      if (formDataJson != null &&
          formDataJson != 'null' &&
          formDataJson.isNotEmpty) {
        final cleanJson = formDataJson.replaceAll('"', '');
        if (cleanJson.isNotEmpty && cleanJson != 'null') {
          // Parse and save form data
          await _saveFormDataFromJS(formDataJson);
          // Clear the stored data
          await _controller
              .runJavaScript("localStorage.removeItem('lastFormSubmit')");
        }
      }

      // Check for password entry
      final passwordJson = await _controller.runJavaScriptReturningResult(
          "localStorage.getItem('lastPasswordEntry')") as String?;

      if (passwordJson != null &&
          passwordJson != 'null' &&
          passwordJson.isNotEmpty) {
        final cleanJson = passwordJson.replaceAll('"', '');
        if (cleanJson.isNotEmpty && cleanJson != 'null') {
          // Parse and save password
          await _savePasswordFromJS(passwordJson);
          // Clear the stored data
          await _controller
              .runJavaScript("localStorage.removeItem('lastPasswordEntry')");
        }
      }
    } catch (e) {
      debugPrint('Error checking stored form data: $e');
    }
  }

  Future<void> _saveFormDataFromJS(String jsonData) async {
    try {
      // Simple parsing since we're getting JSON string
      final url = _currentUrl;
      final domain = Uri.parse(url).host;

      await _trackingService.saveFormData(
        FormDataItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: url,
          domain: domain,
          fields: {'captured': 'true'},
          timestamp: DateTime.now(),
          hasPassword: true,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Form data captured'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving form data: $e');
    }
  }

  Future<void> _savePasswordFromJS(String jsonData) async {
    try {
      final url = _currentUrl;
      final domain = Uri.parse(url).host;

      // Try to get username from the page
      final username = await _controller.runJavaScriptReturningResult('''
        (function() {
          const emailInput = document.querySelector('input[type="email"]');
          if (emailInput) return emailInput.value;
          const textInputs = document.querySelectorAll('input[type="text"]');
          for (let input of textInputs) {
            if (input.value) return input.value;
          }
          return '';
        })();
        ''') as String?;

      final cleanUsername = username?.replaceAll('"', '') ?? 'user';

      if (cleanUsername.isNotEmpty && cleanUsername != 'null') {
        await _trackingService.savePassword(
          PasswordEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            url: url,
            domain: domain,
            username: cleanUsername,
            password: '***SECURED***',
            timestamp: DateTime.now(),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password saved for $cleanUsername'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving password: $e');
    }
  }

  void _loadUrl(String url) {
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }
    _controller.loadRequest(Uri.parse(finalUrl));
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter URL'),
        content: TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            prefixIcon: Icon(Icons.link),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _loadUrl(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadUrl(_urlController.text);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Toggle controls visibility on tap
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // Full WebView
            WebViewWidget(controller: _controller),

            // Overlay controls (shown/hidden)
            if (_showControls) ...[
              // Top gradient overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildAppBar(isDark),
                        _buildUrlBar(isDark),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: _buildNavigationBar(isDark),
                  ),
                ),
              ),
            ],

            // Loading Progress (always visible)
            if (_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: LinearProgressIndicator(
                    value: _loadingProgress / 100,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF667eea),
                    ),
                  ),
                ),
              ),

            // Floating fullscreen toggle button
            if (!_showControls)
              Positioned(
                top: 40,
                right: 16,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showControls = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrowserAnalyticsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: GestureDetector(
        onTap: _showUrlDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _currentUrl,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.refresh,
                size: 18,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavButton(
            icon: Icons.arrow_back,
            onTap: _canGoBack ? () => _controller.goBack() : null,
            isDark: isDark,
          ),
          _NavButton(
            icon: Icons.arrow_forward,
            onTap: _canGoForward ? () => _controller.goForward() : null,
            isDark: isDark,
          ),
          _NavButton(
            icon: Icons.refresh,
            onTap: () => _controller.reload(),
            isDark: isDark,
          ),
          _NavButton(
            icon: Icons.home,
            onTap: () => _loadUrl('https://www.google.com'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: onTap != null
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : Colors.white.withOpacity(0.3),
          size: 22,
        ),
      ),
    );
  }
}
