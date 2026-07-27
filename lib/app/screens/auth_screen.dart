import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_aqualink/app/providers/app_data_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isRegisterMode = false;
  bool _showPassword = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _locationController.clear();
    _contactController.clear();
    _ageController.clear();
    _errorText = null;
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _clearFields();
    });
  }

  void _handleSubmit() {
    final appData = context.read<AppDataProvider>();
    if (_isRegisterMode) {
      final error = appData.signUp(
        location: _locationController.text,
        username: _usernameController.text,
        contact: _contactController.text,
        age: _ageController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.translate('registration_success'))),
      );
    } else {
      final error = appData.logIn(
        _usernameController.text,
        _passwordController.text,
      );
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.translate('login_success'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final theme = Theme.of(context);
    final t = appData.translate;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? t('signup_title') : t('login_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AquaLink',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRegisterMode ? t('signup_title') : t('login_title'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_isRegisterMode) ...[
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: t('location_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: t('username_label'),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            if (_isRegisterMode) ...[
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: t('contact_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t('age_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: t('password_label'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            if (_isRegisterMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: t('confirm_password_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ],
            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(
                  _isRegisterMode ? t('signup_button') : t('login_button'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _toggleMode,
              child: Text(
                _isRegisterMode ? t('have_account') : t('no_account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
