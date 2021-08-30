import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class DialogSearchBar extends StatelessWidget {
  const DialogSearchBar({
    Key? key,
    required this.textEditingController,
  }) : super(key: key);

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Material(
        color: Theme.of(context).primaryTextColor.withOpacity(0.1),
        child: Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Icon(Icons.search),
                    ),
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontFamily: Strings.secondaryFontFamily,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: "Search...",
                          hintStyle: TextStyle(
                            fontFamily: Strings.secondaryFontFamily,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.backspace,
              ),
              onPressed: () {
                textEditingController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
