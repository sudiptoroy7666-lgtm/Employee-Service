import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';

class OfficeMapCard extends StatelessWidget {
  const OfficeMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const officeLocation = LatLng(ApiConfig.officeLatitude, ApiConfig.officeLongitude);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.location_on_outlined, size: 17, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Office Location', style: theme.textTheme.titleSmall),
                      Text(
                        'Check-in radius: 50 meters',
                        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: officeLocation,
                  initialZoom: 16.5,
                  interactionOptions: InteractionOptions(
                    flags: ~InteractiveFlag.all, // Disable gestures for cleaner look
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.softzen.workpulse',
                  ),
                  // Geofence radius circle (50m)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: officeLocation,
                        radius: 50,
                        useRadiusInMeter: true,
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderColor: AppColors.primary.withValues(alpha: 0.5),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                  // Office pin
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: officeLocation,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer address
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.infoBg.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'House 41, Road 13, Block D, Banani, Dhaka 1213',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}