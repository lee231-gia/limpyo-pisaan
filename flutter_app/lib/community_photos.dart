import 'package:flutter/material.dart';
import 'ui.dart';

class CommunityPhoto {
  final String file, caption;
  const CommunityPhoto(this.file, this.caption);
  String get asset => 'assets/community/$file';
}

const communityPhotos = [
  CommunityPhoto(
    'discarded-tires-electronics.jpg',
    'Discarded tires, television casings, and scrap materials.',
  ),
  CommunityPhoto(
    'roadside-litter.jpg',
    'Scattered litter along a roadside embankment.',
  ),
  CommunityPhoto(
    'scrap-beside-store.jpg',
    'Metal sheets and discarded materials beside a store.',
  ),
  CommunityPhoto(
    'roadside-shared-space.jpg',
    'A roadside shared space with trees and loose materials.',
  ),
  CommunityPhoto(
    'ash-beside-concrete.jpg',
    'Ash and scattered waste beside a concrete slab.',
  ),
  CommunityPhoto(
    'burned-waste-slope.jpg',
    'Burned waste and wrappers on a vegetated slope.',
  ),
  CommunityPhoto(
    'litter-in-drain.jpg',
    'Wrappers, leaves, and debris in an open drain.',
  ),
  CommunityPhoto(
    'separated-glass-bottles.jpg',
    'Glass bottles kept together in a crate beside sacks.',
  ),
];

class PhotoCard extends StatelessWidget {
  final CommunityPhoto photo;
  final bool caption;
  const PhotoCard(this.photo, {super.key, this.caption = true});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        button: true,
        label: 'View photo: ${photo.caption}',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showDialog<void>(
            context: context,
            useSafeArea: true,
            builder: (context) => Dialog.fullscreen(
              backgroundColor: const Color(0xFF14251C),
              child: SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Close photo',
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    Expanded(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Center(
                          child: Image.asset(
                            photo.asset,
                            semanticLabel: photo.caption,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        photo.caption,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    photo.asset,
                    fit: BoxFit.cover,
                    cacheWidth: 1200,
                    excludeFromSemantics: true,
                  ),
                ),
                const Positioned(
                  right: 10,
                  bottom: 10,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xB314251C),
                    child: Icon(
                      Icons.open_in_full,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (caption) ...[
        space(10),
        Text(
          photo.caption,
          style: const TextStyle(color: muted, fontSize: 11, height: 1.6),
        ),
      ],
    ],
  );
}
