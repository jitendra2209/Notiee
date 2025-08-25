import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notiee/core/utils/icon_path.dart';
import 'features/todo/presentation/pages/todo_list_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TodoListPage(), // Todos
    const Center(child: Text('Bills Page')), // Bills
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      body: _pages[_selectedIndex],
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
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'todo') {
          Navigator.pushNamed(context, '/add_edit_todo');
        } else if (value == 'note') {
          Navigator.pushNamed(context, '/add_edit_note');
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'todo',
          child: Row(
            children: [
              Icon(Icons.task_alt, size: 20),
              SizedBox(width: 8),
              Text('Add Todo'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'note',
          child: Row(
            children: [
              Icon(Icons.note_add, size: 20),
              SizedBox(width: 8),
              Text('Add Note'),
            ],
          ),
        ),
      ],
      child: FloatingActionButton.small(
        onPressed: null, // This will be handled by PopupMenuButton
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent.shade100,
        elevation: 4,
        child: const Icon(
          Icons.add,
          size: 28,
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
