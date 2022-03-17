import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/cart_items.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => CartItems(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].title,
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
              ),
              itemCount: cart.items.length,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text("ORDER NOW"),
      onPressed: (widget.cart.totalAmount <= 0 || isLoading)
          ? null
          : () async {
              setState(() {
                isLoading = true;
              });
              try {
                await Provider.of<Orders>(context, listen: false).addOrders(
                  widget.cart.items.values.toList(),
                  widget.cart.totalAmount,
                );
              } catch (e) {
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('An error occurred!'),
                    content: const Text('Somthing went wrong.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  ),
                );
              }
              setState(() {
                isLoading = false;
              });
              widget.cart.clear();
            },
    );
  }
}
