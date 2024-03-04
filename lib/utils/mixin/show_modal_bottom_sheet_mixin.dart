import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

mixin ShowModalBottomSheetMixin {
  void onTapImage({
    required BuildContext context,
    required Function() camera,
    required Function() album,
  }) {
    primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: TextButton(
                      onPressed: () {
                        context.pop();
                        camera();
                      },
                      child: Text(
                        'カメラ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: TextButton(
                    onPressed: () {
                      context.pop();
                      album();
                    },
                    child: Text(
                      'アルバム',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                Divider(),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      '閉じる',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onTapOtherDetail({
    required BuildContext context,
    required Function() share,
    required Function() search,
    required Function() report,
    required Function() block,
  }) {
    primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    L10n.of(context).posts_detail_sheet_title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        share();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                            color: Colors.black,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            L10n.of(context).posts_detail_sheet_share,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        search();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.place,
                            color: Colors.black,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            L10n.of(context).posts_detail_sheet_search,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        report();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.announcement_outlined,
                            color: Colors.red,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            L10n.of(context).posts_detail_sheet_report,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        block();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_off,
                            color: Colors.red,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            L10n.of(context).posts_detail_sheet_block,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            L10n.of(context).close,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onTapMyDetail({
    required BuildContext context,
    required Function() share,
    required Function() search,
    required Function() delete,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.sizeOf(context).width - 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    'この投稿について',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        share();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                            color: Colors.black,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'この投稿をシェアする',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        search();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.place,
                            color: Colors.black,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'この投稿の場所を検索する',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                        delete();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.restore_from_trash,
                            color: Colors.red,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'この投稿を削除する',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFEFEFEF),
                        foregroundColor: Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 25,
                          ),
                          SizedBox(width: 20),
                          Text(
                            '閉じる',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
