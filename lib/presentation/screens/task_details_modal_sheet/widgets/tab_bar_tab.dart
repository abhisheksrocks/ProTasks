import 'package:flutter/material.dart';

class TabBarTab extends StatelessWidget {
  final String tabName;
  const TabBarTab({
    Key? key,
    required this.tabName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Text(tabName),
    );
  }
}
