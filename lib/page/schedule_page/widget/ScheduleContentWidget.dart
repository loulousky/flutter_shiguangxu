import 'dart:async';
import 'dart:math';

import 'dart:ui';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/rendering.dart';
import 'package:flutter_shiguangxu/common/Constant.dart';
import 'package:flutter_shiguangxu/common/EventBusUtils.dart';
import 'package:flutter_shiguangxu/common/WindowUtils.dart';

import 'package:flutter_shiguangxu/entity/sechedule_entity.dart';
import 'package:flutter_shiguangxu/page/home_page/event/TodayContentIndexEvent.dart';
import 'package:flutter_shiguangxu/page/home_page/event/TodayWeekCalendarIndexEvent.dart';
import 'package:flutter_shiguangxu/page/schedule_page/presenter/SchedulePresenter.dart';
import 'package:flutter_shiguangxu/page/schedule_page/presenter/ScheduleDatePresenter.dart';
import 'package:flutter_shiguangxu/widget/BottomSheet.dart' as sgx;

import 'package:flutter_shiguangxu/widget/MyBehavior.dart';
import 'package:flutter_shiguangxu/widget/PullListView.dart';
import 'package:flutter_shiguangxu/widget/RefreshScrollPhysics.dart';
import 'package:provider/provider.dart';

import '../schedule_details_page.dart';

class ScheduleContentWidget extends StatefulWidget {
  ScheduleContentWidget();

  @override
  _ScheduleContentWidgettState createState() => _ScheduleContentWidgettState();
}

class _ScheduleContentWidgettState extends State<ScheduleContentWidget>
    with TickerProviderStateMixin {
  List _headerTitleList = [
    "天气",
    "生理期",
    "记账",
    "专注",
    "纪念日",
    "日总结",
    "生日",
    "倒数日",
    "万年历",
    "闹钟",
    "还款提醒"
  ];

  List _headerImageList = [
    "tool_icon_weather.png",
    "icon_menstruation.png",
    "icon_bookkeeping.png",
    "icon_focus.png",
    "icon_jnr.png",
    "icon_summary.png",
    "tool_icon_day.png",
    "icon_dsr.png",
    "tool_icon_calendar.png",
    "tool_icon_clock.png",
    "icon_card.png"
  ];



  ScrollPhysics _contentScrollPhysics;



  List<SecheduleData> dataList = [];
  ScheduleDatePresenter weekPresenter;

  @override
  void initState() {
    weekPresenter = Provider.of<ScheduleDatePresenter>(context, listen: false);
    _contentScrollPhysics = AlwaysScrollableScrollPhysics();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getPlanListData();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getPlanListData() {
    var presenter = Provider.of<SchedulePresenter>(context, listen: false);

    presenter.getListData(context);
  }

  scrollPhysicsChanged(Physics) {
    setState(() {
      _contentScrollPhysics = Physics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: PullListView(
          initialPage: weekPresenter.currentPageIndex * 7 +
              weekPresenter.currentWeekIndex,
          handerContainerHeight: 100,
          handerChild: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _headerImageList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.only(left: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Image.asset(
                            "assets/images/${_headerImageList[index]}"),
                      ),
                      Text("${_headerTitleList[index]}")
                    ],
                  ),
                );
              }),
          contentChild:
              Consumer2<ScheduleDatePresenter,SchedulePresenter>(builder: (context, weekValue,presenter, child) {

            this.dataList = presenter.scheduleList;

            return _getTodayList(weekValue).length == 0
                ? ScrollConfiguration(
                    behavior: MyBehavior(false, true, Colors.blueAccent),
                    child: ListView(
                      physics: _contentScrollPhysics,
                      children: [_showEmptyContent()],
                    ))
                : _showListContent(presenter);
          }),
          scrollPhysicsChanged: _scrollPhysicsChanged,
        ));
  }

  _scrollPhysicsChanged(physics) {
    setState(() {
      _contentScrollPhysics = physics;
    });
  }

  List<SecheduleData> _getTodayList(ScheduleDatePresenter weekPresenter) {
    List<SecheduleData> toDayList = [];

    var time = weekPresenter.getNewCurrentTime();

    for (var value in dataList) {
      if (value.year == time.year &&
          value.month == time.month &&
          value.day == time.day) {
        toDayList.add(value);
      }
    }
    dataList = toDayList;
    return dataList;
  }

  _showListContent(SchedulePresenter presenter) {
    var leadingIcon = [
      "search_class_icon_work.png",
      "search_class_icon_learn.png",
      "search_class_icon_default.png",
      "search_class_icon_health.png",
      "search_class_icon_anniversary.png"
    ];

    var colors = [0xff4BAAFC, 0xff66C85C, 0xff5885FF, 0xffFF6071, 0xff8E7CF8];
    var levelIcon = [
      "icon_level_one.png",
      "icon_level_two.png",
      "icon_level_three.png",
      "icon_level_four.png"
    ];
    return ScrollConfiguration(
        behavior: MyBehavior(false, true, Colors.blueAccent),
        child: ListView.builder(
          physics: _contentScrollPhysics,
          itemBuilder: (context, index) {
            return Material(
              child:GestureDetector(
                onTapUp: (_)=>_onItemCallback(index),
                child:
                Dismissible(
                  onDismissed: (direction){

                    presenter.delSchedule(context,dataList[index].id);

                  },
                  child: Card(
                    margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 50,
                          padding: EdgeInsets.all(8),
                          color: Color(colors[dataList[index].type]).withAlpha(30),
                          child: Image.asset(
                            Constant.IMAGE_PATH + leadingIcon[dataList[index].type],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(dataList[index].title),
                          ),
                        )
                      ],
                    ),
                  ),
                  key: UniqueKey(),
                ),
              ),
            );
          },
          itemCount: dataList.length,
        ));
  }
  _onItemCallback(index) {


    sgx.showModalBottomSheet(
        context: context,
        builder: (context) {
          return ScheduleDetailsPage(dataList[index]);
        },
        backgroundColor: Colors.transparent,
        ratio: 0.85)
        .whenComplete(() {
      Provider.of<SchedulePresenter>(context, listen: false)
          .updateSchedule(context, dataList[index]);
    });
  }
  _showEmptyContent() {

    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/today_empty.png"),
          SizedBox(
            height: 20,
          ),
          Text(
            "今天还没有日程安排吖！",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          Text(
            "未来可期，提前做好日程安排",
            style: TextStyle(color: Colors.black26, fontSize: 14),
          )
        ],
      ),
    );
  }
}
