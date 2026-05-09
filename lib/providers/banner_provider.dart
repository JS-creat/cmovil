import 'package:flutter/material.dart';
import 'package:lucky/models/banner_model.dart';
import 'package:lucky/services/banner_service.dart';

class BannerProvider extends ChangeNotifier {
  final BannerService _bannerService = BannerService();

  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _banners = await _bannerService.obtenerBanners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  BannerModel? getBannerPorId(int id) {
    try {
      return _banners.firstWhere((banner) => banner.id == id);
    } catch (e) {
      return null;
    }
  }
}
