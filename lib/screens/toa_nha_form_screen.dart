import 'package:flutter/material.dart';

import '../models/toa_nha.dart';
import '../services/location_service.dart';
import '../services/toa_nha_api_service.dart';

class ToaNhaFormScreen extends StatefulWidget {
  final ToaNhaViTri? toaNha;
  final bool chiCapNhatViTri;

  const ToaNhaFormScreen({
    super.key,
    this.toaNha,
    this.chiCapNhatViTri = false,
  });

  @override
  State<ToaNhaFormScreen> createState() => _ToaNhaFormScreenState();
}

/// Mot diem toa do (lat, lng) cho goc toa nha
class _DiemBien {
  final double lat;
  final double lng;
  _DiemBien(this.lat, this.lng);
  String get text => '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
}

class _ToaNhaFormScreenState extends State<ToaNhaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _locationLoading = false;
  double? _lastAccuracyMeters;

  /// 4 diem goc toa nha de tao toa do bien (polygon). Thu tu: goc 1, 2, 3, 4.
  final List<_DiemBien?> _bienDiem = [null, null, null, null];
  int? _bienLoadingIndex;

  late final TextEditingController _maToaNha;
  late final TextEditingController _tenToaNha;
  late final TextEditingController _tenChiTiet;
  late final TextEditingController _kinhDo;
  late final TextEditingController _viDo;
  late final TextEditingController _toaDoBien;
  late final TextEditingController _viTri;

  bool get isEdit => widget.toaNha != null;
  bool get chiCapNhatViTri => widget.chiCapNhatViTri;

  @override
  void initState() {
    super.initState();
    final t = widget.toaNha;
    _maToaNha = TextEditingController(text: t?.maToaNha ?? '');
    _tenToaNha = TextEditingController(text: t?.tenToaNha ?? '');
    _tenChiTiet = TextEditingController(text: t?.tenChiTiet ?? '');
    _kinhDo = TextEditingController(text: t?.kinhDo?.toString() ?? '');
    _viDo = TextEditingController(text: t?.viDo?.toString() ?? '');
    _toaDoBien = TextEditingController(text: t?.toaDoBien ?? '');
    _viTri = TextEditingController(text: t?.viTri ?? '');
  }

  @override
  void dispose() {
    _maToaNha.dispose();
    _tenToaNha.dispose();
    _tenChiTiet.dispose();
    _kinhDo.dispose();
    _viDo.dispose();
    _toaDoBien.dispose();
    _viTri.dispose();
    super.dispose();
  }

  /// Lay 1 trong 4 diem goc toa nha (index 0..3), luu vao _bienDiem va cap nhat chuoi polygon neu du 4 diem.
  Future<void> _layDiemBien(int index) async {
    if (index < 0 || index > 3) return;
    setState(() => _bienLoadingIndex = index);
    try {
      final result = await LocationService.getViTriChinhXac();
      if (!mounted) return;
      _bienDiem[index] = _DiemBien(result.latitude, result.longitude);
      final parts = <String>[];
      for (var i = 0; i < 4; i++) {
        final d = _bienDiem[i];
        if (d != null) parts.add(d.text);
      }
      if (parts.length == 4) {
        _toaDoBien.text = parts.join(';');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da lay du 4 goc. Toa do bien da duoc dien.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Da lay goc ${index + 1}/4. Di den goc ${index + 2} va bam tiep.',
            ),
          ),
        );
      }
      setState(() => _bienLoadingIndex = null);
    } catch (e) {
      if (mounted) {
        setState(() => _bienLoadingIndex = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: $e')),
        );
      }
    }
  }

  void _xoaBonDiemBien() {
    setState(() {
      for (var i = 0; i < 4; i++) _bienDiem[i] = null;
      _toaDoBien.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Da xoa 4 diem toa do bien')),
    );
  }

  Future<void> _layViTriHienTai() async {
    setState(() {
      _locationLoading = true;
      _lastAccuracyMeters = null;
    });
    try {
      final result = await LocationService.getViTriChinhXac();
      if (mounted) {
        _viDo.text = result.latitude.toString();
        _kinhDo.text = result.longitude.toString();
        setState(() {
          _locationLoading = false;
          _lastAccuracyMeters = result.accuracyMeters;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Da lay vi tri. Do chinh xac: ${result.accuracyMeters.toStringAsFixed(1)}m',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _locationLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: $e')),
        );
      }
    }
  }

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (chiCapNhatViTri && widget.toaNha != null) {
        final kinhDo = double.tryParse(_kinhDo.text.trim());
        final viDo = double.tryParse(_viDo.text.trim());
        await ToaNhaApiService.capNhatViTri(
          widget.toaNha!.id,
          ToaNhaViTriUpdateRequest(
            kinhDo: kinhDo,
            viDo: viDo,
            toaDoBien: _toaDoBien.text.trim().isEmpty ? null : _toaDoBien.text.trim(),
          ),
        );
      } else {
        await ToaNhaApiService.ghiViTri(
          ToaNhaViTriRequest(
            id: isEdit ? widget.toaNha!.id : 0,
            maToaNha: _maToaNha.text.trim().isEmpty ? null : _maToaNha.text.trim(),
            tenToaNha: _tenToaNha.text.trim().isEmpty ? null : _tenToaNha.text.trim(),
            tenChiTiet: _tenChiTiet.text.trim().isEmpty ? null : _tenChiTiet.text.trim(),
            kinhDo: double.tryParse(_kinhDo.text.trim()),
            viDo: double.tryParse(_viDo.text.trim()),
            toaDoBien: _toaDoBien.text.trim().isEmpty ? null : _toaDoBien.text.trim(),
            viTri: _viTri.text.trim().isEmpty ? null : _viTri.text.trim(),
          ),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Luu thanh cong')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chiCapNhatViTri
              ? 'Cap nhat vi tri'
              : isEdit
                  ? 'Sua toa nha'
                  : 'Them toa nha',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!chiCapNhatViTri) ...[
              TextFormField(
                controller: _maToaNha,
                decoration: const InputDecoration(
                  labelText: 'Ma toa nha',
                  border: OutlineInputBorder(),
                ),
                enabled: !isEdit,
                validator: (v) {
                  if (!isEdit && (v == null || v.trim().isEmpty)) {
                    return 'Nhap ma toa nha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tenToaNha,
                decoration: const InputDecoration(
                  labelText: 'Ten toa nha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tenChiTiet,
                decoration: const InputDecoration(
                  labelText: 'Ten chi tiet',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!isEdit && (v == null || v.trim().isEmpty)) {
                    return 'Nhap ten chi tiet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _viTri,
                decoration: const InputDecoration(
                  labelText: 'Vi tri (mo ta)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Toa do (vi tri)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _locationLoading ? null : _layViTriHienTai,
              child: _locationLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lay vi tri hien tai tu thiet bi (GPS)'),
            ),
            if (_lastAccuracyMeters != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Do chinh xac lan lay truoc: ${_lastAccuracyMeters!.toStringAsFixed(1)}m',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _viDo,
              decoration: const InputDecoration(
                labelText: 'Vi do (latitude)',
                border: OutlineInputBorder(),
                hintText: 'VD: 9.942345',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _kinhDo,
              decoration: const InputDecoration(
                labelText: 'Kinh do (longitude)',
                border: OutlineInputBorder(),
                hintText: 'VD: 106.345678',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            const Text(
              'Toa do bien (polygon) - 4 goc toa nha',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Di lan luot den 4 goc toa nha, moi goc bam nut lay vi tri tuong ung.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(4, (i) {
                final diem = _bienDiem[i];
                final loading = _bienLoadingIndex == i;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: loading ? null : () => _layDiemBien(i),
                          child: loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text('Goc ${i + 1}'),
                        ),
                        if (diem != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${diem.lat.toStringAsFixed(4)}, ${diem.lng.toStringAsFixed(4)}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: _bienDiem.any((d) => d != null) ? _xoaBonDiemBien : null,
              child: const Text('Xoa 4 diem bien'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _toaDoBien,
              decoration: const InputDecoration(
                labelText: 'Toa do bien (chuoi polygon)',
                border: OutlineInputBorder(),
                hintText: 'Tu dong dien khi lay du 4 goc, hoac nhap tay',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _luu,
              child: _saving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Luu'),
            ),
          ],
        ),
      ),
    );
  }
}
