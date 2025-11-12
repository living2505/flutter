import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const QuoteAiApp());

// ====================================================================
// 1. THEME AND UTILITIES
// ====================================================================

const Color primarySeed = Color(0xFF4A148C); // Deep Purple
const Color accentColor = Color(0xFFFFC107); // Amber/Yellow for secondary actions

final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.light,
    background: const Color(0xFFF7F4FA),
    secondary: accentColor,
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: primarySeed,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 3,
    ),
  ),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.dark,
    background: const Color(0xFF121212),
    secondary: accentColor,
  ),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    backgroundColor: primarySeed.darken(0.3),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 5,
    ),
  ),
);

extension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final double newLightness = max(0.0, hsl.lightness - amount);
    return hsl.withLightness(newLightness).toColor();
  }
}

// ====================================================================
// 2. SERVICE LAYER (Separation of Concerns)
// ====================================================================

class QuoteService {
  final Random _rng = Random();

  // Small corpus of quotes
  static const List<String> _corpus = [
    "The best way to get started is to quit talking and begin doing.",
    "Don't let yesterday take up too much of today.",
    "You learn more from failure than from success. Failure builds character.",
    "It's not whether you get knocked down, it's whether you get up.",
    "If you are working on something you really care about, the vision pulls you.",
    "People who are crazy enough to think they can change the world, are the ones who do.",
    "Failure will never overtake me if my determination to succeed is strong enough.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "You must be the change you wish to see in the world.",
    "Act as if what you do makes a difference. It does.",
    "Success usually comes to those who are too busy to be looking for it.",
    "The only limit to our realization of tomorrow is our doubts of today.",
    "Strive not to be a success, but rather to be of value.",
    "The mind is everything. What you think you become.",
    "Eighty percent of success is showing up.",
    "Your time is limited, so don't waste it living someone else's life.",
    "The journey of a thousand miles begins with a single step.",
    "The only way to do great work is to love what you do.",
    "If you want to achieve greatness, stop asking for permission.",
    "I have not failed. I've just found 10,000 ways that won't work.",
    "The power of imagination makes us infinite.",
    "The best revenge is massive success.",
    "The obstacle is the way.",
    "Where there is a will, there is a way.",
    
    // --- Additional Insights (6 Quotes) ---
    "Life is 10% what happens to you and 90% how you react to it.",
    "Our greatest weakness lies in giving up. The most certain way to succeed is always to try just one more time.",
    "The only impossible journey is the one you never begin.",
    "A smooth sea never made a skilled sailor.",
    "If you can dream it, you can achieve it.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",

    // --- Action, Mindset, & Growth (40 Quotes) ---
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "Where there is love, there is life.",
    "Fall down seven times, stand up eight.",
    "The true sign of intelligence is not knowledge but imagination.",
    "Do the difficult things while they are easy and do the great things while they are small.",
    "Everything you can imagine is real.",
    "The key to success is to focus our conscious mind on things we desire, not things we fear.",
    "Move fast and break things. Unless you are breaking stuff, you are not moving fast enough.",
    "The only difference between ordinary and extraordinary is that little extra.",
    "Happiness is not something readymade. It comes from your own actions.",
    "Believe you can and you're halfway there.",
    "Innovation distinguishes between a leader and a follower.",
    "Action is the foundational key to all success.",
    "Our greatest glory is not in never failing, but in rising up every time we fail.",
    "It does not matter how slowly you go as long as you do not stop.",
    "Logic will get you from A to B. Imagination will take you everywhere.",
    "Only I can change my life. No one can do it for me.",
    "We become what we think about.",
    "The struggle you're in today is developing the strength you need for tomorrow.",
    "If you're not failing every now and again, it's a sign you're not doing anything very innovative.",
    "The way to get started is to quit talking and begin doing.",
    "We can not solve problems with the kind of thinking we employed when we came up with them.",
    "Patience, persistence and perspiration make an unbeatable combination for success.",
    "Creativity is intelligence having fun.",
    "Go confidently in the direction of your dreams!",
    "Darkness cannot drive out darkness: only light can do that.",
    "A little progress each day adds up to big results.",
    "The people who are crazy enough to think they can change the world are the ones who do.",
    "If you want to lift yourself up, lift up someone else.",
    "In the middle of difficulty lies opportunity.",
    "The successful warrior is the average man, with laser-like focus.",
    "Don't be afraid to give up the good to go for the great.",
    "The purpose of our lives is to be happy.",
    "The mind, once stretched by a new idea, never returns to its original dimensions.",
    "It always seems impossible until it's done.",
    "Ask yourself if what you're doing today is getting you closer to where you want to be tomorrow.",
    "Don't watch the clock; do what it does. Keep going.",
    "Change your thoughts and you change your world.",
    "The depth of your struggle determines the height of your success.",
    "Simplicity is the ultimate sophistication.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "Where there is love, there is life.",
    "Fall down seven times, stand up eight.",
    "The true sign of intelligence is not knowledge but imagination.",
    "Do the difficult things while they are easy and do the great things while they are small.",
    "Everything you can imagine is real.",
    "The key to success is to focus our conscious mind on things we desire, not things we fear.",
    "Move fast and break things. Unless you are breaking stuff, you are not moving fast enough.",
    "The only difference between ordinary and extraordinary is that little extra.",
    "Happiness is not something readymade. It comes from your own actions.",
    "Believe you can and you're halfway there.",
    "Innovation distinguishes between a leader and a follower.",
    "Action is the foundational key to all success.",
    "Our greatest glory is not in never failing, but in rising up every time we fail.",
    "It does not matter how slowly you go as long as you do not stop.",
    "Logic will get you from A to B. Imagination will take you everywhere.",
    "Only I can change my life. No one can do it for me.",
    "We become what we think about.",
    "The struggle you're in today is developing the strength you need for tomorrow.",
    "If you're not failing every now and again, it's a sign you're not doing anything very innovative.",
    "The way to get started is to quit talking and begin doing.",
    "We can not solve problems with the kind of thinking we employed when we came up with them.",
    "Patience, persistence and perspiration make an unbeatable combination for success.",
    "Creativity is intelligence having fun.",
    "Go confidently in the direction of your dreams!",
    "Darkness cannot drive out darkness: only light can do that.",
    "A little progress each day adds up to big results.",
    "The people who are crazy enough to think they can change the world are the ones who do.",
    "If you want to lift yourself up, lift up someone else.",
    "In the middle of difficulty lies opportunity.",
    "The successful warrior is the average man, with laser-like focus.",
    "Don't be afraid to give up the good to go for the great.",
    "The purpose of our lives is to be happy.",
    "The mind, once stretched by a new idea, never returns to its original dimensions.",
    "It always seems impossible until it's done.",
    "Ask yourself if what you're doing today is getting you closer to where you want to be tomorrow.",
    "Don't watch the clock; do what it does. Keep going.",
    "Change your thoughts and you change your world.",
    "The depth of your struggle determines the height of your success.",
    "Simplicity is the ultimate sophistication."
  ];

