// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class PortfolioGrid extends StatelessWidget {
  const PortfolioGrid({
    super.key,
    this.width,
    this.height,
    required this.portfolioImages,
    required this.proDetails,
  });

  final double? width;
  final double? height;
  final List<String> portfolioImages;
  final ProDetailsStruct proDetails;

  @override
  Widget build(BuildContext context) {
    // Use V2 images if available, otherwise fallback to legacy
    final hasV2 = proDetails.hasPortfolioImagesV2();
    final v2Images = proDetails.portfolioImagesV2;
    
    // For grid display: use crop_3x4 from V2, or legacy URLs
    final displayUrls = hasV2
        ? v2Images.take(4).map((img) => img.crop3x4).where((url) => url.isNotEmpty).toList()
        : portfolioImages.take(4).toList();
    
    // For fullscreen: use crop_9x16 from V2, or same as display
    final fullscreenUrls = hasV2
        ? v2Images.map((img) => img.crop9x16.isNotEmpty ? img.crop9x16 : img.crop3x4).toList()
        : portfolioImages;
    
    if (displayUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    // --- LOGIQUE DE CALCUL AUTOMATIQUE DE LA HAUTEUR ---

    // On récupère la largeur disponible passée par FlutterFlow (qui sera la largeur de l'écran si réglée à 100%).
    final double availableWidth = width ?? MediaQuery.of(context).size.width;

    // Vos paramètres de design
    const int crossAxisCount = 2;
    const double crossAxisSpacing = 6.0;
    const double mainAxisSpacing = 6.0;
    const double childAspectRatio = 0.78;

    // On calcule la largeur d'une seule image
    final double cellWidth =
        (availableWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
            crossAxisCount;

    // On calcule la hauteur d'une seule image en utilisant le ratio
    final double cellHeight = cellWidth / childAspectRatio;

    // On calcule la hauteur totale de la grille (2 rangées + 1 espacement vertical)
    final double totalGridHeight = (2 * cellHeight) + mainAxisSpacing;

    // --- FIN DE LA LOGIQUE DE CALCUL ---

    // On enveloppe notre GridView dans un Container qui a la hauteur EXACTE que nous venons de calculer.
    return SizedBox(
      width: availableWidth,
      height: totalGridHeight,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = displayUrls[index];

          return GestureDetector(
            onTap: () {
              // Navigate to fullscreen viewer with fullscreen URLs (crop_9x16)
              context.pushNamed(
                'PortfolioImageViewer',
                queryParameters: {
                  'portfolioImages': serializeParam(
                    fullscreenUrls,
                    ParamType.String,
                    isList: true,
                  ),
                  'initialIndex': serializeParam(
                    index,
                    ParamType.int,
                  ),
                  'proInfo': serializeParam(
                    proDetails,
                    ParamType.DataStruct,
                  ),
                }.withoutNulls,
                extra: <String, dynamic>{
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 40,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
