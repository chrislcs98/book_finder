import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_finder/book.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class BookDetails extends StatefulWidget {
  const BookDetails(this.book, {Key? key}) : super(key: key);

  final Book book;

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  var authors;
  var authorsList;

  @override
  void initState() {
    super.initState();

    authors = "";
    authorsList = widget.book.authors;
    if (authorsList != null && authorsList.isNotEmpty) {
      var lastAuthor = authorsList.removeAt(authorsList.length - 1);
      if (authorsList.length != 1) {
        for (var author in authorsList) {
          authors += author + ", ";
        }
        authors += lastAuthor;
      } else {
        authors = authorsList[0];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: PreferredSize(
        preferredSize:  Size.fromHeight(AppBar().preferredSize.height),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(20),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(Colors.white)),
                  ),
                ),
                Container(
                  width: 70,
                  // padding: const EdgeInsets.only(left: 15, top: 15),
                  decoration: BoxDecoration(
                    color: widget.book.favFlag
                        ? kPrimaryColor.withOpacity(.3)
                        : Color(0xFF979797).withOpacity(.12),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ),
                  ),
                  child: IconButton(
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        widget.book.favFlag = !widget.book.favFlag;
                      });
                    },
                    icon: Icon(
                      widget.book.favFlag
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: widget.book.favFlag
                          ? Color(0xFFFF4848).withOpacity(.9)
                          : Color(0xFFDBDEE4),
                    ),
                  ),
                ),
              ]
            )
          )
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.hardEdge,
                child: widget.book.thumbnail != null ? Image.network(
                  widget.book.thumbnail!,
                  fit: BoxFit.fitHeight,
                ) : Container(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Container(
                width: double.infinity,
                // margin: EdgeInsets.only(top: getProportionateScreenWidth(20)),
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                      child: Text(
                        widget.book.title,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    authors != "" ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                        vertical: kDefaultPadding/4
                      ),
                      child: Text(
                        "by " + authors,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ) : Container(),
                    const SizedBox(height: 5),
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
                    const SizedBox(height: 5),
                    widget.book.categories!.isNotEmpty ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                        vertical: kDefaultPadding/2
                      ),
                      child: Row(
                        children: List.generate(widget.book.categories!.length, (i) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding/2,
                              vertical: kDefaultPadding/5
                            ),
                            decoration: BoxDecoration(
                              color: kBlueColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              widget.book.categories![i],
                              style: const TextStyle(fontSize: 11, color: kPrimaryColor, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            )
                          );
                        })
                      )
                    ) : Container(),
                    const SizedBox(height: 15),
                    widget.book.description != null ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Description",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ) : Container(),
                    widget.book.description != null ? Padding(
                      padding: const EdgeInsets.only(left: 20, right: 64),
                      child: Text(widget.book.description?? ''),
                    ) : Container(),
                  ]
                ),
              ),
            )
          ]
        )
      ),
    );
  }
}
