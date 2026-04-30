import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenspace/core/theme/app_colors.dart';
import 'package:zenspace/features/wellness/models/wellness_data.dart';

class WellnessSuggestionCard extends StatelessWidget {
  final WellnessSuggestion suggestion;
  final VoidCallback? onTap;
  final bool isCompleted;
  final VoidCallback? onComplete;

  const WellnessSuggestionCard({
    super.key,
    required this.suggestion,
    this.onTap,
    this.isCompleted = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getCategoryStyle(suggestion.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? const Color(0xFF81C784).withValues(alpha: 0.5) : const Color(0xFF2A2A2A),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (onComplete != null)
                  GestureDetector(
                    onTap: () => onComplete!(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF81C784).withValues(alpha: 0.2) : const Color(0xFF2A2A2A),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 22,
                        color: isCompleted ? const Color(0xFF81C784) : AppColors.textSecondary,
                      ),
                    ),
                  ),
                if (onComplete != null && suggestion.duration != null) const SizedBox(width: 8),
                if (suggestion.duration != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      suggestion.duration!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              suggestion.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (suggestion.actionStep != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.arrow_forward, size: 14, color: color.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      suggestion.actionStep!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getCategoryStyle(String category) {
    switch (category.toLowerCase()) {
      case 'emotional':
        return (Icons.favorite, const Color(0xFFE57373));
      case 'physical':
        return (Icons.fitness_center, const Color(0xFF81C784));
      case 'sleep':
        return (Icons.bedtime, const Color(0xFF64B5F6));
      case 'stress':
        return (Icons.psychology, const Color(0xFFFFB74D));
      default:
        return (Icons.spa, const Color(0xFF7C9A92));
    }
  }
}
