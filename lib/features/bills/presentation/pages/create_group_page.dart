import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/application/bloc/auth_bloc.dart';
import '../../application/bloc/bill_bloc.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/group_model.dart';
import '../../infrastructure/contacts_service.dart';

class CreateGroupPage extends StatefulWidget {
  final int month;
  final int year;

  const CreateGroupPage({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  List<ContactModel> _allContacts = [];
  List<ContactModel> _selectedContacts = [];
  List<ContactModel> _filteredContacts = [];
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadContacts() async {
    // Check if we have permission
    final hasPermission = await ContactsService.hasContactPermission();

    if (!hasPermission) {
      // Show permission dialog
      _showPermissionDialog();
    } else {
      // Load contacts
      context.read<BillBloc>().add(const LoadContacts());
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6EBEF),
        title: const Text('Contact Permission'),
        content: const Text(
          'This app needs access to your contacts to help you select group members. '
          'Your contacts will only be used locally on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Load mock contacts instead
              context.read<BillBloc>().add(const LoadContacts());
            },
            child: const Text('Use Sample Contacts'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final granted = await ContactsService.requestContactPermission();
              if (granted) {
                context.read<BillBloc>().add(const LoadContacts());
              } else {
                // Show message and use mock contacts
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permission denied. Using sample contacts.'),
                  ),
                );
                context.read<BillBloc>().add(const LoadContacts());
              }
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts
            .where((contact) =>
                contact.displayName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                contact.phoneNumber.contains(query))
            .toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filterContacts('');
      }
    });
  }

  void _onSearchChanged(String query) {
    _filterContacts(query);
  }

  void _toggleContactSelection(ContactModel contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void _createGroup() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      final currentUser = authState.user;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Add current user to members list
      final members = <GroupMember>[
        GroupMember(
          phoneNumber: currentUser.phoneNumber!,
          displayName: currentUser.displayName ?? 'Me',
          userId: currentUser.uid,
          joinedAt: DateTime.now(),
        ),
        ..._selectedContacts.map((contact) => GroupMember(
              phoneNumber: contact.phoneNumber,
              displayName: contact.displayName,
              userId: contact.userId,
              joinedAt: DateTime.now(),
            )),
      ];

      context.read<BillBloc>().add(CreateGroup(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            creatorId: currentUser.uid!,
            creatorPhone: currentUser.phoneNumber!,
            members: members,
            month: widget.month,
            year: widget.year,
          ));
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  // Neumorphic helper methods
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

  Widget _buildNeumorphicInput({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return _buildNeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          color: Color(0xFF2E3A4B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9EA8B5),
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EBEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6EBEF),
        title: _isSearching
            ? Container(
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
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search contacts...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintStyle: TextStyle(color: Color(0xFF9EA8B5)),
                  ),
                  style: const TextStyle(color: Color(0xFF2E3A4B)),
                  onChanged: _onSearchChanged,
                ),
              )
            : const Text(
                'Create Group',
                style: TextStyle(
                  color: Color(0xFF2E3A4B),
                  fontWeight: FontWeight.w600,
                ),
              ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E3A4B)),
        actions: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _toggleSearch,
                child: Center(
                  child: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: Colors.redAccent.shade100,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<BillBloc, BillState>(
        listener: (context, state) {
          if (state is ContactsLoaded) {
            setState(() {
              _allContacts = state.contacts;
              _filteredContacts = List.from(state.contacts);
            });
          } else if (state is GroupCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is BillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header info
              _buildNeumorphicContainer(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creating group for',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent.shade100,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_getMonthName(widget.month)} ${widget.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3A4B),
                      ),
                    ),
                  ],
                ),
              ),

              // Group details form
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNeumorphicInput(
                      controller: _nameController,
                      hint: 'e.g., Trip to Goa',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a group name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicInput(
                      controller: _descriptionController,
                      hint: 'What is this group for? (Optional)',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // Selected contacts header
              if (_selectedContacts.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Selected Members (${_selectedContacts.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedContacts.clear();
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),

              // Selected contacts chips
              if (_selectedContacts.isNotEmpty)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _selectedContacts[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EBEF),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.shade100.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(-2, -2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              contact.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent.shade100,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _toggleContactSelection(contact),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.redAccent.shade100,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Contacts list
              Expanded(
                child: BlocBuilder<BillBloc, BillState>(
                  builder: (context, state) {
                    if (state is BillLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_filteredContacts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.contacts,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No contacts available'
                                  : 'No contacts found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        final isSelected = _selectedContacts.contains(contact);

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6EBEF),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? Colors.redAccent.shade100.withOpacity(0.3)
                                    : const Color(0xFFBEC8D1),
                                offset: const Offset(4, 4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-4, -4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: _getAvatarColor(contact.displayName),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getAvatarColor(contact.displayName)
                                        .withOpacity(0.5),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(contact.displayName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              contact.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E3A4B),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.phoneNumber,
                                  style: const TextStyle(
                                    color: Color(0xFF7C8BA0),
                                  ),
                                ),
                                if (contact.isRegistered)
                                  const Text(
                                    '✓ Notiee User',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.redAccent.shade100
                                    : const Color(0xFFE6EBEF),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? Colors.redAccent.shade100
                                            .withOpacity(0.5)
                                        : const Color(0xFFBEC8D1),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                  const BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-2, -2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                            onTap: () => _toggleContactSelection(contact),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent.shade100, Colors.redAccent.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.shade100.withOpacity(0.5),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: -4,
              ),
              const BoxShadow(
                color: Color(0xFFBEC8D1),
                offset: Offset(8, 8),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-8, -8),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _createGroup,
              child: const Center(
                child: Text(
                  'Create Group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.pink.shade400,
    ];

    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }
}
