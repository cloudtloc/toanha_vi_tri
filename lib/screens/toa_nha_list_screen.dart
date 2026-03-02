import 'package:flutter/material.dart';

import '../models/toa_nha.dart';
import '../services/toa_nha_api_service.dart';
import '../utils/app_snackbar.dart';
import 'toa_nha_form_screen.dart';

class ToaNhaListScreen extends StatefulWidget {
  const ToaNhaListScreen({super.key});

  @override
  State<ToaNhaListScreen> createState() => _ToaNhaListScreenState();
}

class _ToaNhaListScreenState extends State<ToaNhaListScreen> {
  List<ToaNhaViTri> _list = [];
  bool _loading = true;
  String? _error;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ToaNhaApiService.getDanhSach();
      setState(() {
        _list = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _xoaViTri(ToaNhaViTri item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa vi tri'),
        content: Text(
            'Xoa vi tri (KinhDo, ViDo, ToaDoBien) cua toa nha "${item.tenToaNha ?? item.maToaNha ?? item.id}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ToaNhaApiService.xoaViTri(item.id);
      if (mounted) {
        showThongBao(context, 'Da xoa vi tri');
        _load();
      }
    } catch (e) {
      if (mounted) {
        showThongBao(context, 'Loi: $e', isLoi: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vi tri toa nha'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _load,
            child: const Text('Tai lai'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (ctx) => const ToaNhaFormScreen(),
            ),
          );
          if (created == true) _load();
        },
        child: const Text('Them'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Thu lai'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (_list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text('Chua co toa nha nao')),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: _list.length,
      itemBuilder: (context, index) {
        final item = _list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item.tenToaNha ?? item.maToaNha ?? 'ID ${item.id}'),
            subtitle: Text(
              item.tenChiTiet ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.coViTri)
                  Text(
                    'Vi do: ${item.viDo?.toStringAsFixed(4) ?? "-"}, Kinh do: ${item.kinhDo?.toStringAsFixed(4) ?? "-"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'sua') {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ToaNhaFormScreen(toaNha: item),
                        ),
                      );
                      if (updated == true) _load();
                    } else if (value == 'cap_nhat_vi_tri') {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ToaNhaFormScreen(
                            toaNha: item,
                            chiCapNhatViTri: true,
                          ),
                        ),
                      );
                      if (updated == true) _load();
                    } else if (value == 'xoa_vi_tri') {
                      await _xoaViTri(item);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'sua',
                      child: Text('Sua toa nha'),
                    ),
                    const PopupMenuItem(
                      value: 'cap_nhat_vi_tri',
                      child: Text('Cap nhat vi tri'),
                    ),
                    const PopupMenuItem(
                      value: 'xoa_vi_tri',
                      child: Text('Xoa vi tri'),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ToaNhaFormScreen(toaNha: item),
                ),
              );
              if (updated == true) _load();
            },
          ),
        );
      },
    );
  }
}
