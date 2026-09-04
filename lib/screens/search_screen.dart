import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/gradient_background.dart';
import 'dua_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Dua> _results = [];

  Future<void> _onChanged(String query) async {
    final lang = Localizations.localeOf(context).languageCode;
    final results = await DuaRepository.instance.search(query, lang: lang);
    if (mounted) setState(() => _results = results);
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context, 'search'))),
      body: GradientBackground(
        child: Column(
          children: [
            // A plain borderless TextField sitting in the AppBar gave no
            // visual cue it was tappable - this pill-shaped SearchBar
            // reads unambiguously as "type here" (search icon, clear
            // button, and its own elevated surface).
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SearchBar(
                controller: _controller,
                autoFocus: true,
                hintText: AppStrings.of(context, 'search_hint'),
                leading: const Icon(Icons.search),
                trailing: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: AppStrings.of(context, 'clear'),
                      onPressed: _clear,
                    ),
                ],
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: _controller.text.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          AppStrings.of(context, 'search_examples'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : DuaListView(preloaded: _results),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
