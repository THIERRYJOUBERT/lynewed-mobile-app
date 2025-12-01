import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// Bouton de retour standard pour la map
class MapBackButton extends StatelessWidget {
  const MapBackButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20.0,
        ),
        padding: EdgeInsets.zero,
        tooltip: 'Back',
      ),
    );
  }
}

/// Bouton de géolocalisation standard
class MapLocationButton extends StatelessWidget {
  const MapLocationButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(8.0), // Carré arrondi comme design system
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 24.0,
              ),
        padding: EdgeInsets.zero,
        tooltip: 'My Location',
      ),
    );
  }
}

/// Boutons de zoom (Plus/Moins)
class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildZoomButton(Icons.add, onZoomIn),
        const SizedBox(height: 8),
        _buildZoomButton(Icons.remove, onZoomOut),
      ],
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24.0,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
