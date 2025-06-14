import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'restaurants_screen.dart';

enum PaymentMethod { cardOnline, cashOnDelivery }


class UserAddress {
  final String id;
  String name;
  String city;
  String street;
  String house;
  String apartment;
  bool isDefault;

  UserAddress({
    String? id,
    required this.name,
    required this.city,
    required this.street,
    required this.house,
    required this.apartment,
    this.isDefault = false,
  }) : this.id = id ?? Uuid().v4();

  String get fullAddress => '$city, $street, д. $house, кв. $apartment';

  factory UserAddress.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserAddress(
      id: doc.id,
      name: data['name'] ?? 'Дом',
      city: data['city'] ?? '',
      street: data['street'] ?? '',
      house: data['house'] ?? '',
      apartment: data['apartment'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'city': city,
      'street': street,
      'house': house,
      'apartment': apartment,
      'isDefault': isDefault,
    };
  }
}

class PaymentCard {
  final String id;
  final String cardHolderName;
  final String last4;
  final String expiryDate; 
  final String cardType; 
  bool isDefault;

  PaymentCard({
    String? id,
    required this.cardHolderName,
    required this.last4,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  }) : this.id = id ?? Uuid().v4();

  factory PaymentCard.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PaymentCard(
      id: doc.id,
      cardHolderName: data['cardHolderName'] ?? '',
      last4: data['last4'] ?? '0000',
      expiryDate: data['expiryDate'] ?? '00/00',
      cardType: data['cardType'] ?? 'unknown',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cardHolderName': cardHolderName,
      'last4': last4,
      'expiryDate': expiryDate,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }
}


class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalPrice;
  final String address;
  final String paymentMethod;
  final DateTime orderDate;
  String status;
  final String? appliedPromoCode;
  final double discountAmount;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.address,
    required this.paymentMethod,
    required this.orderDate,
    this.status = 'Новый',
    this.appliedPromoCode,
    this.discountAmount = 0.0,
  });
}

class OrderService with ChangeNotifier {
  final List<Order> _orders = [];
  final Uuid _uuid = Uuid();

  List<Order> get orders {
    var sortedOrders = List<Order>.from(_orders);
    sortedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return sortedOrders;
  }

  Future<void> addOrder({
    required List<CartItem> cartItems,
    required double totalPriceWithDeliveryAndDiscount,
    required String address,
    required PaymentMethod paymentType,
    String? appliedPromoCode,
    double discountAmount = 0.0,
  }) async {
    final List<OrderItem> orderItems = cartItems.map((cartItem) {
      return OrderItem(
        id: cartItem.dish.id,
        name: cartItem.dish.name,
        quantity: cartItem.quantity,
        price: cartItem.dish.price,
      );
    }).toList();

    final String paymentMethodString =
        paymentType == PaymentMethod.cardOnline ? 'Картой онлайн' : 'Наличными курьеру';

    final newOrder = Order(
      id: _uuid.v4(),
      items: orderItems,
      totalPrice: totalPriceWithDeliveryAndDiscount,
      address: address,
      paymentMethod: paymentMethodString,
      orderDate: DateTime.now(),
      status: 'В обработке',
      appliedPromoCode: appliedPromoCode,
      discountAmount: discountAmount,
    );

    _orders.insert(0, newOrder);
    notifyListeners();
  }
}