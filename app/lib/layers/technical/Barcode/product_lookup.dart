class ProductHit {
  const ProductHit({required this.title, this.imageUrl = ''});

  final String title, imageUrl;
}

class ProductLookupException implements Exception {
  const ProductLookupException();
}
