import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenspace/core/constants/asset_constants.dart';
import 'package:zenspace/core/theme/app_colors.dart';

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
      backgroundColor: AppColors.bgColor,
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
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightYellow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.black, width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back, color: AppColors.textDark),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Date text
                      Text(
                        _getFormattedDate(),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Title and dog image
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Thoughts",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightYellow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.black, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _journalController,
                          focusNode: _focusNode,
                          maxLines: null,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write your thoughts...',
                            hintStyle: TextStyle(
                              color: AppColors.textLight,
                            ),
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
                color: AppColors.lightYellow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: AppColors.black, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.text_fields, color: AppColors.textDark),
                    onPressed: () {},
                    tooltip: 'Text style',
                  ),
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: AppColors.textDark),
                    onPressed: () {},
                    tooltip: 'Add image',
                  ),
                  IconButton(
                    icon: Icon(Icons.mic_none_rounded, color: AppColors.textDark),
                    onPressed: () {},
                    tooltip: 'Voice input',
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: AppColors.textDark),
                    onPressed: () {},
                    tooltip: 'Draw',
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz, color: AppColors.textDark),
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