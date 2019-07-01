import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_books/data/model/request/genuine_source_req.dart';
import 'package:flutter_books/data/model/response/book_chapters_resp.dart';
import 'package:flutter_books/data/model/response/book_genuine_source_resp.dart';
import 'package:flutter_books/data/repository/repository.dart';
import 'package:flutter_books/res/colors.dart';
import 'package:flutter_books/res/dimens.dart';
import 'package:flutter_books/ui/details/book_chapters_content_page.dart';

///@author longshaohua
///小说目录章节页

class BookChaptersPage extends StatefulWidget {
  final String _bookId;

  BookChaptersPage(this._bookId);

  @override
  State<StatefulWidget> createState() {
    return BookChaptersPageState();
  }
}

class BookChaptersPageState extends State<BookChaptersPage> {
  List<BookChaptersBean> _listBean = [];
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: titleView(),
      ),
      body: new ListView.separated(
        controller: _controller,
        padding:
            EdgeInsets.fromLTRB(Dimens.leftMargin, 0, Dimens.rightMargin, 0),
        itemCount: _listBean.length,
        itemBuilder: (context, index) {
          return itemView(index);
        },
        separatorBuilder: (context, index) {
          return Divider(height: 1, color: MyColors.dividerDarkColor);
        },
      ),
    );
  }

  Widget titleView() {
    return Container(
      constraints: BoxConstraints.expand(height: Dimens.titleHeight),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      Dimens.leftMargin, 0, Dimens.rightMargin, 0),
                  child: Image.asset(
                    'images/icon_title_back.png',
                    width: 20,
                    height: Dimens.titleHeight,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _listBean = _listBean.reversed.toList();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "目录",
                  style: TextStyle(
                      fontSize: Dimens.titleTextSize,
                      color: MyColors.textPrimaryColor),
                  overflow: TextOverflow.ellipsis,
                ),
                Image.asset(
                  "images/icon_chapters_turn.png",
                  width: 16,
                  height: 16,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void getData() async {
    GenuineSourceReq genuineSourceReq =
        GenuineSourceReq("summary", this.widget._bookId);
    var entryPoint =
        await Repository().getBookGenuineSource(genuineSourceReq.toJson());
    BookGenuineSourceResp bookGenuineSourceResp =
        BookGenuineSourceResp(entryPoint);
    if (bookGenuineSourceResp.data != null &&
        bookGenuineSourceResp.data.length > 0) {
      await Repository()
          .getBookChapters(bookGenuineSourceResp.data[0].id)
          .then((json) {
        BookChaptersResp bookChaptersResp = BookChaptersResp(json);
        setState(() {
          _listBean = bookChaptersResp.chapters;
        });
      }).catchError((e) {
        //请求出错
        print(e.toString());
      });
    }
  }

  Widget itemView(int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BookContentPage(_listBean[index].link);
          }));
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                "${index + 1}.  ",
                style: TextStyle(fontSize: 9, color: MyColors.textBlack9),
              ),
              Expanded(
                child: Text(
                  _listBean[index].title,
                  style: TextStyle(
                      fontSize: Dimens.textSizeM, color: MyColors.textBlack9),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
