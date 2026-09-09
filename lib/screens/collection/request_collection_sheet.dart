import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/mission_model.dart';
import '../../providers/mission_provider.dart';
import '../../providers/robot_provider.dart';
import '../../services/notification_service.dart';

class RequestCollectionSheet extends StatefulWidget {
  const RequestCollectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RequestCollectionSheet(),
    );
  }

  @override
  State<RequestCollectionSheet> createState() => _RequestCollectionSheetState();
}

class _RequestCollectionSheetState extends State<RequestCollectionSheet> {
  String _selectedDepartment = AppConstants.hospitalDepartments.first;
  String _selectedStation = AppConstants.collectionStations.first;
  MissionPriority _selectedPriority = MissionPriority.normal;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    setState(() => _isSubmitting = true);

    final missionProvider = context.read<MissionProvider>();
    final robotProvider = context.read<RobotProvider>();

    await missionProvider.requestPickup(
      department: _selectedDepartment,
      stationId: _selectedStation,
      priority: _selectedPriority,
      notes: _notesController.text.trim(),
      robotProvider: robotProvider,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();

      NotificationService.showToast(
        'Autonomous Pickup Dispatched to $_selectedStation via MQTT handshake!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceSlate : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConstants.neutralGrey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title & Description
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConstants.tealPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: AppConstants.tealAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Waste Pickup',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Dispatch autonomous robot to ward collection station',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Department Dropdown
            const Text(
              'HOSPITAL WARD / DEPARTMENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppConstants.lightSlate,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.apartment_rounded, size: 20),
              ),
              items: AppConstants.hospitalDepartments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDepartment = val);
              },
            ),

            const SizedBox(height: 16),

            // Station Dropdown
            const Text(
              'COLLECTION DROP STATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppConstants.lightSlate,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedStation,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.pin_drop_rounded, size: 20),
              ),
              items: AppConstants.collectionStations.map((stn) {
                return DropdownMenuItem(value: stn, child: Text(stn, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStation = val);
              },
            ),

            const SizedBox(height: 16),

            // Priority Selector
            const Text(
              'PICKUP PRIORITY LEVEL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppConstants.lightSlate,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: MissionPriority.values.map((p) {
                final isSelected = _selectedPriority == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPriority = p),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? p.color.withOpacity(0.18)
                              : (isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? p.color : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(p.icon, color: isSelected ? p.color : AppConstants.neutralGrey, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              p == MissionPriority.normal
                                  ? 'Normal'
                                  : (p == MissionPriority.high ? 'High' : 'Biohazard!'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? p.color : AppConstants.neutralGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Notes field
            const Text(
              'OPTIONAL CLINICAL NOTES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppConstants.lightSlate,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. 2 contaminated dressing trays ready for disposal',
              ),
            ),

            const SizedBox(height: 24),

            // Dispatch Button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRequest,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _isSubmitting ? 'DISPATCHING VIA MQTT...' : 'CONFIRM & DISPATCH ROBOT',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
