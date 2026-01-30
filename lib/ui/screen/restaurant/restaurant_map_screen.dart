import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/theme/style/restaurant_style.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class RestaurantMapScreen extends StatefulWidget {
  const RestaurantMapScreen({
    required this.restaurant,
    super.key,
  });

  final Restaurant restaurant;

  @override
  State<RestaurantMapScreen> createState() => _RestaurantMapScreenState();
}

class _RestaurantMapScreenState extends State<RestaurantMapScreen> {
  MapLibreMapController? _mapController;
  bool _isPinAdded = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _addPin() async {
    if (_mapController == null || _isPinAdded) {
      return;
    }

    final data = await rootBundle.load(Assets.image.pin.path);
    final bytes = data.buffer.asUint8List();
    await _mapController!.addImage('restaurant_pin', bytes);
    await _mapController!.addSymbol(
      SymbolOptions(
        geometry: LatLng(widget.restaurant.lat, widget.restaurant.lng),
        iconImage: 'restaurant_pin',
        iconSize: 0.6,
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _isPinAdded = true;
    });
  }

  String _getLocalizedStyle() {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'ja':
        return Assets.map.earthJa;
      default:
        return Assets.map.earthEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _addPin();
            },
            onStyleLoadedCallback: _addPin,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.restaurant.lat, widget.restaurant.lng),
              zoom: 17,
            ),
            styleString: _getLocalizedStyle(),
            trackCameraPosition: true,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant,
                          size: 20,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.restaurant.name,
                            style: RestaurantStyle.name(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.restaurant.address.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.place,
                            size: 16,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.restaurant.address,
                              style: RestaurantStyle.address().copyWith(
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // RestaurantScreenに戻る際にrestaurantを渡す
                    context.pop(widget.restaurant);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    Translations.of(context).done,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
