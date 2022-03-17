import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_items.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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

      Provider.of<Orders>(context).fetchAllOrders().then((_) {
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
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: Text('No orders found'),
            )
          : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) => OrderItems(orderData.orders[i]),
            ),
    );
  }
}
