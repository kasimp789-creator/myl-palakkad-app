import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/donation_model.dart';

class MylPdfService {
  static Future<pw.Font> _loadFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Manjari-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  /// 1. ഡിജിറ്റൽ അംഗത്വ കാർഡ് (Membership ID Card PDF)
  static Future<void> generateMembershipCard({
    required String memberId,
    required String name,
    required String designation,
    required String mandalam,
    required String panchayat,
    required String shakha,
    required String bloodGroup,
    required String phone,
  }) async {
    final pdf = pw.Document();
    final malFont = await _loadFont();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(85.6 * PdfPageFormat.mm, 54.0 * PdfPageFormat.mm),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green800, width: 2),
            ),
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: PdfColors.green800,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'മുസ്‌ലിം യൂത്ത് ലീഗ്',
                        style: pw.TextStyle(
                          font: malFont,
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'പാലക്കാട് ജില്ലാ കമ്മിറ്റി | MEMBERSHIP CARD',
                        style: pw.TextStyle(font: malFont, color: PdfColors.white, fontSize: 6),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'ID: $memberId',
                                style: pw.TextStyle(
                                  fontSize: 7,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green900,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                name,
                                style: pw.TextStyle(
                                  font: malFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                designation,
                                style: pw.TextStyle(
                                  font: malFont,
                                  fontSize: 7,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              pw.Divider(height: 6, color: PdfColors.green200),
                              pw.Text('മണ്ഡലം: $mandalam', style: pw.TextStyle(font: malFont, fontSize: 7)),
                              pw.Text('പഞ്ചായത്ത്: $panchayat', style: pw.TextStyle(font: malFont, fontSize: 7)),
                              pw.Text('ശാഖ: $shakha', style: pw.TextStyle(font: malFont, fontSize: 7)),
                              pw.Text(
                                'ഫോൺ: $phone | Blood: $bloodGroup',
                                style: const pw.TextStyle(fontSize: 6.5),
                              ),
                            ],
                          ),
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: 'MYL-PKD|$memberId|$name|$phone',
                              width: 45,
                              height: 45,
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'Verified Member',
                              style: const pw.TextStyle(fontSize: 5, color: PdfColors.green800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'MYL_ID_$memberId.pdf');
  }

  /// 2. ചാരിറ്റി ഫണ്ട് രസീത് (Charity Donation Receipt PDF)
  static Future<void> generateDonationReceipt({
    required String receiptNo,
    required String campaignTitle,
    required String donorName,
    required double amount,
    required String mandalam,
    required String panchayat,
    required String date,
  }) async {
    final pdf = pw.Document();
    final malFont = await _loadFont();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green800, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'മുസ്‌ലിം യൂത്ത് ലീഗ് - പാലക്കാട് ജില്ലാ കമ്മിറ്റി',
                          style: pw.TextStyle(
                            font: malFont,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                          ),
                        ),
                        pw.Text(
                          campaignTitle,
                          style: pw.TextStyle(font: malFont, fontSize: 12, color: PdfColors.green700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'രസീത് നമ്പർ: #$receiptNo',
                          style: pw.TextStyle(font: malFont, fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('തീയതി: $date', style: pw.TextStyle(font: malFont, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(color: PdfColors.green800, thickness: 1.5, height: 20),
                pw.Text('പ്രിയപ്പെട്ട $donorName,', style: pw.TextStyle(font: malFont, fontSize: 12)),
                pw.SizedBox(height: 8),
                pw.Text(
                  'പാലക്കാട് ജില്ലാ യൂത്ത് ലീഗ് കമ്മിറ്റിയുടെ "$campaignTitle" നിധിയിലേക്ക് താങ്കൾ നൽകിയ സഹായത്തിന് ഹൃദയം നിറഞ്ഞ നന്ദി രേഖപ്പെടുത്തുന്നു.',
                  style: pw.TextStyle(font: malFont, fontSize: 11),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'മണ്ഡലം: $mandalam  |  പഞ്ചായത്ത്/മുനിസിപ്പാലിറ്റി: $panchayat',
                  style: pw.TextStyle(font: malFont, fontSize: 10, color: PdfColors.grey800),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        border: pw.Border.all(color: PdfColors.green800),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Text(
                        'ലഭിച്ച തുക: ₹ ${amount.toStringAsFixed(0)}/-',
                        style: pw.TextStyle(
                          font: malFont,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                    ),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'MYL-RECEIPT|$receiptNo|$donorName|$amount|$date',
                      width: 50,
                      height: 50,
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'പ്രസിഡന്റ് / ജനറൽ സെക്രട്ടറി',
                          style: pw.TextStyle(font: malFont, fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'ജില്ലാ യൂത്ത് ലീഗ് കമ്മിറ്റി, പാലക്കാട്',
                          style: pw.TextStyle(font: malFont, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'MYL_Receipt_$receiptNo.pdf');
  }

  /// 3. അഡ്മിൻ ഫിനാൻഷ്യൽ സ്റ്റേറ്റ്മെന്റ് PDF (Full Charity Audit Report)
  static Future<void> generateAdminFinancialReport({
    required String campaignTitle,
    required double totalCollected,
    required List<DonationModel> donations,
  }) async {
    final pdf = pw.Document();
    final malFont = await _loadFont();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            pw.Text(
              'മുസ്‌ലിം യൂത്ത് ലീഗ് - പാലക്കാട് ജില്ലാ കമ്മിറ്റി',
              style: pw.TextStyle(font: malFont, fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
            ),
            pw.Text(
              '$campaignTitle - സമ്പൂർണ്ണ ഫണ്ട് കളക്ഷൻ റിപ്പോർട്ട്',
              style: pw.TextStyle(font: malFont, fontSize: 12, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              color: PdfColors.green50,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('ആകെ സമാഹരിച്ച തുക: ₹ ${totalCollected.toStringAsFixed(0)}/-',
                      style: pw.TextStyle(font: malFont, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.Text('ആകെ രസീതുകൾ: ${donations.length}',
                      style: pw.TextStyle(font: malFont, fontSize: 11)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Receipt #', 'Date', 'Donor Name', 'Mandalam', 'Panchayat', 'Amount (Rs)'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
              cellStyle: pw.TextStyle(font: malFont, fontSize: 9),
              data: donations.map((d) => [
                d.receiptNo,
                d.date,
                d.donorName,
                d.mandalam,
                d.panchayat,
                d.amount.toStringAsFixed(0),
              ]).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'MYL_Palakkad_Fund_Report.pdf');
  }
}
