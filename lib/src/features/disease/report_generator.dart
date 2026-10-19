import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'disease_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:io' as io;

class ReportGenerator {
  static Future<void> generateAndShareReport(DiseaseState state, String nickname, bool isMarathi) async {
    final pdf = pw.Document();
    
    // Load fonts for Marathi support
    final font = await PdfGoogleFonts.notoSansDevanagariRegular();
    final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();

    // Get image bytes in a web-safe way
    Uint8List imageBytes;
    if (kIsWeb) {
      final response = await http.get(Uri.parse(state.imagePath!));
      imageBytes = response.bodyBytes;
    } else {
      imageBytes = await io.File(state.imagePath!).readAsBytes();
    }

    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(isMarathi ? 'शेतकरी AI - रोग तपासणी अहवाल' : 'Shetkari AI - Disease Detection Report', 
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                  pw.Text(DateTime.now().toString().split(' ')[0]),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 150,
                  height: 150,
                  child: pw.Image(image, fit: pw.BoxFit.cover),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${isMarathi ? "शेतकऱ्याचे नाव" : "Farmer Name"}: $nickname', style: const pw.TextStyle(fontSize: 14)),
                      pw.SizedBox(height: 8),
                      pw.Text('${isMarathi ? "पीक" : "Crop"}: ${state.cropName}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('${isMarathi ? "आढळलेला रोग" : "Detected Disease"}: ${state.diseaseName}', 
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            _buildSection(isMarathi ? 'लक्षणे' : 'Symptoms', state.symptoms ?? '', fontBold),
            _buildSection(isMarathi ? 'सेंद्रिय उपाय' : 'Organic Remedies', state.organicRemedy ?? '', fontBold),
            _buildSection(isMarathi ? 'रासायनिक उपाय' : 'Chemical Remedies', state.chemicalRemedy ?? '', fontBold),
            _buildSection(isMarathi ? 'प्रतिबंधात्मक उपाय' : 'Prevention', state.prevention ?? '', fontBold),
            pw.Spacer(),
            pw.Center(
              child: pw.Text(
                isMarathi 
                  ? 'सूचना: हा अहवाल AI द्वारे तयार केला आहे. अधिकृत सल्ल्यासाठी कृषी तज्ञांशी संपर्क साधा.'
                  : 'Disclaimer: This report is AI-generated. Consult an expert for official advice.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ),
          ];
        },
      ),
    );

    if (kIsWeb) {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } else {
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'ShetkariAI_Report.pdf');
    }
  }

  static pw.Widget _buildSection(String title, String content, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
        pw.Divider(color: PdfColors.green100, thickness: 1),
        pw.Text(content, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 15),
      ],
    );
  }
}
