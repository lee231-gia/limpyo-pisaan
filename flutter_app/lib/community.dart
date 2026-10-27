import 'package:flutter/material.dart';
import 'state.dart';
import 'ui.dart';
import 'community_photos.dart';
import 'showcase_authoring.dart';

class CommunityPost {
  final String tag, date, title, summary, body;
  final List<String> tips;
  const CommunityPost(
    this.tag,
    this.date,
    this.title,
    this.summary,
    this.body,
    this.tips,
  );
}

const posts = [
  CommunityPost(
    'SHOWCASE',
    'COMMUNITY VOICES',
    'Naunsa naman ni atong palibot? 😩',
    'Magtinabangay ta sa paglimpyo sa atong palibot.',
    "Daghan na kaayog basura nga nagkatag. Unta magtinabangay ta sa paglimpyo kay kita ra gihapon ang maapektuhan ani. Let's keep our community clean! 🌿",
    [],
  ),
  CommunityPost(
    'SHOWCASE',
    'GOOD EXAMPLE',
    'Ing-ani unta, guys! ♻️',
    'Simple ra kaayo pero dako na kaayog tabang.',
    'Instead nga ilabay bisan asa, atong tigomon ug i-separate ang mga empty bottles. Simple ra kaayo pero dako na kaayog tabang sa environment. Keep it up!',
    [],
  ),
  CommunityPost(
    'EDUCATIONAL',
    'WASTE SEGREGATION',
    'Kabalo ba mo? 🌱',
    'Dili tanan basura parehas! Sugdi nato sa atong balay!',
    'Dili tanan basura parehas!\n\nSegregate your waste properly. Sugdi nato sa atong balay!',
    [
      'Biodegradable – food scraps, leaves',
      'Recyclable – bottles, cans, paper',
      'Residual – wrappers, sachets',
    ],
  ),
  CommunityPost(
    'EDUCATIONAL',
    'PROPER DISPOSAL',
    "Ayaw ta'g sunog ug basura! 🚫",
    'Mas maayo nga mag-segregate ug sundon ang proper disposal.',
    'Ang pagsunog sa plastic ug uban pang basura makadaot sa atong health ug environment. Mas maayo nga mag-segregate ug sundon ang proper disposal.',
    [],
  ),
  CommunityPost(
    'ANNOUNCEMENT',
    'DRAINAGE',
    'Atong kanal, atong responsibilidad! 💚',
    "Let's keep our drainage clean!",
    "Mga silingan, please ayaw paglabay ug basura sa kanal. Kung mabara ni, posible magbaha kung kusog ang ulan. Let's keep our drainage clean!",
    [],
  ),
  CommunityPost(
    'EDUCATIONAL',
    'MINI GUIDE',
    'How to Dispose of Waste Properly ♻️',
    'Gamay nga effort, dakong tabang sa atong komunidad!',
    'Gamay nga effort, dakong tabang sa atong komunidad!',
    [
      '1. Separate biodegradable, recyclable, and residual waste.',
      '2. Wash and dry recyclable bottles.',
      '3. Secure garbage bags before collection.',
      '4. Never burn or dump waste.',
      '5. Follow barangay collection schedules.',
    ],
  ),
  CommunityPost(
    'SHOWCASE',
    'OLD TIRES & SCRAP',
    'Hala oy, mura naman ug junkyard! 😭',
    'Unta mahipos ug ma-dispose ni properly.',
    'Daghan kaayog old tires, yero, ug guba nga gamit nga nagkatag. Delikado ni labi na sa mga bata. Unta mahipos ug ma-dispose ni properly.',
    [],
  ),
  CommunityPost(
    'COMMUNITY REMINDER',
    'CLEANLINESS',
    'Limpyo nga Pisaan, responsibility natong tanan! 🌿',
    'Small actions make a cleaner community!',
    'Dili kinahanglan maghulat ug clean-up drive para manglimpyo. Sugdi lang sa paghipos sa kaugalingong basura. Small actions make a cleaner community!',
    [],
  ),
];
const postPhotoIndexes = [1, 7, 7, 4, 6, 7, 0, 3];

