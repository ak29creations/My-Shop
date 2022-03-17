import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import '../widgets/app_drawer.dart';
import '../screens/cart_screen.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewSreen extends StatefulWidget {
  const ProductsOverviewSreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewSreen> createState() => _ProductsOverviewSreenState();
}

class _ProductsOverviewSreenState extends State<ProductsOverviewSreen> {
  var _showOnlyFavorite = false;

  var isInit = true;
  var _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchAllProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MY SHOP"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  _showOnlyFavorite = true;
                } else {
                  _showOnlyFavorite = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOptions.favorites,
              ),
              const PopupMenuItem(
                child: Text("All"),
                value: FilterOptions.all,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch as Widget,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(
                Icons.shopping_cart,
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: Text('No products found'),
            )
          : ProductsGrid(_showOnlyFavorite),
    );
  }
}
