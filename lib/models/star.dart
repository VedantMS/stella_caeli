class Star {
  final String id;        // HIP identifier
  final double ra;        // degrees
  final double dec;       // degrees
  final double magnitude; // Vmag

  // Optional astrophysical metadata
  final double? bv;       // B-V color index
  final double? parallax; // milliarcseconds

  const Star({
    required this.id,
    required this.ra,
    required this.dec,
    required this.magnitude,
    this.bv,
    this.parallax,
  });

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
      id: json['id'] as String,
      ra: (json['ra'] as num).toDouble(),
      dec: (json['dec'] as num).toDouble(),
      magnitude: (json['vmag'] as num).toDouble(),
      bv: (json['bv'] as num?)?.toDouble(),
      parallax: (json['plx'] as num?)?.toDouble(),
    );
  }
}