class HomePage extends StatelessWidget {
  final AppState state;
  final OpenPage open;
  const HomePage({super.key, required this.state, required this.open});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      eyebrow('OUR PLACE. OUR SHARED CARE.'),
      space(12),
      Row(
        children: [
          Flexible(
            child: Text(
              'Hello, ${state.name.split(' ').first}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 9),
          const Icon(Icons.eco_outlined, color: Color(0xFF8DA578), size: 24),
        ],
      ),
      space(8),
      const Text(
        'Let’s keep our community a little cleaner, together.',
        style: TextStyle(color: muted, fontSize: 12),
      ),
      space(24),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: pale,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eyebrow('WELCOME TO LIMPYO PISAAN'),
                  space(18),
                  Text(
                    'A cleaner community\nstarts with us.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  space(14),
                  const Text(
                    'Stay informed. Dispose with care.\nHelp make Purok 3 a place we’re proud to call home.',
                    style: TextStyle(color: muted, fontSize: 12, height: 1.8),
                  ),
                  space(20),
                  FilledButton.icon(
                    onPressed: () => open('updates'),
                    label: const Text(
                      'Explore community updates',
                      style: TextStyle(fontSize: 11),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 17),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/community.png',
              width: double.infinity,
              height: 155,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
      const SectionTitle('How can we help today?'),
      MenuCard(
        icon: Icons.feed_outlined,
        title: 'Community Updates',
        subtitle: 'Notices, reminders, and stories from our neighborhood.',
        onTap: () => open('updates'),
      ),
      MenuCard(
        icon: Icons.local_shipping_outlined,
        title: 'Collection Information',
        subtitle: 'Collection schedules and drop-off locations.',
        onTap: () => open('collection'),
      ),
      MenuCard(
        icon: Icons.edit_note_outlined,
        title: 'Report an Issue',
        subtitle: 'Share a waste-related concern in a few simple steps.',
        onTap: () => open('report'),
      ),
      SectionTitle(
        'Latest in the community',
        action: TextButton(
          onPressed: () => open('updates'),
          child: const Text('View all', style: TextStyle(fontSize: 11)),
        ),
      ),
      for (var i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => open('post:$i'),
            borderRadius: BorderRadius.circular(13),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  IconTile(i == 0 ? Icons.feed_outlined : Icons.grass_outlined),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${posts[i].tag} · ${posts[i].date}',
                          style: const TextStyle(color: muted, fontSize: 8),
                        ),
                        space(7),
                        Text(
                          posts[i].title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 17, color: muted),
                ],
              ),
            ),
          ),
        ),
      space(10),
      Surface(
        color: pale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            eyebrow('A LITTLE EVERYDAY CARE'),
            space(18),
            Text(
              'Small habits.\nCleaner surroundings.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            space(12),
            const Text(
              'Separate waste at home. Keep recyclables clean and dry.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            space(10),
            TextButton.icon(
              onPressed: () => open('guide'),
              label: const Text(
                'Explore the Waste Guide',
                style: TextStyle(fontSize: 11),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
            ),
          ],
        ),
      ),
    ],
  );
}

