import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/mock_database_service.dart';

class StaffManagementSheet extends StatefulWidget {
  const StaffManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const StaffManagementSheet(),
    );
  }

  @override
  State<StaffManagementSheet> createState() => _StaffManagementSheetState();
}

class _StaffManagementSheetState extends State<StaffManagementSheet> {
  final MockDatabaseService _db = MockDatabaseService();
  late List<UserModel> _users;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _users = List.from(_db.getAllUsers());
  }

  void _toggleUserStatus(UserModel user) {
    setState(() {
      _db.updateUserStatus(user.uid, !user.isActive);
      _users = List.from(_db.getAllUsers());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user.name} marked as ${!user.isActive ? "Active on Duty" : "Inactive / Off-Duty"}.',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: !user.isActive ? AppConstants.statusNominal : AppConstants.clinicalNavy,
      ),
    );
  }

  void _showReassignDialog(UserModel user) {
    String selectedWard = user.department;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppConstants.cardBg,
              title: Text('Reassign Ward • ${user.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select target hospital ward / department:', style: TextStyle(fontSize: 13, color: AppConstants.textSecondary)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: AppConstants.hospitalDepartments.contains(selectedWard) ? selectedWard : AppConstants.hospitalDepartments.first,
                    items: AppConstants.hospitalDepartments.map((dept) {
                      return DropdownMenuItem(value: dept, child: Text(dept, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedWard = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _db.updateUserDepartment(user.uid, selectedWard);
                    setState(() {
                      _users = List.from(_db.getAllUsers());
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${user.name} reassigned to $selectedWard.'),
                        backgroundColor: AppConstants.statusNominal,
                      ),
                    );
                  },
                  child: const Text('CONFIRM REASSIGNMENT'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredUsers = _users.where((u) {
      final q = _searchQuery.toLowerCase().trim();
      return u.name.toLowerCase().contains(q) ||
          u.department.toLowerCase().contains(q) ||
          u.role.toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.canvasBg : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.borderSlate : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clinical Staff Management',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Role-Based Access Control • Hospital Ward Allocation',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search staff by name, role or ward...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Staff List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isAdmin = user.role == 'admin';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppConstants.surfaceSlate : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: user.isActive
                              ? (isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0))
                              : AppConstants.crimsonDanger.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isAdmin
                                    ? AppConstants.statusNominal.withOpacity(0.15)
                                    : AppConstants.tealPrimary.withOpacity(0.15),
                                child: Icon(
                                  isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                                  color: isAdmin ? AppConstants.statusNominal : AppConstants.tealAccent,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isAdmin
                                                ? AppConstants.statusNominal.withOpacity(0.12)
                                                : AppConstants.medicalTeal.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user.role.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: isAdmin ? AppConstants.statusNominal : AppConstants.medicalTeal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      user.department,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${user.email} • ${user.phone}',
                                      style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: user.isActive,
                                activeColor: AppConstants.statusNominal,
                                onChanged: (_) => _toggleUserStatus(user),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user.isActive ? 'Status: Active on Duty' : 'Status: Off Duty / Disabled',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: user.isActive ? AppConstants.statusNominal : AppConstants.crimsonDanger,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _showReassignDialog(user),
                                icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                                label: const Text('Reassign Ward', style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
