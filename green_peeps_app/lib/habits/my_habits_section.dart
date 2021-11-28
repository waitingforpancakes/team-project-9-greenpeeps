import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_peeps_app/habits/habit_tile_info.dart';
import 'package:green_peeps_app/habits/habit_tile_info_dialogue.dart';

import 'package:green_peeps_app/models/habit.dart';
import 'package:green_peeps_app/services/habit_firestore.dart';

class MyHabitsSection extends StatefulWidget {
  const MyHabitsSection({Key? key}) : super(key: key);

  @override
  _MyHabitsSectionState createState() => _MyHabitsSectionState();
}

class _MyHabitsSectionState extends State<MyHabitsSection> {
  // List completedhabitKeys = [];
  // List completedhabitList = [];

  // @override
  // void initState() {
  //   super.initState();
  //   getCompletedHabitKeys().then(
  //     (result) {
  //       setState(
  //         () {
  //           completedhabitKeys = result;
  //           for (var key in completedhabitKeys) {
  //             getHabitFromStore(key).then(
  //               (r) {
  //                 setState(
  //                   () {
  //                     completedhabitList.add(r);
  //                   },
  //                 );
  //               },
  //             );
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

  // getCompletedHabitKeys() async {
  //   var userSnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .get();
  //   if (userSnapshot.exists && userSnapshot['userHabits'] != null) {
  //     var habitKeys = userSnapshot['userHabits'].keys.toList();
  //     var copyKeys = [...habitKeys];
  //     for (var key in copyKeys) {
  //       if (userSnapshot['userHabits'][key]['completed'] == false) {
  //         habitKeys.remove(key);
  //       }
  //     }
  //     return habitKeys;
  //   } else {
  //     return [];
  //   }
  // }

  Widget _buildMyHabitsSection(BuildContext context, List<Habit> habitList) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      "Completed Habits",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                    ),
                  ],
                ),
              ),
              Material(
                color: const Color.fromRGBO(248, 244, 219, 1),
                borderRadius: BorderRadius.circular(5.0),
                elevation: 5,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: habitList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          HabitTileInfo(
                              habitNum: index + 1,
                              habitName: habitList[index].title,
                              habitDescription: habitList[index].info),
                          const Divider(
                            color: Colors.grey,
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        childCount: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> users = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    Stream<QuerySnapshot<Map<String, dynamic>>> habits =
        FirebaseFirestore.instance.collection('habits').snapshots();

    return StreamBuilder<DocumentSnapshot>(
        stream: users,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            List completedHabitKeys = [];
            List<Habit> completedHabitList = [];
            var userData = snapshot.data;
            completedHabitKeys = userData!['userHabits'].keys.toList();

            return StreamBuilder<QuerySnapshot>(
              stream: habits,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot2) {
                if (snapshot2.connectionState == ConnectionState.active) {
                  var habitData = snapshot2.data;
                  for (var doc in habitData!.docs) {
                    if (completedHabitKeys.contains(doc.id) && userData['userHabits'][doc.id]['completed']) {
                      Map<String, dynamic> data =
                          doc.data()! as Map<String, dynamic>;
                      var newHabit = Habit(
                          id: doc.id,
                          title: data['title'],
                          info: data['info'],
                          hid: data['hid'],
                          totalAmount: data['amount'],
                          points: data['points'],
                          reps: userData['userHabits'][doc.id]['reps']);
                      completedHabitList.add(newHabit);
                    }
                  }
                  return _buildMyHabitsSection(context, completedHabitList);
                } else {
                  return _buildMyHabitsSection(context, []);
                }
              },
            );
          } else {
            return _buildMyHabitsSection(context, []);
          }
        });
  }
}
