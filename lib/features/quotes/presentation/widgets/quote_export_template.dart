import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ExportTemplate { classic, modern, minimal }

class QuoteExportTemplate extends StatelessWidget {
  final String content;
  final String author;
  final ExportTemplate template;

  const QuoteExportTemplate({
    super.key,
    required this.content,
    required this.author,
    this.template = ExportTemplate.modern,
  });

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case ExportTemplate.classic:
        return _buildClassic();
      case ExportTemplate.minimal:
        return _buildMinimal();
      case ExportTemplate.modern:
        return _buildModern();
    }
  }

  Widget _buildModern() {
    return Container(
      width: 1080,
      height: 1080,
      padding: const EdgeInsets.all(80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            size: 100,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 40),
          Text(
            content,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 60),
          Container(height: 4, width: 100, color: Colors.blueAccent),
          const SizedBox(height: 40),
          Text(
            author.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 32,
              letterSpacing: 4,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassic() {
    return Container(
      width: 1080,
      height: 1080,
      padding: const EdgeInsets.all(100),
      color: const Color(0xFFFDFCF0),
      child: Container(
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2C3E50), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '“$content”',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 60,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 60),
            Text(
              '— $author',
              style: GoogleFonts.lato(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimal() {
    return Container(
      width: 1080,
      height: 1080,
      padding: const EdgeInsets.all(80),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          Text(
            content,
            style: GoogleFonts.dmSans(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
          ),
          const Spacer(),
          Text(
            author,
            style: GoogleFonts.dmSans(fontSize: 40, color: Colors.black45),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
