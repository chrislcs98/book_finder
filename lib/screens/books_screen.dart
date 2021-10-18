import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_finder/sliver_app_bar_delegate.dart';
import 'package:book_finder/book.dart';
import 'book_card.dart';
import 'package:book_finder/constants.dart';

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


class BooksScreenState extends State<BooksScreen> {
  TextEditingController controller = TextEditingController();
  // bool searchFlag = false;
  bool favsFlag = false;
  List<Book> books = [];
  static const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';

  void initState() {
    super.initState();

    // var client = http.Client();
    getBooks('');
  }

  void getBooks(String query) async {
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


    // var keywords = '';
    // bool randomFlag = false;

    if (query.isEmpty) {
      // randomFlag = true;
      Random _rnd = Random();

      String getRandomString(int length) =>
          String.fromCharCodes(Iterable.generate(
              length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

      query = getRandomString(1);
      // keywords = '';
    }

    developer.log('Query: ' + query);
    // var url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=a&maxResults=40&printType=books&fields=totalItems,items(volumeInfo(title,averageRating))&key=' + dotenv.env['API_KEY']!);
    var url = Uri.parse('https://www.googleapis.com/books/v1/volumes?' +
        'maxResults=40&printType=books&q=' + query +
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
      bool famousFlag = true;
      var vol = it['volumeInfo'];
      var rating = vol['averageRating']?.toDouble();

      if (vol['title'] != null) {
        // if (randomFlag && (rating == null || rating < 3)) {
        //   famousFlag = false;
        // }

        if (famousFlag) {
          Book book = Book(
              id: it['id'],
              title: vol['title'],
              authors: vol['authors'],
              rating: rating,
              ratingsCount: vol['ratingCount'],
              publisher: vol['publisher'],
              publishedDate: vol['publishedDate'],
              description: vol['description'],
              pageCount: vol['pageCount'],
              categories: [vol['mainCategory'], ...?vol['categories']],
              thumbnail: vol['imageLinks']?['thumbnail'],
              link: vol['canonicalVolumeLink'],
              buyLink: it['saleInfo']?['buyLink'],
              price: it['saleInfo']?['listPrice']
          );
          book.categories!.removeWhere((value) => value == null);
          // developer.log('${book.ratingsCount}');
          books.add(book);
        }
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // It will provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFixedExtentList(
            itemExtent: 120.0,
            delegate: SliverChildListDelegate(
              [
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 50, right: 20),
                  child: Text(
                    "Explore thousands of books on the go",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  )
                )
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverAppBarDelegate(
              minHeight: 140.0,
              maxHeight: 140.0,
              child: Container(
                color: kBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 35, right: 20, bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0,3), // changes position of shadow
                            ),
                          ],
                        ),
                        // color: kBackgroundColor.withOpacity(0.8),
                        child: ListTile(
                          leading: const Icon(Icons.search),
                          title: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Search for books...',
                              border: InputBorder.none,
                            ),
                            onChanged: getBooks,
                          ),
                          trailing: IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                controller.clear();
                                getBooks('');
                              }
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 23, right: 20, bottom: 0),
                      child: Text(
                        favsFlag ? "Favourites Books" : "Famous Books",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ),
                  ]
                ),
              ),
            ),
          ),
          SliverFixedExtentList(
              itemExtent: 260,
              delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
                return !favsFlag ?
                  BookCard(
                      itemIndex: index,
                      book: books[index],
                      press: () {},
                      parent: this
                  )
                : (books[index].favFlag ?
                    BookCard(
                        itemIndex: index,
                        book: books[index],
                        press: () {},
                        parent: this
                    )
                  : Container());
              },
              childCount: books.length)
          ),
        ],
      )
    );
  }
}