import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'restaurants_screen.dart'; 
import 'checkout_screen.dart';  

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
                    SizedBox(height: 20),
                    Text(
                      'Ваша корзина пуста',
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Самое время выбрать что-нибудь вкусное!',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: Icon(Icons.restaurant_menu_outlined),
                      label: Text('К ресторанам'),
                      onPressed: () {
                        Provider.of<CartService>(context, listen: false).requestNavigationToTab(0);
                      },
                    )
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      final dish = cartItem.dish;
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  dish.imageUrl,
                                  width: 80, 
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.fastfood, color: Colors.grey[400], size: 30)
                                    ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(dish.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text(
                                      '${dish.price.toStringAsFixed(0)} ₸',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline, color: theme.primaryColor.withOpacity(0.8), size: 26),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    onPressed: () {
                                      cart.removeSingleItem(dish.id);
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 26),
                                     padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    onPressed: () {
                                      cart.addItem(dish);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Сумма заказа:', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)), 
                          Text(
                            '${cart.totalPrice.toStringAsFixed(0)} ₸',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Доставка и сервисный сбор будут рассчитаны на следующем шаге.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text('Перейти к оформлению'),
                          onPressed: cart.items.isEmpty ? null : () { 
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CheckoutScreen(),
                            ));
                          },
                        ),
                      ),
                       SizedBox(height: 8),
                       if (cart.items.isNotEmpty) 
                         TextButton(
                              onPressed: (){
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Очистить корзину?'),
                                    content: Text('Вы уверены, что хотите удалить все товары из корзины?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Отмена', style: TextStyle(color: Colors.grey[700])),
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Очистить', style: TextStyle(color: theme.colorScheme.error)),
                                        onPressed: () {
                                          cart.clearCart();
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Очистить корзину', style: TextStyle(color: theme.colorScheme.error, fontSize: 14))
                          )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}