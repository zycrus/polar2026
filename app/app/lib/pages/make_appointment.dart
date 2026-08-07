import 'package:flutter/material.dart';

class CheckupAppointmentPage extends StatefulWidget {
  final String facilityName;
  final String facilityAddress;
  final IconData facilityIcon;

  const CheckupAppointmentPage({
    super.key,
    this.facilityName = 'Santa Rosa City Hospital',
    this.facilityAddress = 'Tagapo, Brgy. Tagapo, Santa Rosa, Laguna 4026',
    this.facilityIcon = Icons.apartment,
  });

  @override
  State<CheckupAppointmentPage> createState() => _CheckupAppointmentPageState();
}

class _CheckupAppointmentPageState extends State<CheckupAppointmentPage> {
  int _currentStep = 1; // Step 1: Schedule, Step 2: Details, Step 3: Confirm

  // Step 1 State
  String _selectedService = 'General Checkup';
  late DateTime _selectedDate;
  late DateTime _startOfWeek;
  int _selectedTimeIndex = 5; // Default: 2:00 PM

  // Step 2 State
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> services = [
    'General Checkup',
    'Pediatric Consultation',
    'Dental Checkup',
    'OB-GYN Consultation',
    'Laboratory & Blood Work',
    'Vaccination & Immunization',
    'Physical Therapy',
  ];

  final List<String> times = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _startOfWeek = now.subtract(Duration(days: now.weekday % 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getDayAbbr(int weekday) {
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return days[weekday % 7];
  }

  void _nextStep() {
    if (_currentStep == 2) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Complete Booking logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment Booked Successfully!')),
      );
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFFC8532B);
    const Color textPrimary = Color(0xFF2B1D19);
    const Color textSecondary = Color(0xFF8C7B73);
    const Color backgroundColor = Color(0xFFFAF6F2);
    const Color cardBg = Colors.white;

    final weekDays = List.generate(7, (i) => _startOfWeek.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: _prevStep,
        ),
        title: const Text(
          'Checkup Appointment',
          style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital Card & Stepper
                    Container(
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(widget.facilityIcon, color: brandPrimary, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.facilityName,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.facilityAddress,
                                      style: const TextStyle(fontSize: 11, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(height: 1, color: Color(0xFFF0E8E2)),
                          ),
                          // Dynamic Stepper Line
                          Row(
                            children: [
                              _buildStepIndicator(label: '1. Schedule', step: 1),
                              _buildStepLine(),
                              _buildStepIndicator(label: '2. Details', step: 2),
                              _buildStepLine(),
                              _buildStepIndicator(label: '3. Confirm', step: 3),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- STEP 1: SCHEDULE ---
                    if (_currentStep == 1) ...[
                      const Text('Select Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: _selectedService,
                            decoration: const InputDecoration(border: InputBorder.none),
                            icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary),
                            isExpanded: true,
                            items: services.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    const Icon(Icons.medical_services_outlined, color: brandPrimary, size: 20),
                                    const SizedBox(width: 12),
                                    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedService = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Select Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_getMonthName(_startOfWeek.month)} ${_startOfWeek.year}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left, color: textSecondary),
                                      onPressed: () => setState(() => _startOfWeek = _startOfWeek.subtract(const Duration(days: 7))),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right, color: textSecondary),
                                      onPressed: () => setState(() => _startOfWeek = _startOfWeek.add(const Duration(days: 7))),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: weekDays.map((date) {
                                final isSelected = _selectedDate.year == date.year &&
                                    _selectedDate.month == date.month &&
                                    _selectedDate.day == date.day;
                                final dayAbbr = _getDayAbbr(date.weekday);
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedDate = date),
                                  child: Column(
                                    children: [
                                      Text(dayAbbr, style: const TextStyle(fontSize: 10, color: textSecondary)),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected ? brandPrimary : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Select Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2.1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: times.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedTimeIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedTimeIndex = index),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? brandPrimary : cardBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                times[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : brandPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    // --- STEP 2: DETAILS ---
                    if (_currentStep == 2) ...[
                      const Text('Patient Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.isEmpty) ? 'Please enter full name' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _contactController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.isEmpty) ? 'Please enter contact number' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.isEmpty) ? 'Please enter age' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Additional Notes / Symptoms (Optional)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // --- STEP 3: CONFIRM ---
                    if (_currentStep == 3) ...[
                      const Text('Appointment Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            _buildSummaryRow('Service', _selectedService),
                            _buildSummaryRow('Date', '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}'),
                            _buildSummaryRow('Time', times[_selectedTimeIndex]),
                            const Divider(height: 20),
                            _buildSummaryRow('Patient Name', _nameController.text),
                            _buildSummaryRow('Contact', _contactController.text),
                            _buildSummaryRow('Age', _ageController.text),
                            if (_notesController.text.isNotEmpty)
                              _buildSummaryRow('Notes', _notesController.text),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Continue / Submit Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentStep == 3 ? 'Confirm Booking' : 'Continue',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8C7B73), fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B1D19))),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({required String label, required int step}) {
    const Color brandPrimary = Color(0xFFC8532B);
    const Color textSecondary = Color(0xFF8C7B73);
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? brandPrimary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isActive || isCompleted ? brandPrimary : textSecondary, width: 1.5),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text('$step', style: TextStyle(color: isActive ? Colors.white : textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? brandPrimary : textSecondary),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 1,
        color: const Color(0xFFE0D8D0),
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
}