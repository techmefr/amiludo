enum SurfaceMaterial {
  wood(
    floorBounce: 0.45,
    wallBounce: 0.55,
    friction: 2.4,
    pitch: 1.0,
    ring: 0.5,
    loudness: 0.9,
  ),
  felt(
    floorBounce: 0.2,
    wallBounce: 0.35,
    friction: 5.5,
    pitch: 0.6,
    ring: 0.15,
    loudness: 0.55,
  ),
  glass(
    floorBounce: 0.6,
    wallBounce: 0.75,
    friction: 1.1,
    pitch: 1.8,
    ring: 1.0,
    loudness: 1.0,
  );

  const SurfaceMaterial({
    required this.floorBounce,
    required this.wallBounce,
    required this.friction,
    required this.pitch,
    required this.ring,
    required this.loudness,
  });

  final double floorBounce, wallBounce, friction, pitch, ring, loudness;

  static SurfaceMaterial parse(String? value) => values.firstWhere(
    (m) => m.name == value,
    orElse: () => wood,
  );
}
