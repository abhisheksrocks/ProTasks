import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/auth_handler.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/status_nav_bar_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/loading_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:flutter/material.dart';

import 'package:protasks/logic/extra_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnterEmailPageViewProvider extends StatelessWidget {
  const EnterEmailPageViewProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TextEditingControllerCubit(),
        ),
      ],
      child: EnterEmailPageView(),
    );
  }
}

class EnterEmailPageView extends StatefulWidget {
  const EnterEmailPageView({Key? key}) : super(key: key);

  @override
  _EnterEmailPageViewState createState() => _EnterEmailPageViewState();
}

class _EnterEmailPageViewState extends State<EnterEmailPageView> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    context
        .read<TextEditingControllerCubit>()
        .beginFetching(newTextEditingController: _textEditingController);
    super.initState();
  }

  void submitEmail() async {
    if (_formKey.currentState!.validate()) {
      context.read<KeyboardVisibilityWithFocusNodeCubit>().dismissKeyboard();
      
      
      String email = _textEditingController.text.trim().toLowerCase();
      LoginCubit.loginEmail = email;
      context.read<LoadingCubit>().changeLoading(
            isLoading: true,
          );
      await AuthHandler.signInWithEmailOnly(email: email);
      context.read<LoadingCubit>().changeLoading(
            isLoading: false,
          );
      
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        
        
        
        
        
        
        
        
        
        
        
        
        SizedBox(),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.77,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.disabled,
                  controller: _textEditingController,
                  validator: (input) {
                    if (input != null) {
                      return input.isValidEmail ? null : 'Enter a valid email';
                    }
                  },
                  focusNode: context
                      .read<KeyboardVisibilityWithFocusNodeCubit>()
                      .getFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counter: const SizedBox(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),

                    
                    fillColor: Colors.pink,
                    focusColor: Colors.orange,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        
                        color: Colors.white,
                        width: 2,
                      ),
                      gapPadding: 0,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        
                        color: Colors.white,
                        width: 2,
                      ),
                      gapPadding: 0,
                    ),
                    labelText: '  E-mail  ',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    hintText: "Your email",
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 2,
                        color: Theme.of(context).errorColor,
                      ),
                      gapPadding: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        
                        color: Colors.white,
                      ),
                      gapPadding: 0,
                    ),
                    labelStyle: TextStyle(
                      fontFamily: Strings.primaryFontFamily,
                      fontWeight: FontWeight.w700,
                      
                      color: Colors.white,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: Strings.primaryFontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.5),
                      
                    ),
                  ),
                ),
              ),
              Text(
                'Must be accessible from this device.\n(We will send a link to login)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          child: Opacity(
            opacity: context
                    .watch<TextEditingControllerCubit>()
                    .state
                    .textString
                    .isNotEmpty
                ? 1
                : 0.5,
            child: Material(
              color: context.read<StatusNavBarCubit>().state.themeMode ==
                      ThemeMode.dark
                  ? Theme.of(context).accentColor
                  : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: context
                        .read<TextEditingControllerCubit>()
                        .state
                        .textString
                        .isNotEmpty
                    ? () {
                        print("Submit");
                        submitEmail();
                      }
                    : null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 2,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.77,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          'Continue',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Strings.primaryFontFamily,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            
                            
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(),
      ],
    );
  }
}
