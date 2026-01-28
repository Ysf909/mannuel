import 'package:flutter/material.dart';
import 'package:mannuel/models/portfolio_link_model.dart';
class AddPortfolioLinkSheet extends StatefulWidget {
  const AddPortfolioLinkSheet({super.key});

  @override
  State<AddPortfolioLinkSheet> createState() => _AddPortfolioLinkSheetState();
}

class _AddPortfolioLinkSheetState extends State<AddPortfolioLinkSheet> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String? _err;

  bool _isValidUrl(String s) {
    final u = Uri.tryParse(s.trim());
    return u != null && (u.scheme == "http" || u.scheme == "https") && u.host.isNotEmpty;
  }

  void _add() {
    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    if (title.isEmpty) return setState(() => _err = "Title is required");
    if (!_isValidUrl(url)) return setState(() => _err = "Enter a valid URL (https://...)");

    Navigator.pop(context, PortfolioLink(title: title, url: url));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      color: Colors.black.withOpacity(0.25),
      child: Center(
        child: Material(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      const Spacer(),
                      const Text("Add your portfolio link(s)", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: "Link Title"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _urlCtrl,
                    decoration: const InputDecoration(labelText: "URL"),
                  ),

                  if (_err != null) ...[
                    const SizedBox(height: 10),
                    Text(_err!, style: const TextStyle(color: Colors.red)),
                  ],

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _add,
                      child: const Text("Add"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
