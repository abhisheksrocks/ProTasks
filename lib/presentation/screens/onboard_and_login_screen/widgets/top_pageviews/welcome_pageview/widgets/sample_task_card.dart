import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/sample_text_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:protasks/core/themes/app_theme.dart';

class SampleTaskCard extends StatelessWidget {
  const SampleTaskCard({
    Key? key,
    this.checked = true,
  }) : super(key: key);

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryTextColor.withOpacity(0.1),
            const Color(0x1A808080),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AbsorbPointer(
            child: MyCircularCheckBox(
              value: checked,
              onChanged: (_) {},
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
                right: 12,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SampleTextPlaceholder(width: double.infinity),
                  const SizedBox(
                    height: 8,
                  ),
                  const SampleTextPlaceholder(width: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
