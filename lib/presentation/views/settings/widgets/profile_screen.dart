import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/data/models/profile_model.dart';
import 'package:finance_tracker/data/models/user_model.dart';
import 'package:finance_tracker/viewmodels/profile_viewmodel.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppbar(title: 'Profile'),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = viewModel.profile;
          if (profile == null) {
            return const Center(child: Text('Profile not available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, profile),
                const Gap(24),
                _buildPersonalInfo(context, profile),
                const Gap(24),
                _buildFinancialInfo(context, profile),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditProfileDialog(
          context,
          context.read<ProfileViewModel>().profile,
        ),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                profile.name?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeaderText(
                    text: profile.name ?? 'No Name',
                    fontSize: 24,
                  ),
                  if (profile.email != null) ...[
                    const Gap(4),
                    Text(profile.email!),
                  ],
                  // if (profile.occupation != null) ...[
                  //   const Gap(4),
                  //   Text(profile.occupation!),
                  // ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, ProfileModel profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Personal Information', fontSize: 20),
            const Gap(16),
            _buildInfoRow(
              context,
              'Phone',
              profile.phoneNumber ?? 'Not set',
              Icons.phone,
            ),
            if (profile.dateOfBirth != null)
              _buildInfoRow(
                context,
                'Date of Birth',
                DateFormat('MMMM d, yyyy').format(profile.dateOfBirth!),
                Icons.cake,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfo(BuildContext context, ProfileModel profile) {
    final currency = profile.currency ?? Helpers.storeCurrency(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Financial Information', fontSize: 20),
            const Gap(16),
            if (profile.monthlyIncome != null)
              _buildInfoRow(
                context,
                'Monthly Income',
                '$currency${profile.monthlyIncome!.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
              ),
            _buildInfoRow(
              context,
              'Preferred Currency',
              currency,
              Icons.currency_exchange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    ProfileModel? profile,
  ) async {
    if (profile == null) return;

    final formKey = GlobalKey<FormState>();
    String name = profile.name;
    String? phoneNumber = profile.phoneNumber;
    String? occupation = profile.occupation;
    double? monthlyIncome = profile.monthlyIncome;
    DateTime? dateOfBirth = profile.dateOfBirth;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  initialValue: name,
                  labelText: 'Name',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your name' : null,
                  onSaved: (value) => name = value ?? '',
                ),
                CustomTextField(
                  initialValue: phoneNumber,
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => phoneNumber = value,
                ),
                CustomTextField(
                  initialValue: occupation,
                  labelText: 'Occupation',
                  onSaved: (value) => occupation = value,
                ),
                CustomTextField(
                  initialValue: monthlyIncome?.toString(),
                  labelText: 'Monthly Income',
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      monthlyIncome = value != null && value.isNotEmpty
                          ? double.tryParse(value)
                          : null,
                ),
                ListTile(
                  title: const Text('Date of Birth'),
                  subtitle: Text(
                    dateOfBirth != null
                        ? DateFormat('MMMM d, yyyy').format(dateOfBirth??DateTime.now())
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: dateOfBirth ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dateOfBirth = date;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final viewModel = context.read<ProfileViewModel>();
                final updatedProfile = profile.copyWith(
                  name: name,
                  phoneNumber: phoneNumber,
                  occupation: occupation,
                  monthlyIncome: monthlyIncome,
                  dateOfBirth: dateOfBirth,
                );
                viewModel.saveProfile(updatedProfile);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}