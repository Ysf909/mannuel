import 'package:flutter/material.dart';
import 'package:mannuel/data/auth_repository.dart';
import 'package:mannuel/models/app_type_model.dart';
import 'package:mannuel/models/portfolio_link_model.dart';
import 'package:mannuel/view/pages/portfolio_links_view.dart';
class ProfessionalDetailsPage extends StatefulWidget {
  const ProfessionalDetailsPage({super.key, required this.accessToken, required this.repo});
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
        professionalJobTitle: _selectedJobTitle!.id,
        preferedJobTypes: _selectedJobTypeIds.toList(),
        preferedJobLocations: _selectedLocationIds.toList(),
        accessToken: widget.accessToken,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      // TODO: navigate next
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Professional info saved ✅")),
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
    // Here keep your same UI styling, but replace mock containers with real inputs.
    // Show loading/error.
    // Use DropdownButtonFormField for selects.
    // Use FilterChips for job types/locations.
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadAll, child: const Text("Retry")),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title dropdown
                        DropdownButtonFormField<AppType>(
                          value: _selectedTitle,
                          items: _titles
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.value)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedTitle = v),
                          decoration: const InputDecoration(labelText: "Professional Title"),
                        ),
                        const SizedBox(height: 12),

                        // Job title dropdown
                        DropdownButtonFormField<AppType>(
                          value: _selectedJobTitle,
                          items: _jobTitles
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.value)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedJobTitle = v),
                          decoration: const InputDecoration(labelText: "Job Title"),
                        ),
                        const SizedBox(height: 12),

                        // Bio
                        TextField(
                          controller: _bioCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: "Bio"),
                        ),
                        const SizedBox(height: 16),

                        const Text("Job Types", style: TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 8,
                          children: _jobTypes.map((jt) {
                            final selected = _selectedJobTypeIds.contains(jt.id);
                            return FilterChip(
                              label: Text(jt.value),
                              selected: selected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedJobTypeIds.add(jt.id);
                                  } else {
                                    _selectedJobTypeIds.remove(jt.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        const Text("Locations", style: TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 8,
                          children: _locations.map((loc) {
                            final selected = _selectedLocationIds.contains(loc.id);
                            return FilterChip(
                              label: Text(loc.value),
                              selected: selected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedLocationIds.add(loc.id);
                                  } else {
                                    _selectedLocationIds.remove(loc.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 18),

                        // Portfolio section
                        Row(
                          children: [
                            const Text("Portfolio Links", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            TextButton(onPressed: _openAddLinkSheet, child: const Text("Add")),
                          ],
                        ),

                        ..._links.asMap().entries.map((entry) {
                          final i = entry.key;
                          final link = entry.value;
                          return ListTile(
                            title: Text(link.title),
                            subtitle: Text(link.url),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => setState(() => _links.removeAt(i)),
                            ),
                          );
                        }),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text("Continue"),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
