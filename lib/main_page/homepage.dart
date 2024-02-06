import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_page/add/add_page.dart';
import 'package:login_page/constant/constants.dart';
import 'package:login_page/firebase/storage.dart';
import 'package:login_page/main_page/chat/chat_page.dart';
import 'package:login_page/model/user.dart';
import 'package:login_page/provider/rebuild_notifier.dart';
import 'package:login_page/provider/username_provider.dart';
import 'package:login_page/user/user_page.dart';
import 'package:login_page/widget/height_spacer.dart';
import 'package:login_page/widget/show_post.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();

  List<UserInfoOri> userData = [];
  List<Map<String, dynamic>> comments = [];
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    final String commentsJson =
        await rootBundle.loadString('assets/data/comment.json');
    final List<dynamic> commentsList = json.decode(commentsJson);

    setState(() {
      comments = List<Map<String, dynamic>>.from(commentsList);
    });
  }

  void rebuildHomePage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rebuildNotifierProvider);
    return FutureBuilder(
        future: Future.delayed(
            Duration.zero, () => ref.watch(usernameStateProvider)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            String username = snapshot.data!;
            print('username: $username');
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: AppConst.kLight,
                centerTitle: false,
                title: Text('My project', style: GoogleFonts.pacifico()),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => const ChatPage()),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat))
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0.w, 10.h, 20.w, 0),
                        child: storyPost(username),
                      ),
                      HeightSpacer(hieght: 20.h),
                      ShowPosts(
                        username: username,
                        heightMultiplier: 0.65.h,
                        page: 'homepage',
                      ),
                    ],
                  ),
                ),
              ),
              // bottomNavigationBar:
              //     SafeArea(child: BottomNav(username: username)),
            );
          } else {
            return Container();
          }
        });
  }

  Widget addImage(BuildContext context, String username) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Container(
        height: 35.h,
        width: 35.w,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.all(
            Radius.circular(AppConst.kRadius),
          ),
        ),
        child: FutureBuilder(
            future: StoreFirebase().fetchUserDatabyName(username),
            builder: (context, snapshot) {
              UserInfoOri? data = snapshot.data;
              return IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddPage(data!.userName)),
                  );
                },
                icon: const Icon(Icons.add),
              );
            }),
      ),
    );
  }

  Widget userProfile(BuildContext context, String username) {
    return FutureBuilder(
      future: StoreFirebase().fetchUserDatabyName(username),
      builder: (context, snapshot) {
        UserInfoOri? data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserPage(
                            userName: data.userName,
                            userId: data.uid!,
                            role: 0,
                          )));
            },
            child: CircleAvatar(
              radius: 24.w,
              backgroundImage: NetworkImage(data!.profilePicture!),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(left: 0.0.w),
            child: GestureDetector(
              onTap: () {},
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: CircleAvatar(
                  radius: 24.w,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // Widget userProfile(BuildContext context, String username) {
  //   return FutureBuilder(
  //     future: StoreFirebase().fetchUserDatabyName(username),
  //     builder: (context, snapshot) {
  //       UserInfoOri? data = snapshot.data;
  //       if (snapshot.connectionState == ConnectionState.done) {
  //         return Padding(
  //           padding: EdgeInsets.only(left: 20.0.w),
  //           child: GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => UserPage(
  //                             userName: data.userName,
  //                             role
  //                           )));
  //             },
  //             child: CircleAvatar(
  //               radius: 20.w,
  //               backgroundImage: NetworkImage(data!.profilePicture!),
  //             ),
  //           ),
  //         );
  //       } else {
  //         return Padding(
  //           padding: EdgeInsets.only(left: 20.0.w),
  //           child: GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => UserPage(
  //                             userName: data!.userName,
  //                           )));
  //             },
  //             child: Shimmer.fromColors(
  //               baseColor: Colors.grey[300]!,
  //               highlightColor: Colors.grey[100]!,
  //               child: CircleAvatar(
  //                 radius: 20.w,
  //               ),
  //             ),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget storyPost(String username) {
    return FutureBuilder(
      future: StoreFirebase().fetchUserDatabyName(username),
      builder: (context, snapshot) {
        UserInfoOri? data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
            width: 80.w,
            height: 80.h,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: 45.w,
                    backgroundColor: AppConst.kGreyLight,
                    child: CircleAvatar(
                        radius: 35.w,
                        backgroundImage: NetworkImage(data!.profilePicture!)),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              ],
            ),
          );
        } else {
          return SizedBox(
            width: 80.w,
            height: 80.h,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () async {},
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: CircleAvatar(
                      radius: 45.w,
                      backgroundColor: AppConst.kGreyLight,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
