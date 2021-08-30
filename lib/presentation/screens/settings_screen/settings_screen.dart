import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/auth_handler.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/confirmation_dialog.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MySliverAppBar(
            title: 'Settings',
            actions: [],
            leading: BackButton(),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (context.read<LoginCubit>().state.currentLoginState ==
                    CurrentLoginState.loggedIn)
                  ListTile(
                    title: Text(
                      'Edit Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final double mediaQueryHeight =
                              context.read<MediaQueryCubit>().state.size.height;

                          final double mediaQueryWidth =
                              context.read<MediaQueryCubit>().state.size.width;

                          final double maxScreenHeight =
                              (mediaQueryHeight > mediaQueryWidth)
                                  ? mediaQueryHeight
                                  : mediaQueryWidth;

                          final TextEditingController _textEditingController =
                              TextEditingController();

                          final _formKey = GlobalKey<FormState>();
                          return Dialog(
                            backgroundColor: Theme.of(context).backgroundColor,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              constraints: BoxConstraints(
                                maxHeight: maxScreenHeight * 0.6,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'EDIT NAME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  FutureBuilder<Person>(
                                      future: UsersDao()
                                          .getCurrentUser(forceUpdate: true),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final currentUser =
                                              snapshot.requireData;
                                          _textEditingController.text =
                                              currentUser.name ?? '';
                                          _textEditingController.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                              offset: _textEditingController
                                                  .text.length,
                                            ),
                                          );
                                        }
                                        return Form(
                                          key: _formKey,
                                          child: TextFormField(
                                            autovalidateMode:
                                                AutovalidateMode.disabled,
                                            controller: _textEditingController,
                                            enabled: true,
                                            validator: (input) {
                                              if (input != null) {
                                                if (input.trim().isEmpty) {
                                                  return "Name can't be empty";
                                                }
                                              }
                                            },
                                            textCapitalization:
                                                TextCapitalization.words,
                                            maxLength: 25,
                                            keyboardType: TextInputType.name,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              counter: const SizedBox(),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.person,
                                                color: Theme.of(context)
                                                    .primaryTextColor,
                                              ),
                                              fillColor: Colors.pink,
                                              focusColor: Colors.orange,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryTextColor,
                                                  width: 2,
                                                ),
                                                gapPadding: 0,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryTextColor
                                                      .withOpacity(0.3),
                                                  width: 2,
                                                ),
                                                gapPadding: 0,
                                              ),
                                              labelText: '  Name  ',
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.auto,
                                              hintText: "Your name",
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  width: 2,
                                                  color: Theme.of(context)
                                                      .errorColor,
                                                ),
                                                gapPadding: 0,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                                gapPadding: 0,
                                              ),
                                              labelStyle: TextStyle(
                                                fontFamily:
                                                    Strings.primaryFontFamily,
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context)
                                                    .primaryTextColor,
                                              ),
                                              hintStyle: TextStyle(
                                                fontFamily:
                                                    Strings.primaryFontFamily,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryTextColor
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await UsersDao().editProfileName(
                                                _textEditingController.text
                                                    .trim());
                                            Fluttertoast.showToast(
                                                msg: "Profile Updated");
                                            UsersDao.currentUser = null;
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ListTile(
                  title: Text(
                    'Select Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.themeSelect);
                  },
                ),
                if (context.read<LoginCubit>().state.currentLoginState ==
                    CurrentLoginState.loggedIn)
                  ListTile(
                    title: Text(
                      'Sync Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRouter.syncScreen);
                    },
                  ),
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    if (state.currentLoginState == CurrentLoginState.loggedIn) {
                      return ListTile(
                        title: Text(
                          'Log out',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => ConfirmationDialog(
                              actionText: 'Log Out',
                              content:
                                  'Are you sure you want to logout?\n\nAny unsynced changes will be LOST.',
                            ),
                          );
                          if (confirm == true) {
                            AuthHandler.signOut();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRouter.dashboard,
                              (route) => true,
                            );
                          }
                        },
                      );
                    }
                    return ListTile(
                      title: Text(
                        'Log in / Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () async {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Infomation"),
                            content: Text(
                                "If you are a NEW USER, local device data is safe.\n\nFor registered users, local device data will be removed and replaced with user's online data."),
                            backgroundColor: Theme.of(context).backgroundColor,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Continue'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          Navigator.of(context)
                              .pushNamed(AppRouter.onboardLogin);
                        }
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    'About the app',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.aboutScreen);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
