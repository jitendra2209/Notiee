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

  // Developer section expansion state
  bool _isDeveloperExpanded = false;

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
      backgroundColor: const Color(0xFFE6EBEF),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Neumorphic Design
            _buildNeumorphicAppBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeumorphicAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: _buildNeumorphicContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _buildNeumorphicButton(
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF7C8BA0),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ),
              _buildNeumorphicButton(
                child: const Icon(
                  Icons.logout,
                  size: 18,
                  color: Color(0xFFE53E3E),
                ),
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: const Color(0xFFE53E3E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              duration: const Duration(seconds: 4),
            ),
          );

          if (state.message.contains('permission') ||
              state.message.contains('denied') ||
              state.message.contains('PERMISSION_DENIED')) {
            _showPermissionErrorDialog();
          }
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF38A169),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Profile Avatar Section
              _buildProfileAvatarSection(),
              const SizedBox(height: 24),

              // User Info Section
              _buildUserInfoSection(),
              const SizedBox(height: 24),

              // Security Section
              _buildPasswordSection(),
              const SizedBox(height: 24),

              // Save Button
              if (_isEditingName ||
                  _isEditingPhone ||
                  _isEditingEmail ||
                  _showPasswordSection)
                _buildSaveButton(),
              const SizedBox(height: 24),

              // Developer Section
              _buildDeveloperSection(),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // Neumorphic Design Helper Methods
  Widget _buildNeumorphicContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFE6EBEF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFBEC8D1),
            offset: Offset(8, 8),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNeumorphicButton({
    required Widget child,
    required VoidCallback onTap,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width ?? 40,
        height: height ?? 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE6EBEF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFBEC8D1),
              offset: Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildNeumorphicInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isEditing = false,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6EBEF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEditing
            ? [
                const BoxShadow(
                  color: Color(0xFFBEC8D1),
                  offset: Offset(4, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0xFFBEC8D1),
                  offset: Offset(2, 2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-2, -2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: !isEditing,
        obscureText: obscureText,
        style: TextStyle(
          color: isEditing ? const Color(0xFF2D3748) : const Color(0xFF7C8BA0),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color:
                isEditing ? const Color(0xFF667EEA) : const Color(0xFF7C8BA0),
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatarSection() {
    return _buildNeumorphicContainer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBEF),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFBEC8D1),
                  offset: Offset(6, 6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-6, -6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF667EEA),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : 'Your Name',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _phoneController.text.isNotEmpty
                ? _phoneController.text
                : 'Phone Number',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C8BA0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return _buildNeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),

          // Name Field
          _buildNeumorphicEditableField(
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
          _buildNeumorphicEditableField(
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
          _buildNeumorphicEditableField(
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
      ),
    );
  }

  Widget _buildNeumorphicEditableField({
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
                color: Color(0xFF4A5568),
              ),
            ),
            _buildNeumorphicButton(
              width: 32,
              height: 32,
              child: Icon(
                isEditing ? Icons.check : Icons.edit,
                size: 16,
                color: isEditing
                    ? const Color(0xFF38A169)
                    : const Color(0xFF667EEA),
              ),
              onTap: onEditToggle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildNeumorphicInput(
          controller: controller,
          hint: hint,
          icon: icon,
          isEditing: isEditing,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return _buildNeumorphicContainer(
      child: Column(
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
                  color: Color(0xFF2D3748),
                ),
              ),
              _buildNeumorphicButton(
                width: 120,
                height: 36,
                child: Text(
                  _showPasswordSection ? 'Cancel' : 'Change',
                  style: const TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _showPasswordSection = !_showPasswordSection;
                  });
                },
              ),
            ],
          ),
          if (_showPasswordSection) ...[
            const SizedBox(height: 20),

            // Current Password
            _buildNeumorphicPasswordField(
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
            _buildNeumorphicPasswordField(
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
              const SizedBox(height: 12),
              _buildPasswordStrengthIndicator(),
            ],
            const SizedBox(height: 16),

            // Confirm Password
            _buildNeumorphicPasswordField(
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
      ),
    );
  }

  Widget _buildNeumorphicPasswordField({
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
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        _buildNeumorphicInput(
          controller: controller,
          hint: hint,
          icon: Icons.lock_outline,
          isEditing: true,
          obscureText: obscureText,
          suffixIcon: _buildNeumorphicButton(
            width: 32,
            height: 32,
            child: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              size: 16,
              color: const Color(0xFF7C8BA0),
            ),
            onTap: onToggleVisibility,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent.shade100, Colors.redAccent.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF667EEA),
                offset: Offset(0, 4),
                blurRadius: 15,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _saveProfile,
              borderRadius: BorderRadius.circular(16),
              child: Center(
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
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBEF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFBEC8D1),
                  offset: Offset(8, 8),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-8, -8),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EBEF),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFBEC8D1),
                        offset: Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Color(0xFFD69E2E),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Permission Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                const Text(
                  'There seems to be a permissions issue with accessing your profile data. '
                  'This might be due to Firestore security rules. Please contact support '
                  'or try logging out and logging back in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C8BA0),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    // OK Button
                    Expanded(
                      child: _buildNeumorphicDialogButton(
                        text: 'OK',
                        textColor: const Color(0xFF667EEA),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Logout & Try Again Button
                    Expanded(
                      child: _buildNeumorphicDialogButton(
                        text: 'Logout & Try Again',
                        textColor: const Color(0xFFE53E3E),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showLogoutDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBEF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EBEF),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFBEC8D1),
                        offset: Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFE53E3E),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C8BA0),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: _buildNeumorphicDialogButton(
                        text: 'Cancel',
                        textColor: const Color(0xFF7C8BA0),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Logout Button
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFE53E3E),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(AuthSignOutRequested(
                                    onSuccess: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/login', (_) => false);
                                    },
                                    onFailure: () {},
                                  ));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeumorphicDialogButton({
    required String text,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE6EBEF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFBEC8D1),
              offset: Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
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
        strengthColor = const Color(0xFFE53E3E);
        strengthText = 'Weak';
        strengthValue = 0.3;
        break;
      case PasswordStrength.medium:
        strengthColor = const Color(0xFFD69E2E);
        strengthText = 'Medium';
        strengthValue = 0.6;
        break;
      case PasswordStrength.strong:
        strengthColor = const Color(0xFF38A169);
        strengthText = 'Strong';
        strengthValue = 1.0;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EBEF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFBEC8D1),
            offset: Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEC8D1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: strengthValue,
                    child: Container(
                      decoration: BoxDecoration(
                        color: strengthColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
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
          const SizedBox(height: 6),
          const Text(
            'Password should be at least 8 characters with letters and numbers',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF7C8BA0),
            ),
          ),
        ],
      ),
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
    return _buildNeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isDeveloperExpanded = !_isDeveloperExpanded;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EBEF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFBEC8D1),
                        offset: Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.code,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developer Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        'About the app developer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C8BA0),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isDeveloperExpanded ? 0.5 : 0,
                  child: _buildNeumorphicButton(
                    width: 32,
                    height: 32,
                    child: const Icon(
                      Icons.expand_more,
                      size: 16,
                      color: Color(0xFF667EEA),
                    ),
                    onTap: () {
                      setState(() {
                        _isDeveloperExpanded = !_isDeveloperExpanded;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isDeveloperExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 20),

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
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EBEF),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFBEC8D1),
                offset: Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF667EEA),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jitendra Mannuru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                'Flutter Developer',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7C8BA0),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Passionate Flutter developer creating beautiful mobile applications.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4A5568),
                  height: 1.4,
                ),
              ),
            ],
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
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSocialButton(
              icon: Icons.code,
              label: 'GitHub',
              color: const Color(0xFF2D3748),
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
              color: const Color(0xFF667EEA),
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
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE6EBEF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFBEC8D1),
              offset: Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-2, -2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EBEF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFBEC8D1),
            offset: Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Notiee',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your smart daily companion for managing todos and notes. '
            'Built with Flutter and powered by Firebase.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4A5568),
              height: 1.3,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.apps, size: 14, color: Color(0xFF667EEA)),
              SizedBox(width: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7C8BA0),
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.flutter_dash, size: 14, color: Color(0xFF667EEA)),
              SizedBox(width: 4),
              Text(
                'Flutter',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7C8BA0),
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
