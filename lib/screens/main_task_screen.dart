import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homework_management_fellow/model/homework.dart';
import 'package:homework_management_fellow/screens/private_task_screen.dart';
import 'package:homework_management_fellow/services/firebaseService.dart';
import 'package:homework_management_fellow/widgets/homework_card.dart';
import 'package:homework_management_fellow/screens/task_create_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Homework> homeworkList = [];
  void initState() {
    super.initState();
    loadHomeworkList();
  }

  void loadHomeworkList() async {
    final prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');
    List<Homework> _homeworkList =
        await Provider.of<FirebaseService>(context, listen: false).getPublicHomeWorkList(uid);
    setState(() {
      homeworkList = _homeworkList;
    });
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');
    homeworkList = await Provider.of<FirebaseService>(context, listen: false).getPublicHomeWorkList(uid);
    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.format_list_numbered_rounded), label: "Public task"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add task"),
          BottomNavigationBarItem(icon: Icon(Icons.local_library_rounded), label: "Private task"),
        ],
      ),
      backgroundColor: Colors.white,
      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Color(0xFF2196f3),
              leading: Icon(
                Icons.filter_alt,
                color: Colors.white,
              ),
              middle: Text(
                "HMF",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
            child: homeworkList != null
                ? taskListBuilder()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("No task been added atm"),
                  ),
          );
        } else if (index == 1) {
          return TaskCreatePage();
        } else {
          return PrivateTaskScreen();
        }
      },
    );
  }

  CupertinoScrollbar taskListBuilder() {
    return CupertinoScrollbar(
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        enablePullUp: false,
        enablePullDown: true,
        header: ClassicHeader(
          textStyle: Theme.of(context).textTheme.bodyText1,
        ),
        enableTwoLevel: false,
        child: ListView.builder(
          itemCount: homeworkList.length,
          itemBuilder: (BuildContext context, int index) {
            return HomeworkCard(homeworkList[index]);
          },
        ),
      ),
    );
  }
}
