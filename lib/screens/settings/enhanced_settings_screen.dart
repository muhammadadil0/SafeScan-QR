import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/child_mode_provider.dart';
import '../../services/history_service.dart';

class EnhancedSettingsScreen extends StatelessWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final childModeProvider = Provider.of<ChildModeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [const Color(0xFFF5F7FA), const Color(0xFFE8EAF6)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Section
              _SectionHeader(title: 'Appearance', isDark: isDark),
              const SizedBox(height: 12),

              // Dark Mode Toggle
              _SettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  activeColor: const Color(0xFF667eea),
                ),
                onTap: () => themeProvider.toggleTheme(),
              ),

              const SizedBox(height: 24),

              // Language Section
              _SectionHeader(title: 'Language', isDark: isDark),
              const SizedBox(height: 12),

              // Language Selection
              _SettingsTile(
                icon: Icons.language,
                title: 'App Language',
                subtitle: languageProvider.languageCode == 'en' ? 'English' : 'اردو',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, languageProvider),
              ),

              const SizedBox(height: 24),

              // Accessibility Section
              _SectionHeader(title: 'Accessibility', isDark: isDark),
              const SizedBox(height: 12),

              // Child Mode Toggle
              _SettingsTile(
                icon: Icons.child_care,
                title: 'Child Mode',
                subtitle: 'Simplified interface for children',
                trailing: Switch(
                  value: childModeProvider.isChildMode,
                  onChanged: (value) => childModeProvider.toggleChildMode(),
                  activeColor: const Color(0xFF667eea),
                ),
                onTap: () => childModeProvider.toggleChildMode(),
              ),

              const SizedBox(height: 24),

              // Account Section
              _SectionHeader(title: 'Account', isDark: isDark),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Manage your account',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.history,
                title: 'Scan History',
                subtitle: 'View all your scans',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Privacy Section
              _SectionHeader(title: 'Privacy & Security', isDark: isDark),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.security,
                title: 'Security Settings',
                subtitle: 'Privacy & security preferences',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear History',
                subtitle: 'Delete all scan history',
                color: Colors.orange,
                onTap: () => _showClearHistoryDialog(context),
              ),

              const SizedBox(height: 24),

              // Support Section
              _SectionHeader(title: 'Support', isDark: isDark),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact us',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: 24),

              // Logout
              _SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                color: Colors.red,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: provider.languageCode == 'en'
                  ? const Icon(Icons.check, color: Color(0xFF667eea))
                  : null,
              onTap: () {
                provider.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇵🇰', style: TextStyle(fontSize: 24)),
              title: const Text('اردو (Urdu)'),
              trailing: provider.languageCode == 'ur'
                  ? const Icon(Icons.check, color: Color(0xFF667eea))
                  : null,
              onTap: () {
                provider.setLanguage('ur');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all scan history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final historyService = HistoryService();
              await historyService.clearHistory();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SafeScan QR',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF667eea),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
      ),
      children: const [
        Text('Your personal QR code security guardian.'),
        SizedBox(height: 16),
        Text('Protect yourself from phishing, malware, and malicious QR codes.'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF667eea)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? const Color(0xFF667eea)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? (isDark ? Colors.white : Colors.grey[900]),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

// History Screen
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All History'),
                  content: const Text('Delete all scan history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _historyService.clearHistory();
                        if (context.mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _historyService.getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No scan history',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final scan = history[index];
              final riskColor = scan.riskScore >= 70
                  ? Colors.red
                  : scan.riskScore >= 40
                      ? Colors.orange
                      : Colors.green;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: riskColor.withOpacity(0.1),
                    child: Text(
                      '${scan.riskScore}',
                      style: TextStyle(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    scan.originalUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${scan.timestamp.day}/${scan.timestamp.month}/${scan.timestamp.year} ${scan.timestamp.hour}:${scan.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    scan.status == SecurityStatus.safe
                        ? Icons.check_circle
                        : scan.status == SecurityStatus.dangerous
                            ? Icons.dangerous
                            : Icons.warning,
                    color: riskColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
