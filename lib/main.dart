import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const IMAGE_URL = 'https://random.dog/woof.json';
const TEXT_URL = 'https://baconipsum.com/api/?type=all-meat&sentences=1';

const IMAGE_FOR_FIRST_INIT = 10;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  late ScrollController _scrollController;

  final List<String> _imagesUrls = [];
  final List<String> _texts = [];

  bool _isFirstInit = true;

  bool isLoading = false;

  _getData() async {
    setState(() {
      isLoading = true;
    });

    if (_isFirstInit) {
      for (var i = 0; i < IMAGE_FOR_FIRST_INIT; i++) {
        await _getImage();
        await _getText();
      }

      _isFirstInit = false;
    } else {
      await _getImage();
      await _getText();
    }

    setState(() {
      isLoading = false;
    });
  }

  _getImage() async {
    final response = await http.get(Uri.parse(IMAGE_URL));

    final body = jsonDecode(response.body);

    if(body['url'].endsWith('jpg') || body['url'].endsWith('png')){
      _imagesUrls.add(body['url']);
      return;
    }

    await _getImage();

  }

  _getText() async {
    final response = await http.get(Uri.parse(TEXT_URL));

    final body = jsonDecode(response.body);

    _texts.add(body[0]);
  }

  @override
  void initState() {
    super.initState();
    _getData();

    _scrollController = ScrollController();
    _scrollController.addListener((() {
      if (_scrollController.position.pixels >=
          _scrollController.position.pixels * 0.95 &&
          !isLoading) {
        _getData();
      }
    }));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список + API'),
      ),
      body: SafeArea(
        child: ListView.separated(
          controller: _scrollController,
          itemCount: _imagesUrls.length,
          separatorBuilder: ((context, index) => const SizedBox(height: 10)),
          itemBuilder: (context, index) {
            return Row(
              children: [
                const Padding(padding: EdgeInsets.only(left:20)),
                Image.network(
                  _imagesUrls[index],
                  height: 300,
                  width: 400,
                  fit: BoxFit.cover,
                ),
                const Padding(padding: EdgeInsets.only(left:20)),
                Container(
                  child: Text(_texts[index], softWrap: true),
                  width: 200,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}