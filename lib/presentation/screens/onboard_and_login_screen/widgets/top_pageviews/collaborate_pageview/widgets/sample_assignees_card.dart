import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/sample_text_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:protasks/core/themes/app_theme.dart';

class SampleAssigneesCard extends StatelessWidget {
  const SampleAssigneesCard({
    Key? key,
    this.isChecked = false,
  }) : super(key: key);

  final bool isChecked;

  final Duration animationDuration = const Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            isChecked
                ? Theme.of(context).accentColor.withOpacity(0.20)
                : Theme.of(context).primaryTextColor.withOpacity(0.1),
            isChecked ? const Color(0x332B3380) : const Color(0x1A808080),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            
            
            decoration: BoxDecoration(
              color: isChecked
                  ? Theme.of(context).accentColor.withOpacity(0.3)
                  : Theme.of(context).primaryTextColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(
              left: 12,
            ),
            padding: EdgeInsets.all(4),
            child: Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: isChecked ? Theme.of(context).accentColor : null,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
                
                left: 12,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SampleTextPlaceholder(
                    width: 100,
                    color: isChecked
                        ? Theme.of(context).accentColor.withOpacity(0.2)
                        : null,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SampleTextPlaceholder(
                    width: double.infinity,
                    height: 20,
                    color: isChecked
                        ? Theme.of(context).accentColor.withOpacity(0.1)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          AbsorbPointer(
            child: MyCircularCheckBox(
              value: isChecked,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
