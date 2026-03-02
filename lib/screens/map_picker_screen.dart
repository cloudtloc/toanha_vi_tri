import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/location_service.dart';
import '../utils/app_snackbar.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialPolygon;

  const MapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialPolygon,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

/// Che do chon tren ban do:
/// - viTri: chi tap de chon 1 diem vi tri chinh.
/// - bien: long press de chon toi da 4 diem toa do bien.
enum _MapMode { viTri, bien }

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  late CameraPosition _initialCamera;
  LatLng? _markerPosition;
  final List<LatLng> _boundaryPoints = [];
  MapType _mapType = MapType.normal;
  _MapMode _mode = _MapMode.viTri;

  @override
  void initState() {
    super.initState();

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      final lat = widget.initialLatitude!;
      final lng = widget.initialLongitude!;
      _markerPosition = LatLng(lat, lng);
      _initialCamera = CameraPosition(
        target: _markerPosition!,
        zoom: 17,
      );
    } else {
      // Tam thoi dua camera ve 1 vi tri mac dinh, sau do se nhay toi vi tri hien tai.
      const fallback = LatLng(10.0, 106.0);
      _markerPosition = null;
      _initialCamera = const CameraPosition(
        target: fallback,
        zoom: 15,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _denViTriHienTai();
      });
    }

    _parseInitialPolygon(widget.initialPolygon);
  }

  void _parseInitialPolygon(String? s) {
    if (s == null || s.trim().isEmpty) return;
    final parts = s.trim().split(';');
    for (final part in parts) {
      final p = part.trim().split(',');
      if (p.length >= 2) {
        final lat = double.tryParse(p[0].trim());
        final lng = double.tryParse(p[1].trim());
        if (lat != null && lng != null) {
          _boundaryPoints.add(LatLng(lat, lng));
        }
      }
    }
  }

  void _onMapTap(LatLng position) {
    if (_mode == _MapMode.viTri) {
      setState(() {
        _markerPosition = position;
      });
    }
  }

  void _onMapLongPress(LatLng position) {
    if (_mode != _MapMode.bien) return;
    setState(() {
      // Cho phep nhieu diem toa do bien, giu dung thu tu nguoi dung chon.
      _boundaryPoints.add(position);
    });
  }

  void _onToggleMapType(MapType type) {
    setState(() {
      _mapType = type;
    });
  }

  void _setMode(_MapMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  void _undoLastBoundaryPoint() {
    if (_boundaryPoints.isEmpty) {
      showThongBao(context, 'Chưa có điểm tọa độ biên để quay lại.', isLoi: true);
      return;
    }
    setState(() {
      _boundaryPoints.removeLast();
    });
  }

  Future<void> _denViTriHienTai() async {
    try {
      final result = await LocationService.getViTriChinhXac();
      final pos = LatLng(result.latitude, result.longitude);
      setState(() {
        _markerPosition = pos;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: pos, zoom: 18),
        ),
      );
    } catch (e) {
      showThongBao(context, 'Không lấy được vị trí hiện tại: $e', isLoi: true);
    }
  }

  void _onSave() {
    if (_markerPosition == null) {
      showThongBao(context, 'Hãy chạm vào bản đồ để chọn vị trí.', isLoi: true);
      return;
    }

    String? polygon;
    if (_boundaryPoints.isNotEmpty) {
      final parts = _boundaryPoints
          .map((e) => '${e.latitude.toStringAsFixed(6)},${e.longitude.toStringAsFixed(6)}')
          .toList();
      polygon = parts.join(';');
    }

    Navigator.pop<Map<String, dynamic>>(context, {
      'lat': _markerPosition!.latitude,
      'lng': _markerPosition!.longitude,
      'polygon': polygon,
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{};
    if (_markerPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('center'),
          position: _markerPosition!,
        ),
      );
    }
    for (var i = 0; i < _boundaryPoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('boundary_$i'),
          position: _boundaryPoints[i],
        ),
      );
    }

    final polygons = <Polygon>{};
    if (_boundaryPoints.length >= 3) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('boundary'),
          points: _boundaryPoints,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.15),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí trên bản đồ'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              mapType: _mapType,
              markers: markers,
              polygons: polygons,
              onMapCreated: (c) => _mapController = c,
              onTap: _onMapTap,
              onLongPress: _onMapLongPress,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Cách sử dụng:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _mode == _MapMode.viTri
                      ? '- Chế độ CHỌN VỊ TRÍ.\n'
                        '- Chạm 1 lần lên bản đồ để chọn vị trí chính (marker).\n'
                        '- Có thể bấm \"Đến vị trí hiện tại\" để nhảy về GPS.'
                      : '- Chế độ CHỌN TỌA ĐỘ BIÊN.\n'
                        '- Nhấn và giữ (long press) để thêm các điểm quanh toà nhà (có thể nhiều hơn 4 điểm).\n'
                        '- Mỗi điểm sẽ được đánh dấu và vẽ đa giác theo đúng thứ tự bạn chọn.',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _setMode(_MapMode.viTri),
                        child: const Text('Chế độ: Vị trí'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _setMode(_MapMode.bien),
                        child: const Text('Chế độ: Tọa độ biên'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _denViTriHienTai,
                  child: const Text('GPS hiện tại'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _undoLastBoundaryPoint,
                  child: const Text('Undo tọa độ biên'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _onToggleMapType(MapType.normal),
                        child: const Text('Bản đồ'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _onToggleMapType(MapType.satellite),
                        child: const Text('Vệ tinh'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Lưu vị trí'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

