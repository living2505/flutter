import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const QuoteAiApp());

class QuoteAiApp extends StatelessWidget {
  const QuoteAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Quote Generator',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const QuoteHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuoteHomePage extends StatefulWidget {
  const QuoteHomePage({super.key});

  @override
  _QuoteHomePageState createState() => _QuoteHomePageState();
}

class _QuoteHomePageState extends State<QuoteHomePage> {
  final TextEditingController _promptController = TextEditingController();
  final Random _rng = Random();
  String _generated = '';
  bool _loading = false;

  // Small corpus of inspirational quotes to train the tiny "AI".
  static const List<String> _corpus = [
    "The best way to get started is to quit talking and begin doing.",
    "Don't let yesterday take up too much of today.",
    "You learn more from failure than from success. Don't let it stop you. Failure builds character.",
    "It's not whether you get knocked down, it's whether you get up.",
    "If you are working on something that you really care about, you don't have to be pushed. The vision pulls you.",
    "People who are crazy enough to think they can change the world, are the ones who do.",
    "Failure will never overtake me if my determination to succeed is strong enough.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "You must be the change you wish to see in the world.",
    "Act as if what you do makes a difference. It does.",
    "Success usually comes to those who are too busy to be looking for it.",
    "The only limit to our realization of tomorrow is our doubts of today."
  ];

  // Markov chain map: word -> list of next words
  Map<String, List<String>> _markov = {};

  @override
  void initState() {
    super.initState();
    _buildMarkovChain();
    _generated = _seededGeneration("inspire");
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  // Build a simple word-level Markov chain from the corpus
  void _buildMarkovChain() {
    _markov = {};
    for (var line in _corpus) {
      final tokens = _tokenize(line);
      for (var i = 0; i < tokens.length; i++) {
        final w = tokens[i];
        final next = (i + 1 < tokens.length) ? tokens[i + 1] : "<END>";
        _markov.putIfAbsent(w, () => <String>[]).add(next);
      }
    }
    // Also add transitions from <START> token for random starts
    for (var line in _corpus) {
      final tokens = _tokenize(line);
      if (tokens.isNotEmpty) {
        _markov.putIfAbsent("<START>", () => <String>[]).add(tokens[0]);
      }
    }
  }

  List<String> _tokenize(String text) {
    // keep punctuation as separate tokens where appropriate
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final tokens = <String>[];
    final parts = cleaned.split(' ');
    for (var p in parts) {
      // preserve trailing punctuation (.,!) as separate token
      if (p.length > 1 && RegExp(r'[.,!?:;]$').hasMatch(p)) {
        tokens.add(p.substring(0, p.length - 1).toLowerCase());
        tokens.add(p.substring(p.length - 1));
      } else {
        tokens.add(p.toLowerCase());
      }
    }
    return tokens;
  }

  // Generate a sentence from Markov chain with an optional seed word
  String _generateMarkov({String? seed, int maxWords = 25}) {
    final sb = StringBuffer();
    String current;

    if (seed != null && seed.trim().isNotEmpty) {
      // use last token of seed if present in model, else random start
      final seedTokens = _tokenize(seed);
      current = seedTokens.isNotEmpty ? seedTokens.last : "<START>";
      if (!_markov.containsKey(current)) {
        // try first token
        current = seedTokens.isNotEmpty ? seedTokens.first : "<START>";
        if (!_markov.containsKey(current)) {
          current = "<START>";
        }
      }
    } else {
      current = "<START>";
    }

    int words = 0;
    while (words < maxWords) {
      final options = _markov[current] ?? _markov["<START>"] ?? <String>[];
      if (options.isEmpty) break;
      final next = options[_rng.nextInt(options.length)];
      if (next == "<END>") break;
      // formatting: if punctuation, append directly
      if (RegExp(r'^[\.,!?:;]$').hasMatch(next)) {
        sb.write(next);
      } else {
        if (sb.isNotEmpty && !sb.toString().endsWith(' ')) sb.write(' ');
        sb.write(_capitalizeIfStart(sb.isEmpty, next));
      }
      current = next;
      words++;
    }

    var out = sb.toString().trim();
    if (out.isEmpty) {
      out = _corpus[_rng.nextInt(_corpus.length)]; // fallback
    }
    // Ensure it ends with punctuation
    if (!RegExp(r'[.!?]$').hasMatch(out)) {
      out = '$out.';
    }
    // Capitalize first letter
    return out[0].toUpperCase() + out.substring(1);
  }

  String _capitalizeIfStart(bool isStart, String token) {
    if (isStart) {
      return token.isNotEmpty ? token[0].toUpperCase() + token.substring(1) : token;
    }
    return token;
  }

  // Combine Markov output with templates to make it feel more "AI-like"
  String _seededGeneration(String userSeed) {
    final seed = userSeed.trim(); // Removed redundant `?? ""`
    // slightly random template choices
    final templates = [
      "\"{quote}\" — Think about it.",
      "\"{quote}\" — Let this guide you.",
      "\"{quote}\"",
      "AI thought: {quote}",
      "A gentle reminder: {quote}"
    ];
    final markov = _generateMarkov(seed: seed, maxWords: 20);

    // small chance to merge two micro-sentences
    String merged = markov;
    if (_rng.nextDouble() < 0.25) {
      final extra = _generateMarkov(seed: '', maxWords: 10);
      merged = _combineSentences(markov, extra);
    }

    final template = templates[_rng.nextInt(templates.length)];
    final quote = template.replaceAll('{quote}', merged);
    return quote;
  }

  String _combineSentences(String a, String b) {
    // merge nicely if punctuation allows
    String aa = a.trim();
    if (aa.endsWith('.')) aa = aa.substring(0, aa.length - 1);
    String bb = b.trim();
    if (bb.isNotEmpty && bb[0] == bb[0].toLowerCase()) {
      bb = bb[0].toUpperCase() + bb.substring(1);
    }
    return "$aa, and $bb";
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
    });

    // Simulate "thinking" delay (very short)
    await Future.delayed(Duration(milliseconds: 300 + _rng.nextInt(400)));

    final seed = _promptController.text.trim();
    final generated = _seededGeneration(seed.isEmpty ? _randomSeed() : seed);

    setState(() {
      _generated = generated;
      _loading = false;
    });
  }

  String _randomSeed() {
    final seeds = ['life', 'success', 'failure', 'dream', 'change', 'focus', 'time', 'courage', 'learn'];
    return seeds[_rng.nextInt(seeds.length)];
  }

  void _copyToClipboard() {
    // DartPad environment may not allow clipboard directly; show snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote copied to clipboard (simulated).')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quote Generator (DartPad)'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Type a word or short prompt and press Generate.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: 'Prompt (e.g., "courage", "dream big")',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _promptController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _loading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome),
                    label: Text(_loading ? 'Generating...' : 'Generate Quote'),
                    onPressed: _loading ? null : _generate,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Random'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]), // Corrected `primary` to `backgroundColor`
                  onPressed: _loading
                      ? null
                      : () {
                          _promptController.clear();
                          _generate();
                        },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Generated Quote', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Text(_generated, style: const TextStyle(fontSize: 20, height: 1.3)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                              onPressed: _copyToClipboard,
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Inspire (save)'),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to favorites (simulated).')));
                              },
                            ),
                            const Spacer(),
                            Text('Local AI', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tip: Implement the following quote in your life and move towards the success gate.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            )
          ],
        ),
      ),
    );
  }
}
