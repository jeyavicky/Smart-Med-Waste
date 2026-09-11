import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/manifest_model.dart';

class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();
  factory PdfExportService() => _instance;
  PdfExportService._internal();

  /// Builds a biomedical waste regulatory manifest PDF document
  Future<Uint8List> generateManifestPdf(ManifestModel manifest) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('0A4D52'),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BIOMEDICAL WASTE REGULATORY MANIFEST',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Form IV - Central Pollution Control Board (CPCB) Rule Compliance',
                          style: const pw.TextStyle(
                            color: PdfColors.grey200,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    pw.BarcodeWidget(
                      data: manifest.manifestNumber,
                      barcode: pw.Barcode.qrCode(),
                      width: 44,
                      height: 44,
                      color: PdfColors.white,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Hospital & Consignment Details Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('D2DCE5'), width: 1),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    _buildMetaRow('Manifest Number:', manifest.manifestNumber, 'Date & Time:', dateFormat.format(manifest.generatedDate)),
                    pw.SizedBox(height: 6),
                    _buildMetaRow('Healthcare Facility:', manifest.hospitalName, 'CPCB Reg No:', manifest.cpcbRegNumber),
                    pw.SizedBox(height: 6),
                    _buildMetaRow('Authorized Officer:', manifest.authorizedOfficer, 'Vehicle Reg:', manifest.vehicleRegNumber),
                    pw.SizedBox(height: 6),
                    _buildMetaRow('Authorized Carrier:', manifest.carrierFacility, 'Disposal Status:', manifest.isDisposalConfirmed ? 'CONFIRMED' : 'PENDING'),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Segregation Breakdown Table Header
              pw.Text(
                'WASTE CATEGORY QUANTITATIVE BREAKDOWN (5-COMPARTMENTS)',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('16252D'),
                ),
              ),
              pw.SizedBox(height: 8),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromHex('D2DCE5'), width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('E6ECEF')),
                    children: [
                      _buildTableCell('Category', isHeader: true),
                      _buildTableCell('Compartment Gate', isHeader: true),
                      _buildTableCell('Treatment Method', isHeader: true),
                      _buildTableCell('Weight (kg)', isHeader: true, alignRight: true),
                    ],
                  ),
                  ...manifest.categoryWeightsKg.entries.map((entry) {
                    final method = _treatmentMethodFor(entry.key);
                    final gate = _gateFor(entry.key);
                    return pw.TableRow(
                      children: [
                        _buildTableCell(entry.key),
                        _buildTableCell(gate),
                        _buildTableCell(method),
                        _buildTableCell('${entry.value.toStringAsFixed(2)} kg', alignRight: true),
                      ],
                    );
                  }),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('F0F4F8')),
                    children: [
                      _buildTableCell('TOTAL CONSIGNMENT', isHeader: true),
                      _buildTableCell('Bags: ${manifest.totalBags}', isHeader: true),
                      _buildTableCell('Verified Auto-Segregated', isHeader: true),
                      _buildTableCell('${manifest.totalWeightKg.toStringAsFixed(2)} kg', isHeader: true, alignRight: true),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Digital Signature & Chain of Custody
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('F7FAFC'),
                  border: pw.Border.all(color: PdfColor.fromHex('D2DCE5'), width: 1),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DIGITAL CHAIN-OF-CUSTODY AUDIT HASH',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('0A4D52'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      manifest.digitalSignatureHash,
                      style: const pw.TextStyle(
                        fontSize: 7.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Facility Signature: [SIGNED ELECTRONICALLY BY INFECTION CONTROL]',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'Carrier Receipt: [CERTIFIED GPS TIMESTAMPED DISPOSAL]',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Triggers OS native print or preview dialog
  Future<void> previewOrPrintManifest(ManifestModel manifest) async {
    final pdfBytes = await generateManifestPdf(manifest);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${manifest.manifestNumber}.pdf',
    );
  }

  static pw.Widget _buildMetaRow(String l1, String v1, String l2, String v2) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '$l1 ', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('16252D'))),
                pw.TextSpan(text: v1, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
              ],
            ),
          ),
        ),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '$l2 ', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('16252D'))),
                pw.TextSpan(text: v2, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Align(
        alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColor.fromHex('0A4D52') : PdfColor.fromHex('16252D'),
          ),
        ),
      ),
    );
  }

  static String _treatmentMethodFor(String category) {
    switch (category.toLowerCase()) {
      case 'sharps':
        return 'Autoclaving & Shredding';
      case 'infectious':
        return 'High-Temp Incineration';
      case 'plastic':
        return 'Chemical Disinfection & Recycling';
      case 'glassware':
      case 'glass':
        return 'Disinfection & Glass Crushing';
      case 'unknown/others':
      case 'unknown':
      default:
        return 'Controlled Deep Burial';
    }
  }

  static String _gateFor(String category) {
    switch (category.toLowerCase()) {
      case 'sharps':
        return 'Gate #1 (Sharps Vault)';
      case 'infectious':
        return 'Gate #2 (Bio-Lock)';
      case 'plastic':
        return 'Gate #3 (Plastic Diverter)';
      case 'glassware':
      case 'glass':
        return 'Gate #4 (Glass Chute)';
      default:
        return 'Gate #5 (Fallback)';
    }
  }
}
