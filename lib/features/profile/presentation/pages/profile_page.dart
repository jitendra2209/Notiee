import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/bloc/profile_bloc.dart';
import '../../domain/model/profile_model.dart';
import '../../../authentication/application/bloc/auth_bloc.dart';
import '../../../authentication/application/bloc/auth_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPasswordSection = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Edit states for individual fields
  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isEditingEmail = false;

  @override
  void initState() {
    super.initState();
    // Load user profile when page initializes
    _loadUserProfile();

    // Add listener to update password strength indicator
    _newPasswordController.addListener(() {
      setState(() {});
    });
  }

  void _loadUserProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      // First populate with existing auth user data
      _populateFromAuthUser(authState.user!);
      // Then try to load from profile collection
      context
          .read<ProfileBloc>()
          .add(ProfileLoadRequested(authState.user!.uid!));
    }
  }

  void _populateFromAuthUser(user) {
    setState(() {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _emailController.text = user.email ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );

            // If there's a permission error, show additional help
            if (state.message.contains('permission') ||
                state.message.contains('denied') ||
                state.message.contains('PERMISSION_DENIED')) {
              _showPermissionErrorDialog();
            }
          } else if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Clear password fields after successful update
            if (state.message.contains('Password')) {
              _currentPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
              setState(() {
                _showPasswordSection = false;
              });
            }
          } else if (state is ProfileLoaded) {
            _populateFields(state.profile);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Info Section
                _buildUserInfoSection(),
                const SizedBox(height: 30),

                // Password Section
                _buildPasswordSection(),
                const SizedBox(height: 30),

                // Save Button - Only show when editing or password section is open
                if (_isEditingName ||
                    _isEditingPhone ||
                    _isEditingEmail ||
                    _showPasswordSection)
                  _buildSaveButton(),
                const SizedBox(height: 10),

                // Developer Details Section
                _buildDeveloperSection(),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Name Field
        _buildEditableField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          isEditing: _isEditingName,
          onEditToggle: () {
            setState(() {
              _isEditingName = !_isEditingName;
            });
          },
        ),
        const SizedBox(height: 16),

        // Phone Field
        _buildEditableField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+91XXXXXXXXXX',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isEditing: _isEditingPhone,
          onEditToggle: () {
            setState(() {
              _isEditingPhone = !_isEditingPhone;
            });
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        _buildEditableField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter your email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isEditing: _isEditingEmail,
          onEditToggle: () {
            setState(() {
              _isEditingEmail = !_isEditingEmail;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showPasswordSection = !_showPasswordSection;
                });
              },
              child: Text(
                _showPasswordSection ? 'Cancel' : 'Change Password',
                style: TextStyle(
                  color: Colors.redAccent.shade100,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (_showPasswordSection) ...[
          const SizedBox(height: 16),

          // Current Password
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Current Password',
            hint: 'Enter current password',
            obscureText: _obscureCurrentPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
          ),
          const SizedBox(height: 16),

          // New Password
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'New Password',
            hint: 'Enter new password',
            obscureText: _obscureNewPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
          // Password strength indicator
          if (_newPasswordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPasswordStrengthIndicator(),
          ],
          const SizedBox(height: 16),

          // Confirm Password
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            hint: 'Confirm new password',
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEditToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: onEditToggle,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isEditing
                      ? Colors.redAccent.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  size: 16,
                  color: isEditing ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isEditing ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isEditing ? Colors.redAccent.shade100 : Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: !isEditing,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: isEditing
                    ? Colors.redAccent.shade100
                    : Colors.grey.shade600,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
            style: TextStyle(
              color: isEditing ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade600,
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade100,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Saving...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _populateFields(ProfileModel profile) {
    _nameController.text = profile.name ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _emailController.text = profile.email ?? '';
  }

  bool get _isAnyFieldEditing =>
      _isEditingName || _isEditingPhone || _isEditingEmail;

  void _saveProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    if (_showPasswordSection) {
      // Validate password fields
      if (_currentPasswordController.text.isEmpty ||
          _newPasswordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all password fields')),
        );
        return;
      }

      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }

      if (_newPasswordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 6 characters'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Check password strength
      if (!_isStrongPassword(_newPasswordController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Password should contain letters, numbers, and be at least 8 characters'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Update password
      context.read<ProfileBloc>().add(
            ProfilePasswordUpdateRequested(
              userId: authState.user!.uid!,
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            ),
          );
    } else if (_isAnyFieldEditing) {
      // Update profile info
      final profile = ProfileModel(
        id: authState.user!.uid!,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        updatedAt: DateTime.now(),
      );

      context.read<ProfileBloc>().add(ProfileUpdateRequested(profile));

      // Reset edit states after saving
      setState(() {
        _isEditingName = false;
        _isEditingPhone = false;
        _isEditingEmail = false;
      });
    }
  }

  void _showPermissionErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Error'),
          content: const Text(
            'There seems to be a permissions issue with accessing your profile data. '
            'This might be due to Firestore security rules. Please contact support '
            'or try logging out and logging back in.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showLogoutDialog();
              },
              child: const Text('Logout & Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested(
                      onSuccess: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (_) => false);
                      },
                      onFailure: () {},
                    ));
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final strength = _getPasswordStrength(password);

    Color strengthColor;
    String strengthText;
    double strengthValue;

    switch (strength) {
      case PasswordStrength.weak:
        strengthColor = Colors.red;
        strengthText = 'Weak';
        strengthValue = 0.3;
        break;
      case PasswordStrength.medium:
        strengthColor = Colors.orange;
        strengthText = 'Medium';
        strengthValue = 0.6;
        break;
      case PasswordStrength.strong:
        strengthColor = Colors.green;
        strengthText = 'Strong';
        strengthValue = 1.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strengthValue,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Password should be at least 8 characters with letters and numbers',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  PasswordStrength _getPasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.medium;

    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (hasLetter && hasNumber && hasSpecial) return PasswordStrength.strong;
    if (hasLetter && hasNumber) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  bool _isStrongPassword(String password) {
    // Check if password has at least 8 characters, contains letters and numbers
    if (password.length < 8) return false;

    bool hasLetter = false;
    bool hasNumber = false;

    for (int i = 0; i < password.length; i++) {
      final char = password[i];
      if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
        hasLetter = true;
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        hasNumber = true;
      }

      if (hasLetter && hasNumber) break;
    }

    return hasLetter && hasNumber;
  }

  Widget _buildDeveloperSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          Icons.code,
          color: Colors.redAccent.shade100,
        ),
        title: const Text(
          'Developer Info',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: const Text(
          'About the app developer',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Developer Info
                _buildDeveloperInfo(),
                const SizedBox(height: 20),

                // Social Media Links
                _buildSocialMediaLinks(),
                const SizedBox(height: 16),

                // App Info
                _buildAppInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jitendra Mannuru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Flutter Developer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Passionate Flutter developer creating beautiful and functional mobile applications. '
          'Specializing in clean architecture and user-centric design.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect with me',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSocialButton(
              icon: Icons.code,
              label: 'GitHub',
              color: Colors.black87,
              url: 'https://github.com/jitendra2209',
            ),
            _buildSocialButton(
              icon: Icons.work,
              label: 'LinkedIn',
              color: const Color(0xFF0077B5),
              url: 'https://www.linkedin.com/in/jitendra-mannuru-05169a15a/',
            ),
            _buildSocialButton(
              icon: Icons.facebook,
              label: 'Facebook',
              color: const Color(0xFF1877F2),
              url: 'https://www.facebook.com/mannuru.jitendra/',
            ),
            _buildSocialButton(
              icon: Icons.chat,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              url: 'https://wa.me/+919652154797',
            ),
            _buildSocialButton(
              icon: Icons.alternate_email,
              label: 'Twitter',
              color: const Color(0xFF1DA1F2),
              url: 'https://x.com/Jitendra_mannur',
            ),
            _buildSocialButton(
              icon: Icons.language,
              label: 'Website',
              color: Colors.redAccent.shade100,
              url: 'https://jitendraportfolio.vercel.app/',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Notiee',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notiee is your smart daily companion for managing todos and bills. '
            'Built with Flutter and powered by Firebase for a seamless experience.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.apps, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.flutter_dash, size: 14, color: Colors.blue),
              SizedBox(width: 4),
              Text(
                'Flutter',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Try to launch the URL with different modes
      bool launched = false;

      try {
        // First try with external application mode
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('Failed to launch with external mode: $e');

        // Fallback to platform default mode
        try {
          launched = await launchUrl(uri);
        } catch (e2) {
          print('Failed to launch with default mode: $e2');
          launched = false;
        }
      }

      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error parsing or launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum PasswordStrength { weak, medium, strong }
