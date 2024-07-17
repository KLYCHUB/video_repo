import 'package:flutter/material.dart';
import 'package:video_repo/components/custom_text_field.dart';
import 'package:video_repo/localization/strings.dart';
import 'package:video_repo/styles/styles.dart';
import 'package:video_repo/utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            snap: true,
            floating: true,
            title: const Padding(
              padding: AppPaddings.all8,
              child: Text(AppStrings.appBarTitle,
                  style: AppTextStyles.appBarTitle),
            ),
            bottom: AppBar(
              title: const Padding(
                padding: AppPaddings.all8,
                child: CustomTextField(
                  hintText: AppStrings.searchHint,
                  icon: Icon(Icons.search, color: AppColors.black),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppBorders.radius),
                ),
                height: MediaQuery.of(context).size.height,
                child: const Column(
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: AppPaddings.horizontal24,
                          child: Text(AppStrings.enterKeyword,
                              style: AppTextStyles.modalTitle),
                        ),
                        const Padding(
                          padding: AppPaddings.horizontal24,
                          child: CustomTextField(
                            hintText: AppStrings.exampleHint,
                            icon: null,
                          ),
                        ),
                        Padding(
                          padding: AppPaddings.horizontal24,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.red),
                              color: AppColors.lightRed,
                              borderRadius:
                                  BorderRadius.circular(AppBorders.radius),
                            ),
                            child: InkWell(
                              onTap: () {},
                              child: const Padding(
                                padding: AppPaddings.horizontal24,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Center(
                                          child: Image(
                                            height: 70,
                                            image: AssetImage(
                                                'assets/images/bg.png'),
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 8.5),
                                            child: Image(
                                              height: 40,
                                              image: AssetImage(
                                                  'assets/images/video.png'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(AppStrings.selectVideo,
                                        style: AppTextStyles.selectVideoText),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width * 0.9, 49),
                              backgroundColor: AppColors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppBorders.radius),
                              ),
                            ),
                            child: const Text(AppStrings.add,
                                style: AppTextStyles.modalButtonText),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 49),
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorders.radius),
              ),
            ),
            child: const Text(AppStrings.addNewVideo,
                style: AppTextStyles.modalButtonText),
          ),
        ),
      ],
    );
  }
}
