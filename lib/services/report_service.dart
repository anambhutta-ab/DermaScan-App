import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class ReportService {
  static Future<void> generateAndDisplayReport({
    required String diseaseName,
    required double confidence,
    required String
    icd10Code, 
    required Uint8List originalImageBytes,
    required Uint8List heatmapImageBytes,
    required String explanation,
  }) async {
    final pdf = pw.Document();

    final originalImage = pw.MemoryImage(originalImageBytes);
    final heatmapImage = pw.MemoryImage(heatmapImageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start, //
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  "DERMASCAN AI CLINICAL REPORT",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.Text("Date: ${DateTime.now().toString().split(' ')[0]}"),
              pw.Divider(thickness: 2),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, //
                  children: [
                    pw.Text(
                      "Prediction: $diseaseName",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      "Confidence Score: ${(confidence * 100).toStringAsFixed(2)}%",
                    ),
                    pw.Text("ICD-10 Code: $icd10Code"), // Fixed variable name
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 200,
                        height: 200,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                        ), //[cite: 2]
                        child: pw.Image(originalImage),
                      ),
                      pw.Text("Original Scan"),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 200,
                        height: 200,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                        ), //[cite: 2]
                        child: pw.Image(heatmapImage),
                      ),
                      pw.Text("AI Heatmap"),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),
              pw.Text(
                "AI INTERPRETATION:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(explanation, style: const pw.TextStyle(fontSize: 11)),

              pw.Spacer(),
              pw.Text(
                "Disclaimer: This is an AI-generated preliminary analysis and not a final diagnosis.",
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'DermaScan_Report.pdf',
    );
  }
}
