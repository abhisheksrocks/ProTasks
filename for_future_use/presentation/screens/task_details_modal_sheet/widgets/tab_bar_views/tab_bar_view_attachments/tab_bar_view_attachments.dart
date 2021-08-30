import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

import 'widgets/attachment_section_heading.dart';
import 'widgets/attachment_action_button.dart';

class TabBarViewAttachments extends StatelessWidget {
  static const double _length = 120;
  static const double _spacingBetweenActionButtons = 12;
  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    return ListView(
      children: [
        const AttachmentSectionHeading(
          padding: const EdgeInsets.symmetric(
            horizontal: _spacingBetweenActionButtons * 1.5,
            vertical: _spacingBetweenActionButtons,
          ),
          sectionTitle: "Add New Files",
        ),
        // GridView.count(
        //   crossAxisCount: 6,
        //   crossAxisSpacing: 10,
        //   mainAxisSpacing: 10,
        //   shrinkWrap: true,
        //   physics: NeverScrollableScrollPhysics(),
        //   children: [
        //     Container(
        //       color: Colors.pink,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.teal,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.purple,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.black,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.green,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.yellow,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //   ],
        // ),
        // // GridView(
        //   gridDelegate:
        //       SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 150),
        //   physics: NeverScrollableScrollPhysics(),
        //   children: [
        //     Container(
        //       color: Colors.pink,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.pink,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.pink,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.pink,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //     Container(
        //       color: Colors.pink,
        //       child: AspectRatio(
        //         aspectRatio: 1,
        //       ),
        //     ),
        //   ],
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _spacingBetweenActionButtons,
          ),
          child: Column(
            children: [
              Align(
                child: Wrap(
                  runSpacing: _spacingBetweenActionButtons,
                  spacing: _spacingBetweenActionButtons,
                  children: [
                    AttachmentActionButton(
                      sideLength: _length,
                      iconToShow: Icon(Icons.camera_rounded),
                      buttonText: "Take Picture",
                      // TODO: Implement onTap function
                      onTap: () async {
                        // final ImagePicker _picker = ImagePicker();
                        // _picker.getImage(source: ImageSource.camera);
                      },
                    ),
                    AttachmentActionButton(
                      sideLength: _length,
                      iconToShow: Icon(Icons.photo_rounded),
                      buttonText: "Pick Image",
                      // TODO: Implement onTap function
                      onTap: () async {
                        // final ImagePicker _picker = ImagePicker();
                        // _picker.getImage(source: ImageSource.gallery);
                      },
                    ),
                    AttachmentActionButton(
                      sideLength: _length,
                      iconToShow: Icon(Icons.insert_drive_file_rounded),
                      buttonText: "Document",
                      // TODO: Implement onTap function
                      onTap: () async {
                        // FilePickerResult? _filePickerResult =
                        //     await FilePicker.platform.pickFiles();
                        // if (_filePickerResult != null) {
                        //   List<File> _files = _filePickerResult.paths
                        //       .map((path) => File(path!))
                        //       .toList();
                        // }
                      },
                    ),
                    AttachmentActionButton(
                      sideLength: _length,
                      iconToShow: Icon(Icons.person_rounded),
                      buttonText: "Contact",
                      // TODO: Implement onTap function
                      onTap: () {},
                    ),
                    AttachmentActionButton(
                      sideLength: _length,
                      iconToShow: Icon(Icons.audiotrack_rounded),
                      buttonText: "Audio",
                      // TODO: Implement onTap function
                      onTap: () {},
                    ),
                    AttachmentActionButton(
                      sideLength: _length,
                      iconToShow: Icon(Icons.location_on_rounded),
                      buttonText: "Location",
                      // TODO: Implement onTap function
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: _spacingBetweenActionButtons,
        ),
        AttachmentSectionHeading(
          padding: const EdgeInsets.symmetric(
            horizontal: _spacingBetweenActionButtons * 1.5,
          ),
          sectionTitle: "Files Added",
          actionWidget: TextButton(
            child: Row(
              children: [
                const Text('Sort'),
                const Icon(Icons.sort_rounded),
              ],
            ),
            // style: Theme.of(context).textButtonThemeStyle,
            // TODO: Implement sort function
            onPressed: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _spacingBetweenActionButtons,
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 5,
            children: [
              Container(
                decoration: BoxDecoration(
                  // color: Theme.of(context).chatBackgroundColor,
                  // color: Theme.of(context).primaryColor,
                  color: Theme.of(context).primaryTextColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file_rounded,
                        size: 60,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meeting Notes.pdf',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: Strings.secondaryFontFamily,
                              ),
                            ),
                            Text(
                              '2 Pages - 956 KB - PDF - Yesterday',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: Strings.primaryFontFamily,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .primaryTextColor
                                    .withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Material(
                color: Theme.of(context).primaryTextColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          size: 60,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Study Material.docx',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: Strings.secondaryFontFamily,
                                ),
                              ),
                              Text(
                                '14 Pages - 19 MB - DOCX - Yesterday',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: Strings.primaryFontFamily,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .primaryTextColor
                                      .withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  // color: Theme.of(context).chatBackgroundColor,
                  // color: Theme.of(context).primaryColor,
                  color: Theme.of(context).primaryTextColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file_rounded,
                        size: 60,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Study Material.docx',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: Strings.secondaryFontFamily,
                              ),
                            ),
                            Text(
                              '2 Pages - 956 KB - PDF - Yesterday',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: Strings.primaryFontFamily,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .primaryTextColor
                                    .withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
    // return GridView(
    //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //       maxCrossAxisExtent: maxCrossAxisExtent),
    //   children: [],
    // );
  }
}
