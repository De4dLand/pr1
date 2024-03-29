import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:core';
//Bước 1: Thiết kế model
class Product {
  String search_image;
  String styleid;
  String brands_filter_facet;
  String price;
  String product_additional_info;
  Product({
      required this.search_image,
      required this.styleid,
      required this.brands_filter_facet,
      required this.price,
      required this.product_additional_info
      }
    );
}
//Thiết kế activity
class ProductListScreen extends StatefulWidget
{
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}
//Bước 3:Define Activity:Lấy dữ liệu từ server về
class _ProductListScreenState  extends State<ProductListScreen>{
  late List<Product> products= [];
  //hàm khởi tạo
  final Cart cart= Cart();//Khởi tạo giỏ hàng
  @override
  void initState() {
    super.initState();
    fetchProduct();//Hàm lấy dữ liệu từ server
  }
  //Hàm đọc dữ liệu từ server
  Future<void> fetchProduct() async
  {
    String url ="http://192.168.165.202/server/get.php";
    final response = await http.get(Uri.parse(url),headers:{ "Access-Control_Allow_Origin": "*"});
    if (response.statusCode == 200)
      {
        final Map<String, dynamic> data =json.decode(response.body);
        setState(() {
          products = convertMapToList(data);
        });
      }
    else
      {
        throw Exception("Khong doc duoc du lieu ");
      }
  }
  //Hàm convert từ map thành List
  List<Product> convertMapToList(Map<String, dynamic> data)
  {
    List<Product> productList = [];
    data.forEach((key, value)
    {
      for(int i =0;i<value.length;i++)
      {
        Product products= Product(
            search_image : value[i]['search_image'] ??'',
            styleid : value[i]['styleid'] ?? 0 ,
            brands_filter_facet : value[i]['brands_filter_facet'] ?? '',
            price: value[i]['price'] ?? 0 ,
            product_additional_info: value[i]['product_additional_info'] ?? '');
        productList.add(products);
      }
    }
    );
    return productList;
  }
  //Tạo layout
  @override
  Widget build(BuildContext context)
  {
    var i= products.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sach san pham"),
      ),
      body: products != null ?
      ListView.builder(
          itemCount: i,
          itemBuilder: (context,index)
      {
        return ListTile(
          title: Text(products[index].brands_filter_facet),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: ${products[index].price} '),
              Text('product_additional_info : ${products[index].product_additional_info}'),
            ],
        ),
        leading: Image.network(
        products[index].search_image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
          onTap: (){
            //click on items
            Navigator.push(context,
              MaterialPageRoute(builder: (context)=>ProductDetailScreen(products[index],cart),
            ),
            );
          },
        );
      })
          :const Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}
//Dinh nghia chi tiet san pham
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final Cart cart;
  const ProductDetailScreen(this.product,this.cart) ;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Thong tin san pham"),
       actions: [
         ElevatedButton(
           onPressed: ()
       {
         cart.addToCart(product);
         //dua ra thong bao
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('San pham da duoc them vao gio hang'))
         );
         Navigator.push(context,
         MaterialPageRoute(builder: (context)=> CartScreen(cart)),);
       }, child: Icon(Icons.shopping_cart),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(0)
          ),
        ),
       ],
     ),
     body: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Padding(padding: const EdgeInsets.all(8.0),
         child: Text('Brand: ${product.brands_filter_facet}'),
         ),
         Image.network(product.search_image,
           width: 500,
           height: 500,
           fit: BoxFit.cover,),
         Padding(padding: const EdgeInsets.all(8.0),
          child: Text('Info: ${product.product_additional_info}',
         style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
            ),
         ),
         Padding(padding: const EdgeInsets.all(8.0),
         child: Text('ID: ${product.styleid}'),

         ),
         Padding(padding: const EdgeInsets.all(8.0),
         child: Text('Price: ${product.price}'),)
       ],
     ),
   );
  }

}
//xu ly gio hang
class Cart
{
  List<Product> items = [];

  void addToCart(Product product) {
    items.add(product);
  }

}
class CartScreen extends StatelessWidget
{
  final Cart cart;
  CartScreen(this.cart);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shopping Cart"),),
      body: ListView.builder(
          itemCount: cart.items.length,
          itemBuilder: (context,index)
      {
        return ListTile(
          title: Text(cart.items[index].brands_filter_facet),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cart.items[index].price),Text(cart.items[index].styleid)
            ],
          ),
            leading: Image.network(
            cart.items[index].search_image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
            )
        );
      }),

    );
  }

}
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danh sach san pham',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}