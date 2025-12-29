import 'package:flutter/material.dart';
import '../models/credit_model.dart';
import '../services/local_service.dart';

class CreditsScreen extends StatefulWidget {
  static const String routeName = 'credits';
  const CreditsScreen({super.key, required this.title});
  final String title;

  @override
  State createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  List<CreditModel> _items = List.empty();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          title: Text(
            item.creditName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            item.creditMembers,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Theme.of(context).dividerColor);
      },
    );
  }

  void _loadData() {
    Services.readJsonCredits().then((itemsFromServer) {
      setState(() {
        _items = itemsFromServer;
      });
    });
  }
}