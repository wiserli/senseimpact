import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pothole_detection_app/view/home_view.dart';

import '../theme/theme_utils.dart';

class BottomNavBar extends StatefulWidget {
  static const String routeName = '/bottomNavBar';
  final int? initialPage;
  final int? initialModelViewTab;
  final String? additionalArg;

  const BottomNavBar({
    Key? key,
    this.initialPage,
    this.initialModelViewTab,
    this.additionalArg,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  int currentPage = 0;
  TabController? tabController;

  // Local copies of initial arguments
  int? _initialPage;
  int? _initialModelViewTab;
  String? _additionalArg;

  final List<Color> colors = [
    CustomColors.fuchsiaColor,
    CustomColors.darkPinkColor,
    Colors.deepPurple,
    CustomColors.darkblueAccentColor,
  ];

  @override
  void initState() {
    super.initState();
    _initialPage = widget.initialPage;
    _initialModelViewTab = widget.initialModelViewTab;
    _additionalArg = widget.additionalArg;

    currentPage = _initialPage ?? 0;

    tabController = TabController(
      length: 4,
      initialIndex: currentPage,
      vsync: this,
    );

    tabController!.addListener(() {
      final value = tabController!.index;
      if (value != currentPage && mounted) {
        changePage(value);
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to exit the app?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Yes'),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (currentPage != 0) {
      tabController!.animateTo(0);
      return false; // Prevents exiting the app
    } else {
      final bool shouldExit = await _showExitDialog() ?? false;
      return shouldExit; // Allows the app to close if the user confirms
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color unselectedColor =
        colors[currentPage].computeLuminance() < 0.5
            ? Colors.black
            : Colors.white;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        // maintainBottomViewPadding: true,
        top: false,
        bottom: false,
        child: Scaffold(
          body: BottomBar(
            clip: Clip.none,
            fit: StackFit.expand,
            borderRadius: BorderRadius.circular(500),
            duration: const Duration(milliseconds: 500),
            curve: Curves.decelerate,
            showIcon: false,
            width: MediaQuery.of(context).size.width * 0.8,
            barColor:
                colors[currentPage].computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
            start: 2,
            end: 0,
            offset: 10.h,
            barAlignment: Alignment.bottomCenter,
            iconHeight: 30,
            iconWidth: 30,
            reverse: true,
            barDecoration: BoxDecoration(
              color: colors[currentPage],
              borderRadius: BorderRadius.circular(500),
            ),
            iconDecoration: BoxDecoration(
              color: colors[currentPage],
              borderRadius: BorderRadius.circular(500),
            ),
            hideOnScroll: true,
            scrollOpposite: false,
            onBottomBarHidden: () {},
            onBottomBarShown: () {},
            body: (context, controller) {
              Widget view;
              switch (currentPage) {
                case 0:
                  view = HomeView();
                  _initialModelViewTab = null;
                  _additionalArg = null;
                  break;

                default:
                  view = Container();
              }
              return view;
            },
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                TabBar(
                  dividerColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                  controller: tabController,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color:
                          currentPage <= 4
                              ? colors[currentPage]
                              : unselectedColor,
                      width: 4,
                    ),
                    insets: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  ),
                  tabs: [
                    SizedBox(
                      height: 55,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.view_in_ar,
                          size: 30,
                          color: currentPage == 0 ? colors[0] : unselectedColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: currentPage == 1 ? colors[1] : unselectedColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.account_tree_outlined,
                          color: currentPage == 2 ? colors[2] : unselectedColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.manage_accounts_outlined,
                          color: currentPage == 3 ? colors[3] : unselectedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
