import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String caseNumber;
  final String status;
  final Color statusColor;

  // Additional detail fields from Firestore document
  final String? barangay;
  final String? locationType;
  final String? landmarkDetails;
  final GeoPoint? coordinates;
  final String? natureOfReport;
  final Timestamp? createdAt;

  const ReportCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.caseNumber,
    required this.status,
    required this.statusColor,
    this.barangay,
    this.locationType,
    this.landmarkDetails,
    this.coordinates,
    this.natureOfReport,
    this.createdAt,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool _isExpanded = false;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.month}/${date.day}/${date.year} at $hour:$minute $period';
  }

  String _getLocationSummary() {
    if (widget.locationType == 'LANDMARK') {
      return widget.landmarkDetails ?? 'Landmark details specified';
    } else if (widget.coordinates != null) {
      return 'Lat: ${widget.coordinates!.latitude.toStringAsFixed(4)}, Long: ${widget.coordinates!.longitude.toStringAsFixed(4)}';
    }
    return 'Location recorded';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Always Visible)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B1D19),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.caseNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C7B73),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.status.toUpperCase(),
                      style: TextStyle(
                        color: widget.statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF8C7B73),
                    ),
                  ),
                ],
              ),

              // Expandable Details View
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: Color(0xFFEAE6E4)),
                      const SizedBox(height: 12),
                      if (widget.barangay != null)
                        _buildDetailRow(
                          icon: Icons.location_city_rounded,
                          label: 'Barangay',
                          value: 'Brgy. ${widget.barangay}',
                        ),
                      _buildDetailRow(
                        icon: widget.locationType == 'GPS'
                            ? Icons.my_location
                            : widget.locationType == 'PIN'
                                ? Icons.push_pin
                                : Icons.place,
                        label: 'Location (${widget.locationType ?? "GPS"})',
                        value: _getLocationSummary(),
                      ),
                      if (widget.natureOfReport != null && widget.natureOfReport!.isNotEmpty)
                        _buildDetailRow(
                          icon: Icons.notes_rounded,
                          label: 'Details / Description',
                          value: widget.natureOfReport!,
                        ),
                      _buildDetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Date Submitted',
                        value: _formatTimestamp(widget.createdAt),
                      ),
                    ],
                  ),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8C7B73)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C7B73),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A3E39),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}