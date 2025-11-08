import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constant/app_colors.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String? _selectedRegion;
  String? _selectedProvince;
  int _affectedCount = 0;
  String? _selectedStatus;
  String? _remarks;
  DateTime _incidentDate = DateTime.now();

  final List<String> _statusOptions = [
    'Stable',
    'Injured',
    'Deceased',
    'Missing',
    'Displaced'
  ];

  final CollectionReference _regionsRef =
  FirebaseFirestore.instance.collection('region-data');

  final CollectionReference _provincesRef =
  FirebaseFirestore.instance.collection('province-data');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 20),
            const Text(
              "Report Status",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.borderColor,
                    width: 2.0,
                  ),
                ),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter your name' : null,
              onSaved: (value) => _name = value ?? '',
            ),
            const SizedBox(height: 20),

            // Region Dropdown
            StreamBuilder<QuerySnapshot>(
              stream: _regionsRef.orderBy('Region').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final regions = snapshot.data!.docs
                    .map((doc) => (doc.data() as Map<String, dynamic>)['Region']?.toString() ?? 'Unnamed')
                    .toList()
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                return buildDropdown(
                  hint: 'Select Region',
                  value: _selectedRegion,
                  items: regions,
                  onChanged: (val) => setState(() => _selectedRegion = val),
                );
              },
            ),
            const SizedBox(height: 20),

            // Province Dropdown (all provinces)
            StreamBuilder<QuerySnapshot>(
              stream: _provincesRef.orderBy('Province').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final provinces = snapshot.data!.docs
                    .map((doc) => (doc.data() as Map<String, dynamic>)['Province']?.toString() ?? 'Unnamed')
                    .toList()
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                return buildDropdown(
                  hint: 'Select Province',
                  value: _selectedProvince,
                  items: provinces,
                  onChanged: (val) => setState(() => _selectedProvince = val),
                );
              },
            ),
            const SizedBox(height: 20),

            // Affected Individuals
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _affectedCount.toString(),
                    decoration: InputDecoration(
                      labelText: 'Number of affected individuals',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      setState(() => _affectedCount = parsed);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Optional Stepper buttons
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_up),
                      onPressed: () => setState(() => _affectedCount += 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () =>
                          setState(() => _affectedCount = (_affectedCount - 1).clamp(0, 99999)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Dropdown
            buildDropdown(
              hint: 'Select Status',
              value: _selectedStatus,
              items: _statusOptions,
              onChanged: (val) => setState(() => _selectedStatus = val),
            ),
            const SizedBox(height: 20),

            // Incident Date Picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _incidentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _incidentDate = picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Incident Date: ${_incidentDate.toLocal().toIso8601String().substring(0, 10)}',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Remarks / Notes
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Remarks / Notes',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.borderColor,
                      width: 2.0,
                    ),
                  ),
                ),
                onSaved: (val) => _remarks = val,
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  final data = {
                    'Name': _name,
                    'Region': _selectedRegion,
                    'Province': _selectedProvince,
                    'AffectedCount': _affectedCount,
                    'Status': _selectedStatus,
                    'IncidentDate': _incidentDate,
                    'Remarks': _remarks ?? '',
                    'Timestamp': FieldValue.serverTimestamp(),
                  };

                  await FirebaseFirestore.instance.collection('reports').add(data);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted successfully')),
                  );

                  // Reset form
                  setState(() {
                    _name = '';
                    _selectedRegion = null;
                    _selectedProvince = null;
                    _affectedCount = 0;
                    _selectedStatus = null;
                    _remarks = '';
                    _incidentDate = DateTime.now();
                  });
                  _formKey.currentState!.reset();
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable dropdown container
  Widget buildDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Container(
        width: 500,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hint),
              value: value,
              items: items
                  .map((v) => DropdownMenuItem<String>(
                value: v,
                child: Text(v),
              ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        );
    }
}
