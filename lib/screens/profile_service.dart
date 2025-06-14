import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_service.dart'; 

class ProfileService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String collectionName) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не аутентифицирован для доступа к $collectionName');
    }
    return _firestore.collection('users').doc(user.uid).collection(collectionName);
  }


  Future<List<UserAddress>> getAddresses() async {
    final snapshot = await _getCollection('addresses').get();
    return snapshot.docs.map((doc) => UserAddress.fromFirestore(doc)).toList();
  }

  Future<void> addAddress(UserAddress address) async {
    final addresses = await getAddresses();
    if (addresses.isEmpty) {
      address.isDefault = true;
    } else if (address.isDefault) {
      await _clearDefaultFlag('addresses');
    }
    await _getCollection('addresses').doc(address.id).set(address.toFirestore());
    notifyListeners();
  }
  
  Future<void> updateAddress(UserAddress address) async {
    if (address.isDefault) {
       await _clearDefaultFlag('addresses');
    }
    await _getCollection('addresses').doc(address.id).update(address.toFirestore());
    notifyListeners();
  }

  Future<void> deleteAddress(String addressId) async {
    await _getCollection('addresses').doc(addressId).delete();
    final remaining = await getAddresses();
    if (remaining.isNotEmpty && !remaining.any((addr) => addr.isDefault)) {
      remaining.first.isDefault = true;
      await updateAddress(remaining.first);
    }
    notifyListeners();
  }


  Future<List<PaymentCard>> getPaymentMethods() async {
    final snapshot = await _getCollection('payment_methods').orderBy('isDefault', descending: true).get();
    return snapshot.docs.map((doc) => PaymentCard.fromFirestore(doc)).toList();
  }

  Future<void> addPaymentMethod(PaymentCard card) async {
    final cards = await getPaymentMethods();
    if (cards.isEmpty) {
      card.isDefault = true;
    } else if (card.isDefault) {
      await _clearDefaultFlag('payment_methods');
    }
    await _getCollection('payment_methods').doc(card.id).set(card.toFirestore());
    notifyListeners();
  }

  Future<void> deletePaymentMethod(String cardId) async {
    await _getCollection('payment_methods').doc(cardId).delete();
     final remaining = await getPaymentMethods();
    if (remaining.isNotEmpty && !remaining.any((c) => c.isDefault)) {
      final firstCard = remaining.first;
      firstCard.isDefault = true;
      await _getCollection('payment_methods').doc(firstCard.id).update(firstCard.toFirestore());
    }
    notifyListeners();
  }
  
  Future<void> setDefaultPaymentMethod(String cardId) async {
    await _clearDefaultFlag('payment_methods');
    await _getCollection('payment_methods').doc(cardId).update({'isDefault': true});
    notifyListeners();
  }
  
  Future<void> _clearDefaultFlag(String collectionName) async {
    final batch = _firestore.batch();
    final querySnapshot = await _getCollection(collectionName)
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}