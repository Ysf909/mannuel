import 'package:flutter/material.dart';

import 'package:mannuel/data/auth_repository.dart';
import 'package:mannuel/models/app_type_model.dart';
import 'package:mannuel/models/portfolio_link_model.dart';
import 'package:mannuel/view/pages/home_view.dart';
import 'package:mannuel/view/pages/portfolio_links_view.dart';

import '../widgets/hutopia_scaled_screen.dart';
import '../widgets/hutopia_theme.dart';
import '../widgets/hutopia_primary_button.dart';

class ProfessionalDetailsPage extends StatefulWidget {
  const ProfessionalDetailsPage({
    super.key,
    required this.accessToken,
    required this.repo,
  });

  final String accessToken;
  final AuthRepository repo;

  @override
  State<ProfessionalDetailsPage> createState() => _ProfessionalDetailsPageState();
}

class _ProfessionalDetailsPageState extends State<ProfessionalDetailsPage> {
  
  final _bioCtrl = TextEditingController();

  bool _loading = true;
  String? _error;

  List<AppType> _titles = [];
  List<AppType> _jobTitles = [];
  List<AppType> _jobTypes = [];
  List<AppType> _locations = [];

  AppType? _selectedTitle;
  AppType? _selectedJobTitle;

  final Set<int> _selectedJobTypeIds = {};
  final Set<int> _selectedLocationIds = {};

  final List<PortfolioLink> _links = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = widget.accessToken;

      final titles = await widget.repo.getProfessionalTitles(token);
      final jobTitles = await widget.repo.getJobTitles(token);
      final jobTypes = await widget.repo.getJobTypes(token);
      final locations = await widget.repo.getLocations(token);

      setState(() {
        _titles = titles;
        _jobTitles = jobTitles;
        _jobTypes = jobTypes;
        _locations = locations;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openAddLinkSheet() async {
    final newLink = await showModalBottomSheet<PortfolioLink>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPortfolioLinkSheet(),
    );

    if (newLink != null) {
      setState(() => _links.add(newLink));
    }
  }

  Future<void> _submit() async {
    if (_selectedTitle == null || _selectedJobTitle == null) {
      setState(() => _error = "Please select Professional Title and Job Title.");
      return;
    }
    if (_selectedJobTypeIds.isEmpty) {
      setState(() => _error = "Please select at least one Job Type.");
      return;
    }
    if (_selectedLocationIds.isEmpty) {
      setState(() => _error = "Please select at least one Location.");
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
     await widget.repo.registerProfessionalInfos(
  professionalTitle: _selectedTitle!.id,

  // ✅ send job title as list
  preferedJobTitles: [_selectedJobTitle!.id],

  preferedJobTypes: _selectedJobTypeIds.toList(),

  // ✅ rename to preferedLocations
  preferedLocations: _selectedLocationIds.toList(),

  accessToken: widget.accessToken,
);


      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Professional info saved ✅")),
      );

      Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => HomeView(accessToken: widget.accessToken),
  ),
);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

              // Progress bar (50%)
              Positioned(
                top: 80,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('50%', style: TextStyle(fontSize: 11, color: HutopiaTheme.body)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.50,
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
                  'Professional Info',
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
                  'Help us understand your profile\nand job preferences',
                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body, height: 1.35),
                ),
              ),

              Positioned(
                top: 245,
                left: HutopiaTheme.sidePad,
                right: HutopiaTheme.sidePad,
                bottom: 20,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadAll,
                                child: const Text("Retry"),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),

                                // Professional Title
                                _DropField<AppType>(
                                  label: "Professional Title",
                                  value: _selectedTitle,
                                  items: _titles,
                                  getLabel: (t) => t.value,
                                  onChanged: (v) => setState(() => _selectedTitle = v),
                                ),
                                const SizedBox(height: 14),

                                // Job Title
                                _DropField<AppType>(
                                  label: "Job Title",
                                  value: _selectedJobTitle,
                                  items: _jobTitles,
                                  getLabel: (t) => t.value,
                                  onChanged: (v) => setState(() => _selectedJobTitle = v),
                                ),
                                const SizedBox(height: 14),

                                // Bio
                                _MultilineField(
                                  label: "Bio",
                                  controller: _bioCtrl,
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  "Job Types",
                                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body),
                                ),
                                const SizedBox(height: 10),

                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _jobTypes.map((jt) {
                                    final selected = _selectedJobTypeIds.contains(jt.id);
                                    return _Chip(
                                      text: jt.value,
                                      selected: selected,
                                      onTap: () {
                                        setState(() {
                                          if (selected) {
                                            _selectedJobTypeIds.remove(jt.id);
                                          } else {
                                            _selectedJobTypeIds.add(jt.id);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  "Preferred Locations",
                                  style: TextStyle(fontSize: 13, color: HutopiaTheme.body),
                                ),
                                const SizedBox(height: 10),

                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _locations.map((loc) {
                                    final selected = _selectedLocationIds.contains(loc.id);
                                    return _Chip(
                                      text: loc.value,
                                      selected: selected,
                                      onTap: () {
                                        setState(() {
                                          if (selected) {
                                            _selectedLocationIds.remove(loc.id);
                                          } else {
                                            _selectedLocationIds.add(loc.id);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 22),

                                // Portfolio
                                Row(
                                  children: [
                                    const Text(
                                      "Portfolio Links",
                                      style: TextStyle(fontSize: 13, color: HutopiaTheme.body),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: _openAddLinkSheet,
                                      child: const Text(
                                        "Add",
                                        style: TextStyle(color: HutopiaTheme.primary),
                                      ),
                                    ),
                                  ],
                                ),

                                if (_links.isEmpty)
                                  const Text(
                                    "No links added yet.",
                                    style: TextStyle(fontSize: 12, color: HutopiaTheme.hint),
                                  )
                                else
                                  ..._links.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final link = entry.value;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  link.title,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: HutopiaTheme.title,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  link.url,
                                                  style: const TextStyle(fontSize: 12, color: HutopiaTheme.body),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () => setState(() => _links.removeAt(i)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                if (_error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ),

                                const SizedBox(height: 18),

                                _loading
                                    ? const Center(child: CircularProgressIndicator())
                                    : HutopiaPrimaryButton(
                                        width: double.infinity,
                                        height: HutopiaTheme.btnH,
                                        text: "Continue",
                                        onPressed: _submit,
                                      ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- UI Helpers (Hutopia-style) ----------

class _DropField<T> extends StatelessWidget {
  const _DropField({
    required this.label,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HutopiaTheme.fieldH,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: HutopiaTheme.fieldBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Text(label, style: const TextStyle(fontSize: 13, color: HutopiaTheme.hint)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: items
                    .map((t) => DropdownMenuItem<T>(
                          value: t,
                          child: Text(getLabel(t), style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: HutopiaTheme.fieldBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: const TextStyle(fontSize: 13, color: HutopiaTheme.hint),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? HutopiaTheme.primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? HutopiaTheme.primary : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: selected ? HutopiaTheme.primary : HutopiaTheme.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
