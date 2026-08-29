import 'package:flutter/material.dart';
import '../models/dua.dart';
import '../services/dua_repository.dart';
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
    final results = await DuaRepository.instance.search(query);
    if (mounted) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          decoration: const InputDecoration(
            hintText: 'Search by dua number, situation or emotion',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
      ),
      body: GradientBackground(
        child: _controller.text.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Try "travel", "forgiveness", "sleep", or "anxious"',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : DuaListScreen(preloaded: _results),
      ),
    );
  }
}
