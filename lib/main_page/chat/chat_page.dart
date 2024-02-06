import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login_page/constant/constants.dart';
import 'package:login_page/firebase/storage.dart';
import 'package:login_page/main_page/chat/chat_room.dart';
import 'package:login_page/model/follow.dart';
import 'package:login_page/model/user.dart';
import 'package:login_page/provider/search_provider.dart';
import 'package:login_page/provider/uid_provider.dart';
import 'package:login_page/provider/username_provider.dart';
import 'package:login_page/widget/appstyle.dart';
import 'package:login_page/widget/custom_text.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatRoomState();
}

class _ChatRoomState extends ConsumerState<ChatPage> {
  TextEditingController search = TextEditingController();
  List<FollowingUser> accounts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            searchFilter(),
            searchResult(),
          ],
        ),
      )),
    );
  }

  Widget searchFilter() {
    String uid = ref.watch(uidStateProvider);
    return CustomTextField(
        controller: search,
        onChanged: (value) async {
          accounts = await StoreFirebase().filterChatAccount(value, uid);
          ref.read(searchNotifierProvider.notifier).triggerRebuild();
          print('hi, ${accounts.length}');
        },
        suffixIcon: const Icon(Icons.search),
        hintText: 'search name',
        obscureText: false,
        color: AppConst.kGreyLight);
  }

  Widget searchResult() {
    String ownerName = ref.watch(usernameStateProvider);
    print('result');
    return Expanded(
      child: Consumer(builder: (context, ref, child) {
        ref.watch(searchNotifierProvider);
        return SizedBox(
          width: AppConst.kWidth * 0.9,
          child: ListView(
            children: ListTile.divideTiles(
              color: const Color.fromARGB(255, 94, 94, 94),
              context: context,
              tiles: accounts.map((FollowingUser account) {
                return FutureBuilder(
                    future: StoreFirebase().fetchUserDatabyUid(account.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        UserInfoOri? data = snapshot.data!;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0.h),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ChatRoom(
                              //       profilePicture: data.profilePicture!,
                              //       friendName: data.userName,
                              //     ),
                              //   ),
                              // );
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ChatRoom(
                                        profilePicture: data.profilePicture!,
                                        friendName: data.userName,
                                        friendUid: data.uid!,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data.profilePicture!),
                              ),
                              title: Text(
                                account.username,
                                style: appstyle(
                                    15, AppConst.kLight, FontWeight.w400),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    });
              }),
            ).toList(),
          ),
        );
      }),
    );
  }
}
