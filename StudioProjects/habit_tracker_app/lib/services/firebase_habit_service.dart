import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class FirebaseHabitService {
  final FirebaseFirestore? firestore;

  FirebaseHabitService({this.firestore});

  CollectionReference<Map<String, dynamic>> _habitsCollection(String userId) {
    final instance = firestore ?? FirebaseFirestore.instance;
    return instance.collection('users').doc(userId).collection('habits');
  }

  Stream<List<Habit>> watchHabits(String userId) {
    return _habitsCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> addHabit({
    required String userId,
    required Habit habit,
  }) async {
    await _habitsCollection(userId).doc(habit.id).set(habit.toMap());
  }

  Future<void> updateHabit({
    required String userId,
    required Habit habit,
  }) async {
    await _habitsCollection(userId).doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit({
    required String userId,
    required String id,
  }) async {
    await _habitsCollection(userId).doc(id).delete();
  }
}
