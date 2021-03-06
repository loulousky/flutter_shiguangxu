import 'dart:ui';

import 'package:flustars/flustars.dart';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;

import 'package:flutter_shiguangxu/common/ColorUtils.dart';
import 'package:flutter_shiguangxu/common/Constant.dart';
import 'package:flutter_shiguangxu/common/NavigatorUtils.dart';
import 'package:flutter_shiguangxu/common/WindowUtils.dart';
import 'package:flutter_shiguangxu/page/quadrant_page/quadrant_page.dart';
import 'package:flutter_shiguangxu/page/schedule_page/presenter/SchedulePresenter.dart';
import 'package:flutter_shiguangxu/page/schedule_page/presenter/ScheduleDatePresenter.dart';
import 'package:flutter_shiguangxu/page/schedule_page/presenter/ScheduleWeekPresenter.dart';
import 'package:flutter_shiguangxu/page/schedule_page/schedule_week_page.dart';
import 'package:flutter_shiguangxu/page/schedule_page/widget/ScheduleAddPlanDialog.dart';
import 'package:flutter_shiguangxu/page/schedule_page/widget/ScheduleContentWidget.dart';

import 'package:flutter_shiguangxu/widget/BottomPopupRoute.dart';
import 'package:flutter_shiguangxu/widget/PopupWindow.dart';
import 'package:provider/provider.dart';

import 'widget/ScheduleWeekCalendarWidget.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  EdgeInsetsTween _tween;

  Animation<EdgeInsets> _animation;

  AnimationController _controller;

  double lastMoveIndex = 0;
  bool isShowBasic = true;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _tween = new EdgeInsetsTween(
        begin: EdgeInsets.only(left: 0.0), end: EdgeInsets.only(left: 0.0));
    _animation = _tween.animate(_controller);

    _animation.addStatusListener((AnimationStatus status) {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "today",
        backgroundColor: ColorUtils.mainColor,
        onPressed: () => _showAddPlanDialog(),
        child: Icon(Icons.add),
      ),
      backgroundColor: Color.fromARGB(255, 249, 250, 252),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTopWidget(),
          _buildMultipleView(),
          Expanded(
            child: ScheduleContentWidget(),
          )
        ],
      ),
    );
  }

  _showAddPlanDialog() {
    var contentKey = GlobalKey();

    var weekPresenter =
        Provider.of<ScheduleDatePresenter>(context, listen: false);
    Navigator.push(
        context,
        BottomPopupRoute(
            child: GestureDetector(
          onTapDown: (down) {
            if (down.globalPosition.dy <
                WindowUtils.getHeightDP() -
                    contentKey.currentContext.size.height) {
              Navigator.pop(context);
            }
          },
          child: ScheduleAddPlanDialog(
              contentKey, weekPresenter.getNewCurrentTime(),
              addScheduleCallback: (data) {
            Provider.of<SchedulePresenter>(context, listen: false)
                .addSchedule(data, context, success: (title) {
              if (data.year == null) {
                _showSuccessDialog(title);
              }
            });
          }),
        )));
  }

  _showSuccessDialog(String title) {
    PopupWindow.showDialog(context, 2000, this, (context) {
      return Material(
        color: Color.fromARGB(230, 255, 255, 255),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          decoration: BoxDecoration(),
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: Image.asset(Constant.IMAGE_PATH + "add_icon_hook.png"),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 5),
                  Text(
                    "清单添加成功",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(title,
                      style: TextStyle(fontSize: 16, color: Colors.black))
                ],
              )
            ],
          ),
        ),
      );
    }, top: 35, left: 10, right: 10);
  }

  _buildMultipleView() {
    var images = [
      "icon_all_view.png",
      "icon_week_view.png",
      "icon_month_view.png",
      "icon_quadrant_view.png",
      "icon_undone_view.png"
    ];
    var titles = ["全部", "周视图", "月视图", "四象限", "未完成"];
    return isShowBasic
        ? ScheduleWeekCalendarWidget()
        : Container(
            color: ColorUtils.mainColor,
            height: 60,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTapDown: (_) => _onMultipleItemClick(index),
                  child: Column(
                    children: <Widget>[
                      Image.asset(Constant.IMAGE_PATH + images[index]),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        titles[index],
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                );
              },
              itemCount: titles.length,
            ),
          );
  }

  _onMultipleItemClick(index) {
    switch (index) {
      case 1:
        NavigatorUtils.push(context, ScheduleWeekPage());
        break;
      case 3:
        NavigatorUtils.push(context, QuadrantPage());
        break;
    }
  }

  _buildTopWidget() {
    return Container(
      color: ColorUtils.mainColor,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    isShowBasic = !isShowBasic;
                  });
                },
                child: Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Consumer<ScheduleDatePresenter>(
                        builder: (_, presenter, child) {


                      return isShowBasic
                          ? Image.asset(
                              "assets/images/abc_ic_menu_copy_mtrl_am_alpha.png",
                              color: Colors.white70,
                            )
                          : Row(
                              children: <Widget>[
                                Text(
                                  "${presenter.getNewCurrentTime().day}",
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      "${DateUtil.getZHWeekDay(presenter.getNewCurrentTime())}\n${presenter.getNewCurrentTime().month}月",
                                      style: TextStyle(
                                          letterSpacing: 0,
                                          wordSpacing: 0,
                                          color: Colors.white),
                                    )
                                  ],
                                )
                              ],
                            );
                    })),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.only(
                          left: 20, top: 5, right: 20, bottom: 5),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(40, 255, 255, 255),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0))),
                      child: Text(
                        "改变自己,从现在做起",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              Image.asset("assets/images/home_img_totoro.png")
            ],
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
