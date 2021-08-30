import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/package_info_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  String processName(String input) {
    String stringToReturn = '';
    final stringList = input.split("(");
    stringToReturn += stringList.elementAt(0);
    for (int i = 1; i < stringList.length; i++) {
      stringToReturn += "\n(${stringList.elementAt(i)}";
    }
    return stringToReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryTextColor,
                        shape: BoxShape.circle,
                      ),
                      margin: EdgeInsets.only(
                        right: 8,
                      ),
                      child: Image.asset(
                        'assets/images/logo_foreground.png',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  processName(PackageInfoHandler.appName),
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  PackageInfoHandler.version,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About the Developer',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        "This app is created by Abhishek, a passion driven developer in Bangalore, India. He likes creating apps. He hopes it's been a pleasant experience so far. With time, he'll keep adding more features to this app.",
                        style: TextStyle(
                          fontFamily: Strings.secondaryFontFamily,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "\nYou can connect with him on LinkedIn, he would be delighted to talk to you.\n",
                        style: TextStyle(
                          fontFamily: Strings.secondaryFontFamily,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: Color(0xFF0077B5),
                              ),
                              icon: FaIcon(
                                FontAwesomeIcons.linkedin,
                              ),
                              onPressed: () async {
                                String url =
                                    "https://www.linkedin.com/in/abhishek-97099b125/?lipi=urn%3Ali%3Apage%3Ad_flagship3_feed%3BGqj4u%2FmDTGaFIObC1B6uPQ%3D%3D";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Unable to open! Try again later.",
                                  );
                                }
                              },
                              // label: Text('Abhishek on LinkedIn'),
                              label: RichText(
                                text: TextSpan(
                                  text: "Abhishek on",
                                  children: [
                                    TextSpan(
                                      text: " LinkedIn",
                                      style: TextStyle(
                                        fontFamily: Strings.primaryFontFamily,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    )
                                  ],
                                  style: TextStyle(
                                    fontFamily: Strings.primaryFontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "\nView the latest changes, follow along the development, or make your own ProTasks clone😉 from GitHub:\n",
                        style: TextStyle(
                          fontFamily: Strings.secondaryFontFamily,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: Color(0xFF3fb950),
                              ),
                              icon: FaIcon(
                                FontAwesomeIcons.github,
                              ),
                              onPressed: () async {
                                String url =
                                    "https://github.com/abhisheksrocks/ProTasks";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Unable to open! Try again later.",
                                  );
                                }
                              },
                              // label: Text('Abhishek on LinkedIn'),
                              label: RichText(
                                text: TextSpan(
                                  text: "ProTasks on",
                                  children: [
                                    TextSpan(
                                      text: " GitHub",
                                      style: TextStyle(
                                        fontFamily: Strings.primaryFontFamily,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    )
                                  ],
                                  style: TextStyle(
                                    fontFamily: Strings.primaryFontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "\nIf you found a bug or had a query specfic to the app, you can reach the developer via email:\n",
                        style: TextStyle(
                          fontFamily: Strings.secondaryFontFamily,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              style: Theme.of(context).myTextButtonStyle,
                              icon: Icon(Icons.mail),
                              onPressed: () async {
                                Uri mailUri = Uri(
                                  scheme: 'mailto',
                                  path: 'developer@protasks.in',
                                );
                                if (await canLaunch(mailUri.toString())) {
                                  await launch(mailUri.toString());
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Unable to open! Try again later.",
                                  );
                                }
                              },
                              label: Text('developer@protasks.in'),
                            ),
                          ),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          text: "\nAnd most of all things, ",
                          style: TextStyle(
                            fontFamily: Strings.secondaryFontFamily,
                            fontSize: 14,
                            color: Theme.of(context).primaryTextColor,
                          ),
                          children: [
                            TextSpan(
                              text: "thanks a lot for using the app.",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text: "❤\n",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.arrow_back,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      label: Text('Go Back'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
