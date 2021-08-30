import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/logic/cubit/root_cubits/side_drawer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrawerElement extends StatelessWidget {
  const DrawerElement({
    Key? key,
    this.id,
    this.level = 0,
    this.onTap,
    required this.icon,
    required this.label,
  }) : super(key: key);

  final String? id;
  final int level;
  final Widget icon;
  final String label;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 36 + level * 20,
          right: 36,
          bottom: 12,
          top: 12,
        ),
        color: context.read<SideDrawerCubit>().state.selectID == id
            ? Theme.of(context).primaryTextColor.withOpacity(0.1)
            : null,
        child: Row(
          children: [
            icon,
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: AutoSizeText(
                '$label',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
