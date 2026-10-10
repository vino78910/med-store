import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class AddEditMedicineScreen extends StatefulWidget {
  const AddEditMedicineScreen({super.key});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _strengthController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _initialStockController = TextEditingController(text: '50');
  final _minStockThresholdController = TextEditingController(text: '15');
  final _dailyConsumptionController = TextEditingController(text: '3.0');
  final _batchNumberController = TextEditingController();
  final _unitController = TextEditingController(text: 'units');

  String _dosageForm = 'Tablet';
  String _category = 'Analgesic';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));

  final List<String> _dosageForms = [
    'Tablet',
    'Syrup',
    'Suspension',
    'Capsule',
    'Inhaler',
    'Injection',
    'Drops',
    'Ointment',
  ];

  final List<String> _categories = [
    'Analgesic / Antipyretic',
    'Antibiotic / Antibacterial',
    'Antidiabetic',
    'Antihypertensive',
    'Bronchodilator / Respiratory',
    'Antihistamine / Allergy',
    'Cardiovascular',
    'Gastrointestinal',
    'Vitamins / Supplements',
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medicine Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Medicine Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Brand / Medicine Name *',
                  hintText: 'e.g. Paracetamol Syrup',
                  prefixIcon: Icon(Icons.medication_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Generic Name
              TextFormField(
                controller: _genericNameController,
                decoration: const InputDecoration(
                  labelText: 'Generic / Scientific Name *',
                  hintText: 'e.g. Acetaminophen Oral Suspension',
                  prefixIcon: Icon(Icons.science_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter generic name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Strength & Dosage Form
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _strengthController,
                      decoration: const InputDecoration(
                        labelText: 'Strength *',
                        hintText: 'e.g. 250mg/5ml',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _dosageForm,
                      decoration: const InputDecoration(labelText: 'Dosage Form'),
                      items: _dosageForms
                          .map((form) => DropdownMenuItem(
                                value: form,
                                child: Text(form),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _dosageForm = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category & Manufacturer
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Therapeutic Category'),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer / Brand Pharma',
                  hintText: 'e.g. Cipla Healthcare Ltd',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Stock & Forecasting Parameters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Initial Stock & Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _initialStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Initial Quantity *',
                        prefixIcon: Icon(Icons.inventory_rounded),
                      ),
                      validator: (val) {
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Cannot be negative';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Packaging Unit',
                        hintText: 'bottles / strips',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Min Stock Threshold & Average Daily Consumption
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minStockThresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Reserve Stock *',
                        hintText: 'Threshold',
                      ),
                      validator: (val) {
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed < 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dailyConsumptionController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Avg Daily Burn *',
                        hintText: 'units/day',
                      ),
                      validator: (val) {
                        final parsed = double.tryParse(val ?? '');
                        if (parsed == null || parsed < 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Batch Number & Expiry Date
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _batchNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Batch Number',
                        hintText: 'BATCH-2024-X',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() => _expiryDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormat.format(_expiryDate),
                              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveMedicine,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Save & Initialize Stock Monitoring'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMedicine() {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);

    final initialStock = int.parse(_initialStockController.text.trim());
    final minStock = int.parse(_minStockThresholdController.text.trim());
    final dailyBurn = double.parse(_dailyConsumptionController.text.trim());
    final batch = _batchNumberController.text.trim().isEmpty
        ? 'BATCH-${DateTime.now().millisecondsSinceEpoch % 10000}'
        : _batchNumberController.text.trim();

    appState.addMedicineToInventory(
      name: _nameController.text.trim(),
      genericName: _genericNameController.text.trim(),
      strength: _strengthController.text.trim(),
      dosageForm: _dosageForm,
      category: _category,
      manufacturer: _manufacturerController.text.trim().isEmpty
          ? 'Registered Manufacturer'
          : _manufacturerController.text.trim(),
      initialStock: initialStock,
      minStockThreshold: minStock,
      averageDailyConsumption: dailyBurn,
      batchNumber: batch,
      expiryDate: _expiryDate,
      unit: _unitController.text.trim().isEmpty ? 'units' : _unitController.text.trim(),
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.normal,
        content: Text('Added ${_nameController.text} to live inventory monitoring.'),
      ),
    );
  }
}
