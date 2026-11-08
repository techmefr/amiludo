class BarcodeProduct {
  const BarcodeProduct({required this.title, this.imageUrl = ''});

  final String title, imageUrl;

  Map<String, Object?> toJson() => {'title': title, 'imageUrl': imageUrl};

  factory BarcodeProduct.fromJson(Map<String, dynamic> j) => BarcodeProduct(
    title: j['title'] as String? ?? '',
    imageUrl: j['imageUrl'] as String? ?? '',
  );
}
