import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50, // soft blue background
        useMaterial3: true,
      ),
      home: const ProductsScreen(),
    );
  }
}


class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  static final List<Product> products = [
    Product(
      id: 'p1',
      name: 'Laptop',
      price: 50000,
      imageUrl:
      'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRVqc0bsjplVKiudTPxQc_np4uW5mQ4ct9YLolfMlsLmfxmDCDB6CLstJZjZWVfysWx8sZx5dfOCQ6ccgs0Yx4Onk8izqTSJok9qCOiPWIz',
    ),
    Product(
      id: 'p2',
      name: 'Phone',
      price: 25000,
      imageUrl:
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR9Q0Bz8zcRgf5FCvRxrIDPIn4ub1sO-NGijw&s',
    ),
    Product(
      id: 'p3',
      name: 'Headphones',
      price: 3000,
      imageUrl:
      'https://ecommerce.datablitz.com.ph/cdn/shop/files/4548736142978_800x.jpg?v=1697354579',
    ),
    Product(
      id: 'p4',
      name: 'Keyboard',
      price: 1500,
      imageUrl:
      'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQ3ZEp9poKIe5yr-GxeZrpHCK7L1nf8Yee12E-yYW2OndNdMCgD',
    ),
    Product(
      id: 'p5',
      name: 'Mouse',
      price: 1200,
      imageUrl:
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBciH9_EEdLyBD348j988djcIDDki2nwMCMA&s',
    ),
    Product(
      id: 'p6',
      name: 'Monitor',
      price: 12000,
      imageUrl:
      'https://www.lg.com/content/dam/channel/wcms/ph/images/monitors/24mr400-b_aphq_eacm_ph_c/gallery/large03.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kent Jude Sacapano'),
        actions: [
          CartBadge(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          final product = products[i];
          return ProductCard(product: product);
        },
      ),
    );
  }
}


class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.items.containsKey(product.id);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text('₱${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CartProvider>().addItem(product);
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(inCart ? 'Add More' : 'Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear Cart',
            onPressed: cart.totalQuantity > 0
                ? () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear Cart?'),
                  content: const Text(
                      'Are you sure you want to clear the cart?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        cart.clearCart();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
                : null,
          ),
        ],
      ),
      body: cart.totalQuantity == 0
          ? const Center(child: Text('Your cart is empty.'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (_, i) {
                final item = cart.items.values.toList()[i];
                return CartItemTile(item: item);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total: ₱${cart.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.product.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 30),
          ),
        ),
        title: Text(item.product.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('₱${item.totalPrice.toStringAsFixed(2)}'),
        trailing: SizedBox(
          width: 110,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => cart.decrementQuantity(item.product.id),
              ),
              Text(item.quantity.toString(), style: const TextStyle(fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => cart.incrementQuantity(item.product.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CartBadge extends StatelessWidget {
  final VoidCallback onPressed;
  const CartBadge({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: onPressed,
            ),
            if (cart.totalQuantity > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    cart.totalQuantity.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}


class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    final currentQty = _items[productId]!.quantity;
    if (currentQty > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
