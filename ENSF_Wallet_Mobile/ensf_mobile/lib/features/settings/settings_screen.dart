import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _currency = 'FCFA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        children: [
          Card(
            elevation: ThemeConstants.defaultElevation,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: ThemeConstants.defaultElevation,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: const Text('English'),
                  onTap: () {
                    // TODO: Implement language selection
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Currency'),
                  trailing: DropdownButton<String>(
                    value: _currency,
                    isDense: true,
                    onChanged: (String? value) {
                      setState(() {
                        _currency = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'FCFA',
                        child: Text('FCFA'),
                      ),
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD'),
                      ),
                      DropdownMenuItem(
                        value: 'EUR',
                        child: Text('EUR'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: ThemeConstants.defaultElevation,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement help & support
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement about screen
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
