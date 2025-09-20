import 'package:flutter/material.dart';
import '../../models/Commande.dart';

class CommandeSwipeItem extends StatefulWidget {
  final Commande commande;
  final VoidCallback onDeleteClick;
  final VoidCallback onFicheClick;
  final VoidCallback onDuplicateClick;
  final Widget content;

  const CommandeSwipeItem({
    super.key,
    required this.commande,
    required this.onDeleteClick,
    required this.onFicheClick,
    required this.onDuplicateClick,
    required this.content,
  });

  @override
  State<CommandeSwipeItem> createState() => _CommandeSwipeItemState();
}

class _CommandeSwipeItemState extends State<CommandeSwipeItem> {
  double offsetX = 0;
  final double maxSwipe = 180;
  final GlobalKey _cardKey = GlobalKey();
  double cardHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 🌈 Boutons derrière la carte, arrondis et même hauteur
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      color: const Color(0xFF000000),
                      //                      color: const Color(0xFFFFE8D1),
                      icon: Icons.content_copy,
                      iconColor: const Color(0xFFFFC107),
                      onTap: widget.onDuplicateClick,
                      height: cardHeight,
                    ),
                    _ActionButton(
                      color: const Color(0xFFFFC107),
                      icon: Icons.description,
                      onTap: widget.onFicheClick,
                      height: cardHeight,
                    ),
                    _ActionButton(
                      color: const Color(0xFFDC3B3B),
                      icon: Icons.delete,
                      onTap: widget.onDeleteClick,
                      height: cardHeight,
                    ),
                  ],
                ),
              ),

              // 🟦 Carte devant (foreground)
              Transform.translate(
                offset: Offset(offsetX, 0),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      offsetX += details.delta.dx;
                      offsetX = offsetX.clamp(-maxSwipe, 0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      if (offsetX > -maxSwipe * 0.5) {
                        offsetX = 0;
                      } else {
                        offsetX = -maxSwipe;
                      }
                    });
                  },
                  child: ClipRRect(
                    key: _cardKey,
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_cardKey.currentContext != null) {
                            final h =
                                _cardKey.currentContext!.size?.height ?? 0;
                            if (cardHeight != h) setState(() => cardHeight = h);
                          }
                        });
                        return Container(
                          color: Colors.white,
                          child: widget.content,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final double height;

  const _ActionButton({
    required this.color,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: height,
      color: color,
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
