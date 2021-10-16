class Book {
  final String id, title;
  final double? rating;
  final String? thumbnail, publisher, publishedDate, mainCategory, description, link, buyLink;
  final int? ratingsCount, pageCount;
  final Map? price;
  List? categories, authors = [];
  bool favFlag;


  Book({required this.id, required this.rating, required this.title, this.authors,
    this.thumbnail, this.favFlag = false, this.categories, this.mainCategory,
    this.description, this.ratingsCount, this.pageCount, this.link, this.buyLink,
    this.price, this.publisher, this.publishedDate});
}

// // list of books
// // for our demo
// var books2 = [
//   Book(
//     id: '1',
//     rating: 4.5,
//     title: "The More of Less",
//     author: "Joshua Becker",
//     image: "assets/images/logo.png",
//     tags: ["Minimalism"],
//     favFlag: true
//   ),
//   Book(
//     id: '2',
//     rating: 4.5,
//     title: "The Good Surgeon",
//     author: "Don Felker",
//     image: "assets/images/logo.png",
//     tags: ["Medical"]
//   ),
//   Book(
//     id: '3',
//     rating: 4.5,
//     title: "1984",
//     author: "George Orwell",
//     image: "assets/images/logo.png",
//     tags: ["Medical"],
//     favFlag: true
//   ),
//   Book(
//     id: '4',
//     rating: 2,
//     title: "A",
//     author: "A F",
//     image: "assets/images/logo.png",
//   ),
//   Book(
//     id: '5',
//     rating: 4,
//     title: "B",
//     author: "B F",
//     image: "assets/images/logo.png",
//     tags: ["Cars"]
//   ),
//   Book(
//     id: '6',
//     rating: 3,
//     title: "C",
//     author: "C F",
//     image: "assets/images/logo.png"
//   ),
// ];