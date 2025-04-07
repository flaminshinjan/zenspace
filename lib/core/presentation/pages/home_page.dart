import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/journal/presentation/pages/journal_list_page.dart';
import '../../../features/journal/services/journal_service.dart';

class HomePage extends StatefulWidget {
  final JournalService journalService;

  const HomePage({
    Key? key,
    required this.journalService,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5DE),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          JournalListPage(journalService: widget.journalService),
          Container(color: const Color(0xFFF3F5DE)), // Placeholder for Music page
          Container(color: const Color(0xFFF3F5DE)), // Placeholder for Profile page
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 0, right: 24, bottom: 24),
        child: SizedBox(
          width: 166,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3E6D0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, Icons.home_outlined),
                  _buildNavItem(1, Icons.book_outlined),
                  _buildNavItem(2, Icons.music_note_outlined),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.black,
            size: 16,
          ),
        ),
      ),
    );
  }
} 