import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notiee/core/utils/icon_path.dart';
import '../../../authentication/application/bloc/auth_bloc.dart';
import '../../application/bloc/bill_bloc.dart';
import '../../domain/models/group_model.dart';
import '../widgets/month_tabs.dart';
import '../widgets/group_card.dart';
import 'create_group_page.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  List<GroupModel> _currentGroups = [];
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.phoneNumber != null) {
      _userPhone = authState.user!.phoneNumber!;
      _loadGroupsByCurrentMonth();
    }
  }

  void _loadGroupsByCurrentMonth() {
    if (_userPhone != null) {
      context
          .read<BillBloc>()
          .add(LoadGroupsByMonth(_userPhone!, _selectedMonth, _selectedYear));
    }
  }

  void _onMonthChanged(int month, int year) {
    setState(() {
      _selectedMonth = month;
      _selectedYear = year;
    });

    if (_userPhone != null) {
      context.read<BillBloc>().add(LoadGroupsByMonth(_userPhone!, month, year));
    }
  }

  void _createGroup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupPage(
          month: _selectedMonth,
          year: _selectedYear,
        ),
      ),
    );

    if (result == true) {
      _loadGroupsByCurrentMonth();
    }
  }

  void _onGroupTap(GroupModel group) {
    // TODO: Navigate to group details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on ${group.name}'),
      ),
    );
  }

  void _onEditGroup(GroupModel group) {
    // TODO: Navigate to edit group page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${group.name}'),
      ),
    );
  }

  void _onDeleteGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authState = context.read<AuthBloc>().state;
              if (authState.user?.uid != null) {
                context.read<BillBloc>().add(
                      DeleteGroup(group.id, authState.user!.uid!),
                    );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _isUserCreator(GroupModel group) {
    final authState = context.read<AuthBloc>().state;
    return authState.user?.uid == group.creatorId;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade50,
      body: BlocListener<BillBloc, BillState>(
        listener: (context, state) {
          if (state is GroupsLoadedByMonth) {
            setState(() {
              _currentGroups = state.groups;
            });
          } else if (state is GroupDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadGroupsByCurrentMonth();
          } else if (state is BillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Month tabs
            MonthTabs(
              selectedMonth: _selectedMonth,
              selectedYear: _selectedYear,
              onMonthChanged: _onMonthChanged,
            ),

            const SizedBox(height: 16),

            // Content area
            Expanded(
              child: BlocBuilder<BillBloc, BillState>(
                builder: (context, state) {
                  if (state is BillLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_currentGroups.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: _currentGroups.length,
                    itemBuilder: (context, index) {
                      final group = _currentGroups[index];
                      return GroupCard(
                        group: group,
                        isCreator: _isUserCreator(group),
                        onTap: () => _onGroupTap(group),
                        onEdit: () => _onEditGroup(group),
                        onDelete: () => _onDeleteGroup(group),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentGroups.isNotEmpty
          ? FloatingActionButton.small(
              onPressed: _createGroup,
              backgroundColor: Colors.white,
              foregroundColor: Colors.redAccent.shade100,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            IconPath.empty_group,
            width: 150,
            height: 150,
          ),
          const Text(
            'No Groups Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group for ${_getMonthName(_selectedMonth)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _createGroup,
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade100,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
