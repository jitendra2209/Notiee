import 'package:flutter/material.dart';

class MonthTabs extends StatefulWidget {
  final int selectedMonth;
  final int selectedYear;
  final Function(int month, int year) onMonthChanged;

  const MonthTabs({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
  });

  @override
  State<MonthTabs> createState() => _MonthTabsState();
}

class _MonthTabsState extends State<MonthTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentYear = DateTime.now().year;

  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _currentYear = widget.selectedYear;
    _tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: widget.selectedMonth - 1,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final selectedMonth = _tabController.index + 1;
        widget.onMonthChanged(selectedMonth, _currentYear);
      }
    });
  }

  @override
  void didUpdateWidget(MonthTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _tabController.animateTo(widget.selectedMonth - 1);
    }
    if (oldWidget.selectedYear != widget.selectedYear) {
      _currentYear = widget.selectedYear;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeYear(bool next) {
    setState(() {
      _currentYear = next ? _currentYear + 1 : _currentYear - 1;
    });
    widget.onMonthChanged(widget.selectedMonth, _currentYear);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Year selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeYear(false),
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
              Text(
                _currentYear.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => _changeYear(true),
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        // Month tabs
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Colors.redAccent.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            dividerColor: Colors.transparent,
            tabs: monthNames.map((month) {
              return Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(month),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
