import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '郵便番号で住所検索'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final postalCodeController = TextEditingController();
  final zipCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              TextFormField(
                maxLength: 7,
                onChanged: (value) async {
                  // 入力された文字数が７以外の場合終了
                  if (value.length != 7) {
                    return;
                  }
                  final address = await zipCodeToAddress(value);
                  // 返ってきた値がnullの場合終了
                  if (address == null) {
                    return;
                  }
                  // 住所が返ってきたら、postalCodeControllerを取得する。
                  postalCodeController.text = address;
                },
                controller: zipCodeController,
                decoration: const InputDecoration(
                    hintText: '7ケタで住所を入力してください', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),
              TextFormField(
                enabled: false,
                decoration: const InputDecoration(
                    hintText: '都道府県市町村', border: OutlineInputBorder()),
                textInputAction: TextInputAction.done,
                controller: postalCodeController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> zipCodeToAddress(String zipCode) async {
  if (zipCode.length != 7) {
    return null;
  }
  final response = await get(
    Uri.parse(
      'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode',
    ),
  );
  // 正常なコードが返ってきているか
  if (response.statusCode != 200) {
    return null;
  }
  // 該当する住所があるかチェックする
  final result = jsonDecode(response.body);
  if (result['results'] == null) {
    return null;
  }
  final addressMap = (result['results'] as List).first;
  final address =
      '${addressMap['address1']} ${addressMap['address2']} ${addressMap['address3']}';
  return address;
}
