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
    symbol: '🐻',
    mythology:
    'In Indian astronomy, Ursa Major is known as Saptarishi — the seven great sages: '
        'Atri, Bharadvaja, Gautama, Jamadagni, Kashyapa, Vasishtha, and Vishwamitra. '
        'They are eternal guides of dharma and cosmic order.\n\n'
        'In Greek mythology, Ursa Major represents Callisto, a nymph transformed into a bear by Hera. '
        'Zeus placed her in the sky to protect her.',
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
    'Ursa Minor contains Polaris, the North Star. It has been used for navigation '
        'for thousands of years by sailors and travelers.\n\n'
        'In mythology, it is sometimes associated with Arcas, the son of Callisto.',
    bestMonths: ['Visible all year (Northern Hemisphere)'],
    famousStars: [
      'Polaris',
      'Kochab',
      'Pherkad',
    ],
  ),

  'orion': _ConstellationInfo(
    name: 'Orion',
    symbol: '🏹',
    mythology:
    'Orion was a mighty hunter in Greek mythology, placed in the sky by Zeus. '
        'His belt and sword make him one of the most recognizable constellations.\n\n'
        'In Indian astronomy, Orion is associated with Mriga (the celestial deer).',
    bestMonths: ['December', 'January', 'February'],
    famousStars: [
      'Betelgeuse',
      'Rigel',
      'Bellatrix',
      'Saiph',
    ],
  ),

  'gemini': _ConstellationInfo(
    name: 'Gemini',
    symbol: '♊',
    mythology:
    'Gemini represents the twins Castor and Pollux. Pollux was immortal, and '
        'Castor was mortal; Zeus united them in the sky so they could remain together.',
    bestMonths: ['January', 'February'],
    famousStars: [
      'Castor',
      'Pollux',
    ],
  ),

  'canis_major': _ConstellationInfo(
    name: 'Canis Major',
    symbol: '🐕',
    mythology:
    'Canis Major represents Orion’s hunting dog. It contains Sirius, '
        'the brightest star in the night sky.\n\n'
        'Sirius was sacred in ancient Egypt and associated with the flooding of the Nile.',
    bestMonths: ['December', 'January', 'February'],
    famousStars: [
      'Sirius',
      'Adhara',
      'Wezen',
    ],
  ),

  'lyra': _ConstellationInfo(
    name: 'Lyra',
    symbol: '🎶',
    mythology:
    'Lyra represents the lyre of Orpheus, the legendary musician whose music '
        'could charm all living things.\n\n'
        'It is a small but prominent constellation due to Vega.',
    bestMonths: ['June', 'July', 'August'],
    famousStars: [
      'Vega',
      'Sheliak',
      'Sulafat',
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
