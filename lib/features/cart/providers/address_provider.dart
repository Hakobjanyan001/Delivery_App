import 'package:flutter/material.dart';
import '../../../core/models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final List<AddressModel> _addresses = [];
  String? _selectedAddressId;

  List<AddressModel> get addresses => [..._addresses];
  String? get selectedAddressId => _selectedAddressId;

  AddressModel? get selectedAddress {
    if (_selectedAddressId == null) return null;
    try {
      return _addresses.firstWhere((addr) => addr.id == _selectedAddressId);
    } catch (_) {
      return null;
    }
  }

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  void addAddress(String title, String address, {double? lat, double? lng, String? entrance, String? floor, String? apartment}) {
    final newAddress = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Այլ' : title,
      address: address,
      latitude: lat,
      longitude: lng,
      entrance: entrance,
      floor: floor,
      apartment: apartment,
    );
    _addresses.add(newAddress);
    _selectedAddressId = newAddress.id;
    notifyListeners();
  }

  void updateAddressDetails(String id, {String? address, double? lat, double? lng, String? entrance, String? floor, String? apartment}) {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      final old = _addresses[index];
      _addresses[index] = AddressModel(
        id: old.id,
        title: old.title,
        address: address ?? old.address,
        latitude: lat ?? old.latitude,
        longitude: lng ?? old.longitude,
        entrance: entrance ?? old.entrance,
        floor: floor ?? old.floor,
        apartment: apartment ?? old.apartment,
      );
      notifyListeners();
    }
  }

  void updateAddressCoordinates(String id, double lat, double lng) {
    updateAddressDetails(id, lat: lat, lng: lng);
  }

  void removeAddress(String id) {
    _addresses.removeWhere((addr) => addr.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    notifyListeners();
  }
}
