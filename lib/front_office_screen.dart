import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FrontOfficeScreen extends StatefulWidget {
  const FrontOfficeScreen({super.key});

  @override
  State<FrontOfficeScreen> createState() => _FrontOfficeScreenState();
}

class _FrontOfficeScreenState extends State<FrontOfficeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Define the tabs for the Front Office module
  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.person_add_alt_1_outlined, 'label': 'Admission Enquiry'},
    {'icon': Icons.book_online_outlined, 'label': 'Visitor Book'},
    {'icon': Icons.phone_in_talk_outlined, 'label': 'Phone Call Log'},
    {'icon': Icons.outbox_outlined, 'label': 'Postal Dispatch'},
    {'icon': Icons.move_to_inbox_outlined, 'label': 'Postal Receive'},
    {'icon': Icons.report_problem_outlined, 'label': 'Complain'},
    {'icon': Icons.settings_outlined, 'label': 'Setup Front Office'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // Add a listener to rebuild the FAB when the tab changes.
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Builds a FAB based on the currently selected tab.
  Widget? _buildFloatingActionButton() {
    final currentTabLabel = _tabs[_tabController.index]['label'];
    if (currentTabLabel == 'Admission Enquiry') {
      // This button is now moved inside the _AdmissionEnquiryTab widget.
      return null;
    } else if (currentTabLabel == 'Visitor Book') {
      // This button is now moved inside the _VisitorBookTab widget.
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // The AppBar is integrated into the main dashboard, so we only need the TabBar.
      // If this screen were standalone, you would include an AppBar here.
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: theme.colorScheme.primary,
        tabs: _tabs.map((tab) {
          return Tab(icon: Icon(tab['icon']), text: tab['label']);
        }).toList(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _AdmissionEnquiryTab(), // Replaced with the new tab content
          const _VisitorBookTab(), // Replaced placeholder with the new tab content
          _buildPlaceholderTab(
            icon: Icons.phone_in_talk_outlined,
            title: 'Phone Call Log',
            description:
                'Track and manage all incoming and outgoing phone calls.',
          ),
          _buildPlaceholderTab(
            icon: Icons.outbox_outlined,
            title: 'Postal Dispatch',
            description: 'Manage all outgoing mail and package dispatches.',
          ),
          _buildPlaceholderTab(
            icon: Icons.move_to_inbox_outlined,
            title: 'Postal Receive',
            description: 'Manage all incoming mail and package receipts.',
          ),
          _buildPlaceholderTab(
            icon: Icons.report_problem_outlined,
            title: 'Complain',
            description:
                'Track and resolve complaints from students, parents, and staff.',
          ),
          _buildPlaceholderTab(
            icon: Icons.settings_outlined,
            title: 'Setup Front Office',
            description: 'Configure all front office operations and settings.',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// A generic placeholder widget for a tab's content.
  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for the Admission Enquiry Tab
class _AdmissionEnquiryTab extends StatefulWidget {
  const _AdmissionEnquiryTab();

  @override
  State<_AdmissionEnquiryTab> createState() => _AdmissionEnquiryTabState();
}

class _AdmissionEnquiryTabState extends State<_AdmissionEnquiryTab> {
  final List<Map<String, dynamic>> _summaryData = [];

  @override
  void initState() {
    super.initState();
    // Populate summary data here to avoid doing it in every build
    _summaryData.addAll([
      {
        'title': 'Total Enquiries',
        'icon': Icons.list_alt,
        'color': Colors.blue,
      },
      {
        'title': 'New Enquiries',
        'icon': Icons.fiber_new,
        'color': Colors.orange,
      },
      {'title': 'Enrolled', 'icon': Icons.school, 'color': Colors.green},
      {
        'title': 'Contacted',
        'icon': Icons.phone_in_talk,
        'color': Colors.purple,
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('admission_enquiries')
              .orderBy('enquiryDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text('No admission enquiries found.'));
            }

            // Calculate summary data from the live snapshot
            final int totalEnquiries = docs.length;
            final int newEnquiries = docs
                .where((d) => (d.data() as Map)['status'] == 'New')
                .length;
            final int enrolledEnquiries = docs
                .where((d) => (d.data() as Map)['status'] == 'Enrolled')
                .length;
            final int contactedEnquiries = docs
                .where((d) => (d.data() as Map)['status'] == 'Contacted')
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admission Enquiry Overview',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Summary Cards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: _summaryData.length,
                    itemBuilder: (context, index) {
                      final item = _summaryData[index];
                      final values = [
                        totalEnquiries,
                        newEnquiries,
                        enrolledEnquiries,
                        contactedEnquiries,
                      ];
                      return _buildSmallSummaryCard(
                        item['title'],
                        values[index].toString(),
                        item['icon'],
                        item['color'],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Enquiry Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Enquiry List/Table
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Enquiry No.')),
                          DataColumn(label: Text('Student Name')),
                          DataColumn(label: Text('Father\'s Name')),
                          DataColumn(label: Text('Father\'s Phone')),
                          DataColumn(label: Text('Enquiry Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Source')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: docs.map((doc) {
                          final enquiry = doc.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(Text(enquiry['enquiryNo'] ?? '')),
                              DataCell(Text(enquiry['studentName'] ?? '')),
                              DataCell(Text(enquiry['fatherName'] ?? '')),
                              DataCell(Text(enquiry['fatherPhone'] ?? '')),
                              DataCell(Text(enquiry['enquiryDate'] ?? '')),
                              DataCell(
                                Chip(
                                  label: Text(enquiry['status'] ?? 'N/A'),
                                  backgroundColor: _getStatusColor(
                                    enquiry['status'] ?? '',
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataCell(Text(enquiry['source'] ?? '')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        // todo: Implement edit functionality
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Edit ${enquiry['enquiryNo']}',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        // todo: Implement delete functionality
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Delete ${enquiry['enquiryNo']}',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Add New Enquiry Button - Moved here from FAB
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: const _AddAdmissionEnquiryForm(),
                            );
                          },
                        ).then((value) {
                          if (value == true) {
                            // Data is refreshed automatically by StreamBuilder
                          }
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Enquiry'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmallSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for the Visitor Book Tab
class _VisitorBookTab extends StatefulWidget {
  const _VisitorBookTab();
  @override
  State<_VisitorBookTab> createState() => _VisitorBookTabState();
}

class _VisitorBookTabState extends State<_VisitorBookTab> {
  final List<Map<String, dynamic>> _summaryData = [];

  @override
  void initState() {
    super.initState();
    // Populate summary data here
    _summaryData.addAll([
      {
        'title': 'Total Visitors',
        'icon': Icons.groups_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Currently In',
        'icon': Icons.login_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Checked Out',
        'icon': Icons.logout_outlined,
        'color': Colors.orange,
      },
      {
        'title': 'Security Alerts',
        'icon': Icons.security_outlined,
        'color': Colors.red,
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('visitors')
              .orderBy('checkInTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text('No visitors found.'));
            }

            // Calculate summary data from the live snapshot
            final int totalVisitors = docs.length;
            final int currentlyIn = docs
                .where((d) => (d.data() as Map)['status'] == 'Checked In')
                .length;
            final int checkedOut = docs
                .where((d) => (d.data() as Map)['status'] == 'Checked Out')
                .length;
            const int securityAlerts = 0; // Placeholder for security alerts

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visitor Book Overview',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Summary Cards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: _summaryData.length,
                    itemBuilder: (context, index) {
                      final item = _summaryData[index];
                      final values = [
                        totalVisitors,
                        currentlyIn,
                        checkedOut,
                        securityAlerts,
                      ];
                      return _buildSmallSummaryCard(
                        item['title'],
                        values[index].toString(),
                        item['icon'],
                        item['color'],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Visitor Records',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Visitor List/Table
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Visitor ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Company')),
                          DataColumn(label: Text('Purpose')),
                          DataColumn(label: Text('Person to Meet')),
                          DataColumn(label: Text('Transport')),
                          DataColumn(label: Text('Vehicle No.')),
                          DataColumn(label: Text('Check In')),
                          DataColumn(label: Text('Check Out')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: docs.map((doc) {
                          final visitor = doc.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(Text(visitor['visitorId'] ?? '')),
                              DataCell(Text(visitor['name'] ?? '')),
                              DataCell(Text(visitor['company'] ?? '')),
                              DataCell(Text(visitor['purpose'] ?? '')),
                              DataCell(Text(visitor['personToMeet'] ?? '')),
                              DataCell(Text(visitor['transportMode'] ?? 'N/A')),
                              DataCell(Text(visitor['vehicleNumber'] ?? 'N/A')),
                              DataCell(Text(visitor['checkInTime'] ?? '')),
                              DataCell(
                                Text(visitor['checkOutTime'] ?? ''),
                              ), // Assuming this field might exist
                              DataCell(
                                Chip(
                                  label: Text(visitor['status'] ?? 'N/A'),
                                  backgroundColor: _getStatusColor(
                                    visitor['status'] ?? '',
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        // todo: Implement edit functionality
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        // todo: Implement delete functionality
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Check In New Visitor Button - Moved here from FAB
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: const _AddVisitorForm(),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Check In New Visitor'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmallSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Checked In':
        return Colors.green;
      case 'Checked Out':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'New':
      return Colors.orange;
    case 'Contacted':
      return Colors.blue;
    case 'Enrolled':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

// New widget for the Add Admission Enquiry Form
class _AddAdmissionEnquiryForm extends StatefulWidget {
  const _AddAdmissionEnquiryForm();

  @override
  State<_AddAdmissionEnquiryForm> createState() =>
      _AddAdmissionEnquiryFormState();
}

class _AddAdmissionEnquiryFormState extends State<_AddAdmissionEnquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSession;
  String? _selectedClass;
  String? _selectedSource;

  // Dummy data for dropdowns
  final List<String> _academicSessions = ['2024-2025', '2025-2026'];
  final List<String> _classes = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4'];
  final List<String> _sources = [
    'Website',
    'Referral',
    'Walk-in',
    'Advertisement',
  ];

  @override
  void dispose() {
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEnquiry() async {
    if (_formKey.currentState!.validate()) {
      try {
        final firestore = FirebaseFirestore.instance;
        const uuid = Uuid();
        final enquiryNo = 'ENQ-${uuid.v4().substring(0, 6).toUpperCase()}';

        await firestore.collection('admission_enquiries').add({
          'enquiryNo': enquiryNo,
          'studentName': _studentNameController.text,
          'fatherName': _fatherNameController.text,
          'motherName': _motherNameController.text,
          'fatherPhone': _phoneController.text,
          'email': _emailController.text,
          'classSought': _selectedClass,
          'academicSession': _selectedSession,
          'source': _selectedSource,
          'notes': _notesController.text,
          'enquiryDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'status': 'New',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enquiry saved successfully!')),
          );
          Navigator.of(context).pop(true); // Pop and indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save enquiry: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Admission Enquiry',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(labelText: 'Student Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Student name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(labelText: 'Father Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Father name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(labelText: 'Mother Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSession,
                decoration: const InputDecoration(
                  labelText: 'Academic Session*',
                ),
                items: _academicSessions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSession = value),
                validator: (value) =>
                    value == null ? 'Please select a session' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(labelText: 'Class Sought*'),
                items: _classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedClass = value),
                validator: (value) =>
                    value == null ? 'Please select a class' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSource,
                decoration: const InputDecoration(labelText: 'Enquiry Source'),
                items: _sources
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSource = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any specific requirements or notes...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveEnquiry,
                    child: const Text('Save Enquiry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget for the Add Visitor Form
class _AddVisitorForm extends StatefulWidget {
  const _AddVisitorForm();

  @override
  State<_AddVisitorForm> createState() => _AddVisitorFormState();
}

class _AddVisitorFormState extends State<_AddVisitorForm> {
  final _formKey = GlobalKey<FormState>();
  final _visitorNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _personToMeetController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _selectedPurpose;
  String? _selectedDepartment;
  String? _selectedTransportMode;
  bool _isVehicleNumberApplicable = false;

  // Dummy data for dropdowns
  final List<String> _purposes = [
    'Meeting',
    'Parent Visit',
    'Delivery',
    'Interview',
    'Other',
  ];
  final List<String> _departments = [
    'Principal\'s Office',
    'Accounts',
    'Admissions',
    'HR',
    'IT',
  ];
  final List<String> _transportModes = [
    'Walk-in',
    'Car',
    'Motorbike',
    'Bicycle',
    'Other',
  ];

  @override
  void dispose() {
    _visitorNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _personToMeetController.dispose();
    _vehicleNumberController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _updateVehicleNumberState(String? mode) {
    setState(() {
      _selectedTransportMode = mode;
      _isVehicleNumberApplicable =
          mode != null && mode != 'Walk-in' && mode != 'Bicycle';
      if (!_isVehicleNumberApplicable) {
        _vehicleNumberController.clear();
      }
    });
  }

  Future<void> _checkInVisitor() async {
    if (_formKey.currentState!.validate()) {
      try {
        final firestore = FirebaseFirestore.instance;
        const uuid = Uuid();
        final visitorId = 'VIS-${uuid.v4().substring(0, 6).toUpperCase()}';

        await firestore.collection('visitors').add({
          'visitorId': visitorId,
          'name': _visitorNameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'company': _companyController.text,
          'purpose': _selectedPurpose,
          'personToMeet': _personToMeetController.text,
          'department': _selectedDepartment,
          'transportMode': _selectedTransportMode,
          'vehicleNumber': _vehicleNumberController.text,
          'remarks': _remarksController.text,
          'checkInTime': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          'status': 'Checked In',
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor checked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // ignore: empty_catches
      } catch (e) {}
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visitor Check In',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _visitorNameController,
                decoration: const InputDecoration(labelText: 'Visitor Name*'),
                validator: (value) =>
                    value!.isEmpty ? 'Visitor name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company/Organization',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Visit*',
                ),
                items: _purposes
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPurpose = value),
                validator: (value) =>
                    value == null ? 'Please select a purpose' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _personToMeetController,
                decoration: const InputDecoration(labelText: 'Person to Meet*'),
                validator: (value) =>
                    value!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDepartment = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTransportMode,
                decoration: const InputDecoration(
                  labelText: 'Mode of Transport',
                ),
                items: _transportModes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: _updateVehicleNumberState,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Number Plate',
                  hintText: _isVehicleNumberApplicable
                      ? 'Enter vehicle number'
                      : 'Not applicable',
                ),
                enabled: _isVehicleNumberApplicable,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Any additional notes...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _checkInVisitor,
                    icon: const Icon(Icons.login),
                    label: const Text('Check In Visitor'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
