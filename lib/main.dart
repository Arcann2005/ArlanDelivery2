import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


import 'firebase_options.dart';
import 'screens/restaurants_screen.dart';
import 'screens/cart_screen.dart' as new_cart_screen;
import 'screens/order_service.dart';
import 'screens/profile_service.dart';
import 'screens/addresses_screen.dart';
import 'screens/payment_methods_screen.dart';

const MaterialColor DodoOrange = MaterialColor(
  0xFFFF6900, 
  <int, Color>{
    50: Color(0xFFFFF3EC), 
    100: Color(0xFFFFE0CC),
    200: Color(0xFFFFC099),
    300: Color(0xFFFFA166),
    400: Color(0xFFFF8940),
    500: Color(0xFFFF6900),
    600: Color(0xFFE65F00),
    700: Color(0xFFCC5400),
    800: Color(0xFFB34A00),
    900: Color(0xFF803400),
  },
);

const Color DodoBlack = Color(0xFF212121);
const Color DodoGrey = Color(0xFF757575);
const Color DodoLightGrey = Color(0xFFE0E0E0);
const Color DodoBackgroundGrey = Color(0xFFF5F5F5);

const String restaurantsScreenTitle = 'Рестораны';
const String cartScreenTitle = 'Корзина';
const String ordersScreenTitle = 'Мои заказы';
const String profileScreenTitleFoodApp = 'Профиль';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => OrderService()),
        ChangeNotifierProvider(create: (context) => ProfileService()),
      ],
      child: FoodDeliveryApp(),
    ),
  );
}

class FoodDeliveryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Доставка Еды',
      theme: ThemeData(
        primarySwatch: DodoOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DodoOrange, 
          primary: DodoOrange, 
          secondary: DodoOrange.shade50, 
          background: DodoBackgroundGrey, 
          surface: Colors.white, 
          error: Colors.red.shade700, 
          errorContainer: Colors.red.shade100, 
          onErrorContainer: Colors.red.shade900, 
          onPrimary: Colors.white, 
          onSecondary: DodoBlack, 
          onBackground: DodoBlack,
          onSurface: DodoBlack, 
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DodoOrange,
            foregroundColor: Colors.white, 
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), 
            ),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), 
            borderSide: BorderSide(color: DodoLightGrey), 
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: DodoLightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: DodoOrange, width: 2), 
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
          labelStyle: TextStyle(color: DodoGrey), 
          hintStyle: TextStyle(color: DodoGrey.withOpacity(0.6)), 
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, 
          foregroundColor: DodoBlack, 
          elevation: 0.0, 
          iconTheme: IconThemeData(color: DodoGrey),
          titleTextStyle: TextStyle(
              color: DodoBlack, fontSize: 20, fontWeight: FontWeight.bold),
          centerTitle: true, 
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white, 
          indicatorColor: DodoOrange.shade50, 
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DodoOrange); 
              }
              return TextStyle(fontSize: 12, color: DodoGrey); 
            },
          ),
          iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return IconThemeData(color: DodoOrange, size: 26); 
              }
              return IconThemeData(color: DodoGrey, size: 24); 
            },
          ),
          elevation: 1.0, 
        ),
        cardTheme: CardTheme(
          elevation: 1, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0) 
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: DodoBlack, fontWeight: FontWeight.bold, fontSize: 32),
          headlineMedium: TextStyle(color: DodoBlack, fontWeight: FontWeight.bold, fontSize: 28),
          headlineSmall: TextStyle(color: DodoBlack, fontWeight: FontWeight.bold, fontSize: 24),
          titleLarge: TextStyle(color: DodoBlack, fontWeight: FontWeight.w600, fontSize: 20),
          titleMedium: TextStyle(color: DodoBlack, fontWeight: FontWeight.w500, fontSize: 18),
          titleSmall: TextStyle(color: DodoBlack, fontWeight: FontWeight.w400, fontSize: 16),
          bodyLarge: TextStyle(color: DodoBlack.withOpacity(0.9), fontSize: 16),
          bodyMedium: TextStyle(color: DodoBlack.withOpacity(0.8), fontSize: 14),
          bodySmall: TextStyle(color: DodoGrey, fontSize: 12),
          labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), 
          labelMedium: TextStyle(color: DodoGrey, fontSize: 14), 
          labelSmall: TextStyle(color: DodoGrey.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        dividerColor: DodoLightGrey, 
        scaffoldBackgroundColor: DodoBackgroundGrey, 
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator(color: DodoOrange))); 
        } else if (snapshot.hasData) {
          return MainAppScreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
}

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);
    final orders = orderService.orders;
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 80, color: DodoLightGrey), 
            SizedBox(height: 16),
            Text('У вас пока нет заказов', style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22, color: DodoGrey)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Сделайте свой первый заказ, и он появится здесь.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, color: DodoGrey),
              ),
            ),
             SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                 Provider.of<CartService>(context, listen: false).requestNavigationToTab(0);
              },
              child: Text('Перейти к ресторанам')
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.0),
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        return Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            key: PageStorageKey(order.id),
            leading: CircleAvatar(
              backgroundColor: DodoOrange.withOpacity(0.1), 
              child: Icon(Icons.receipt_long, color: DodoOrange), 
            ),
            title: Text(
              'Заказ от ${DateFormat('dd.MM.yyyy HH:mm').format(order.orderDate)}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Статус: ${order.status}\nID: ${order.id.substring(0, 8)}...',
               style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text(
                  '${order.totalPrice.toStringAsFixed(0)} ₸',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: DodoOrange),
                ),
                SizedBox(height: 4),
                Icon(Icons.expand_more, color: DodoGrey.withOpacity(0.6))
              ],
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).copyWith(top:0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1, color: DodoLightGrey), 
                    SizedBox(height: 8),
                    _buildDetailRow(theme, "Полный ID заказа:", order.id),
                    _buildDetailRow(theme, "Адрес доставки:", order.address),
                    _buildDetailRow(theme, "Способ оплаты:", order.paymentMethod),
                    SizedBox(height: 10),
                    Text('Состав заказа:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 3.0, bottom: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('• ${item.name} (x${item.quantity})', style: theme.textTheme.bodyMedium)),
                          Text('${(item.price * item.quantity).toStringAsFixed(0)} ₸', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    )).toList(),
                    Divider(height: 20, color: DodoLightGrey), 
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Итоговая сумма:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('${order.totalPrice.toStringAsFixed(0)} ₸', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: DodoOrange)),
                        ],
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: DodoBlack.withOpacity(0.9))),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey))),
        ],
      ),
    );
  }
}


