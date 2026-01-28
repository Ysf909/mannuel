import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../view_model/personal_info_view_model.dart';
import '../widgets/hutopia_scaled_screen.dart';
import '../widgets/hutopia_theme.dart';
import '../widgets/hutopia_text_field.dart';
import '../widgets/hutopia_primary_button.dart';

class PersonalInfoView extends StatelessWidget {
  final String email;
  const PersonalInfoView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PersonalInfoViewModel(context.read<AuthRepository>(), email: email),
      child: const _PersonalInfoBody(),
    );
  }
}

class _PersonalInfoBody extends StatelessWidget {
  const _PersonalInfoBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PersonalInfoViewModel>();

    return Scaffold(
      backgroundColor: HutopiaTheme.bg,
      body: SafeArea(
        child: HutopiaScaledScreen(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),

              // Progress bar 25%
              Positioned(
                top: 80,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('25%', style: TextStyle(fontSize: 11, color: HutopiaTheme.body)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.25,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(HutopiaTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const Positioned(
                top: 140,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Text(
                  'Personal Info',
                  style: TextStyle(
                    fontSize: 28,
                    color: HutopiaTheme.title,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Positioned(
                top: 185,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Text(
                  'General info on the representative. The\nperson creating the Candidate account',
                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body, height: 1.35),
                ),
              ),

              // Upload picture
              Positioned(
                top: 260,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upload picture (UI only)')),
                      ),
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: HutopiaTheme.primary, width: 1.5),
                        ),
                        child: const Icon(Icons.person_outline, color: HutopiaTheme.primary, size: 30),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload Picture',
                      style: TextStyle(fontSize: 12, color: HutopiaTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 360,
                left: HutopiaTheme.sidePad,
                child: HutopiaTextField(
                  width: HutopiaTheme.fieldW,
                  height: HutopiaTheme.fieldH,
                  hint: 'First name',
                  controller: vm.firstNameController,
                ),
              ),
              Positioned(
                top: 436,
                left: HutopiaTheme.sidePad,
                child: HutopiaTextField(
                  width: HutopiaTheme.fieldW,
                  height: HutopiaTheme.fieldH,
                  hint: 'Last name',
                  controller: vm.lastNameController,
                ),
              ),

              // Date dropdown row
              Positioned(
                top: 512,
                left: HutopiaTheme.sidePad,
                child: SizedBox(
                  width: HutopiaTheme.fieldW,
                  height: HutopiaTheme.fieldH,
                  child: Row(
                    children: [
                      Expanded(child: _DropBox(label: 'Day', value: vm.day, items: List.generate(31, (i) => i + 1), onChanged: vm.setDay)),
                      const SizedBox(width: 10),
                      Expanded(child: _DropBox(label: 'Month', value: vm.month, items: List.generate(12, (i) => i + 1), onChanged: vm.setMonth)),
                      const SizedBox(width: 10),
                      Expanded(child: _DropBox(label: 'Year', value: vm.year, items: List.generate(60, (i) => 1970 + i), onChanged: vm.setYear)),
                    ],
                  ),
                ),
              ),

              const Positioned(
                top: 585,
                left: HutopiaTheme.sidePad,
                child: Text('Birth date', style: TextStyle(fontSize: 12, color: HutopiaTheme.body)),
              ),

              const Positioned(
                top: 630,
                left: HutopiaTheme.sidePad,
                child: Text('Gender', style: TextStyle(fontSize: 12, color: HutopiaTheme.body)),
              ),

              Positioned(
                top: 655,
                left: HutopiaTheme.sidePad,
                child: Row(
                  children: [
                    _GenderOption(
                      label: 'Male',
                      selected: vm.gender == Gender.male,
                      onTap: () => vm.setGender(Gender.male),
                    ),
                    const SizedBox(width: 18),
                    _GenderOption(
                      label: 'Female',
                      selected: vm.gender == Gender.female,
                      onTap: () => vm.setGender(Gender.female),
                    ),
                  ],
                ),
              ),

              if (vm.errorText != null)
                Positioned(
                  top: 705,
                  left: HutopiaTheme.sidePad,
                  right: HutopiaTheme.sidePad,
                  child: Text(
                    vm.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              Positioned(
                top: 760,
                left: HutopiaTheme.sidePad,
                child: vm.isLoading
                    ? const SizedBox(
                        width: HutopiaTheme.btnW,
                        height: HutopiaTheme.btnH,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : HutopiaPrimaryButton(
                        width: HutopiaTheme.btnW,
                        height: HutopiaTheme.btnH,
                        text: 'Continue',
                        onPressed: () => vm.submit(context),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropBox extends StatelessWidget {
  final String label;
  final int value;
  final List<int> items;
  final ValueChanged<int> onChanged;

  const _DropBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HutopiaTheme.fieldH,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: HutopiaTheme.fieldBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: HutopiaTheme.body)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: items
                    .map((v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text('$v', style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (v) => v == null ? null : onChanged(v),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF9AA0A6)),
              color: selected ? HutopiaTheme.primary : Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: HutopiaTheme.body)),
        ],
      ),
    );
  }
}
