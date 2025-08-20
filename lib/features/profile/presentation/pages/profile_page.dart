import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            icon: const Icon(Icons.logout),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(),
                const SizedBox(height: 30),

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
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  const NetworkImage('https://via.placeholder.com/150'),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _changeProfilePicture,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to change profile picture',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade100,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _populateFields(ProfileModel profile) {
    _nameController.text = profile.name ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _emailController.text = profile.email ?? '';
  }

  void _changeProfilePicture() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture change coming soon!')),
    );
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
              content: Text('Password must be at least 6 characters')),
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
}
