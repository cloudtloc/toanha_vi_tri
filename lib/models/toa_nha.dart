class ToaNhaViTri {
  final int id;
  final String? maToaNha;
  final String? tenToaNha;
  final String? tenChiTiet;
  final double? kinhDo;
  final double? viDo;
  final String? toaDoBien;
  final String? viTri;
  final int? khuId;

  ToaNhaViTri({
    required this.id,
    this.maToaNha,
    this.tenToaNha,
    this.tenChiTiet,
    this.kinhDo,
    this.viDo,
    this.toaDoBien,
    this.viTri,
    this.khuId,
  });

  factory ToaNhaViTri.fromJson(Map<String, dynamic> json) {
    return ToaNhaViTri(
      id: json['id'] as int,
      maToaNha: json['maToaNha'] as String?,
      tenToaNha: json['tenToaNha'] as String?,
      tenChiTiet: json['tenChiTiet'] as String?,
      kinhDo: (json['kinhDo'] as num?)?.toDouble(),
      viDo: (json['viDo'] as num?)?.toDouble(),
      toaDoBien: json['toaDoBien'] as String?,
      viTri: json['viTri'] as String?,
      khuId: json['khuId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maToaNha': maToaNha,
      'tenToaNha': tenToaNha,
      'tenChiTiet': tenChiTiet,
      'kinhDo': kinhDo,
      'viDo': viDo,
      'toaDoBien': toaDoBien,
      'viTri': viTri,
      'khuId': khuId,
    };
  }

  bool get coViTri => kinhDo != null || viDo != null || (toaDoBien != null && toaDoBien!.isNotEmpty);
}

class ToaNhaViTriRequest {
  final int? id;
  final String? maToaNha;
  final String? tenToaNha;
  final String? tenChiTiet;
  final double? kinhDo;
  final double? viDo;
  final String? toaDoBien;
  final String? viTri;
  final int? khuId;

  ToaNhaViTriRequest({
    this.id,
    this.maToaNha,
    this.tenToaNha,
    this.tenChiTiet,
    this.kinhDo,
    this.viDo,
    this.toaDoBien,
    this.viTri,
    this.khuId,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (id != null) m['id'] = id;
    if (maToaNha != null) m['maToaNha'] = maToaNha;
    if (tenToaNha != null) m['tenToaNha'] = tenToaNha;
    if (tenChiTiet != null) m['tenChiTiet'] = tenChiTiet;
    if (kinhDo != null) m['kinhDo'] = kinhDo;
    if (viDo != null) m['viDo'] = viDo;
    m['toaDoBien'] = toaDoBien;
    if (viTri != null) m['viTri'] = viTri;
    if (khuId != null) m['khuId'] = khuId;
    return m;
  }
}

class ToaNhaViTriUpdateRequest {
  final double? kinhDo;
  final double? viDo;
  final String? toaDoBien;

  ToaNhaViTriUpdateRequest({
    this.kinhDo,
    this.viDo,
    this.toaDoBien,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (kinhDo != null) m['kinhDo'] = kinhDo;
    if (viDo != null) m['viDo'] = viDo;
    m['toaDoBien'] = toaDoBien;
    return m;
  }
}
