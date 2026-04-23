import 'dart:io';

import 'package:flutter/material.dart';

import '../models/business_card.dart';

/// Visual preview of a BusinessCard. Renders differently based on templateId.
class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.card, this.compact = false});

  final BusinessCard card;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = Color(card.primaryColor);
    final template = card.templateId;

    return AspectRatio(
      aspectRatio: compact ? 16 / 9 : 1.586, // ISO/IEC 7810 ID-1 ratio
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: template == 'modern'
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: template == 'minimal'
              ? Theme.of(context).colorScheme.surface
              : (template == 'classic' ? color : null),
          border: template == 'minimal'
              ? Border.all(color: color, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: _buildContent(context, color, template),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color color, String template) {
    final isLight = template != 'minimal';
    final primaryText = isLight ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final secondaryText = isLight
        ? Colors.white.withOpacity(0.85)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (card.photoPath != null && File(card.photoPath!).existsSync())
          CircleAvatar(
            radius: compact ? 24 : 36,
            backgroundImage: FileImage(File(card.photoPath!)),
          )
        else
          CircleAvatar(
            radius: compact ? 24 : 36,
            backgroundColor: primaryText.withOpacity(0.2),
            child: Text(
              _initials(card.fullName),
              style: TextStyle(
                fontSize: compact ? 16 : 24,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.fullName.isEmpty ? card.cardName : card.fullName,
                style: TextStyle(
                  fontSize: compact ? 16 : 22,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (card.jobTitle.isNotEmpty)
                Text(
                  card.jobTitle,
                  style: TextStyle(fontSize: compact ? 12 : 14, color: secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (card.company.isNotEmpty)
                Text(
                  card.company,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    color: secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (!compact && card.email.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(card.email,
                    style: TextStyle(fontSize: 12, color: secondaryText)),
              ],
              if (!compact && card.phone.isNotEmpty)
                Text(card.phone,
                    style: TextStyle(fontSize: 12, color: secondaryText)),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
