import 'package:flutter/material.dart';

enum ReportStatus { dispatched, underReview, approved, rejected }

class ReportHistoryItem {
  final String caseId;
  final String category;
  final ReportStatus status;

  const ReportHistoryItem({
    required this.caseId,
    required this.category,
    required this.status,
  });

  // Helper to get formatted status text
  String get statusText {
    switch (status) {
      case ReportStatus.dispatched:
        return 'Dispatched';
      case ReportStatus.underReview:
        return 'Under review';
      case ReportStatus.approved:
        return 'Approved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  // Helper to get corresponding dot color
  Color get statusColor {
    switch (status) {
      case ReportStatus.dispatched:
        return const Color(0xFFE0533C); // Terracotta/Orange-Red
      case ReportStatus.underReview:
        return const Color(0xFFD99B26); // Amber/Gold
      case ReportStatus.approved:
        return const Color(0xFF38A169); // Green
      case ReportStatus.rejected:
        return const Color(0xFFE53E3E); // Red
    }
  }
}