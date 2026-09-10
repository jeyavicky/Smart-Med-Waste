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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border.all(color: AppConstants.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConstants.dividerSubtle,
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
                    color: AppConstants.clinicalNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: AppConstants.clinicalNavy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Request Waste Pickup',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppConstants.clinicalNavy,
                        ),
                      ),
                      Text(
                        'Dispatch autonomous AMR to ward collection station',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 14),

            // Department Dropdown
            const Text(
              'HOSPITAL WARD / DEPARTMENT',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppConstants.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.apartment_rounded, size: 20, color: AppConstants.coolSlate),
              ),
              items: AppConstants.hospitalDepartments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDepartment = val);
              },
            ),

            const SizedBox(height: 14),

            // Station Dropdown
            const Text(
              'COLLECTION DROP STATION',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppConstants.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedStation,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.pin_drop_rounded, size: 20, color: AppConstants.coolSlate),
              ),
              items: AppConstants.collectionStations.map((stn) {
                return DropdownMenuItem(value: stn, child: Text(stn, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStation = val);
              },
            ),

            const SizedBox(height: 14),

            // Priority Selector
            const Text(
              'PICKUP PRIORITY LEVEL',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppConstants.textSecondary,
                letterSpacing: 0.6,
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
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (p == MissionPriority.emergencyBiologicalSpill
                                  ? AppConstants.crimsonDangerLight
                                  : (p == MissionPriority.high
                                      ? AppConstants.amberWarning.withOpacity(0.12)
                                      : AppConstants.clinicalNavy.withOpacity(0.08)))
                              : AppConstants.surfaceInteractive,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? p.color : AppConstants.dividerSubtle,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(p.icon, color: isSelected ? p.color : AppConstants.coolSlate, size: 18),
                            const SizedBox(height: 4),
                            Text(
                              p == MissionPriority.normal
                                  ? 'Normal'
                                  : (p == MissionPriority.high ? 'High' : 'Biohazard!'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? p.color : AppConstants.textSecondary,
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

            const SizedBox(height: 14),

            // Notes field
            const Text(
              'OPTIONAL CLINICAL NOTES',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppConstants.textSecondary,
                letterSpacing: 0.6,
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

            const SizedBox(height: 20),

            // Dispatch Button (Primary Navy #0F2942, 8px radius, minHeight 48)
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRequest,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isSubmitting ? 'DISPATCHING VIA MQTT...' : 'CONFIRM & DISPATCH ROBOT',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
