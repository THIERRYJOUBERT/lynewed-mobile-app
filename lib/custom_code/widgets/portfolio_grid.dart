// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class PortfolioGrid extends StatelessWidget {
  const PortfolioGrid({
    Key? key,
    this.width,
    this.height,
    required this.portfolioImages,
    required this.proDetails,
  }) : super(key: key);

  final double? width;
  final double? height;
  final List<String> portfolioImages;
  final ProDetailsStruct proDetails;

  @override
  Widget build(BuildContext context) {
    final displayImages = portfolioImages.take(4).toList();
    if (displayImages.isEmpty) {
      return SizedBox.shrink();
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
    return Container(
      width: availableWidth,
      height: totalGridHeight,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        primary: false,
        // On enlève shrinkWrap, car le parent a maintenant une taille fixe.
        physics:
            const NeverScrollableScrollPhysics(), // La grille ne doit pas défiler.
        itemCount: displayImages.length,
        itemBuilder: (context, index) {
          final imageUrl = displayImages[index];

          return GestureDetector(
            onTap: () {
              // La logique de navigation reste inchangée et correcte
              context.pushNamed(
                'PortfolioImageViewer',
                queryParameters: {
                  'portfolioImages': serializeParam(
                    portfolioImages,
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
                  kTransitionInfoKey: TransitionInfo(
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
