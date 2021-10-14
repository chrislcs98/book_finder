class Book {
  final double stars;
  final String id, name;
  final String? image, description;
  var tags = <String>[];
  bool favFlag = false;
  bool searchFlag = true;

  Book({required this.id, required this.stars, required this.name, this.image, required this.favFlag, required this.searchFlag, required this.tags, this.description});
}