class UpdatesPage extends StatefulWidget {
  final OpenPage open;
  final AppState state;
  const UpdatesPage({super.key, required this.open, required this.state});
  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  bool showcase = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showcase =
        PageStorage.maybeOf(
              context,
            )?.readState(context, identifier: 'showcase-tab')
            as bool? ??
        showcase;
  }

  void select(bool value) {
    PageStorage.maybeOf(
      context,
    )?.writeState(context, value, identifier: 'showcase-tab');
    setState(() => showcase = value);
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const PageHeading(
        'Community Updates',
        subtitle: 'Good to know. Good to share.',
      ),
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: pale,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            for (final tab in [false, true])
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: showcase == tab
                        ? Colors.white
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: () => select(tab),
                  child: Text(
                    tab ? 'Showcase' : 'Announcements',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
      space(17),
      Text(
        showcase
            ? 'Ideas and practical steps for a cleaner neighborhood.'
            : 'Stay informed with community notices and reminders.',
        style: const TextStyle(color: muted, fontSize: 11, height: 1.8),
      ),
      space(22),
      if (!showcase)
        for (final i in [2, 3, 4, 5, 7])
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: InkWell(
              onTap: () => widget.open('post:$i'),
              borderRadius: BorderRadius.circular(16),
              child: Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Tag(posts[i].tag),
                        Text(
                          posts[i].date,
                          style: const TextStyle(fontSize: 10, color: muted),
                        ),
                      ],
                    ),
                    space(18),
                    const Text(
                      'Community information',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                    space(13),
                    Text(
                      posts[i].title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        letterSpacing: -.4,
                      ),
                    ),
                    space(12),
                    Text(
                      posts[i].summary,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    space(23),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Read post',
                          style: TextStyle(
                            color: green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.arrow_forward, size: 17, color: green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      if (showcase) ...[
        FilledButton.icon(
          onPressed: () async {
            final added = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => AddShowcasePage(state: widget.state),
              ),
            );
            if (added == true && context.mounted) setState(() {});
          },
          icon: const Icon(Icons.add),
          label: const Text('Add showcase'),
        ),
        space(20),
        for (final entry in widget.state.showcases) ...[
          InkWell(
            onTap: () => widget.open('resident:${entry.id}'),
            child: Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.photo != null) ...[
                    localPhoto(entry.photo),
                    space(16),
                  ],
                  const Tag('COMMUNITY STORY'),
                  space(12),
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  space(10),
                  Text(
                    entry.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  space(12),
                  Text(
                    '${entry.author} · ${entry.date}',
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          space(18),
        ],
        for (final i in [0, 1, 6]) ...[
          InkWell(
            onTap: () => widget.open('post:$i'),
            child: Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PhotoCard(
                    communityPhotos[postPhotoIndexes[i]],
                    caption: false,
                  ),
                  space(20),
                  Tag(posts[i].date),
                  space(14),
                  Text(
                    posts[i].title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  space(12),
                  Text(
                    posts[i].summary,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  space(16),
                  const Text(
                    'See the story →',
                    style: TextStyle(color: green, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          space(18),
        ],
      ],
    ],
  );
}

class PostPage extends StatelessWidget {
  final int index;
  final VoidCallback back;
  const PostPage({super.key, required this.index, required this.back});
  @override
  Widget build(BuildContext context) {
    final post = posts[index.clamp(0, posts.length - 1)];
    return PageBody(
      children: [
        PageHeading(
          post.tag == 'SHOWCASE' ? 'Community showcase' : 'Community update',
          back: back,
        ),
        Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tag(post.tag),
              space(20),
              Text(post.title, style: Theme.of(context).textTheme.titleLarge),
              space(17),
              Text(
                post.date,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
              space(24),
              PhotoCard(
                communityPhotos[postPhotoIndexes[index.clamp(
                  0,
                  posts.length - 1,
                )]],
              ),
              space(24),
              Text(
                post.body,
                style: const TextStyle(fontSize: 13, height: 1.8),
              ),
              space(20),
              for (final tip in post.tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: TextStyle(color: green)),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 12, height: 1.7),
                        ),
                      ),
                    ],
                  ),
                ),
              if (index == 0) ...[
                const SectionTitle('Around our shared spaces'),
                for (final photo in [0, 2, 3, 6, 4, 5]) ...[
                  PhotoCard(communityPhotos[photo]),
                  space(24),
                ],
              ],
              space(10),
              const Notice(
                'Keep recyclables clean and dry, and keep waste away from drains.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommunityMap extends StatelessWidget {
  const CommunityMap({super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Container(
      height: 210,
      color: pale,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            Positioned(
              left: box.maxWidth * .10,
              top: 25,
              child: Container(
                width: box.maxWidth * .3,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFB4C4A0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD7E0CA), width: 9),
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                width: box.maxWidth * .32,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFA4BA8B),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Positioned(
              left: box.maxWidth * .45,
              top: 0,
              bottom: 0,
              child: Container(width: 23, color: Colors.white),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 115,
              child: Container(height: 22, color: Colors.white),
            ),
            Positioned(
              left: box.maxWidth * .24,
              top: 65,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: green,
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            Positioned(
              right: box.maxWidth * .15,
              bottom: 40,
              child: const CircleAvatar(
                radius: 17,
                backgroundColor: green,
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const Positioned(
              left: 10,
              bottom: 8,
              child: Text(
                'PUROK 3 · BARANGAY PISAAN',
                style: TextStyle(fontSize: 8, color: muted),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CollectionPage extends StatelessWidget {
  final OpenPage open;
  const CollectionPage({super.key, required this.open});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const PageHeading(
        'Collection Information',
        subtitle: 'A little clarity for your everyday disposal.',
      ),
      const Notice(
        'Prepare for collection\nSeparate your waste and tie bags securely before collection.',
        icon: Icons.schedule_outlined,
      ),
      Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collection schedule',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            space(12),
            const Tag('WEEKLY COLLECTION'),
            space(20),
            for (final item in [
              ('Collection day', 'Monday'),
              ('Collection time', '8:00 AM'),
              ('Service area', 'Upper Pisaan'),
              ('Update window', '11:00 AM'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.$1,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        item.$2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
            const Text(
              'Keep waste contained and leave pathways clear.',
              style: TextStyle(fontSize: 10, color: muted, height: 1.7),
            ),
          ],
        ),
      ),
      const SectionTitle('Drop-off locations'),
      const CommunityMap(),
      space(17),
      MenuCard(
        icon: Icons.location_on_outlined,
        title: 'Community drop-off point',
        subtitle:
            'Location details await barangay confirmation.\nView details →',
        onTap: () => open('dropoff'),
      ),
      space(12),
      const Notice(
        'Keep waste contained and share collection updates with neighbors who do not have a phone.',
        icon: Icons.menu_book_outlined,
      ),
    ],
  );
}

class DropoffPage extends StatelessWidget {
  final VoidCallback back;
  const DropoffPage({super.key, required this.back});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      PageHeading('Drop-off details', back: back),
      Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Tag('DROP-OFF LOCATION'),
            space(20),
            Text(
              'Community drop-off point',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            space(22),
            const CommunityMap(),
            space(25),
            detail('Address / landmark', 'Purok 3 · Lower Pisaan'),
            detail('Accepted waste', 'Plastic bottles · clean and dry'),
            detail('Operating hours', '8:00 AM – 11:00 AM'),
            const Notice(
              'Bring clean, dry plastic bottles and keep different waste types separated.',
            ),
          ],
        ),
      ),
    ],
  );
}
