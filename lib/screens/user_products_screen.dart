import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context).fetchAllProducts();
  }

  const UserProductsScreen({Key? key}) : super(key: key);
  static const routeName = 'user-products';
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    String? id;
    id = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProduct(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemBuilder: (_, i) => UserProductItem(
              productsData.items[i].id,
              productsData.items[i].title,
              productsData.items[i].imageUrl,
            ),
            itemCount: productsData.items.length,
          ),
        ),
      ),
    );
  }
}
