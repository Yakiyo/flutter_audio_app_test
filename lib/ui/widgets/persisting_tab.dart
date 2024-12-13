import 'package:flutter/material.dart';

/// A widget encapsulating a tab body that persists its state between tab changes
class PersistingTab extends StatefulWidget {
  final Widget child;
  const PersistingTab({super.key, required this.child});

  @override
  State<PersistingTab> createState() => _PersistingTabState();
}

class _PersistingTabState extends State<PersistingTab>
    with AutomaticKeepAliveClientMixin<PersistingTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}