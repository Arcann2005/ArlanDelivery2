import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'profile_service.dart';
import 'order_service.dart';


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


class PaymentMethodsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Способы оплаты'),
      ),
      body: Consumer<ProfileService>(
        builder: (context, profileService, child) {
          return FutureBuilder<List<PaymentCard>>(
            future: profileService.getPaymentMethods(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_off_outlined, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('Нет сохраненных карт', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Text('Нажмите "+", чтобы добавить новую карту.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              final cards = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: cards.length,
                itemBuilder: (ctx, i) => _buildPaymentCard(context, cards[i], profileService),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddCardDialog(context),
      ),
    );
  }

 
  Widget _buildPaymentCard(BuildContext context, PaymentCard card, ProfileService service) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12);

    return Dismissible(
      key: ValueKey(card.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: borderRadius,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.only(bottom: 16),
        child: Icon(Icons.delete_sweep, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Подтверждение'),
            content: Text('Вы уверены, что хотите удалить эту карту?'),
            actions: <Widget>[
              TextButton(child: Text('Нет'), onPressed: () => Navigator.of(ctx).pop(false)),
              TextButton(child: Text('Да, удалить'), onPressed: () => Navigator.of(ctx).pop(true)),
            ],
          ),
        );
      },
      onDismissed: (_) {
        service.deletePaymentMethod(card.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Карта **** ${card.last4} удалена'),
          behavior: SnackBarBehavior.floating,
        ));
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: card.isDefault ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: card.isDefault 
            ? BorderSide(color: theme.primaryColor, width: 1.5)
            : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: card.isDefault ? null : () {
            service.setDefaultPaymentMethod(card.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _getCardIcon(card.cardType),
                    SizedBox(width: 16),
                    Text('**** **** **** ${card.last4}', style: TextStyle(fontSize: 18, fontFamily: 'monospace', letterSpacing: 1.5)),
                    Spacer(),
                    if(card.isDefault) Chip(
                      label: Text('Основная'), 
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                      padding: EdgeInsets.symmetric(horizontal: 6), 
                      visualDensity: VisualDensity.compact
                    )
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(card.cardHolderName.toUpperCase(), style: TextStyle(color: Colors.grey[700], letterSpacing: 0.5)),
                    Text(card.expiryDate, style: TextStyle(color: Colors.grey[700])),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _getCardIcon(String cardType) {
    if (cardType == 'visa') {
      return Icon(Icons.credit_card, color: Colors.blue.shade900, size: 32);
    } else if (cardType == 'mastercard') {
      return Icon(Icons.credit_card, color: Colors.orange.shade800, size: 32);
    }
    return Icon(Icons.credit_card, color: Colors.grey, size: 32);
  }

  void _showAddCardDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Text('Добавить новую карту', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: CardInputDialog(amount: 0),
        ),
      ),
    );

    if (result != null && result['success'] == true) {
      final cardDetails = result['cardDetails'] as Map<String, String>;
      final number = cardDetails['cardNumber']!;

      final newCard = PaymentCard(
        cardHolderName: cardDetails['cardHolderName']!,
        last4: number.substring(number.length - 4),
        expiryDate: cardDetails['expiryDate']!,
        cardType: number.startsWith('4') ? 'visa' : (number.startsWith('5') ? 'mastercard' : 'unknown'),
      );

      final service = Provider.of<ProfileService>(context, listen: false);
      try {
        await service.addPaymentMethod(newCard);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Карта успешно добавлена'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка при добавлении карты: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

class CardInputDialog extends StatefulWidget {
  final double amount;
  const CardInputDialog({Key? key, required this.amount}) : super(key: key);

  @override
  _CardInputDialogState createState() => _CardInputDialogState();
}

class _CardInputDialogState extends State<CardInputDialog> {
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
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