import 'dart:convert';
import 'package:fake_store/cart.dart';
import 'package:fake_store/detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  int cartCount = 0; // Initial count of items in the cart
  List<Map<String, dynamic>> cartItems = []; // List to store cart items

  late Future<List<dynamic>> _productListFuture;

  @override
  void initState() {
    super.initState();
    _productListFuture = _fetchProducts();
  }

  // Fetch product data from the API
  Future<List<dynamic>> _fetchProducts() async {
    var url = Uri.parse("http://127.0.0.1:5000/products");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Add product to the cart
  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cartItems.add(product);
      cartCount = cartItems.length; // Update cart count
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 20, left: 20),
            child: InkWell(
              child: badges.Badge(
                badgeContent: Text(
                  "$cartCount",
                  style: const TextStyle(fontSize: 10, color: Colors.yellow),
                ),
                badgeAnimation: const badges.BadgeAnimation.scale(
                  loopAnimation: false,
                  curve: Curves.fastOutSlowIn,
                  colorChangeAnimationCurve: Curves.easeInCubic,
                ),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  badgeColor: Colors.purple,
                  padding: const EdgeInsets.all(3),
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                  elevation: 0,
                ),
                child: const Icon(Icons.shopping_cart),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(cartItems: cartItems),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _productListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: ElevatedButton(
                child: const Text("No record"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(data: 12),
                    ),
                  );
                },
              ),
            );
          } else {
            var products = snapshot.data!;
            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                var product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    data: product['product_id'],
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              'http://127.0.0.1:5000/${product['image']}',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error,
                                  size: 50,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "\$${product['price']}",
                            style: const TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  print("Favorite");
                                },
                                icon: const Icon(Icons.favorite, color: Colors.deepOrangeAccent),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _addToCart(product); // Add product to cart
                                  },
                                  icon: const Icon(Icons.add_shopping_cart), // Icon for the button
                                  label: const Text('Add to Cart'), // Text for the button
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Custom padding
                                    backgroundColor: Colors.white38, // Change the background color if needed
                                    shape: const StadiumBorder(), // Optional: Add a rounded button shape
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
