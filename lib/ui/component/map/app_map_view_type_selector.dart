import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

class AppMapViewTypeSelector extends StatelessWidget {
  const AppMapViewTypeSelector({
    required this.currentViewType,
    required this.onViewTypeChanged,
    super.key,
  });

  final MapViewType currentViewType;
  final void Function(MapViewType) onViewTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: MapViewType.values.map((type) {
          final isSelected = type == currentViewType;
          return Expanded(
            child: GestureDetector(
              onTap: () => onViewTypeChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF1A73E8) : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: type == MapViewType.detail
                        ? const Radius.circular(12)
                        : Radius.zero,
                    right: type == MapViewType.world
                        ? const Radius.circular(12)
                        : Radius.zero,
                  ),
                ),
                child: Text(
                  _getLabel(type, l10n),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(MapViewType type, L10n l10n) {
    switch (type) {
      case MapViewType.detail:
        return l10n.mapViewTypeRecord;
      case MapViewType.japan:
        return l10n.mapViewTypeJapan;
      case MapViewType.world:
        return l10n.mapViewTypeWorld;
    }
  }
}
