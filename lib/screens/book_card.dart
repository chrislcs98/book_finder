import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_finder/book.dart';
import 'package:book_finder/constants.dart';
import 'package:book_finder/screens/books_screen.dart';
import 'package:flutter/widgets.dart';

class BookCard extends StatefulWidget {
  BookCard({
    key,
    required this.itemIndex,
    required this.book,
    required this.press,
    this.parent,
  }) : super(key: key);

  final int itemIndex;
  final Function press;
  Book book;
  final BooksScreenState? parent;

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    // It will provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      height: 260,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => widget.press(),
        splashColor: kBlueColor,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            // Those are our background
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0,3), // changes position of shadow
                  ),
                ],
              ),
            ),
            // Book Image
            Positioned(
              top: kDefaultPadding,
              left: kDefaultPadding,
              child: Hero(
                tag: widget.book.id,
                child: Container(
                  // padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  height: 200,
                  // // image is square but we add extra 20 + 20 padding that's why width is 200
                  // width: 150,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: widget.book.thumbnail != null ? Image.network(
                      widget.book.thumbnail!,
                      fit: BoxFit.fitWidth,
                    ) : Container(),
                  ),
                )
              ),
            ),
            // Book Details
            Positioned(
//              top: widget.book.name.length < (size.width/21.82) ? 40 : 30,
              left: 140,
              child: SizedBox(
                height: 260,
//                width: 200,
                // our image take 200 width, that's why we set out total width - 200
                width: size.width - 190,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Book Author
                    widget.book.authors != null &&  widget.book.authors!.isNotEmpty ?
                    Tooltip(
                      message: widget.book.authors![0],
                      margin: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding*2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: kDefaultPadding/4
                        ),
                        child: Text(
                          "by " + widget.book.authors![0],
                          style: Theme.of(context).textTheme.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ) : Container(),
                    // Book Title
                    Tooltip(
                      message: widget.book.title,
                      margin: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding*2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: kDefaultPadding/4
                        ),
                        child: Text(
                          widget.book.title,
                          style: Theme.of(context).textTheme.headline6,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis
                        )
                      )
                    ),
                    // Book Rating
                    widget.book.rating != null ? Padding(
                      padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: kDefaultPadding/4
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 15
                          ),
                          Text(
                            " ${widget.book.rating}",
                            style: Theme.of(context).textTheme.caption,
                          )
                        ]
                      )
                    ) : Container(),
                    // Book Category,
                    widget.book.categories!.isNotEmpty ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                          vertical: kDefaultPadding/2
                      ),
                      child: Tooltip(
                        message: widget.book.categories![0],
                        margin: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding*2,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding/2,
                              vertical: kDefaultPadding/5
                          ),
                          decoration: BoxDecoration(
                            color: kBlueColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            widget.book.categories![0],
                            style: const TextStyle(fontSize: 11, color: kPrimaryColor, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          )
                        ),
                      )
                    ) : Container(),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}