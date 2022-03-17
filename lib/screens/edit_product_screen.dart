import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);
  static const routeName = '/add-edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  var isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocus.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != '') {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocus.removeListener(_updateImage);
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlController.dispose();
    _imageUrlFocus.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageUrlFocus.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    if (_form.currentState != null) {
      final isValid = _form.currentState!.validate();
      if (isValid) {
        _form.currentState!.save();
        setState(() {
          _isLoading = true;
        });

        if (_editedProduct.id != '') {
          await Provider.of<Products>(context, listen: false)
              .updateProduct(_editedProduct.id, _editedProduct);
        } else {
          try {
            await Provider.of<Products>(context, listen: false)
                .addProduct(_editedProduct);
          } catch (error) {
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
        }
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _editedProduct.id == ''
            ? const Text('Add Product')
            : const Text('Edit Product'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocus),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title field is required';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: newValue!,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: initValues['price'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocus,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocus),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Price field is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(newValue!),
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: initValues['description'],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocus,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Description field is required';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: newValue!,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Center(child: Text('Enter URL'))
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.fill,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocus,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Image URL field is required';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: newValue!,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _saveForm();
                          },
                          child: _editedProduct.id == ''
                              ? const Text('Save')
                              : const Text('Update'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
