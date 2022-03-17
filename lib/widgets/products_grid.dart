import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  const ProductsGrid(this.showFavs, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: const ProductItem(),
      ),
      itemCount: products.length,
    );
  }
}
