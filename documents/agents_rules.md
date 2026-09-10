# TASK: Refactor SmartMedWaste Flutter App (SIH 26115)

## 1. DESIGN & THEME (Light Medical Clinical)
- Light Mode only (Material 3). No dark/neon/sci-fi UI.
- Palette: Background `#F8FAFC`, Cards `#FFFFFF` (`border: 1px solid #E2E8F0`), Primary `#0F2942`, Accent `#0D9488`, Text `#0F172A`/`#64748B`.
- 5 Compartment Colors (Border & Fill Tint):
  1. Sharps: `#475569` / `#F1F5F9`
  2. Infectious: `#D97706` / `#FEF3C7`
  3. Plastic: `#DC2626` / `#FEE2E2`
  4. Glassware: `#2563EB` / `#DBEAFE`
  5. Unknown/Others: `#7E22CE` / `#F3E8FF`

## 2. CORE ARCHITECTURAL REQUIREMENTS
- **Multi-Robot Fleet:** Manage array of 4 robots (`R01`–`R04`) with states (`battery`, `temp`, `voltage`, `status`, `assignedWard`).
- **5 Internal Compartments per Robot:** Track `currentKg`, `maxKg`, and `fillPercent` for Sharps, Infectious, Plastic, Glassware, and Unknown/Others.
- **Robot Fleet Selector:** Top horizontal carousel/chips on Dashboard to switch the active robot view.

## 3. SCREEN & FUNCTION REQUIREMENTS
- `dashboard_screen.dart`:
  - Robot selector carousel (`R01`–`R04`).
  - Active robot hero card (status, location, battery metrics).
  - 5 compartment fill-level progress bars with >85% warning tags.
  - FAB: `+ Request Pickup` dialog.
- `ai_detection_screen.dart`:
  - Camera view with bounding box HUD.
  - Show Detected Object, 5-Bin Category (incl. Unknown/Others), Confidence %, Net Weight, and Mechanical Gate Action.
  - Include "Simulate Next Item" button to cycle through all 5 categories.
- `tracking_screen.dart`: Hospital corridor canvas showing multi-robot locations & destination points.
- `robot_screen.dart`: Subsystem diagnostics (LiDAR, Camera, Motors, Gate Servos).
- `history_screen.dart`: Audit log of collection IDs, weights across all 5 categories, and disposal status.

## 4. CODE RULES
- Use `flutter_riverpod` or `provider`.
- Provide complete, compilable mock data (no empty `// TODO` blocks).
- Clean code only: avoid verbose comments and unnecessary wrapper widgets.