
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

import '../main.dart'; 

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String cuisine;
  final double rating;
  final String deliveryTime;
  final String? promoText;
  final List<String> categories;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    this.promoText,
    this.categories = const [],
  });
}

class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dish && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CartItem {
  final Dish dish;
  int quantity;

  CartItem({required this.dish, this.quantity = 1});

  double get totalPrice => dish.price * quantity;
}


// --- СЕРВИС КОРЗИНЫ ---
class CartService with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  final ValueNotifier<int?> navigateToTabNotifier = ValueNotifier<int?>(null);

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(Dish dish) {
    if (_items.containsKey(dish.id)) {
      _items.update(
          dish.id, (existingItem) => CartItem(dish: dish, quantity: existingItem.quantity + 1));
    } else {
      _items.putIfAbsent(dish.id, () => CartItem(dish: dish, quantity: 1));
    }
    notifyListeners();
  }

  void removeSingleItem(String dishId) {
    if (!_items.containsKey(dishId)) {
      return;
    }
    if (_items[dishId]!.quantity > 1) {
      _items.update(
          dishId, (existingItem) => CartItem(dish: existingItem.dish, quantity: existingItem.quantity - 1));
    } else {
      _items.remove(dishId);
    }
    notifyListeners();
  }

  void removeItem(String dishId) {
    _items.remove(dishId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void requestNavigationToTab(int tabIndex) {
    navigateToTabNotifier.value = tabIndex;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (navigateToTabNotifier.value == tabIndex) { 
        navigateToTabNotifier.value = null;
      }
    });
  }
}



final List<Restaurant> mockRestaurants = [
    Restaurant(
    id: '5',
    name: 'Burger King',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDxYwshCz4XvXDZazVG4LAQL8lamAG6Y2p6g&s',
    cuisine: 'Фастфуд, Бургеры',
    rating: 4.7,
    deliveryTime: '20-30 мин',
    categories: ['Бургеры', 'Картофель фри', 'Напитки', 'Соусы'],
  ),
  Restaurant(
    id: '1',
    name: 'У Ерсайына',
    imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cmVzdGF1cmFudHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
    cuisine: 'Фастфуд, Бургеры',
    rating: 4.5,
    deliveryTime: '25-35 мин',
    categories: ['Бургеры', 'Картофель фри', 'Напитки', 'Десерты'],
  ),
  Restaurant(
    id: '2',
    name: 'Суши Мастер',
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cmVzdGF1cmFudHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
    cuisine: 'Японская, Суши, Роллы',
    rating: 4.8,
    deliveryTime: '30-45 мин',
    categories: ['Роллы', 'Суши', 'Супы', 'Горячее'],
  ),
  Restaurant(
    id: '3',
    name: 'Пицца Челентано',
    imageUrl: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8cmVzdGF1cmFudHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
    cuisine: 'Итальянская, Пицца',
    rating: 4.3,
    deliveryTime: '35-50 мин',
    categories: ['Пицца', 'Паста', 'Салаты', 'Напитки'],
  ),
  Restaurant(
    id: '4',
    name: 'Кофе Хауз',
    imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cmVzdGF1cmFudHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
    cuisine: 'Кофейня, Десерты, Завтраки',
    rating: 4.6,
    deliveryTime: '20-30 мин',
    promoText: 'Каждый 5-й кофе бесплатно',
    categories: ['Кофе', 'Чай', 'Выпечка', 'Завтраки', 'Сэндвичи'],
  ),
];


