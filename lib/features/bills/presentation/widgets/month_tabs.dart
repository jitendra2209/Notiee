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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _changeYear(false),
                    child: Center(
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.redAccent.shade100,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                _currentYear.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A4B),
                ),
              ),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _changeYear(true),
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.redAccent.shade100,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Month tabs
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EBEF),
            borderRadius: BorderRadius.circular(20),
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
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent.shade100, Colors.redAccent.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.shade100.withOpacity(0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF7C8BA0),
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
