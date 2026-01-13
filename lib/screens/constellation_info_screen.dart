import 'package:flutter/material.dart';

/// ConstellationInfoScreen
/// ----------------------
/// Displays educational information about a constellation.
///
/// Data is STATIC and keyed by constellation ID.
/// No astronomy or sensor logic here.
class ConstellationInfoScreen extends StatelessWidget {
  final String id;

  const ConstellationInfoScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final data = _constellationData[id] ?? _unknownConstellation(id);

    return Scaffold(
      appBar: AppBar(
        title: Text(data.name),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Name
            Row(
              children: [
                Text(
                  data.symbol,
                  style: const TextStyle(
                    fontSize: 42,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _sectionTitle('Mythology'),
            _sectionText(data.mythology),

            const SizedBox(height: 20),

            _sectionTitle('Best Time to Observe'),
            _bulletList(data.bestMonths),

            const SizedBox(height: 20),

            _sectionTitle('Famous Stars'),
            _bulletList(data.famousStars),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '• $item',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// --------------------------------
/// Static constellation data
/// --------------------------------

class _ConstellationInfo {
  final String name;
  final String symbol;
  final String mythology;
  final List<String> bestMonths;
  final List<String> famousStars;

  const _ConstellationInfo({
    required this.name,
    required this.symbol,
    required this.mythology,
    required this.bestMonths,
    required this.famousStars,
  });
}

final Map<String, _ConstellationInfo> _constellationData = {
  'ursa_major': _ConstellationInfo(
    name: 'Saptarishi (Ursa Major)',
    symbol: '🌌',
    mythology:
    'In Indian astronomy, Ursa Major is known as Saptarishi — the Seven Great Sages: '
        'Atri, Bharadvaja, Gautama, Jamadagni, Kashyapa, Vasishtha, and Vishwamitra. '
        'They are regarded as eternal custodians of cosmic law (ṛta) and spiritual wisdom.\n\n'
        'Across different yugas, the Saptarishi are believed to guide humanity, '
        'preserve sacred knowledge, and re-establish dharma whenever it declines. '
        'The constellation’s slow apparent motion around the pole symbolises timelessness and continuity.\n\n'
        'In Greek mythology, Ursa Major represents Callisto, a nymph transformed into a bear by Hera out of jealousy. '
        'Zeus placed her among the stars to protect her, where she eternally circles the heavens.',
    bestMonths: ['March', 'April', 'May', 'June'],
    famousStars: [
      'Dubhe',
      'Merak',
      'Phecda',
      'Megrez',
      'Alioth',
      'Mizar',
      'Alkaid',
    ],
  ),


  'ursa_minor': _ConstellationInfo(
    name: 'Ursa Minor',
    symbol: '🧭',
    mythology:
    'Ursa Minor is closely associated with navigation and the concept of cosmic orientation. '
        'Its brightest star, Polaris, lies nearly aligned with Earth’s rotational axis, making it '
        'a fixed reference point in the sky.\n\n'
        'In Greek mythology, Ursa Minor is often identified as Arcas, the son of Callisto, '
        'placed in the heavens by Zeus to protect him.',
    bestMonths: ['Visible all year (Northern Hemisphere)'],
    famousStars: [
      'Polaris',
      'Kochab',
      'Pherkad',
      'Yildun',
      'Eta Ursae Minoris',
    ],
  ),

  'orion': _ConstellationInfo(
    name: 'Orion',
    symbol: '🏹',
    mythology:
    'Orion was a giant and mighty hunter in Greek mythology, famed for his strength and pride. '
        'His boasts of conquering all beasts angered Gaia, who sent a scorpion to kill him.\n\n'
        'After his death, Zeus placed Orion among the stars, where his figure dominates the winter sky. '
        'His belt, sword, and shoulders form one of the most recognizable celestial patterns.\n\n'
        'In Indian astronomy, Orion is associated with Mriga (the celestial deer). '
        'The belt stars are sometimes interpreted as the arrow of Prajapati, symbolizing desire, sacrifice, '
        'and cosmic order within Vedic symbolism.',
    bestMonths: ['December', 'January', 'February'],
    famousStars: [
      'Betelgeuse',
      'Rigel',
      'Bellatrix',
      'Saiph',
      'Mintaka',
      'Alnilam',
      'Alnitak',
    ],
  ),


  'gemini': _ConstellationInfo(
    name: 'Gemini',
    symbol: '♊',
    mythology:
    'Gemini represents the twins Castor and Pollux, born to the same mother but with different '
        'fates—Castor mortal and Pollux divine.\n\n'
        'When Castor died, Pollux begged Zeus to let them share immortality, resulting in the twins '
        'alternating between Olympus and the underworld, symbolizing eternal brotherhood.',
    bestMonths: ['January', 'February'],
    famousStars: [
      'Castor',
      'Pollux',
      'Alhena',
      'Wasat',
      'Mebsuta',
    ],
  ),

  'canis_major': _ConstellationInfo(
    name: 'Canis Major',
    symbol: '🐕',
    mythology:
    'Canis Major represents the larger hunting dog of Orion, faithfully following the hunter '
        'across the heavens.\n\n'
        'Its brightest star, Sirius, was of immense importance in ancient Egypt, where its heliacal '
        'rising marked the annual flooding of the Nile and symbolized rebirth and renewal.',
    bestMonths: ['December', 'January', 'February'],
    famousStars: [
      'Sirius',
      'Adhara',
      'Wezen',
      'Aludra',
      'Mirzam',
    ],
  ),

  'lyra': _ConstellationInfo(
    name: 'Lyra',
    symbol: '🎶',
    mythology:
    'Lyra represents the lyre of Orpheus, whose music was said to charm animals, trees, and even stones.\n\n'
        'After Orpheus’s death, Zeus placed his lyre among the stars, honoring the power of art and music '
        'to transcend mortality.',
    bestMonths: ['June', 'July', 'August'],
    famousStars: [
      'Vega',
      'Sheliak',
      'Sulafat',
      'Delta Lyrae',
      'Epsilon Lyrae (Double Double)',
    ],
  ),

  'cassiopeia': _ConstellationInfo(
    name: 'Cassiopeia',
    symbol: '👑',
    mythology:
    'Cassiopeia was a proud queen who claimed her beauty surpassed that of the sea nymphs. '
        'Her arrogance angered Poseidon, leading to her punishment.\n\n'
        'She was placed in the sky, tied to a throne, forever circling the celestial pole—sometimes upside down—'
        'as a warning against vanity.',
    bestMonths: ['October', 'November', 'December'],
    famousStars: [
      'Schedar',
      'Caph',
      'Gamma Cassiopeiae',
      'Ruchbah',
      'Segin',
    ],
  ),

  'cygnus': _ConstellationInfo(
    name: 'Cygnus',
    symbol: '🦢',
    mythology:
    'Cygnus is associated with the swan, often linked to Zeus or to the musician Orpheus in different myths.\n\n'
        'It lies along the Milky Way and forms the famous Northern Cross asterism, making it rich in stars '
        'and deep-sky objects.',
    bestMonths: ['June', 'July', 'August', 'September'],
    famousStars: [
      'Deneb',
      'Albireo',
      'Sadr',
      'Gienah',
      'Delta Cygni',
    ],
  ),

  'scorpius': _ConstellationInfo(
    name: 'Scorpius',
    symbol: '🦂',
    mythology:
    'Scorpius represents the scorpion sent by Gaia or Artemis to punish Orion for his arrogance.\n\n'
        'To prevent further conflict, Zeus placed Scorpius opposite Orion in the sky, ensuring they '
        'never rise at the same time.',
    bestMonths: ['May', 'June', 'July'],
    famousStars: [
      'Antares',
      'Shaula',
      'Sargas',
      'Dschubba',
      'Acrab',
    ],
  ),

  'leo': _ConstellationInfo(
    name: 'Leo',
    symbol: '🦁',
    mythology:
    'Leo represents the Nemean Lion, a fearsome beast slain by Hercules as part of his first labor.\n\n'
        'The lion’s impenetrable hide symbolized invincibility, and its placement in the sky commemorates '
        'strength, courage, and triumph over adversity.',
    bestMonths: ['March', 'April', 'May'],
    famousStars: [
      'Regulus',
      'Denebola',
      'Algieba',
      'Zosma',
      'Chertan',
    ],
  ),

  'taurus': _ConstellationInfo(
    name: 'Taurus',
    symbol: '🐂',
    mythology:
    'Taurus represents the bull that Zeus transformed into to abduct Europa.\n\n'
        'The constellation is one of the oldest known, deeply significant in ancient agricultural societies '
        'and home to the Pleiades and Hyades star clusters.',
    bestMonths: ['November', 'December', 'January'],
    famousStars: [
      'Aldebaran',
      'Elnath',
      'Hyades',
      'Pleiades',
      'Prima Hyadum',
    ],
  ),
};

_ConstellationInfo _unknownConstellation(String id) {
  return _ConstellationInfo(
    name: id,
    symbol: '✨',
    mythology:
    'No detailed mythology is available for this constellation yet.',
    bestMonths: ['Unknown'],
    famousStars: [],
  );
}
