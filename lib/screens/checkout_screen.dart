import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; 

import 'restaurants_screen.dart'; 
import 'order_service.dart'; 
import 'profile_service.dart';
import 'cart_screen.dart';
import 'addresses_screen.dart'; 

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    var buffer = StringBuffer();
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }

    var newText = buffer.toString();
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _NewCardOption {} 

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _promoCodeController = TextEditingController();
  bool _isLoading = true;

  Object? _selectedPaymentOption;
  List<PaymentCard> _savedCards = [];
  final _newCardOptionSingleton = _NewCardOption(); 

  List<UserAddress> _savedAddresses = [];
  UserAddress? _selectedAddress; 

  static const double deliveryFee = 350.0;
  final Map<String, double> _validPromoCodes = {
    'SALE5': 0.05, 'PROMO10': 0.10, 'SAVE15': 0.15, 'BEST20': 0.20,
  };
  String? _appliedPromoCode;
  double _discountAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData(); 
  }

  Future<void> _loadInitialData() async {
    final profileService = Provider.of<ProfileService>(context, listen: false);
    try {
      final cards = await profileService.getPaymentMethods();
      final addresses = await profileService.getAddresses();

      if (mounted) {
        setState(() {
          _savedCards = cards;
          _savedAddresses = addresses; 
          Object? defaultPaymentOption;
          final defaultCards = cards.where((c) => c.isDefault).toList();
          if (defaultCards.isNotEmpty) {
            defaultPaymentOption = defaultCards.first;
          } else if (cards.isNotEmpty) {
            defaultPaymentOption = cards.first;
          } else {
            defaultPaymentOption = _newCardOptionSingleton; 
          }
          _selectedPaymentOption = defaultPaymentOption;

          final defaultAddress = addresses.firstWhereOrNull((a) => a.isDefault);
          if (defaultAddress != null) {
            _selectedAddress = defaultAddress;
            _addressController.text = defaultAddress.fullAddress;
          } else if (addresses.isNotEmpty) {
            _selectedAddress = addresses.first; 
            _addressController.text = addresses.first.fullAddress;
          } else {
            _selectedAddress = null; 
            _addressController.clear();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка загрузки данных: $e"), backgroundColor: Colors.red,));
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  void _applyPromoCode() {
    final code = _promoCodeController.text.trim().toUpperCase();
    FocusScope.of(context).unfocus();
    if (_appliedPromoCode != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Промокод уже применен.'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating,));
      return;
    }
    if (_validPromoCodes.containsKey(code)) {
      final cart = Provider.of<CartService>(context, listen: false);
      final discountPercentage = _validPromoCodes[code]!;
      final calculatedDiscount = cart.totalPrice * discountPercentage;
      setState(() {
        _appliedPromoCode = code;
        _discountAmount = calculatedDiscount;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Промокод "$code" применен! Скидка: ${_discountAmount.toStringAsFixed(0)} ₸'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверный промокод или срок действия истек.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,));
    }
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _discountAmount = 0.0;
      _promoCodeController.clear();
    });
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Промокод удален.'), backgroundColor: Colors.blueGrey, behavior: SnackBarBehavior.floating,));
  }

  Future<void> _placeOrder(CartService cart, OrderService orderService, ProfileService profileService) async {
    if (!(_formKey.currentState?.validate() ?? false) || _selectedPaymentOption == null || _selectedAddress == null) {
        if (_selectedPaymentOption == null) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пожалуйста, выберите способ оплаты.'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating,));
        }
        if (_selectedAddress == null) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пожалуйста, выберите адрес доставки.'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating,));
        }
      return;
    }
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();

    if (mounted) setState(() { _isLoading = true; });

    String successMessageToDisplay = '';
    bool paymentProcessSuccessful = true;
    PaymentMethod finalPaymentMethodType = PaymentMethod.cashOnDelivery;

    final double cartTotalAfterDiscount = cart.totalPrice - _discountAmount;
    final double finalOrderTotal = cartTotalAfterDiscount + deliveryFee;

    if (_selectedPaymentOption is PaymentCard) {
      await Future.delayed(Duration(seconds: 1)); 
      final selectedCard = _selectedPaymentOption as PaymentCard;
      paymentProcessSuccessful = true;
      finalPaymentMethodType = PaymentMethod.cardOnline;
      successMessageToDisplay = 'Оплата картой **** ${selectedCard.last4} прошла успешно! Заказ оформлен.';

    } else if (_selectedPaymentOption is _NewCardOption) {
      final result = await _showEnterCardDetailsDialog(finalOrderTotal);

      if (result != null && result['success'] == true) {
        paymentProcessSuccessful = true;
        finalPaymentMethodType = PaymentMethod.cardOnline;
        successMessageToDisplay = 'Онлайн оплата прошла успешно! Заказ оформлен.';

        final cardDetails = result['cardDetails'] as Map<String, String>;
        final number = cardDetails['cardNumber']!;
        final newCard = PaymentCard(
          cardHolderName: cardDetails['cardHolderName']!,
          last4: number.substring(number.length - 4),
          expiryDate: cardDetails['expiryDate']!,
          cardType: number.startsWith('4') ? 'visa' : (number.startsWith('5') ? 'mastercard' : 'unknown'),
        );
        profileService.addPaymentMethod(newCard);

      } else {
        paymentProcessSuccessful = false;
      }
    } else if (_selectedPaymentOption == PaymentMethod.cashOnDelivery) {
        paymentProcessSuccessful = true;
        finalPaymentMethodType = PaymentMethod.cashOnDelivery;
        successMessageToDisplay = 'Заказ успешно оформлен! Оплата наличными курьеру.';
    }

    if (!paymentProcessSuccessful) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    try {
      final List<CartItem> orderItems = List.from(cart.items.values);
      await orderService.addOrder(
        cartItems: orderItems,
        totalPriceWithDeliveryAndDiscount: finalOrderTotal,
        address: _selectedAddress!.fullAddress, 
        paymentType: finalPaymentMethodType,
        appliedPromoCode: _appliedPromoCode,
        discountAmount: _discountAmount,
      );
      cart.clearCart();
      if (mounted) {
         setState(() {
           _isLoading = false; _appliedPromoCode = null; _discountAmount = 0.0; _promoCodeController.clear();
         });
        showDialog(
          context: context, barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: Text('Заказ оформлен!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(successMessageToDisplay + '\nВы будете перенаправлены на экран "Мои заказы".', textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Provider.of<CartService>(context, listen: false).requestNavigationToTab(2);
                },
              ),
            ],
          ),
        );
      }
    } catch (error) {
       if (mounted) {
         setState(() { _isLoading = false; });
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при оформлении заказа: $error'), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating,));
       }
    }
  }

  Future<Map<String, dynamic>?> _showEnterCardDetailsDialog(double amount) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Text('Данные для оплаты', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: SizedBox(width: double.maxFinite, child: _CardInputDialog(amount: amount)),
      ),
    );
  }

  Future<bool?> _showAddressDialog(BuildContext context, {UserAddress? address}) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AddressFormDialog(address: address), 
    );
  }

  Widget _buildPaymentSelection(ThemeData theme) {
    List<Widget> paymentWidgets = [];

    for (var card in _savedCards) {
      paymentWidgets.add(
        RadioListTile<Object>(
          title: Text('Карта **** ${card.last4}'),
          subtitle: Text(card.cardType.toUpperCase()),
          value: card,
          groupValue: _selectedPaymentOption,
          onChanged: (value) => setState(() => _selectedPaymentOption = value),
          secondary: _getCardIcon(card.cardType),
          activeColor: theme.primaryColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0), 
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      );
    }

    paymentWidgets.add(
      RadioListTile<Object>(
        title: const Text('Другой картой онлайн'),
        value: _newCardOptionSingleton,
        groupValue: _selectedPaymentOption,
        onChanged: (value) => setState(() => _selectedPaymentOption = value),
        secondary: Icon(Icons.add_card_outlined, color: theme.primaryColor),
        activeColor: theme.primaryColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0), 
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );

    paymentWidgets.add(
      RadioListTile<Object>(
        title: const Text('Наличными курьеру'),
        value: PaymentMethod.cashOnDelivery,
        groupValue: _selectedPaymentOption,
        onChanged: (value) => setState(() => _selectedPaymentOption = value),
        secondary: Icon(Icons.payments_outlined, color: theme.primaryColor),
        activeColor: theme.primaryColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0), 
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );

    return Column(children: paymentWidgets);
  }

  Widget _buildAddressSelection(ThemeData theme) {
    List<Widget> addressWidgets = [];

    if (_savedAddresses.isEmpty) {
        addressWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('У вас нет сохраненных адресов.', style: TextStyle(color: Colors.grey[600])),
          ),
        );
    } else {
        for (var address in _savedAddresses) {
          addressWidgets.add(
            RadioListTile<UserAddress>(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(address.isDefault ? Icons.home_work : Icons.location_on_outlined, color: theme.primaryColor),
                      ),
                      Text(address.name, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  Text(
                    address.fullAddress,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                  ),
                ],
              ),
              subtitle: null,
              value: address,
              groupValue: _selectedAddress,
              onChanged: (value) {
                setState(() {
                  _selectedAddress = value;
                  if (value != null) {
                    _addressController.text = value.fullAddress;
                  }
                });
              },
              activeColor: theme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0), 
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        }
    }

    addressWidgets.add(
      ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.add_location_alt_outlined, color: theme.primaryColor),
        ),
        title: Text('Добавить новый адрес', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () async {
          FocusScope.of(context).unfocus();
          final result = await _showAddressDialog(context);
          if (result == true) {
            await _loadInitialData();
          }
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0), 
      ),
    );

    return Column(children: addressWidgets);
  }

  Icon _getCardIcon(String cardType) {
    final Color color = (cardType == 'visa') ? Colors.blue.shade900 : (cardType == 'mastercard' ? Colors.orange.shade800 : Colors.grey);
    return Icon(Icons.credit_card, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final orderService = Provider.of<OrderService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final theme = Theme.of(context);

    final double subTotal = cart.totalPrice;
    final double totalAfterDiscount = subTotal - _discountAmount;
    final double orderTotalWithDeliveryAndDiscount = totalAfterDiscount + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: Text('Оформление заказа'), elevation: 1,),
      body: _isLoading
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text('Загружаем способы оплаты и адреса...', style: theme.textTheme.titleMedium)]))
          : cart.items.isEmpty && !_isLoading
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]), SizedBox(height: 16), Text('Заказ был успешно оформлен\nили корзина пуста.', textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, color: Colors.grey[600])), SizedBox(height: 20), ElevatedButton(onPressed: (){ Navigator.of(context).popUntil((route) => route.isFirst); Provider.of<CartService>(context, listen: false).requestNavigationToTab(0); }, child: Text('Вернуться к ресторанам'))]))
            : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Состав заказа:', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) {
                          final cartItem = cart.items.values.toList()[i];
                          return ListTile(
                             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                             leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cartItem.dish.imageUrl,
                                width: 60, height: 60, fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.fastfood_outlined, color: Colors.grey[400])),
                              ),
                            ),
                            title: Text(cartItem.dish.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                            subtitle: Text('x${cartItem.quantity} • ${cartItem.dish.price.toStringAsFixed(0)} ₸/шт.'),
                            trailing: Text('${(cartItem.dish.price * cartItem.quantity).toStringAsFixed(0)} ₸', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(height: 1, indent: 16, endIndent: 16),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text('Адрес доставки:', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: _buildAddressSelection(theme),
                    ),
                    SizedBox(height: 24), 

                    Text('Промокод (если есть):', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _promoCodeController,
                            decoration: InputDecoration(
                              hintText: 'Введите промокод',
                              prefixIcon: Icon(Icons.local_offer_outlined, color: theme.primaryColor),
                              border: _appliedPromoCode != null ? InputBorder.none : null,
                              filled: _appliedPromoCode != null,
                              fillColor: _appliedPromoCode != null ? Colors.grey[100] : null,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            enabled: _appliedPromoCode == null,
                          ),
                        ),
                        SizedBox(width: 10),
                        _appliedPromoCode == null
                          ? ElevatedButton(
                              onPressed: cart.items.isEmpty ? null : _applyPromoCode,
                              child: Text('Применить'),
                              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18.5)),
                            )
                          : TextButton.icon(
                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                              label: Text('Удалить', style: TextStyle(color: theme.colorScheme.error)),
                              onPressed: _removePromoCode,
                            )
                      ],
                    ),
                    if (_appliedPromoCode != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text('Применен: $_appliedPromoCode (Скидка: ${_discountAmount.toStringAsFixed(0)} ₸)', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                      ),
                    SizedBox(height: 24),
                    Text('Способ оплаты:', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: _buildPaymentSelection(theme),
                    ),
                    SizedBox(height: 16),
                    Divider(thickness: 0.8),
                     Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Сумма товаров:', style: theme.textTheme.titleMedium), Text('${subTotal.toStringAsFixed(0)} ₸', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500))],),
                    ),
                    if (_discountAmount > 0)
                       Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Скидка:', style: theme.textTheme.titleMedium?.copyWith(color: Colors.green.shade700)), Text('- ${_discountAmount.toStringAsFixed(0)} ₸', style: theme.textTheme.titleMedium?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w500))],),
                      ),
                     Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Доставка:', style: theme.textTheme.titleMedium), Text('${deliveryFee.toStringAsFixed(0)} ₸', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500))],),
                    ),
                    Divider(thickness: 1.2, height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Итого к оплате:', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), Text('${orderTotalWithDeliveryAndDiscount.toStringAsFixed(0)} ₸', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),)],),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: theme.elevatedButtonTheme.style?.copyWith(padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18))),
                        onPressed: cart.items.isEmpty || _isLoading ? null : () => _placeOrder(cart, orderService, profileService),
                        child: Text('Оформить заказ', style: TextStyle(fontSize: 17)),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CardInputDialog extends StatefulWidget {
  final double amount;
  const _CardInputDialog({Key? key, required this.amount}) : super(key: key);

  @override
  _CardInputDialogState createState() => _CardInputDialogState();
}

class _CardInputDialogState extends State<_CardInputDialog> {
  final _cardFormKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final FocusNode _cvvFocusNode = FocusNode();

  String _cardNumber = '';
  String _cardHolder = 'ИМЯ ФАМИЛИЯ';
  String _expiryDate = 'ММ/ГГ';
  String _cvv = '';
  bool _isCvvFocused = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() => setState(() => _cardNumber = _cardNumberController.text));
    _cardHolderController.addListener(() => setState(() => _cardHolder = _cardHolderController.text.toUpperCase()));
    _expiryDateController.addListener(() => setState(() => _expiryDate = _expiryDateController.text));
    _cvvController.addListener(() => setState(() => _cvv = _cvvController.text));
    _cvvFocusNode.addListener(() {
      setState(() {
        _isCvvFocused = _cvvFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cvvFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_cardFormKey.currentState?.validate() ?? false) {
      _cardFormKey.currentState!.save();
      Navigator.of(context).pop({
        'success': true,
        'cardDetails': {
          'cardNumber': _cardNumberController.text.replaceAll(RegExp(r'\s+'), ''),
          'expiryDate': _expiryDateController.text,
          'cardHolderName': _cardHolderController.text.trim().toUpperCase(),
        }
      });
    }
  }

  Widget _buildCardFront() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.contactless_rounded, color: Colors.white.withOpacity(0.8), size: 30),
              _buildCardLogo(),
            ],
          ),
          Spacer(),
          Text(
            _cardNumber.isEmpty ? 'XXXX  XXXX  XXXX  XXXX' : _cardNumber,
            style: TextStyle(fontFamily: 'monospace', fontSize: 20, color: Colors.white, letterSpacing: 2),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Владелец', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    Text(
                      _cardHolder.isEmpty ? 'ИМЯ ФАМИЛИЯ' : _cardHolder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Срок', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    Text(
                      _expiryDate.isEmpty ? 'ММ/ГГ' : _expiryDate,
                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.grey.shade700, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 25),
          Container(height: 40, color: Colors.black),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    height: 40,
                    color: Colors.white,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _cvv.isEmpty ? '' : '***',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.black, fontStyle: FontStyle.italic, letterSpacing: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text('CVV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardLogo() {
    String firstDigit = _cardNumber.isNotEmpty ? _cardNumber[0] : '';
    if (firstDigit == '4') {
      return Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
    } else if (firstDigit == '5') {
       return Text('MC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
    }
    return SizedBox(width: 50, height: 40);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotateAnim,
                child: child,
                builder: (context, child) {
                  final isUnder = (ValueKey(_isCvvFocused) != child?.key);
                  var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                  tilt = isUnder ? -tilt : tilt;
                  final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                  return Transform(
                    transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                    child: child,
                    alignment: Alignment.center,
                  );
                },
              );
            },
            child: AspectRatio(
              key: ValueKey(_isCvvFocused),
              aspectRatio: 1.586,
              child: _isCvvFocused ? _buildCardBack() : _buildCardFront(),
            ),
          ),
          SizedBox(height: 24),
          Form(
            key: _cardFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(labelText: 'Номер карты', prefixIcon: Icon(Icons.credit_card_outlined), counterText: ""),
                  keyboardType: TextInputType.number,
                  maxLength: 22,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    CardNumberInputFormatter(),
                  ],
                  validator: (v) => (v == null || v.replaceAll(RegExp(r'\s+'), '').length != 16) ? 'Введите 16 цифр карты' : null,
                  onChanged: (v) {
                    if (v.length == 22) FocusScope.of(context).nextFocus();
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _cardHolderController,
                  decoration: InputDecoration(labelText: 'Имя на карте (латиницей)', prefixIcon: Icon(Icons.person_pin_outlined)),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))],
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(labelText: 'ММ/ГГ', prefixIcon: Icon(Icons.calendar_today_outlined), counterText: ""),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          ExpiryDateInputFormatter(),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().length != 5) return 'ММ/ГГ';
                          final parts = v.split('/');
                          if (parts.length != 2) return 'Формат';
                          final month = int.tryParse(parts[0]);
                          final year = int.tryParse(parts[1]);
                          if (month == null || year == null || month < 1 || month > 12) return 'Месяц';
                          final currentYear = DateTime.now().year % 100;
                          final currentMonth = DateTime.now().month;
                          if (year < currentYear || (year == currentYear && month < currentMonth)) return 'Истек';
                          return null;
                        },
                        onChanged: (v) {
                          if (v.length == 5) FocusScope.of(context).requestFocus(_cvvFocusNode);
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        focusNode: _cvvFocusNode,
                        decoration: InputDecoration(labelText: 'CVV', prefixIcon: Icon(Icons.lock_outline), counterText: ""),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                        validator: (v) => (v == null || v.trim().length != 3) ? '3 цифры' : null,
                        onEditingComplete: _submitForm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          if (widget.amount > 0) ...[
            Text('Сумма к оплате: ${widget.amount.toStringAsFixed(0)} ₸', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8))),
            SizedBox(height: 20),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: _submitForm,
                child: Text(widget.amount > 0 ? 'Оплатить' : 'Сохранить карту'),
              ),
              SizedBox(height: 8),
              TextButton(
                child: Text('Отмена', style: TextStyle(color: theme.hintColor)),
                onPressed: () => Navigator.of(context).pop({'success': false}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}