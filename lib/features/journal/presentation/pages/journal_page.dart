import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenspace/core/constants/asset_constants.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _journalController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _journalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return 'Today, ${DateFormat('MMMM d, yyyy').format(now)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAE6), // Light cream background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date text
                      Text(
                        _getFormattedDate(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Title and dog image
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Thoughts",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            AssetConstants.journalDog,
                            width: 48,
                            height: 48,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Journal text field
                      TextField(
                        controller: _journalController,
                        focusNode: _focusNode,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write your thoughts...',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFBFD342),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.text_fields),
                    onPressed: () {},
                    tooltip: 'Text style',
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: () {},
                    tooltip: 'Add image',
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded),
                    onPressed: () {},
                    tooltip: 'Voice input',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                    tooltip: 'Draw',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                    tooltip: 'More options',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Bottom padding for safe area
          ],
        ),
      ),
    );
  }
} 