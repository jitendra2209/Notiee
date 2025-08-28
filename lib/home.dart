import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notiee/core/utils/icon_path.dart';
import 'features/todo/presentation/pages/todo_list_page.dart';
import 'features/bills/presentation/pages/bills_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Widget> _pages = [
    const TodoListPage(), // Todos
    const BillsPage(), // Bills
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });

    if (_isFabExpanded) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void _onMenuItemTap(String action) {
    _toggleFab(); // Close the menu

    if (action == 'todo') {
      Navigator.pushNamed(context, '/add_edit_todo');
    } else if (action == 'note') {
      Navigator.pushNamed(context, '/add_edit_note');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 10),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.redAccent.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () {
          //     context.read<AuthBloc>().add(AuthSignOutRequested(
          //           onSuccess: () {
          //             Navigator.pushNamedAndRemoveUntil(
          //                 context, '/login', (_) => false);
          //           },
          //           onFailure: () {},
          //         ));
          //   },
          // ),
        ],
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_selectedIndex == 0) _buildAnimatedFabMenu(),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0 ? _buildFloatingActionButton(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 80, right: 80, bottom: 16),
          height: 50,
          decoration: BoxDecoration(
            color: Colors.redAccent.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildNavItem(
              icon: IconPath.svgnotes,
              label: 'Todos',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            _buildNavItem(
              icon: IconPath.svgbill,
              label: 'Bills',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
          ]),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Todos';
      case 1:
        return 'Bills';

      default:
        return 'Home';
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: _toggleFab,
      backgroundColor: Colors.white,
      foregroundColor: Colors.redAccent.shade100,
      elevation: 4,
      child: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _fabAnimation.value * 0.1, // 45 degrees in radians
            child: Icon(
              _isFabExpanded ? Icons.close : Icons.add,
              size: 28,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedFabMenu() {
    return Positioned(
      bottom: 90, // Position above the FAB and bottom nav
      right: 16,
      child: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Add Note option
              Transform.translate(
                offset: Offset(0, (1 - _fabAnimation.value) * 50),
                child: Opacity(
                  opacity: _fabAnimation.value,
                  child: _buildMenuOption(
                    icon: Icons.note_add,
                    label: 'Add Note',
                    onTap: () => _onMenuItemTap('note'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Add Todo option
              Transform.translate(
                offset: Offset(0, (1 - _fabAnimation.value) * 30),
                child: Opacity(
                  opacity: _fabAnimation.value,
                  child: _buildMenuOption(
                    icon: Icons.task_alt,
                    label: 'Add Todo',
                    onTap: () => _onMenuItemTap('todo'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.redAccent.shade100,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.redAccent.shade100,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: isSelected ? Colors.redAccent.shade100 : Colors.white,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.redAccent.shade100,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