class MainAppScreen extends StatefulWidget {
  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _tabController;
  late CartService _cartService;

  final List<Widget> _screens = [
    RestaurantsScreen(),
    new_cart_screen.CartScreen(),
    OrdersScreen(),
    ProfileScreenFoodApp(),
  ];

  final List<String> _screenTitles = [
    restaurantsScreenTitle,
    cartScreenTitle,
    ordersScreenTitle,
    profileScreenTitleFoodApp,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
    _cartService = Provider.of<CartService>(context, listen: false);

    _tabController.addListener(() {
      if (_tabController.index != _selectedTabIndex && !_tabController.indexIsChanging) {
        if (mounted) {
          setState(() {
            _selectedTabIndex = _tabController.index;
          });
        }
      }
    });

    _cartService.navigateToTabNotifier.addListener(_handleTabNavigationRequest);
  }

  void _handleTabNavigationRequest() {
    final targetTab = _cartService.navigateToTabNotifier.value;
    if (targetTab != null && targetTab != _selectedTabIndex) {
      _onTabTapped(targetTab);
    }
  }

  void _onTabTapped(int index) {
    if (_selectedTabIndex != index) {
       if (mounted) {
         setState(() {
          _selectedTabIndex = index;
        });
       }
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartForBadge = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedTabIndex]),
        centerTitle: true,
        actions: [
          if (_selectedTabIndex != 3)
            IconButton(
              icon: Icon(Icons.notifications_none_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreenFoodApp()),
                );
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _screens,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: _onTabTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: restaurantsScreenTitle,
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${cartForBadge.totalQuantity}'),
              isLabelVisible: cartForBadge.totalQuantity > 0,
              child: Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text('${cartForBadge.totalQuantity}'),
              isLabelVisible: cartForBadge.totalQuantity > 0,
              child: Icon(Icons.shopping_cart),
            ),
            label: cartScreenTitle,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: ordersScreenTitle,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: profileScreenTitleFoodApp,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cartService.navigateToTabNotifier.removeListener(_handleTabNavigationRequest);
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _toggleMode() {
    if (mounted) {
      setState(() {
        _isRegistering = !_isRegistering;
        _errorMessage = null;
        _formKey.currentState?.reset();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();

    if (isValid) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      try {
        if (_isRegistering) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        }
      } on FirebaseAuthException catch (e) {
         if (mounted) {
           setState(() {
            _errorMessage = _getReadableErrorMessage(e.code);
          });
         }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Произошла непредвиденная ошибка. Пожалуйста, попробуйте снова.';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _getReadableErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Этот email уже используется другим аккаунтом.';
      case 'invalid-email':
        return 'Адрес email введен некорректно.';
      case 'operation-not-allowed':
         return 'Вход с использованием email и пароля не разрешен.';
      case 'weak-password':
        return 'Пароль слишком простой.';
      case 'user-disabled':
        return 'Учетная запись этого пользователя была отключена.';
      case 'user-not-found':
        return 'Пользователь с таким email не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'account-exists-with-different-credential':
        return 'Аккаунт уже существует с другим способом входа.';
      case 'invalid-credential':
        return 'Неверные учетные данные.';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте ваше интернет-соединение.';
      case 'too-many-requests':
        return 'Слишком много попыток. Пожалуйста, попробуйте позже.';
      default:
        return 'Произошла ошибка аутентификации. ($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.local_pizza_outlined, 
                      size: 80,
                      color: DodoOrange,
                    ),
                    SizedBox(height: 24),
                    Text(
                      _isRegistering ? 'Создайте аккаунт' : 'С возвращением!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: DodoBlack,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isRegistering
                          ? 'Начните заказывать любимые блюда уже сегодня.'
                          : 'Войдите, чтобы продолжить заказ.',
                      style: theme.textTheme.titleSmall?.copyWith( 
                            color: DodoGrey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    if (_errorMessage != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: DodoGrey), 
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Пожалуйста, введите ваш email';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$").hasMatch(value.trim())) {
                          return 'Введите корректный адрес email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock_outline, color: DodoGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: DodoGrey,
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен содержать минимум 6 символов';
                        }
                        return null;
                      },
                    ),
                    if (_isRegistering) ...[
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Подтвердите пароль',
                          prefixIcon: Icon(Icons.lock_person_outlined, color: DodoGrey), 
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: DodoGrey, 
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, подтвердите ваш пароль';
                          }
                          if (value != _passwordController.text) {
                            return 'Пароли не совпадают';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_isRegistering ? 'Зарегистрироваться' : 'Войти'),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _toggleMode,
                      child: Text(
                        _isRegistering
                            ? 'Уже есть аккаунт? Войти'
                            : 'Нет аккаунта? Создать',
                        style: TextStyle(fontSize: 15, color: DodoOrange), 
                      ),
                    ),
                    if (!_isRegistering) ...[
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading ? null : () {
                          _showResetPasswordDialog(context);
                        },
                        child: Text(
                          'Забыли пароль?',
                          style: TextStyle(fontSize: 14, color: DodoGrey), 
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final emailResetController = TextEditingController();
    final formKeyReset = GlobalKey<FormState>();
    bool _isSendingReset = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text('Сброс пароля', style: theme.textTheme.titleLarge?.copyWith(color: DodoBlack)),
            content: Form(
              key: formKeyReset,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Введите ваш email, и мы отправим вам инструкции.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: emailResetController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: DodoGrey),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Пожалуйста, введите ваш email';
                      }
                       if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$").hasMatch(value.trim())) {
                          return 'Введите корректный адрес email';
                        }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Отмена', style: TextStyle(color: DodoOrange)),
              ),
              ElevatedButton(
                onPressed: _isSendingReset
                    ? null
                    : () async {
                        if (formKeyReset.currentState?.validate() ?? false) {
                          if (mounted) {
                            setDialogState(() {
                              _isSendingReset = true;
                            });
                          }
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: emailResetController.text.trim(),
                            );
                            Navigator.pop(dialogContext);
                             if(mounted) {
                               ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Инструкции отправлены на ${emailResetController.text.trim()}'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                             }
                          } on FirebaseAuthException catch (e) {
                             if(mounted) {
                               ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(_getReadableErrorMessage(e.code)),
                                  backgroundColor: theme.colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                             }
                          } finally {
                            if (mounted) {
                               setDialogState(() {
                                _isSendingReset = false;
                              });
                            }
                          }
                        }
                      },
                child: _isSendingReset
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : Text('Отправить'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class ProfileScreenFoodApp extends StatefulWidget {
  @override
  _ProfileScreenFoodAppState createState() => _ProfileScreenFoodAppState();
}

class _ProfileScreenFoodAppState extends State<ProfileScreenFoodApp> {
  User? _currentUser;
  bool _isLoadingLogout = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserName();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          _loadUserName();
        });
      }
    });
  }

  Future<void> _loadUserName() async {
    final user = _currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _userName = prefs.getString('user_name_${user.uid}') ?? user.displayName;
        });
      }
    } else {
       if (mounted) {
        setState(() {
          _userName = null;
        });
      }
    }
  }

  void _onProfileEdited() {
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _currentUser;
    final cartService = Provider.of<CartService>(context, listen: false);

    if (user == null) {
      return Center(child: Text("Пользователь не аутентифицирован."));
    }

    String displayInitial = 'П';
    if (_userName?.isNotEmpty == true) {
      displayInitial = _userName![0];
    } else if (user.email?.isNotEmpty == true) {
      displayInitial = user.email![0];
    }

    String displayName = _userName ?? user.email ?? 'Пользователь';


    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await user.reload();
          _currentUser = FirebaseAuth.instance.currentUser;
          await _loadUserName();
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0, 
              color: Colors.white, 
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: DodoOrange.shade50, 
                      child: Text(
                        displayInitial.toUpperCase(),
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: DodoOrange), 
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: DodoBlack),
                      textAlign: TextAlign.center,
                    ),
                    if (user.email != null && displayName != user.email)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          user.email!,
                          style: theme.textTheme.titleSmall?.copyWith(color: DodoGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSectionTitle("Аккаунт"),
            Card(
              elevation: 0, 
              color: Colors.white, 
              child: Column(
                children: [
                  _buildProfileListTile(
                    icon: Icons.person_outline,
                    title: 'Редактировать профиль',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreenFoodApp()),
                      );
                      if (result == true || result == null) {
                         _onProfileEdited();
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildProfileListTile(
                    icon: Icons.lock_outline,
                    title: 'Изменить пароль',
                    onTap: () {
                      _showChangePasswordDialog(context, user);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildSectionTitle("Заказы и Оплата"),
             Card(
              elevation: 0, 
              color: Colors.white, 
              child: Column(
                children: [
                   _buildProfileListTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'История заказов',
                    onTap: () {
                      cartService.requestNavigationToTab(2);
                    },
                  ),
                  _buildDivider(),
                  _buildProfileListTile(
                    icon: Icons.location_on_outlined,
                    title: 'Мои адреса доставки',
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => AddressesScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildProfileListTile(
                    icon: Icons.credit_card_outlined,
                    title: 'Способы оплаты',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentMethodsScreen()));
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
             _buildSectionTitle("Настройки"),
             Card(
              elevation: 0, 
              color: Colors.white, 
              child: Column(
                children: [
                   _buildProfileListTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Настройки уведомлений',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationScreenFoodApp()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade900, 
                padding: EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isLoadingLogout
                  ? null
                  : () async {
                      if (mounted) {
                        setState(() {
                          _isLoadingLogout = true;
                        });
                      }
                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (e) {
                         if(mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка при выходе из аккаунта: $e'),
                              backgroundColor: theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                         }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoadingLogout = false;
                          });
                        }
                      }
                    },
              icon: _isLoadingLogout
                  ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade900)))
                  : Icon(Icons.logout, size: 20),
              label: Text('Выйти из аккаунта', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: DodoGrey, 
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildProfileListTile({required IconData icon, required String title, VoidCallback? onTap, Widget? trailing}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: DodoOrange, size: 24), 
      title: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: DodoBlack)), 
      trailing: trailing ?? Icon(Icons.chevron_right, color: DodoLightGrey), 
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildDivider() => Divider(height: 1, indent: 16, endIndent: 16, color: DodoLightGrey); 


  void _showChangePasswordDialog(BuildContext context, User user) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKeyPassword = GlobalKey<FormState>();
    bool _isChangingPassword = false;
    bool _obscureCurrent = true;
    bool _obscureNew = true;
    bool _obscureConfirm = true;


    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text('Изменить пароль', style: theme.textTheme.titleLarge?.copyWith(color: DodoBlack)),
            contentPadding: EdgeInsets.fromLTRB(20,20,20,0),
            content: SingleChildScrollView(
              child: Form(
                key: formKeyPassword,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: _obscureCurrent,
                      decoration: InputDecoration(
                          labelText: 'Текущий пароль',
                          prefixIcon: Icon(Icons.lock_outline, color: DodoGrey),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: DodoGrey),
                            onPressed: () => setDialogState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Введите текущий пароль' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                          labelText: 'Новый пароль',
                          prefixIcon: Icon(Icons.lock_person_outlined, color: DodoGrey),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: DodoGrey),
                            onPressed: () => setDialogState(() => _obscureNew = !_obscureNew),
                          ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Введите новый пароль';
                        if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                          labelText: 'Подтвердите новый пароль',
                          prefixIcon: Icon(Icons.lock_person_outlined, color: DodoGrey),
                           suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: DodoGrey),
                            onPressed: () => setDialogState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                      ),
                      validator: (value) => (value != newPasswordController.text) ? 'Пароли не совпадают' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Отмена', style: TextStyle(color: DodoOrange))),
              ElevatedButton(
                onPressed: _isChangingPassword ? null : () async {
                  if (formKeyPassword.currentState?.validate() ?? false) {
                    if (mounted) setDialogState(() => _isChangingPassword = true);
                    try {
                      final credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: currentPasswordController.text.trim(),
                      );
                      await user.reauthenticateWithCredential(credential);
                      await user.updatePassword(newPasswordController.text.trim());
                      Navigator.pop(dialogContext);
                      if(mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Пароль успешно изменен'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                      }
                    } on FirebaseAuthException catch (e) {
                      if(mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(_getReadableErrorMessageForProfile(e.code)), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating));
                      }
                    } catch (e) {
                      if(mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Произошла непредвиденная ошибка.'), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating));
                      }
                    } finally {
                      if (mounted) setDialogState(() => _isChangingPassword = false);
                    }
                  }
                },
                child: _isChangingPassword ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getReadableErrorMessageForProfile(String code) {
    switch (code) {
      case 'wrong-password': return 'Неверный текущий пароль.';
      case 'weak-password': return 'Новый пароль слишком простой.';
      case 'requires-recent-login': return 'Эта операция требует недавней аутентификации. Пожалуйста, выйдите и войдите снова.';
      case 'user-disabled': return 'Учетная запись пользователя отключена.';
      case 'user-not-found': return 'Пользователь не найден (ошибка).';
      case 'network-request-failed': return 'Ошибка сети. Проверьте соединение.';
      case 'too-many-requests': return 'Слишком много запросов. Попробуйте позже.';
      default: return 'Произошла ошибка ($code)';
    }
  }
}

class EditProfileScreenFoodApp extends StatefulWidget {
  @override
  _EditProfileScreenFoodAppState createState() => _EditProfileScreenFoodAppState();
}

class _EditProfileScreenFoodAppState extends State<EditProfileScreenFoodApp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  User? _currentUser;
  String? _initialEmail;
  String? _initialName;


  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _currentUser;
    if (user != null) {
      _initialEmail = user.email ?? '';
      _emailController.text = _initialEmail!;
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
         _initialName = prefs.getString('user_name_${user.uid}') ?? user.displayName ?? '';
        _nameController.text = _initialName!;
      }
    }
  }

  Future<void> _saveUserNameToPrefs(String name, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name_$userId', name);
  }

  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();
    FocusScope.of(context).unfocus();

    if (mounted) setState(() => _isLoading = true);

    try {
      final user = _currentUser;
      if (user == null) throw Exception("Пользователь не аутентифицирован");

      String newEmail = _emailController.text.trim();
      String newName = _nameController.text.trim();
      bool emailChanged = newEmail != _initialEmail;
      bool nameChanged = newName != _initialName;
      bool changesMade = false;


      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(newEmail);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Письмо для подтверждения нового email ($newEmail) отправлено. Пожалуйста, проверьте почту и войдите снова после подтверждения, если email изменится.'),
              backgroundColor: Colors.blueAccent,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 7),
            ),
          );
         }
        changesMade = true;
      }

      if (nameChanged) {
        await user.updateDisplayName(newName);
        await _saveUserNameToPrefs(newName, user.uid);
        changesMade = true;
      }

      if (!changesMade) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Нет изменений для сохранения.'), behavior: SnackBarBehavior.floating));
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Профиль успешно обновлен!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
            Navigator.pop(context, true);
         }
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_getReadableErrorMessageForEditProfile(e.code)), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating));
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Произошла непредвиденная ошибка: $e'), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getReadableErrorMessageForEditProfile(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Этот email уже используется другим аккаунтом.';
      case 'invalid-email': return 'Неверный формат email.';
      case 'requires-recent-login': return 'Эта операция требует недавней аутентификации. Пожалуйста, выйдите и войдите снова.';
      case 'user-disabled': return 'Учетная запись пользователя отключена.';
      case 'user-not-found': return 'Пользователь не найден.';
      case 'network-request-failed': return 'Ошибка сети.';
      case 'too-many-requests': return 'Слишком много запросов.';
      default: return 'Произошла ошибка ($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Редактировать профиль')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Ваше имя',
                    prefixIcon: Icon(Icons.person_outline, color: DodoGrey),
                    hintText: 'Как к вам обращаться?'
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Пожалуйста, введите ваше имя' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: DodoGrey),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Пожалуйста, введите ваш email';
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$").hasMatch(value.trim())) return 'Введите корректный адрес email';
                    return null;
                  },
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Text('Сохранить изменения'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class NotificationScreenFoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Уведомления')),
      body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildNotificationCard(
              context,
              icon: Icons.restaurant_menu,
              iconColor: DodoOrange,
              title: 'Ваш заказ №10532 принят!',
              message: 'Ресторан "Вкусная точка" начал готовить ваш заказ.',
              time: 'Сегодня, 18:32',
            ),
            _buildNotificationCard(
              context,
              icon: Icons.delivery_dining,
              iconColor: DodoOrange, 
              title: 'Курьер в пути!',
              message: 'Курьер забрал ваш заказ №10532 и скоро будет у вас.',
              time: 'Сегодня, 18:55',
            ),
             _buildNotificationCard(
              context,
              icon: Icons.local_offer,
              iconColor: DodoOrange, 
              title: 'Новая акция от "Суши Wok"',
              message: 'Скидка 20% на все роллы по промокоду EDA20.',
              time: 'Вчера, 12:10',
            ),
            _buildNotificationCard(
              context,
              icon: Icons.star_border_outlined,
              iconColor: DodoOrange, 
              title: 'Оцените ваш заказ',
              message: 'Пожалуйста, оцените качество блюд и доставки заказа №10521.',
              time: '2 дня назад, 20:15',
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Больше уведомлений нет',
                style: TextStyle(color: DodoGrey),
              ),
            )
          ],
        ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, {
      required IconData icon,
      required Color iconColor,
      required String title,
      required String message,
      required String time,
      }) {
    final theme = Theme.of(context);
    return Card(
        elevation: 0, 
        color: Colors.white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 6.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, color: iconColor, size: 24),
                radius: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith( 
                        fontWeight: FontWeight.bold,
                        color: DodoBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                         color: DodoGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DodoGrey.withOpacity(0.7) 
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}