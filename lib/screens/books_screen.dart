import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_finder/book.dart';

import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;

// APIs
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/books/v1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class BooksScreen extends StatefulWidget {
  BooksScreen({Key? key, this.title=''}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  BooksScreenState createState() => BooksScreenState();
}

//enum SingingCharacter { name, location, price }

class BooksScreenState extends State<BooksScreen> {
  List<Book> books = [];
  static const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';

  void initState() {
    super.initState();

    // var client = http.Client();
    getBooks();
  }

  void getBooks({String query=''}) async {
    books.clear();

    // final _googleSignIn = GoogleSignIn(
    //   scopes: <String>[BooksApi.booksScope],
    //   clientId: dotenv.env['CLIENT_ID'],
    // );
    // var httpClient = (await _googleSignIn.authenticatedClient());
    // print(httpClient);
    // // var client = clientViaApiKey(dotenv.env['API_KEY'] ?? '', baseClient: httpClient);
    // // print(client);
    //
    // // var booksApi = BooksApi(httpClient);
    // // var booksf = await booksApi.volumes.recommended.list();
    // // print(booksf);

    var keywords = 'intitle,inauthor:';

    if (query.isEmpty) {
      Random _rnd = Random();

      String getRandomString(int length) =>
          String.fromCharCodes(Iterable.generate(
              length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

      query = getRandomString(1);
      keywords = '';
    }

    developer.log('Query: ' + query);
    // var url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=a&maxResults=40&printType=books&fields=totalItems,items(volumeInfo(title,averageRating))&key=' + dotenv.env['API_KEY']!);
    var url = Uri.parse('https://www.googleapis.com/books/v1/volumes?' +
        'maxResults=40&printType=books&q=' + keywords + query +
        '&fields=totalItems,items(id,volumeInfo(title,authors,averageRating,' +
        'publisher,publishedDate,description,pageCount,ratingsCount,mainCategory,' +
        'categories,imageLinks/thumbnail,canonicalVolumeLink),saleInfo(buyLink,listPrice))' +
        '&key=' + dotenv.env['API_KEY']!);

    // var url = Uri.parse('https://www.googleapis.com/books/v1/volumes/recommended?maxResults=40&printType=books&authorization=' + dotenv.env['CLIENT_ID']!);
    // var url = Uri.parse('https://www.googleapis.com/books/v1/users/' + dotenv.env['CLIENT_ID']! + '/bookshelves');


    var response = await http.get(url);
    // developer.log('Response status: ${response.statusCode}');
    // developer.log('Response body: ${response.body}');

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    developer.log('Map: $decodedResponse');

    decodedResponse['items'].forEach((it) {
      var vol = it['volumeInfo'];
      Book book = Book(
        id: it['id'],
        title: vol['title'],
        authors: vol['authors'],
        rating: vol['averageRating']?.toDouble(),
        ratingsCount: vol['ratingCount'],
        publisher: vol['publisher'],
        publishedDate: vol['publishedDate'],
        description: vol['description'],
        pageCount: vol['pageCount'],
        categories: [vol['mainCategory'], ...?vol['categories']],
        thumbnail: vol['thumbnail'],
        link: vol['canonicalVolumeLink'],
        buyLink: it['saleInfo']?['buyLink'],
        price: it['saleInfo']?['listPrice']
      );
      // developer.log('${book.ratingsCount}');
      books.add(book);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container();

  }
}