import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.pharmacyAdmin;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Pharmacy details
  final _pharmacyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hoursController = TextEditingController(text: '8:00 AM - 10:00 PM');

  @override
  Widget build(BuildContext context) {
    final isStaff = _selectedRole != UserRole.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Your Role',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              // Role Selection Tabs
              Row(
                children: [
                  _buildRoleSelector(UserRole.pharmacyAdmin, 'Pharmacy Admin'),
                  const SizedBox(width: 8),
                  _buildRoleSelector(UserRole.pharmacist, 'Pharmacist'),
                  const SizedBox(width: 8),
                  _buildRoleSelector(UserRole.patient, 'Patient'),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Personal & Account Credentials',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email_outlined)),
                validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password (min 6 chars) *', prefixIcon: Icon(Icons.lock_outline)),
                validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters' : null,
              ),

              if (isStaff) ...[
                const SizedBox(height: 24),
                const Text(
                  'Pharmacy Facility Information',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _pharmacyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Pharmacy Name *',
                    hintText: 'e.g. HealthCare Chemist',
                    prefixIcon: Icon(Icons.local_pharmacy_outlined),
                  ),
                  validator: (val) => isStaff && (val == null || val.trim().isEmpty) ? 'Pharmacy name required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Location / Full Address *',
                    hintText: 'Street, Sector, City',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (val) => isStaff && (val == null || val.trim().isEmpty) ? 'Address required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone *',
                    hintText: '+91 98765 00000',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (val) => isStaff && (val == null || val.trim().isEmpty) ? 'Phone required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Operating Hours *',
                    hintText: 'e.g. 8:00 AM - 10:00 PM',
                    prefixIcon: Icon(Icons.access_time_rounded),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRegistration,
                  child: const Text('Complete Registration'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _submitRegistration() {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);

    appState.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      pharmacyName: _pharmacyNameController.text.trim(),
      pharmacyAddress: _addressController.text.trim(),
      pharmacyPhone: _phoneController.text.trim(),
      operatingHours: _hoursController.text.trim(),
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.normal,
        content: Text('Successfully registered as ${_selectedRole.displayName}!'),
      ),
    );
  }
}