Map<String, List<Dish>> mockMenuData = {
  '1': [ 
    Dish(id: 'd101', name: 'Классический Бургер', description: 'Сочная говяжья котлета, свежие овощи, фирменный соус.', price: 1400, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YnVyZ2VyfGVufDB8fDB8fHww&auto=format&fit=crop&w=400&q=60', category: 'Бургеры'),
    Dish(id: 'd102', name: 'Двойной Чизбургер', description: 'Две котлеты, двойной сыр чеддер, маринованные огурчики.', price: 1850, imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Y2hlZXNlYnVyZ2VyfGVufDB8fDB8fHww&auto=format&fit=crop&w=400&q=60', category: 'Бургеры'),
    Dish(id: 'd103', name: 'Картофель Фри (L)', description: 'Хрустящий золотистый картофель, подается с соусом.', price: 750, imageUrl: 'https://cdn.foodpicasso.com/assets/2022/11/08/ceebd385af54eae454daf44defa24fcb---jpg_1000x_103c0_convert.jpg', category: 'Картофель фри'),
    Dish(id: 'd106', name: 'Картофель по-деревенски', description: 'Ароматные дольки картофеля со специями.', price: 850, imageUrl: 'https://img.iamcook.ru/2023/upl/recipes/cat/u-dbb93a7949002917d4d2894d4ec53d21.jpg', category: 'Картофель фри'),
    Dish(id: 'd104', name: 'Кока-Кола (0.5л)', description: 'Классический освежающий напиток.', price: 500, imageUrl: 'https://eda.yandex.ru/images/3529908/3c8fde5df4dd8ed1294ddf7f23454a1b-800x800.jpg', category: 'Напитки'),
    Dish(id: 'd107', name: 'Сок Апельсиновый (0.3л)', description: 'Натуральный апельсиновый сок.', price: 600, imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8b3JhbmdlJTIwanVpY2V8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Напитки'),
    Dish(id: 'd105', name: 'Шоколадный Маффин', description: 'Нежный маффин с кусочками шоколада.', price: 600, imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVmZmlufGVufDB8fDB8fHww&auto=format&fit=crop&w=400&q=60', category: 'Десерты'),
    Dish(id: 'd108', name: 'Чизкейк Нью-Йорк', description: 'Классический чизкейк на песочной основе.', price: 1250, imageUrl: 'https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c2hlZXNlY2FrZXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=60', category: 'Десерты'),
  ],
  '2': [ 
    Dish(id: 'd201', name: 'Ролл "Филадельфия"', description: 'Нежный лосось, сливочный сыр, огурец, рис, нори.', price: 2250, imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c3VzaGklMjByb2xsfGVufDB8fDB8fHww&auto=format&fit=crop&w=400&q=60', category: 'Роллы'),
    Dish(id: 'd202', name: 'Ролл "Калифорния"', description: 'Крабовое мясо, авокадо, огурец, икра тобико.', price: 1950, imageUrl: 'https://www.foodland.ru/upload/iblock/a82/a82c720dfe8ffb750dd545ee43b59e22.jpg', category: 'Роллы'),
    Dish(id: 'd203', name: 'Суши "Лосось" (2 шт.)', description: 'Классические суши с ломтиком свежего лосося.', price: 900, imageUrl: 'https://sushiwok.ru/img/41d73a69d00513d1822e93bc03ef7700', category: 'Суши'),
    Dish(id: 'd207', name: 'Суши "Угорь" (2 шт.)', description: 'Ароматный угорь на подушке из риса.', price: 1100, imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c3VzaGl8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Суши'),
    Dish(id: 'd204', name: 'Мисо суп с лососем', description: 'Японский суп с тофу, водорослями и лососем.', price: 1100, imageUrl: 'https://eda.ru/images/RecipePhoto/390x390/holodnyy-miso-sup-s-lososem-shiitake-i-bobami-edamame_186656_photo_194302.jpg', category: 'Супы'),
    Dish(id: 'd210', name: 'Том Ям с креветками', description: 'Острый тайский суп с креветками и кокосовым молоком.', price: 1900, imageUrl: 'https://seafood-shop.ru/upload/resize_cache/webp/iblock/af0/af0d5a2a044fe387ce7a6fd52978e338/362a21d060de00e813d1b6d012bcbc61.webp', category: 'Супы'),
    Dish(id: 'd205', name: 'Удон с курицей терияки', description: 'Лапша удон с курицей в соусе терияки и овощами.', price: 2400, imageUrl: 'https://images.unsplash.com/photo-1626804475297-41608ea09aeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dWRvbiUyMG5vb2RsZXN8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Горячее'),
    Dish(id: 'd211', name: 'Рис с морепродуктами', description: 'Обжаренный рис с креветками, кальмарами и мидиями.', price: 2600, imageUrl: 'https://rice.ua/wp-content/uploads/2018/04/ris_s_moreproduktami.jpg', category: 'Горячее'),
  ],
  '3': [ 
    Dish(id: 'd301', name: 'Пицца "Маргарита"', description: 'Томатный соус, моцарелла, базилик.', price: 2400, imageUrl: 'https://images.unsplash.com/photo-1594007654729-407eedc4be65?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cGl6emF8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Пицца'),
    Dish(id: 'd302', name: 'Пицца "Пепперони"', description: 'Пикантная пицца с пепперони и моцареллой.', price: 2900, imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8cGl6emF8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Пицца'),
    Dish(id: 'd304', name: 'Пицца "Четыре Сыра"', description: 'Моцарелла, дорблю, пармезан, чеддер.', price: 3100, imageUrl: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8cGl6emF8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Пицца'),
    Dish(id: 'd303', name: 'Паста "Карбонара"', description: 'Спагетти, бекон, сливочный соус, пармезан.', price: 2600, imageUrl: 'https://static.tildacdn.com/tild6164-6239-4561-a130-376437623033/_4.png', category: 'Паста'),
    Dish(id: 'd305', name: 'Паста "Болоньезе"', description: 'Феттуччине с мясным рагу болоньезе.', price: 2750, imageUrl: 'https://cdn1.ozonusercontent.com/s3/club-storage/images/article_image_1632x1000/685/f6d7c2eb-4616-4d99-bdf0-0d28b62f2dce.jpeg', category: 'Паста'),
    Dish(id: 'd306', name: 'Салат "Цезарь" с курицей', description: 'Романо, куриное филе, гренки, пармезан, соус "Цезарь".', price: 2100, imageUrl: 'https://svoya.ru/upload/resize_cache/webp/iblock/a53/a532975677abce40f37f49e6885c6722.webp', category: 'Салаты'),
    Dish(id: 'd307', name: 'Салат "Греческий"', description: 'Свежие овощи, фета, оливки, оливковое масло.', price: 1900, imageUrl: 'https://resizer.mail.ru/p/9ff6b103-e01c-5b8c-906b-45420327b7e3/AQAFzkAauAADlnYx7A41y0Vbroj57t3YCDI9n_pIkF2zZkD8OgzV8Alb0okGQqJYsczsK-h65by_6AaUKNCH-iG2zJs.jpg', category: 'Салаты'),
    Dish(id: 'd308', name: 'Лимонад Домашний', description: 'Освежающий лимонад собственного приготовления.', price: 750, imageUrl: 'https://eda.ru/images/RecipePhoto/4x3/bistrij-limonad_23884_photo_8362.jpg', category: 'Напитки'),
    Dish(id: 'd309', name: 'Морс Клюквенный', description: 'Натуральный клюквенный морс.', price: 650, imageUrl: 'https://img.freepik.com/premium-photo/glass-currant-mors-berry-compote-black_105609-545.jpg', category: 'Напитки'),
  ],
  '4': [ 
    Dish(id: 'd401', name: 'Эспрессо', description: 'Классический крепкий кофе.', price: 600, imageUrl: 'https://galaktika29.ru/upload/iblock/db6/k0ta8ki954k0l5qrh3rt4214nfa40rep.jpg', category: 'Кофе'),
    Dish(id: 'd402', name: 'Капучино', description: 'Эспрессо со взбитым молоком и молочной пеной.', price: 900, imageUrl: 'https://cdn.prod.website-files.com/5f92b98ef775e43402afe27f/632845fd4a30f55ce6011c1d_Polyakovfoto_Simple%20Coffee17803.jpg', category: 'Кофе'),
    Dish(id: 'd403', name: 'Латте', description: 'Эспрессо с большим количеством молока и немного пены.', price: 1000, imageUrl: 'https://agropererobka.com.ua/content/recipes/show/ice_late_tiramisu_1702561265.jpg', category: 'Кофе'),
    Dish(id: 'd404', name: 'Чай Черный (Ассам)', description: 'Классический черный чай.', price: 500, imageUrl: 'https://sakiproducts.com/cdn/shop/articles/Benefits-of-Drinking-Black-Tea-thumbnail_800x800.jpg?v=1660832924', category: 'Чай'),
    Dish(id: 'd405', name: 'Чай Зеленый (Сенча)', description: 'Японский зеленый чай.', price: 550, imageUrl: 'https://uraltea.com/upload/iblock/98d/41ajmwv8p31kit0px8io195k4xlat98c/china_greentea.jpg', category: 'Чай'),
    Dish(id: 'd406', name: 'Круассан с миндалем', description: 'Свежий круассан с миндальной начинкой.', price: 750, imageUrl: 'https://drazhin.by//assets/cache_image/products/82/dv5a4224_500x500_c43.jpg', category: 'Выпечка'),
    Dish(id: 'd407', name: 'Макарун (ассорти)', description: 'Набор из 3-х французских пирожных макарун.', price: 1100, imageUrl: 'https://cdn.food.ru/unsigned/fit/640/480/ce/0/czM6Ly9tZWRpYS9waWN0dXJlcy8yMDIyMDMwOS8zM2Z0RGYuanBlZw.jpg', category: 'Выпечка'),
    Dish(id: 'd408', name: 'Сырники со сметаной', description: 'Нежные творожные сырники, подаются со сметаной.', price: 1400, imageUrl: 'https://cdn.food.ru/unsigned/fit/640/480/ce/0/czM6Ly9tZWRpYS9waWN0dXJlcy8yMDIyMDMzMS83THY3c3cuanBlZw.jpg', category: 'Завтраки'),
    Dish(id: 'd409', name: 'Овсяная каша с ягодами', description: 'Полезная овсяная каша на молоке с сезонными ягодами.', price: 1200, imageUrl: 'https://polinka.online/upload/dev2fun.imagecompress/webp/iblock/aa9/u1yt2302z13fmnqyvnxrm0tznpwvieqa.webp', category: 'Завтраки'),
    Dish(id: 'd410', name: 'Сэндвич с ветчиной и сыром', description: 'Классический сэндвич на тостовом хлебе.', price: 1300, imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c2FuZHdpY2h8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Сэндвичи'),
    Dish(id: 'd411', name: 'Сэндвич с лососем и авокадо', description: 'Полезный сэндвич на цельнозерновом хлебе.', price: 1750, imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8c2FuZHdpY2h8ZW53MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=60', category: 'Сэндвичи'),
  ],
  '5': [
    Dish(id: 'd601', name: 'Воппер', description: 'Культовый бургер с говяжьей котлетой на огне, свежими овощами и соусом.', price: 2100, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSU6X3H2CNyYPjq9aTdpoCpXKWvH6Ej5U2ThA&s', category: 'Бургеры'),
    Dish(id: 'd602', name: 'Биг Кинг', description: 'Две говяжьи котлеты, сыр, специальный соус, салат и лук.', price: 2300, imageUrl: 'https://burgerkings.ru/image/cache/catalog/photo/93098606-big-king-600x600.jpg', category: 'Бургеры'),
    Dish(id: 'd603', name: 'Чикенбургер', description: 'Нежное куриное филе в хрустящей панировке с овощами и соусом.', price: 1500, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTYO_gzNUj6uWpQZRLLTQSb_tGBrLZaUV-Uew&s', category: 'Бургеры'),
    Dish(id: 'd604', name: 'Картофель Фри', description: 'Классический золотистый картофель фри.', price: 700, imageUrl: 'https://bonfit.ru/upload/iblock/278/2784383a9d35989dc5791f24283ec756.jpg', category: 'Картофель фри'),
    Dish(id: 'd605', name: 'Луковые Кольца', description: 'Хрустящие луковые кольца в панировке.', price: 850, imageUrl: 'https://eda.yandex.ru/images/3609085/e19a93a66b99dc33628e86cabf9db9a2-800x800.jpg', category: 'Картофель фри'),
    Dish(id: 'd606', name: 'Кока-Кола (0.5л)', description: 'Классический прохладительный напиток.', price: 500, imageUrl: 'https://thumbs.dreamstime.com/b/%D0%BB%D0%BE%D0%BD%D0%B4%D0%BE%D0%BD-%D0%B2%D0%B5%D0%BB%D0%B8%D0%BA%D0%BE%D0%B1%D1%80%D0%B8%D1%82%D0%B0%D0%BD%D0%B8%D1%8F-%D0%BE%D0%B5-%D0%B4%D0%B5%D0%BA%D0%B0%D0%B1%D1%80%D1%8F-%D0%B1%D1%83%D0%BC%D0%B0%D0%B6%D0%BD%D1%8B%D0%B9-%D1%81%D1%82%D0%B0%D0%BA%D0%B0%D0%BD%D1%87%D0%B8%D0%BA-%D0%BF%D0%B8%D1%82%D1%8C%D1%8F-%D0%BA%D0%BE%D0%BA%D0%B0-%D0%BA%D0%BE%D0%BB%D1%8B-105726337.jpg', category: 'Напитки'),
    Dish(id: 'd607', name: 'Молочный Коктейль', description: 'Густой молочный коктейль: клубника.', price: 1100, imageUrl: 'https://cdn-irec.r-99.com/sites/default/files/imagecache/300o/product-images/2651532/wCDvTahJYDh9Etpztyw.jpg', category: 'Напитки'),
    Dish(id: 'd608', name: 'Мороженое Сандэй', description: 'Ванильное мороженое с шоколадным топпингом.', price: 750, imageUrl: 'https://irecommend.ru/sites/default/files/product-images/2592897/pdMKzzT7QGktTDGz4cjQQ.jpeg', category: 'Десерты'),
    Dish(id: 'd609', name: 'Сырный соус', description: 'Вкусный сырный соус от Hainz', price: 150, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQr33ttgwoRAexWV1Y065jrApwvhPBQKzsEhA&s', category: 'Соусы'),

  ],
};


class RestaurantsScreen extends StatefulWidget {
  @override
  _RestaurantsScreenState createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  String _searchQuery = '';
  List<Restaurant> _filteredRestaurants = mockRestaurants;

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = mockRestaurants;
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredRestaurants = mockRestaurants;
      } else {
        _filteredRestaurants = mockRestaurants
            .where((restaurant) =>
                restaurant.name.toLowerCase().contains(_searchQuery) ||
                restaurant.cuisine.toLowerCase().contains(_searchQuery) ||
                restaurant.categories.any((cat) => cat.toLowerCase().contains(_searchQuery)))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: TextField(
            onChanged: _updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Поиск ресторанов или блюд...',
              prefixIcon: Icon(Icons.search, color: DodoGrey), 
            ),
          ),
        ),
        Expanded(
          child: _filteredRestaurants.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 70, color: DodoLightGrey), 
                        SizedBox(height: 20),
                        Text(
                          'Ничего не найдено',
                          style: theme.textTheme.titleMedium?.copyWith(color: DodoGrey, fontWeight: FontWeight.w500),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Попробуйте изменить поисковый запрос или проверьте фильтры.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                  itemCount: _filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = _filteredRestaurants[index];
                    return RestaurantCard(restaurant: restaurant);
                  },
                ),
        ),
      ],
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0, 
      color: Colors.white, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12), 
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuScreen(restaurant: restaurant),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)), 
                  child: Image.network(
                    restaurant.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: DodoLightGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, size: 40, color: DodoGrey), 
                            SizedBox(height: 8),
                            Text("Не удалось загрузить фото", style: TextStyle(color: DodoGrey))
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: DodoLightGrey, 
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(DodoOrange), 
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (restaurant.promoText != null && restaurant.promoText!.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: DodoOrange, 
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                        boxShadow: [
                           BoxShadow(
                            color: Colors.black.withOpacity(0.1), 
                            blurRadius: 4,
                            offset: Offset(1,2)
                           )
                        ]
                      ),
                      child: Text(
                        restaurant.promoText!,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DodoBlack.withOpacity(0.6), 
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: DodoOrange, size: 18), 
                        SizedBox(width: 5),
                        Text(
                          restaurant.rating.toString(),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: DodoBlack), 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu_outlined, size: 16, color: DodoGrey), 
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          restaurant.cuisine,
                          style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey), 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: DodoGrey), 
                      SizedBox(width: 6),
                      Text(
                        '~ ${restaurant.deliveryTime}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey), 
                      ),
                    ],
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

// --- ЭКРАН МЕНЮ РЕСТОРАНА ---
class MenuScreen extends StatelessWidget {
  final Restaurant restaurant;

  const MenuScreen({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Dish> menuItems = mockMenuData[restaurant.id] ?? [];
    final cart = Provider.of<CartService>(context);

    Map<String, List<Dish>> categorizedMenu = {};
    if (menuItems.isNotEmpty) {
      for (var categoryName in restaurant.categories) {
        categorizedMenu[categoryName] = [];
      }
      for (var dish in menuItems) {
        if (categorizedMenu.containsKey(dish.category)) {
           categorizedMenu[dish.category]!.add(dish);
        } else {
          (categorizedMenu[dish.category] ??= []).add(dish);
        }
      }
      categorizedMenu.removeWhere((key, value) => value.isEmpty && !restaurant.categories.contains(key));
    } else if (restaurant.categories.isNotEmpty) {
      for (var category in restaurant.categories) {
        categorizedMenu[category] = [];
      }
    }

    bool isEmptyMenu = categorizedMenu.values.every((list) => list.isEmpty) && restaurant.categories.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: [
            IconButton(
                icon: Icon(Icons.info_outline, color: DodoGrey), 
                onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Информация о ресторане "${restaurant.name}" (в разработке)'))
                     );
                },
            ),
        ],
      ),
      body: isEmptyMenu
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu_outlined, size: 70, color: DodoLightGrey),
                    SizedBox(height: 20),
                    Text(
                      'Меню пока пусто',
                      style: theme.textTheme.titleMedium?.copyWith(color: DodoGrey, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Скоро здесь появятся новые блюда!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
            slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: DodoOrange, size: 22), 
                            SizedBox(width: 6),
                            Text('${restaurant.rating}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: DodoBlack)),
                            SizedBox(width: 10),
                            Expanded(child: Text('(${restaurant.cuisine})', style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey))),
                          ],
                        ),
                        SizedBox(height: 8),
                         Row(
                           children: [
                             Icon(Icons.timer_outlined, size: 18, color: DodoGrey), 
                             SizedBox(width: 6),
                             Text('Доставка: ~ ${restaurant.deliveryTime}', style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey)),
                           ],
                         ),
                        if (restaurant.promoText != null && restaurant.promoText!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.local_offer_outlined, size: 18, color: DodoOrange), 
                                SizedBox(width: 6),
                                Expanded(child: Text(restaurant.promoText!, style: theme.textTheme.bodyMedium?.copyWith(color: DodoOrange, fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ),
                         Divider(height: 32, thickness: 0.8, color: DodoLightGrey), 
                      ],
                    ),
                  ),
                ),
                ...categorizedMenu.entries.map((entry) {
                  String categoryName = entry.key;
                  List<Dish> dishesInCategory = entry.value;

                  return SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            categoryName,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: DodoBlack),
                          ),
                        ),
                        if (dishesInCategory.isEmpty && restaurant.categories.contains(categoryName))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            child: Center(child: Text('В этой категории пока нет блюд.', style: theme.textTheme.bodyMedium?.copyWith(color: DodoGrey))),
                          )
                        else
                          ...dishesInCategory.map((dish) => DishCard(dish: dish)),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                }).toList(),
                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],),
       floatingActionButton: cart.totalQuantity > 0 && !isEmptyMenu
          ? FloatingActionButton.extended(
              onPressed: () {
                Provider.of<CartService>(context, listen: false).requestNavigationToTab(1); 
                Navigator.pop(context); 
              },
              backgroundColor: DodoOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
              label: Text('В корзину (${cart.totalQuantity}) - ${NumberFormat.simpleCurrency(locale: 'kk', name: '₸').format(cart.totalPrice)}',
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 15), 
              ),
              icon: Icon(Icons.shopping_cart_checkout_outlined, color: Colors.white), 
            )
          : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- ВИДЖЕТ КАРТОЧКИ БЛЮДА (DishCard) ---
class DishCard extends StatelessWidget {
  final Dish dish;

  const DishCard({Key? key, required this.dish}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartService>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0), 
      child: Card(
        elevation: 0, 
        color: Colors.white, 
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12), 
          onTap: () {
            cart.addItem(dish);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${dish.name}" добавлен в корзину'),
                backgroundColor: DodoOrange, 
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
                margin: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                action: SnackBarAction(
                  label: 'ОТМЕНА',
                  textColor: Colors.white,
                  onPressed: (){
                    cart.removeSingleItem(dish.id);
                  },
                ),
              )
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dish.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: DodoBlack)), 
                      SizedBox(height: 4),
                      Text(
                        dish.description,
                        style: theme.textTheme.bodySmall?.copyWith(color: DodoGrey, height: 1.3), 
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        NumberFormat.simpleCurrency(locale: 'kk', name: '₸').format(dish.price), 
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: DodoOrange), 
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), 
                      child: Image.network(
                        dish.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                            color: DodoLightGrey, 
                            child: Icon(Icons.fastfood_outlined, color: DodoGrey, size: 40) 
                        ),
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(DodoOrange), 
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}