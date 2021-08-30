import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/page_controller_cubit.dart';
import 'package:protasks/presentation/screens/membership_screen/widgets/free_view/pageviews/free_stats_pageview.dart';
import 'package:protasks/presentation/screens/membership_screen/widgets/free_view/pageviews/free_first_pageview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageviewContainerProvider extends StatelessWidget {
  PageviewContainerProvider({Key? key}) : super(key: key);

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PageControllerCubit>(
          create: (context) => PageControllerCubit(
            pageController: _pageController,
          ),
        ),
      ],
      child: PageviewContainer(),
    );
  }
}

class PageviewContainer extends StatefulWidget {
  const PageviewContainer({
    Key? key,
  }) : super(key: key);

  @override
  _PageviewContainerState createState() => _PageviewContainerState();
}

class _PageviewContainerState extends State<PageviewContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView(
          controller: context.read<PageControllerCubit>().pageController,
          physics: BouncingScrollPhysics(),
          children: [
            FreeFirstPageview(),
            FreeStatsPageview(),
          ],
        ),
        BlocBuilder<PageControllerCubit, PageControllerState>(
          builder: (context, state) {
            return Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: state.currentPage < 1
                      ? null
                      : () {
                          context.read<PageControllerCubit>().previousPage();
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Opacity(
                      opacity: state.currentPage < 1 ? 0.3 : 1,
                      // opacity: 0,
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: state.currentPage > 0
                      ? null
                      : () {
                          context.read<PageControllerCubit>().nextPage();
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Opacity(
                      opacity: state.currentPage > 0 ? 0.3 : 1,
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
