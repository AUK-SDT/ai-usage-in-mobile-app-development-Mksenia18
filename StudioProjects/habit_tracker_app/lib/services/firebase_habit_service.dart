import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class FirebaseHabitService {
  final FirebaseFirestore? firestore;

  FirebaseHabitService({this.firestore});

  Future<List<Habit>> fetchHabits() async {
    final instance = firestore ?? FirebaseFirestore.instance;
    final snapshot = await instance.collection('habits').get();
    return snapshot.docs
        .map((doc) => Habit.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addHabit(Habit habit) async {
    final instance = firestore ?? FirebaseFirestore.instance;
    await instance.collection('habits').doc(habit.id).set(habit.toMap());
  }

  Future<void> updateHabit(Habit habit) async {
    final instance = firestore ?? FirebaseFirestore.instance;
    await instance.collection('habits').doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String id) async {
    final instance = firestore ?? FirebaseFirestore.instance;
    await instance.collection('habits').doc(id).delete();
  }
}