  Map<String, List<String>> _markov = {};

  QuoteService() {
    _buildMarkovChain();
  }

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
    for (var line in _corpus) {
      final tokens = _tokenize(line);
      if (tokens.isNotEmpty) {
        _markov.putIfAbsent("<START>", () => <String>[]).add(tokens[0]);
      }
    }
  }

  List<String> _tokenize(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final tokens = <String>[];
    final parts = cleaned.split(' ');
    for (var p in parts) {
      if (p.length > 1 && RegExp(r'[.,!?:;]$').hasMatch(p)) {
        tokens.add(p.substring(0, p.length - 1).toLowerCase());
        tokens.add(p.substring(p.length - 1));
      } else {
        tokens.add(p.toLowerCase());
      }
    }
    return tokens;
  }

  String _generateMarkov({String? seed, int maxWords = 20}) {
    final sb = StringBuffer();
    String current;
    
    final startWord = _getStartWordFromSeed(seed);
    current = startWord;

    int words = 0;
    while (words < maxWords) {
      final options = _markov[current] ?? _markov["<START>"] ?? <String>[];
      if (options.isEmpty) break;
      final next = options[_rng.nextInt(options.length)];
      if (next == "<END>") break;
      
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
      out = _corpus[_rng.nextInt(_corpus.length)];
    }
    if (!RegExp(r'[.!?]$').hasMatch(out)) {
      out = '$out.';
    }
    return out[0].toUpperCase() + out.substring(1);
  }

  String _getStartWordFromSeed(String? seed) {
     if (seed != null && seed.trim().isNotEmpty) {
        final seedTokens = _tokenize(seed);
        if (seedTokens.isNotEmpty) {
          if (_markov.containsKey(seedTokens.last)) return seedTokens.last;
          if (_markov.containsKey(seedTokens.first)) return seedTokens.first;
        }
    }
    return "<START>";
  }

  String _capitalizeIfStart(bool isStart, String token) {
    if (isStart) {
      return token.isNotEmpty ? token[0].toUpperCase() + token.substring(1) : token;
    }
    return token;
  }
  
  String generateQuote(String userSeed, {bool useTemplate = true}) {
    final seed = userSeed.trim(); 
    final markov = _generateMarkov(seed: seed, maxWords: 20);

    String merged = markov;
    if (_rng.nextDouble() < 0.25) {
      final extra = _generateMarkov(seed: '', maxWords: 10);
      merged = _combineSentences(markov, extra);
    }
    
    if (!useTemplate) return merged;

    final templates = [
      "\"{quote}\" — Thought.",
      "\n✨ \"{quote}\" ✨\n",
      "AI thought: {quote}",
    ];
    final template = templates[_rng.nextInt(templates.length)];
    return template.replaceAll('{quote}', merged);
  }

  String _combineSentences(String a, String b) {
    String aa = a.trim();
    if (aa.endsWith('.')) aa = aa.substring(0, aa.length - 1);
    String bb = b.trim();
    if (bb.isNotEmpty && bb[0] == bb[0].toLowerCase()) {
      bb = bb[0].toUpperCase() + bb.substring(1);
    }
    return "$aa, and $bb";
  }

  String getRandomSeed() {
    final seeds = ['life', 'success', 'failure', 'dream', 'change', 'focus', 'time', 'courage', 'learn'];
    return seeds[_rng.nextInt(seeds.length)];
  }
}

