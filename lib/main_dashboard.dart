import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_management/front_office_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;
  int _attendanceChartIndex = 0; // For the attendance chart PageView

  final List<Map<String, dynamic>> destinations = [
    {'icon': Icons.space_dashboard_outlined, 'label': 'Home'}, // Dashboard
    {'icon': Icons.meeting_room_outlined, 'label': 'Front Office'},
    {'icon': Icons.people_outline, 'label': 'Student Information'},
    {'icon': Icons.receipt_long_outlined, 'label': 'Fees Collection'},
    {'icon': Icons.play_circle_outline, 'label': 'E-Learning / Online Course'},
    {'icon': Icons.school_outlined, 'label': 'Academic'},
    {'icon': Icons.business_outlined, 'label': 'Multi Branch'},
    {'icon': Icons.video_call_outlined, 'label': 'G-Meet Live Classes'},
    {'icon': Icons.duo_outlined, 'label': 'Zoom Live Classes'},
    {'icon': Icons.gavel_outlined, 'label': 'Disciplinary / Behavior'},
    {'icon': Icons.arrow_downward_outlined, 'label': 'Income'},
    {'icon': Icons.arrow_upward_outlined, 'label': 'Expenses'},
    {'icon': Icons.grade_outlined, 'label': 'CBSE Examination'},
    {'icon': Icons.quiz_outlined, 'label': 'Examination / Online Examination'},
    {
      'icon': Icons.qr_code_scanner_outlined,
      'label': 'Attendance / QR Code Attendance',
    },
    {'icon': Icons.calendar_today_outlined, 'label': 'Annual School Calendar'},
    {'icon': Icons.rule_folder_outlined, 'label': 'Lesson Plan'},
    {'icon': Icons.badge_outlined, 'label': 'Human Resource'},
    {
      'icon': Icons.supervised_user_circle_outlined,
      'label': 'Teacher Management',
    },
    {'icon': Icons.local_library_outlined, 'label': 'Library'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Inventory / Procurement'},
    {'icon': Icons.directions_bus_outlined, 'label': 'Transport / Logistics'},
    {'icon': Icons.hotel_outlined, 'label': 'Hostel / Room Management'},
    {'icon': Icons.card_membership_outlined, 'label': 'Certificate'},
    {'icon': Icons.web_outlined, 'label': 'Front CMS'},
    {'icon': Icons.groups_outlined, 'label': 'Alumni'},
    {'icon': Icons.assessment_outlined, 'label': 'Reports'},
    {'icon': Icons.settings_outlined, 'label': 'System Setting'},
    {'icon': Icons.person_outline, 'label': 'Profile'},
  ];

  // List to hold the widget instances for the main content area.
  // This prevents them from being rebuilt on every setState.
  late final List<Widget> _mainContentScreens;
  late final PageController _attendancePageController;

  @override
  void initState() {
    super.initState();
    _mainContentScreens = List.generate(destinations.length, (index) {
      final label = destinations[index]['label'];
      // Pre-build the widgets that have complex state.
      if (label == 'Front Office')
        // ignore: curly_braces_in_flow_control_structures
        return const FrontOfficeScreen(); // This is fine
      return _buildPlaceholderWidget(label); // Use a context-free builder
    });
    _attendancePageController = PageController(viewportFraction: 0.9);
    _refreshUserData();
  }

  // Fetches the latest user data from Firebase.
  Future<void> _refreshUserData() async {
    await user?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        user = refreshedUser;
      });
    }
  }

  // Logout function
  Future<void> _logout() async {
    // Capture the navigator before the async gap.
    final navigator = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    // Navigate back to login and remove all previous routes
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void dispose() {
    _attendancePageController.dispose();
    super.dispose();
  }

  // Placeholder for profile picture upload logic
  Future<void> _uploadProfilePicture() async {
    // todo: Implement image picker and Firebase Storage upload logic.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture upload coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final drawer = Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            accountName: Text(
              user?.displayName ?? 'Admin User',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.onPrimary,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!) as ImageProvider
                  : null,
              child: user?.photoURL == null
                  ? Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? 'A',
                    )
                  : null,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero, // Remove padding from ListView
              itemCount: destinations.length,
              itemBuilder: (context, index) =>
                  _buildDrawerItem(context, theme, destinations, index),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withAlpha(245),
      appBar: AppBar(
        title: const Text('Admins Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {}, // todo: Navigate to notifications screen
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                // Find the index for the 'Profile' screen and navigate to it.
                final profileIndex = destinations.indexWhere(
                  (element) => element['label'] == 'Profile',
                );
                if (profileIndex != -1) {
                  setState(() => _selectedIndex = profileIndex);
                }
              },
              child: CircleAvatar(
                radius: 18,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!) as ImageProvider
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person_outline, size: 20)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: drawer,
      body: _buildMainContent(theme),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    ThemeData theme,
    List<Map<String, dynamic>> destinations,
    int index,
  ) {
    final item = destinations[index];
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        item['icon'],
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        item['label'],
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.of(context).pop(); // Close the drawer
      },
    );
  }

  /// A context-free method to create placeholder widgets.
  /// This is safe to call from initState.
  Widget _buildPlaceholderWidget(String label) {
    // For complex screens with their own state, we return them directly.
    // For simple placeholders, we can return a builder that uses the context
    // from the `build` method.
    return Builder(
      builder: (context) {
        return _buildPlaceholderScreen(context, label);
      },
    );
  }

  /// Builds the actual placeholder screen using the provided context.
  /// This is now only called from `build` or a `Builder`.
  Widget _buildPlaceholderScreen(BuildContext context, String label) {
    if (label == 'Home') return _buildDashboardHome(Theme.of(context));
    if (label == 'Profile') return _buildProfileScreen(Theme.of(context));

    // Default placeholder
    return Center(
      child: Text(
        '$label Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    // Use an IndexedStack to switch between widgets without rebuilding them.
    // This preserves the state of each screen, including scroll position and
    // the state of the PageView controllers within the FrontOfficeScreen.
    return IndexedStack(
      index: _selectedIndex,
      children: List.generate(destinations.length, (index) {
        final label = destinations[index]['label'];
        if (label == 'Front Office') return _mainContentScreens[index];
        // For other screens, we now build them with context.
        return _buildPlaceholderScreen(context, label);
      }),
    );
  }

  Widget _buildDashboardHome(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            user?.displayName ?? 'User',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          _buildShortcuts(theme),
          const SizedBox(height: 32),
          Text(
            'Weekly Attendance Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Swipeable attendance charts with page indicators
          Column(
            children: [
              AspectRatio(
                aspectRatio: 1.2, // Use aspect ratio for responsiveness
                child: PageView(
                  controller: _attendancePageController,
                  onPageChanged: (index) {
                    setState(() {
                      _attendanceChartIndex = index;
                    });
                  },
                  children: [
                    _buildAttendanceCard(
                      theme,
                      title: 'Student Attendance',
                      data: const [245, 248, 235, 240, 250],
                      total: 250,
                      cardAccentColor: Colors.blue.shade700,
                      chartBarColor: Colors.orange.shade400,
                    ),
                    _buildAttendanceCard(
                      theme,
                      title: 'Teacher Attendance',
                      data: const [28, 30, 30, 29, 27],
                      total: 30,
                      cardAccentColor: Colors.orange.shade700,
                      chartBarColor: Colors.blue.shade400,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildPageIndicator(2),
            ],
          ),
          const SizedBox(height: 32),
          // New section for Recent and Upcoming Activities
          Column(
            children: [
              _buildRecentActivities(theme),
              const SizedBox(height: 24),
              _buildUpcomingActivities(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen(ThemeData theme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!) as ImageProvider
                          : null,
                      backgroundColor: theme.colorScheme.primary,
                      child: user?.photoURL == null
                          ? Text(
                              user?.displayName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'A',
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: theme.colorScheme.secondary,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                          onPressed: _uploadProfilePicture,
                          tooltip: 'Change Profile Picture',
                          constraints: const BoxConstraints(
                            minHeight: 44,
                            minWidth: 44,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  user?.displayName ?? 'Admin User',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcuts(ThemeData theme) {
    final List<DashboardItem> shortcutItems = [
      DashboardItem(
        icon: Icons.assessment_outlined,
        title: 'Manage Reports',
        description: 'Generate and view reports',
        onTap: () {},
        color: Colors.blue.shade700,
      ),
      DashboardItem(
        icon: Icons.campaign_outlined,
        title: 'Send Notification',
        description: 'Broadcast to users',
        onTap: () {},
      ),
      DashboardItem(
        icon: Icons.edit_calendar_outlined,
        title: 'Manage Leave',
        description: 'Approve or deny requests',
        onTap: () {},
        color: Colors.orange,
      ),
    ];

    return AspectRatio(
      aspectRatio: 16 / 6, // Responsive aspect ratio
      child: PageView.builder(
        controller: PageController(
          viewportFraction: 0.9,
        ), // Adjusted for better spacing
        padEnds: false,
        itemCount: shortcutItems.length,
        itemBuilder: (context, index) {
          final item = shortcutItems[index];
          return Container(
            margin: const EdgeInsets.only(
              right: 12.0,
            ), // Add margin between cards
            child: DashboardCard(item: item),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceCard(
    ThemeData theme, {
    required String title,
    required List<int> data,
    required int total,
    Color? cardAccentColor,
    Color? chartBarColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white, // Ensure card background is white
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  // Title uses cardAccentColor
                  fontWeight: FontWeight.bold,
                  color: cardAccentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daily attendance out of $total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _AttendanceChart(
                  data: data,
                  total: total,
                  barColor: chartBarColor ?? theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _attendanceChartIndex == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _attendanceChartIndex == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _AttendanceChart extends StatelessWidget {
  final List<int> data;
  final int total;
  final Color barColor;

  const _AttendanceChart({
    // ignore: unused_element_parameter
    super.key, // The key is now used.
    required this.data,
    required this.total,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: total.toDouble(),
        barTouchData: BarTouchData(
          enabled: false,
        ), // Disabled for persistent labels
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final dayStyle = TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                final valueStyle = TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Increased font size for better visibility
                );

                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                final index = value.toInt();
                if (index < 0 || index >= days.length) return const SizedBox();

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Column(
                    children: [
                      Text(days[index], style: dayStyle),
                      const SizedBox(height: 4),
                      Text(data[index].toString(), style: valueStyle),
                    ],
                  ),
                );
              },
              reservedSize: 65, // Further increased space to prevent overflow
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          return _makeBar(index, data[index].toDouble(), barColor);
        }),
        gridData: const FlGridData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 450),
      swapAnimationCurve: Curves.easeOut,
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    final barGradient = LinearGradient(
      colors: [color.withOpacity(0.8), color],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: barGradient,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}

// New data models for activities
class RecentActivity {
  final IconData icon;
  final String title;
  final String description;
  final String time; // e.g., "2 hours ago", "Yesterday"

  RecentActivity({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
  });
}

class UpcomingActivity {
  final IconData icon;
  final String title;
  final String date; // e.g., "Oct 28", "Tomorrow"
  final String time; // e.g., "10:00 AM"

  UpcomingActivity({
    required this.icon,
    required this.title,
    required this.date,
    required this.time,
  });
}

// Extension to organize new activity-related methods within the state class
extension _MainDashboardScreenStateActivities on _MainDashboardScreenState {
  Widget _buildRecentActivities(ThemeData theme) {
    final List<RecentActivity> activities = [
      RecentActivity(
        icon: Icons.person_add_alt_1_outlined,
        title: 'New Student Enrolled',
        description: 'John Doe joined Grade 5A.',
        time: '2 hours ago',
      ),
      RecentActivity(
        icon: Icons.assignment_turned_in_outlined,
        title: 'Assignment Graded',
        description: 'Math assignment for Grade 7 completed.',
        time: 'Yesterday',
      ),
      RecentActivity(
        icon: Icons.group_add_outlined,
        title: 'New Teacher Hired',
        description: 'Ms. Emily White for English Dept.',
        time: '3 days ago',
      ),
    ];

    return Card(
      // Wrap ExpansionTile in a Card for consistent styling
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          'Recent Activities',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: activities
                  .map(
                    (activity) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade800,
                          child: Icon(activity.icon, size: 22),
                        ),
                        title: Text(
                          activity.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          activity.description,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: Text(
                          activity.time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActivities(ThemeData theme) {
    final List<UpcomingActivity> activities = [
      UpcomingActivity(
        icon: Icons.event_note_outlined,
        title: 'Parent-Teacher Meeting',
        date: 'Oct 28',
        time: '09:00 AM',
      ),
      UpcomingActivity(
        icon: Icons.school_outlined,
        title: 'Annual Sports Day',
        date: 'Nov 05',
        time: 'All Day',
      ),
      UpcomingActivity(
        icon: Icons.menu_book_outlined,
        title: 'Curriculum Review',
        date: 'Nov 10',
        time: '02:00 PM',
      ),
    ];

    return Card(
      // Wrap ExpansionTile in a Card
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          'Upcoming Events',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: activities
                  .map(
                    (activity) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade800,
                          child: Icon(activity.icon, size: 22),
                        ),
                        title: Text(
                          activity.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${activity.date}, ${activity.time}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color? color;

  DashboardItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.color,
  });
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.item});

  final DashboardItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = item.color ?? theme.colorScheme.primary;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: cardColor.withOpacity(0.5),
          width: 1,
        ), // Use cardColor for border
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(item.icon, size: 40, color: cardColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