// ====================================================================
// 3. ROOT WIDGETS AND NAVIGATION
// ====================================================================

class QuoteAiApp extends StatefulWidget {
  const QuoteAiApp({super.key});

  @override
  State<QuoteAiApp> createState() => _QuoteAiAppState();
}

class _QuoteAiAppState extends State<QuoteAiApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final QuoteService _quoteService = QuoteService(); // Initialize Service
  final List<String> _inspiredQuotes = [];

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _addInspiredQuote(String quote) {
    setState(() {
      if (!_inspiredQuotes.contains(quote)) {
        _inspiredQuotes.insert(0, quote);
      }
    });
  }

  void _removeInspiredQuote(String quote) {
    setState(() {
      _inspiredQuotes.remove(quote);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Quote Generator',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: QuoteNavigationWrapper(
        toggleTheme: _toggleTheme,
        inspiredQuotes: _inspiredQuotes,
        addInspiredQuote: _addInspiredQuote,
        removeInspiredQuote: _removeInspiredQuote,
        quoteService: _quoteService, // Pass service down
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuoteNavigationWrapper extends StatefulWidget {
  final ValueChanged<bool> toggleTheme;
  final List<String> inspiredQuotes;
  final ValueChanged<String> addInspiredQuote;
  final ValueChanged<String> removeInspiredQuote;
  final QuoteService quoteService;

  const QuoteNavigationWrapper({
    super.key,
    required this.toggleTheme,
    required this.inspiredQuotes,
    required this.addInspiredQuote,
    required this.removeInspiredQuote,
    required this.quoteService,
  });

  @override
  State<QuoteNavigationWrapper> createState() => _QuoteNavigationWrapperState();
}

class _QuoteNavigationWrapperState extends State<QuoteNavigationWrapper> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      QuoteGeneratorPage(
        isDark: isDark,
        addInspiredQuote: widget.addInspiredQuote,
        removeInspiredQuote: widget.removeInspiredQuote,
        inspiredQuotes: widget.inspiredQuotes,
        quoteService: widget.quoteService,
      ),
      InspirationsPage(
        quotes: widget.inspiredQuotes,
        removeInspiredQuote: widget.removeInspiredQuote,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'AI Quote Generator' : 'My Inspirations',
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(!isDark),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomBarTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Generate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Inspirations',
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// 4. GENERATOR SCREEN (Fixed and Improved)
// ====================================================================

class QuoteGeneratorPage extends StatefulWidget {
  final bool isDark;
  final ValueChanged<String> addInspiredQuote;
  final ValueChanged<String> removeInspiredQuote;
  final List<String> inspiredQuotes;
  final QuoteService quoteService;

  const QuoteGeneratorPage({
    super.key,
    required this.isDark,
    required this.addInspiredQuote,
    required this.removeInspiredQuote,
    required this.inspiredQuotes,
    required this.quoteService,
  });

  @override
  _QuoteGeneratorPageState createState() => _QuoteGeneratorPageState();
}

class _QuoteGeneratorPageState extends State<QuoteGeneratorPage> {
  final TextEditingController _promptController = TextEditingController();
  final Random _rng = Random();
  String _generated = '';
  String _currentTip = '';
  bool _loading = false;
  
  static const List<String> _tips = [
    'Success is a journey, not a destination.',
    'Focus on process, not just outcomes.',
    'Small daily improvements are the key to staggering results.',
    'Learn from everyone; follow no one.',
    'The mind is everything. What you think, you become.',
  ];
  
  @override
  void initState() {
    super.initState();
    _generated = widget.quoteService.generateQuote("inspire");
    _updateTip();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
  
  void _simulateHapticFeedback() {
    // Simulated Haptic Feedback
    Timer(const Duration(milliseconds: 50), () {});
  }

  // >>>>>> FIXED METHOD 1: _copyToClipboard <<<<<<
  void _copyToClipboard() {
    _simulateHapticFeedback();
    // In a real app, use Clipboard.setData(ClipboardData(text: _generated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Quote copied to clipboard (simulated).'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(milliseconds: 1500),
      )
    );
  }
  
  // >>>>>> FIXED METHOD 2: _shareQuote <<<<<<
  void _shareQuote() {
    _simulateHapticFeedback();
    // In a real app, use the share package: Share.share(_generated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing (simulated): "${_generated}"'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      )
    );
  }
  
  void _updateTip() {
    setState(() {
      _currentTip = _tips[_rng.nextInt(_tips.length)];
    });
  }

  Future<void> _generate() async {
    _simulateHapticFeedback();
    
    final seed = _promptController.text.trim();
    if (seed.isNotEmpty && seed.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a longer prompt or use Random.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _generated = '';
    });

    await Future.delayed(Duration(milliseconds: 400 + _rng.nextInt(500)));

    try {
      final generated = widget.quoteService.generateQuote(seed.isEmpty ? widget.quoteService.getRandomSeed() : seed);
      
      setState(() {
        _generated = generated;
        _loading = false;
        _updateTip();
      });
      
    } catch (e) {
      setState(() {
        _generated = 'ERROR: Failed to generate quote. Try "Random" or check your input.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final isInspired = widget.inspiredQuotes.contains(_generated);

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: <Widget>[
          // --- Prompt Area ---
          Text(
            'Type a keyword to inspire the AI.',
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            decoration: InputDecoration(
              labelText: 'Prompt (e.g., "courage", "dream big")',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _promptController.clear(),
              ),
            ),
            onSubmitted: (_) => _generate(),
          ),
          const SizedBox(height: 15),

          // --- Buttons ---
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.darken(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: _loading ? null : [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                        : const Icon(Icons.auto_awesome),
                    label: Text(_loading ? 'Generating...' : 'Generate Quote', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _loading ? null : _generate,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.shuffle),
                label: const Text('Random'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                onPressed: _loading
                    ? null
                    : () {
                        _promptController.clear();
                        _generate();
                      },
              ),
            ],
          ),
          const SizedBox(height: 25),

          // --- Quote Display Card with AnimatedSwitcher ---
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _loading
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            height: 150,
                            child: Center(
                              child: CircularProgressIndicator(color: primaryColor),
                            ),
                          )
                        : Column(
                            key: ValueKey(_generated), // Key changes on every new quote
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('AI Wisdom', style: theme.textTheme.titleLarge?.copyWith(
                                color: primaryColor.darken(0.1),
                                fontWeight: FontWeight.w800,
                              )),
                              const SizedBox(height: 15),
                              Text(
                                _generated,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Divider(color: primaryColor.withOpacity(0.2)),
                              // --- Actions ---
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copy'),
                                    onPressed: _copyToClipboard, // <<-- FIXED
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      side: BorderSide(color: primaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Share Button Added
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.share),
                                    label: const Text('Share'),
                                    onPressed: _shareQuote, // <<-- FIXED
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: secondaryColor,
                                      side: BorderSide(color: secondaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Spacer(),
                                  // Save Button
                                  ElevatedButton.icon(
                                    icon: Icon(isInspired ? Icons.favorite : Icons.favorite_border),
                                    label: Text(isInspired ? 'Saved' : 'Inspire'),
                                    onPressed: () {
                                      if (isInspired) {
                                        widget.removeInspiredQuote(_generated);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from Inspirations.')));
                                      } else {
                                        widget.addInspiredQuote(_generated);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Inspirations!')));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isInspired ? Colors.red : primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // --- Animated Footer Tip ---
          SizedBox(
            height: 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child: Text(
                '💡 Tip: $_currentTip',
                key: ValueKey(_currentTip),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ====================================================================
// 5. INSPIRATIONS SCREEN (Saved Quotes)
// ====================================================================

class InspirationsPage extends StatelessWidget {
  final List<String> quotes;
  final ValueChanged<String> removeInspiredQuote;

  const InspirationsPage({
    super.key,
    required this.quotes,
    required this.removeInspiredQuote,
  });

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 60, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
            const SizedBox(height: 10),
            Text(
              "No inspired quotes yet!",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            Text("Go to the Generator tab to find inspiration.", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
            title: Text(
              quote,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                removeInspiredQuote(quote);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quote removed.')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
