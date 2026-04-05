import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class AppConfig {
  static const String googleGeminiKey =
      String.fromEnvironment('GOOGLE_GEMINI_KEY');
  static const String openAiKey = String.fromEnvironment('OPENAI_KEY');
}

class AppSettings extends ChangeNotifier {
  bool _aiImageGenerationEnabled = false;
  bool _multipleImagesEnabled = false;
  bool _proteinDenseMealsEnabled = false;

  bool get aiImageGenerationEnabled => _aiImageGenerationEnabled;
  bool get multipleImagesEnabled => _multipleImagesEnabled;
  bool get proteinDenseMealsEnabled => _proteinDenseMealsEnabled;

  void setAiImageGeneration(bool value) {
    _aiImageGenerationEnabled = value;
    notifyListeners();
  }

  void setMultipleImages(bool value) {
    _multipleImagesEnabled = value;
    notifyListeners();
  }

  void setProteinDenseMeals(bool value) {
    _proteinDenseMealsEnabled = value;
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: MaterialApp(
      title: 'GainzGuru',
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(),
      ),
    );
  }
}

// ------------------ MESSAGE CLASS --------------------
class Message {
  final String sender;
  final String? text;
  final String? image;

  Message({required this.sender, this.text, this.image});
}

// ------------------ HOME PAGE --------------------
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final Random _random = Random();
  int _currentSayingIndex = 0;

  final List<String> sayings = [
    "Fuel your goals with smart meals",
    "Progress starts in the kitchen",
    "Simple ingredients, better outcomes",
    "Consistency beats intensity",
    "Build healthy habits daily",
    "Strong nutrition supports strong training",
    "Balance protein, carbs, and fats",
    "Cook with purpose and clarity",
    "Preparation drives performance",
    "Small choices create long-term results",
    "Better meals, better recovery",
    "Plan your meals, own your day",
    "Healthy routines create momentum",
    "Choose quality ingredients first",
    "Sustainable progress is the goal",
  ];

  @override
  void initState() {
    super.initState();
    _currentSayingIndex = _random.nextInt(sayings.length);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentSaying = sayings[_currentSayingIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(24),
              child: Row(
        children: [
          Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/logo_border.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
                  const SizedBox(width: 16),
                  Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                          'GainzGuru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                          'AI-powered Recipe Assistant',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                            ),
                          ],
                        ),
                      ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => _showSettingsMenu(context),
                      ),
                          ],
                        ),
            ),
            
            // Main content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quote section
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.1),
                                Colors.blue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Text(
                                    currentSaying,
                                    style: const TextStyle(
                                      color: Color(0xFF2D3436),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                        textAlign: TextAlign.center,
                                  );
                                },
                      ),
                      const SizedBox(height: 8),
                              Text(
                                '- GainzGuru',
                        style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                        ),
                        const SizedBox(height: 40),
                        // Features section
                        Column(
                          children: [
                            _buildFeatureItem(
                              Icons.camera_alt_rounded,
                              'Scan Ingredients',
                              'Take a photo of your ingredients',
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              Icons.restaurant_menu_rounded,
                              'Get Recipe',
                              'AI will suggest the perfect recipe',
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              Icons.fitness_center_rounded,
                              'Track Macros',
                              'Monitor your protein and calories',
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Action button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),  // Added padding to move button up
                      child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        try {
                          final pickedFile = await picker.pickImage(source: ImageSource.camera);
                          if (pickedFile != null) {
                              final settings = Provider.of<AppSettings>(context, listen: false);
                              if (settings.multipleImagesEnabled) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MultipleImageScreen(firstImagePath: pickedFile.path),
                                  ),
                                );
                              } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                                builder: (context) => ChatScreen(initialImagePath: pickedFile.path),
                              ),
                            );
                              }
                          }
                        } catch (e) {
                          print("Error capturing image: $e");
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error capturing image. Please try again.'),
                              ),
                            );
                          }
                        }
                },
                child: Container(
                        width: double.infinity,
                        height: 60,
                  decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFB39DDB),  // Softer purple
                                    const Color(0xFF7986CB),  // More blue presence
                                  ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                    color: const Color(0xFF7986CB).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                      'Analyze Image',
                      style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                    ),
                                  ],
                    ),
                  ),
                ),
              ),
                  ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8E44AD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8E44AD),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add settings menu
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => const SettingsMenu(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

// Add this new widget before MyHomePage class
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        final settings = Provider.of<AppSettings>(context);
        return Container(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    size: 28,
                    color: const Color(0xFF8E44AD),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // AI Image Generation Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Generated Recipe Images',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Generate appetizing images of recipes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: settings.aiImageGenerationEnabled,
                    onChanged: (bool value) {
                      settings.setAiImageGeneration(value);
                    },
                    activeColor: const Color(0xFF8E44AD),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Multiple Images Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enable Multiple Images',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Submit a fridge and pantry image',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: settings.multipleImagesEnabled,
                    onChanged: (bool value) {
                      settings.setMultipleImages(value);
                    },
                    activeColor: const Color(0xFF8E44AD),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Protein Dense Meals Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'High Protein Recipes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Prioritize protein-focused recipes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: settings.proteinDenseMealsEnabled,
                    onChanged: (bool value) {
                      settings.setProteinDenseMeals(value);
                    },
                    activeColor: const Color(0xFF8E44AD),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------ CHAT SCREEN (Image Analysis) --------------------
class ChatScreen extends StatefulWidget {
  final String? initialImagePath;
  final String? secondImagePath;
  final List<String> additionalImagePaths;  // Add support for additional images
  
  const ChatScreen({
    super.key, 
    this.initialImagePath, 
    this.secondImagePath,
    this.additionalImagePaths = const [],
  });
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isGeneratingImage = false;
  String _loadingMessage = '';
  Timer? _loadingMessageTimer;
  int _loadingMessageIndex = 0;
  String? _currentImagePath;
  String? _secondImagePath;
  bool _waitingForSecondImage = false;
  String? _generatedImageBase64;
  String? _lastRecipeName;
  Map<String, String> _mealTypeImages = {};
  int _calories = 600;
  int _protein = 45;    // Default fallback value
  int _carbs = 60;     // Default fallback value
  int _fats = 25;      // Default fallback value
  int _healthScore = 7; // Default fallback value
  String _selectedMealType = 'Lunch'; // Default value
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  List<String> _identifiedIngredients = []; // Store identified ingredients
  late List<AnimationController> _dotControllers;
  late AnimationController _rotationController;  // Inner circle rotation
  late AnimationController _outerRotationController;  // Add this line for outer ring rotation

  final List<String> _recipeLoadingMessages = [
    'Analyzing ingredients in image...',  // Only for initial analysis
    'Generating recipe...',              // For recipe generation
    'Calculating nutritional data...',    // For nutrition calculation
    'Generating recipe image...',         // For AI image generation
    'Finalizing results...'              // For completion
  ];

  final List<String> _imageLoadingMessages = [
    'Generating your recipe image...',
    'Crafting a beautiful presentation...',
    'Adding finishing touches...',
    'Perfecting the plating design...',
  ];

  // Add a completion state variable at the class level
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    // Initialize dot animation controllers with slower duration
    _dotControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2500),  // Increased from 2000 to 2500 for slower animation
      )..repeat(),
    );

    // Initialize rotation controller for inner circle
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();  // Make it repeat indefinitely

    // Initialize rotation controller for outer ring
    _outerRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),  // Slightly slower for contrast
    )..repeat();  // Make it repeat indefinitely
    
    if (widget.initialImagePath != null) {
      print("Initializing with image path: ${widget.initialImagePath}");
      _currentImagePath = widget.initialImagePath;
      _secondImagePath = widget.secondImagePath;
      
      // Process all images together
      _processMultipleImages();
    }
  }

  @override
  void dispose() {
    _loadingMessageTimer?.cancel();
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    _rotationController.dispose();
    _outerRotationController.dispose();  // Add this line
    super.dispose();
  }

  void _startLoadingMessages(bool isImageGeneration) {
    _loadingMessageIndex = 0;
    final random = Random();
    
    // Set initial message based on current state
    setState(() {
      if (isImageGeneration) {
        _loadingMessage = 'Generating recipe image...';
      } else {
        _loadingMessage = _recipeLoadingMessages[_loadingMessageIndex];
      }
    });

    // Cancel any existing timer
    _loadingMessageTimer?.cancel();

    // We don't need cycling messages anymore, just update based on state
    _loadingMessageTimer = null;
  }

  Future<void> _processMultipleImages() async {
    if (_currentImagePath == null) return;
        
        setState(() {
      _messages.clear();
      _isLoading = true;
      _loadingMessage = 'Analyzing all ingredients...';
    });
    _startLoadingMessages(false);

    try {
      List<String> allPaths = [
        _currentImagePath!,
        if (_secondImagePath != null) _secondImagePath!,
        ...widget.additionalImagePaths,
      ];

      List<String> allIngredients = [];
      
      // Process each image
      for (String path in allPaths) {
        final imageBytes = await File(path).readAsBytes();
        final ingredients = await _getIngredientsFromImage(imageBytes);
        allIngredients.addAll(ingredients);
      }

      // Remove duplicates and sort
      _identifiedIngredients = allIngredients.toSet().toList()..sort();

      if (_identifiedIngredients.isNotEmpty) {
        // Generate recipe with all ingredients
        final firstImageBytes = await File(_currentImagePath!).readAsBytes();
        await _analyzeImageWithGemini(firstImageBytes, false);
      } else {
    setState(() {
      _messages.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error processing multiple images: $e");
      setState(() {
        _messages.add(Message(
      sender: "assistant",
          text: "An error occurred while processing the images."
        ));
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _getIngredientsFromImage(Uint8List imageBytes) async {
    final apiKey = AppConfig.googleGeminiKey;
    if (apiKey.isEmpty) {
      return [];
    }
    final endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    final prompt = """Analyze the image and identify any food, drinks, or edible items you can see with certainty. Try to read labels and get the best guess of what is in the image. Format your response as a JSON object with the following structure:

{
  "identified_ingredients": ["ingredient1", "ingredient2", ...]
}

List ONLY items that you can see with high confidence in the image. Do not include assumed ingredients or items that aren't visible.""";

    final request = {
      "contents": [
        {
          "parts": [
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Encode(imageBytes)
              }
            },
            {
              "text": prompt
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final textResponse = responseData["candidates"][0]["content"]["parts"][0]["text"];
        
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textResponse);
        if (jsonMatch != null) {
          final jsonResponse = jsonDecode(jsonMatch.group(0)!);
          return List<String>.from(
            jsonResponse['identified_ingredients'].map((i) => _toSentenceCase(i.toString()))
          );
        }
      }
    } catch (e) {
      print("Error analyzing image: $e");
    }
    
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return _buildResultsView();
  }

  Widget _buildResultsView() {
    if (_currentImagePath == null) {
      print("No image path available");
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    print("Building view with image path: $_currentImagePath");
    
    // Show loading screen while generating image or recipe
    if (_isLoading || _isCompleting) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: () async => false,  // Prevent back button during loading
          child: Stack(
            children: [
              // Animated gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB39DDB).withOpacity(0.1),
                      const Color(0xFF7986CB).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                    // Animated loading container with multiple effects
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating outer ring
                          RotationTransition(
                            turns: _outerRotationController,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    const Color(0xFFB39DDB).withOpacity(0.2),
                                    const Color(0xFF7986CB).withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Pulsing waves
                          ...List.generate(3, (index) {
                            return TweenAnimationBuilder(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(seconds: 2 + index),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: 0.8 + (0.2 * value),
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Color.lerp(
                                          const Color(0xFFB39DDB),
                                          const Color(0xFF7986CB),
                                          value,
                                        )!.withOpacity((1 - value) * 0.3),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          // Main circle with rotating gradient
                          RotationTransition(
                            turns: _rotationController,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const SweepGradient(
                                  colors: [
                                    Color(0xFFB39DDB),
                                    Color(0xFF7986CB),
                                    Color(0xFFB39DDB),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7986CB).withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: TweenAnimationBuilder(
                                  tween: Tween(begin: 0.8, end: 1.0),
                                  duration: const Duration(milliseconds: 1500),
                                  builder: (context, double scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: Icon(
                                        _isGeneratingImage 
                                          ? Icons.restaurant_menu
                                          : Icons.kitchen,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Animated loading message with bouncing dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
              Text(
                          _loadingMessage.replaceAll('...', ''),  // Remove any existing dots
                style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Single set of animated dots
                        SizedBox(
                          width: 24,
                          child: _isLoading ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _dotControllers[index],
                                builder: (context, child) {
                                  final value = _dotControllers[index].value;
                                  
                                  // Each dot starts its animation with a larger delay
                                  final adjustedValue = (value + (index * 0.33)) % 1.0;
                                  
                                  // Use a smoother easing curve with longer transitions
                                  final easeValue = Curves.easeInOut.transform(
                                    adjustedValue < 0.5 
                                        ? adjustedValue * 2 
                                        : (1 - adjustedValue) * 2
                                  );
                                  
                                  // Smaller movement range
                                  final offset = -2 * easeValue;  // Reduced from -3 to -2 for less height

                                  return Transform.translate(
                                    offset: Offset(0, offset + 1),  // Added +3 to lower the baseline position
                                    child: Text(
                                      '.',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ) : const SizedBox(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress indicator with smooth completion
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TweenAnimationBuilder(
                        tween: Tween(begin: 0.0, end: _isCompleting ? 1.0 : 0.95),
                        duration: Duration(milliseconds: _isCompleting ? 500 : 8000),
                        curve: _isCompleting ? Curves.easeOut : Curves.easeInOut,
                        onEnd: () {
                          if (_isLoading && !_isCompleting && mounted) {
                            setState(() {
                              // Stay at 95% by forcing a rebuild
                            });
                          }
                        },
                        builder: (context, double value, child) {
                          return Stack(
                            children: [
                              // Background progress
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.lerp(
                                      const Color(0xFFB39DDB),
                                      const Color(0xFF7986CB),
                                      value,
                                    )!,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Hint text with fade effect
                    TweenAnimationBuilder(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value * 0.7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFB39DDB).withOpacity(0.1),
                                  const Color(0xFF7986CB).withOpacity(0.1),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                'This may take a moment',
                style: TextStyle(
                                color: Colors.grey[600],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Curved black background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            height: 150, // Height for the curved black background
          ),
          // Main content
          CustomScrollView(
            slivers: [
              // Image section with floating header
              SliverAppBar(
                expandedHeight: 250, // Reduced from 400 to 100
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Modified image section
                      _buildImageSection(),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Content section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.only(bottom: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe details
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recipe Details',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Based on your ingredients',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_identifiedIngredients.isNotEmpty)
                              _buildIngredientsSection(),
                            _buildMealTypeSelector(),
                          ],
                        ),
                      ),
                      if (_messages.isNotEmpty && _messages.first.text != null && !_identifiedIngredients.isEmpty && !_isLoading)
                        _buildRecipeContent(),
                      if (_identifiedIngredients.isEmpty)
                        _buildTipsSection(),
                      const SizedBox(height: 24),  // Added spacing before button
                      _buildNewPhotoButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Remove the loading overlay since we already have a dedicated loading screen
        ],
      ),
    );
  }

  Widget _buildMacroIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF8E44AD),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Text('Recipe image will appear here'),
      ),
    );
  }

  Future<void> _regenerateRecipe() async {
    if (_identifiedIngredients.isEmpty) {
      print("No ingredients detected, showing tips screen");
      setState(() {
        _isLoading = false;
        _isCompleting = false;  // Ensure completion state is reset
        _messages.clear();  // Clear any existing messages
      });
      return;
    }

    try {
      // Clear previous recipe but keep the image
      setState(() {
        _messages.clear();
        _isLoading = true;
        _isCompleting = false;  // Reset completion state
        _loadingMessage = 'Generating new recipe...';
      });

      // Force new recipe generation
      if (_currentImagePath != null) {
        final imageBytes = await File(_currentImagePath!).readAsBytes();
        final prompt = _getRecipeGenerationPrompt();

    final apiKey = AppConfig.googleGeminiKey;
        if (apiKey.isEmpty) {
          throw Exception('Missing GOOGLE_GEMINI_KEY');
        }
        final endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    final request = {
      "contents": [
        {
          "parts": [
            {
                  "text": prompt
            }
          ]
        }
      ]
    };

        print("Sending recipe generation request for meal type: $_selectedMealType");
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
          final textResponse = responseData["candidates"][0]["content"]["parts"][0]["text"];
          
          try {
            print("Processing recipe response");
            // Extract the JSON part from the response
            final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textResponse);
            if (jsonMatch != null) {
              final jsonResponse = jsonDecode(jsonMatch.group(0)!);
              
              if (jsonResponse['recipe'] != null) {
                // Format the recipe text for display
                final recipe = jsonResponse['recipe'];
                final recipeName = recipe['name'];
                final ingredients = recipe['ingredients'];
                final instructions = recipe['instructions'];
                
                String formattedText = """**Recipe:**\n\n$recipeName\n\n**Ingredients:**\n""";
                
                // Format ingredients with sentence case
                for (var ingredient in ingredients) {
                  formattedText += "* ${ingredient['amount']} ${_toSentenceCase(ingredient['item'])}\n";
                }
                
                // Format instructions
                formattedText += "\n**Instructions:**\n";
                for (int i = 0; i < instructions.length; i++) {
                  formattedText += "${i + 1}. ${instructions[i]}\n";
                }
                
                print("Processing formatted recipe text");
                // Process the formatted text
                await _processResponseText(formattedText, preserveImage: true);
                
                // If we have a recipe name and AI image generation is enabled, generate the image
                final settings = Provider.of<AppSettings>(context, listen: false);
                if (settings.aiImageGenerationEnabled && recipeName != null) {
                  print("Generating recipe image for: $recipeName");
                  await _generateRecipeImage(recipeName);
                }
    } else {
                throw Exception('Invalid recipe format in response');
              }
            } else {
              throw Exception('No valid JSON found in response');
            }
          } catch (e, stackTrace) {
            print("Error parsing recipe: $e");
            print("Stack trace: $stackTrace");
            if (mounted) {
      setState(() {
        _messages.add(Message(
            sender: "assistant",
                    text: "An error occurred while processing the recipe."));
        _isLoading = false;
        _isCompleting = false;
      });
    }
  }
        } else {
          print("API request failed with status code: ${response.statusCode}");
          print("Response body: ${response.body}");
          throw Exception('Failed to generate recipe: ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      print("Error in _regenerateRecipe: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
    setState(() {
      _isLoading = false;
          _isCompleting = false;
          _messages.add(Message(
              sender: "assistant",
              text: "An error occurred while generating the recipe. Please try again."));
        });
      }
    }
  }

  Future<void> _processResponseText(String textResponse, {bool preserveImage = false, bool isInitialAnalysis = false}) async {
    try {
      print("Starting _processResponseText");
      
      if (mounted) {
        setState(() {
          _messages.add(Message(sender: "assistant", text: textResponse));
        if (!preserveImage) {
          _generatedImageBase64 = null;
          }
          if (!isInitialAnalysis) {
            _isLoading = true;
            _isCompleting = false;
          }
          _loadingMessage = 'Calculating nutritional data...';
        });

        await _calculateNutritionValues();

        final settings = Provider.of<AppSettings>(context, listen: false);
        if (settings.aiImageGenerationEnabled && !preserveImage) {
          _loadingMessage = 'Generating recipe image...';
          // Image generation will handle its own loading states
        } else {
          setState(() {
            _loadingMessage = 'Finalizing results...';
            _isCompleting = true;
          });
        }
        
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isCompleting = false;
          });
          print("Recipe processing completed successfully");
        }
      }
    } catch (e, stackTrace) {
      print("Error in _processResponseText: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCompleting = false;
          _messages.add(Message(
              sender: "assistant",
              text: "An error occurred while processing the recipe. Please try again."));
        });
      }
    }
  }

  Future<void> _calculateNutritionValues() async {
    try {
      print("\n=== Starting Nutrition Calculation ===");
      
      // Check if we have recipe text
      if (_messages.isEmpty) {
        print("❌ Error: Messages list is empty");
        return;
      }
      if (_messages.first.text == null) {
        print("❌ Error: First message has no text");
        return;
      }

      final recipeText = _messages.first.text!;
      print("\n📝 Recipe Text Found:");
      print(recipeText);

      // Extract ingredients section
      RegExp ingredientsRegex = RegExp(r'\*\*Ingredients:\*\*\n(.*?)(?=\n\*\*Instructions:|$)', dotAll: true);
      final ingredientsMatch = ingredientsRegex.firstMatch(recipeText);
      if (ingredientsMatch == null) {
        print("❌ Error: No ingredients section found in recipe text");
        return;
      }

      // Extract instructions section
      RegExp instructionsRegex = RegExp(r'\*\*Instructions:\*\*\n(.*?)$', dotAll: true);
      final instructionsMatch = instructionsRegex.firstMatch(recipeText);
      if (instructionsMatch == null) {
        print("❌ Error: No instructions section found in recipe text");
        return;
      }

      final ingredients = ingredientsMatch.group(1)!
          .split('\n')
          .where((line) => line.trim().startsWith('*'))
          .map((line) => line.trim().substring(2))
          .where((line) => line.isNotEmpty)
          .toList();
      
      final instructions = instructionsMatch.group(1)!
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
      
      print("\n📋 Extracted Ingredients:");
      ingredients.forEach((ingredient) => print("  • $ingredient"));
      print("\n📝 Extracted Instructions:");
      instructions.forEach((instruction) => print("  • $instruction"));

      final apiKey = AppConfig.googleGeminiKey;
      if (apiKey.isEmpty) {
        return;
      }
      final endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

      final prompt = """Analyze the following ingredients and its cooking method:

Ingredients:
${ingredients.join('\n')}

Instructions:
${instructions.join('\n')}

Calculate precise nutritional values based on the ingredients and cooking methods. Consider cooking oils, seasonings, and any nutritional changes from the cooking process. Return ONLY a JSON object in this format:
{
  "calories": number,
  "protein": number,
  "carbs": number,
  "fats": number,
  "health_score": number (1-10)
}

For the health score calculation, consider:
1. If this is a SNACK:
   - Score based on portion control, nutrient density, and appropriateness as a snack
   - Don't penalize for low calories/protein if it's a reasonable snack portion
   - Consider if it provides sustained energy vs empty calories

2. If this is a MEAL (Breakfast/Lunch/Dinner):
   - Score based on macro balance, portion size, and nutritional completeness
   - Consider if calories are appropriate for the meal type
   - Factor in protein content relative to meal size
   - Consider overall nutrient profile and balance

Be exact with calculations. Use standard nutritional databases. Consider:
1. All ingredients including cooking oils and seasonings
2. Cooking methods and their impact on nutrition
3. Any nutritional changes from cooking processes (e.g., oil absorption, nutrient retention)
""";

      print("\n🔍 Sending API Request with prompt:");
      print(prompt);

      final request = {
        "contents": [
          {
            "parts": [
              {
                "text": prompt
              }
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request),
      );

      print("\n📨 API Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final textResponse = responseData["candidates"][0]["content"]["parts"][0]["text"];
        
        print("\n📥 Raw API Response:");
        print(textResponse);
        
        // Extract JSON
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textResponse);
        if (jsonMatch != null) {
          print("\n🎯 Found JSON in response:");
          final jsonText = jsonMatch.group(0)!;
          print(jsonText);
          
          try {
            final nutritionData = jsonDecode(jsonText);
            print("\n✅ Successfully parsed nutrition data:");
            print("Calories: ${nutritionData['calories']}");
            print("Protein: ${nutritionData['protein']}g");
            print("Carbs: ${nutritionData['carbs']}g");
            print("Fats: ${nutritionData['fats']}g");
            print("Health Score: ${nutritionData['health_score']}/10");
            print("Explanation: ${nutritionData['health_score_explanation']}");
            
            if (mounted) {
      setState(() {
                // Round decimal numbers to integers
                _calories = (nutritionData['calories'] is int) 
                    ? nutritionData['calories'] 
                    : (nutritionData['calories'] as num).round();
                
                _protein = (nutritionData['protein'] is int)
                    ? nutritionData['protein']
                    : (nutritionData['protein'] as num).round();
                
                _carbs = (nutritionData['carbs'] is int)
                    ? nutritionData['carbs']
                    : (nutritionData['carbs'] as num).round();
                
                _fats = (nutritionData['fats'] is int)
                    ? nutritionData['fats']
                    : (nutritionData['fats'] as num).round();
                
                _healthScore = (nutritionData['health_score'] is int)
                    ? nutritionData['health_score']
                    : (nutritionData['health_score'] as num).round();
              });
            }
          } catch (e) {
            print("\n❌ Error parsing nutrition JSON: $e");
            // Use fallback values if parsing fails
            if (mounted) {
      setState(() {
                _calories = 600;
                _protein = 45;
                _carbs = 60;
                _fats = 25;
                _healthScore = 5;  // Default to middle score
              });
            }
          }
        } else {
          print("\n❌ No valid JSON found in response");
          print("Response was: $textResponse");
        }
      } else {
        print("\n❌ API request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("\n❌ Error in nutrition calculation:");
      print("Error: $e");
      print("Stack trace: $stackTrace");
    }
  }

  // Remove the old _calculateHealthScore method since we now get it from the API
// ... existing code ...

  // Add helper method for sentence casing
  String _toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Add method to get recipe generation prompt
  String _getRecipeGenerationPrompt() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    
    if (settings.proteinDenseMealsEnabled) {
      return """Using these available items: ${_identifiedIngredients.map((i) => _toSentenceCase(i)).join(', ')} plus basic cooking essentials (salt, pepper, cooking oil, butter) and common spices.

Create the most PROTEIN-DENSE single-serving recipe possible for ${_selectedMealType.toUpperCase()}. This should be an EXTREME protein-focused meal - think bodybuilder/powerlifter level protein. The goal is MAXIMUM PROTEIN, however, still respect the meal conventions.

Guideline for LUNCH and DINNER:
- Prioritize the highest protein ingredients from our list
- Stack proteins aggressively (multiple protein sources in one dish is encouraged)
- Don't worry about being conventional - this is about GAINS
- If we have eggs, use ALL of them
- If we have any meat/fish/poultry, make it the star
- If we have dairy (cottage cheese, Greek yogurt, etc.), incorporate it heavily
- Add protein-rich ingredients wherever possible
- Portion sizes should be MASSIVE for protein items
- You can assume access to protein powders and creatine

Guideline for BREAKFAST:
- For breakfast, focus on a light protein source like eggs or a diabolical protein shake (can use water as base if no milk is available). DO NOT use meats.
- You can assume access to protein powders and creatine
- You can assume access to a blender

Guideline for SNACKS:
- For snacks, single out ONE item that is high in protein and use that as a snack. ONLY ONE ITEM!
- Just select ONE item and tell the user to get it into their system ASAP

Format the response as a JSON object with this structure:

{
  "recipe": {
    "name": "Recipe Name Here (make it sound EPIC)",
    "ingredients": [
      {"item": "ingredient1", "amount": "quantity1 (for one massive serving)"},
      {"item": "ingredient2", "amount": "quantity2 (for one massive serving)"},
      ...
    ],
    "instructions": [
      "Step 1 description",
      "Step 2 description",
      ...
    ]
  }
}""";
    } else {
      return """Using these available items: ${_identifiedIngredients.map((i) => _toSentenceCase(i)).join(', ')} plus basic cooking essentials (salt, pepper, cooking oil, butter) and common spices.

Create a single-serving recipe that would be typical for ${_selectedMealType.toUpperCase()}. Choose ingredients from our list that make sense for this meal type - you don't need to use everything, but DO NOT use items that are not in our list (even if it makes the meal a bit incomplete). Use metric measurements. 


Guidlines for BREAKFAST:
- For breakfast, focus on either an english styled breakfast or a healthy smoothie. Keep it light and simple.

Guidlines for LUNCH:
- Wraps, burgers, sandwiches, salads, etc. are all good options.
- Rice and pasta dishes are also good options if they are healthy and not too heavy.

Guidlines for DINNER:
- Steaks, chicken, fish, and other protein-rich items are all good options.
- Rice and pasta dishes are also good options. 
- This should be a heavy meal, but still healthy.

Guidlines for SNACKS:
- This should be a light snack, such as a pre-packaged item, a healthy bite, or a piece of fruit.


Format the response as a JSON object with this structure:

{
  "recipe": {
    "name": "Recipe Name Here",
    "ingredients": [
      {"item": "ingredient1", "amount": "quantity1 (for one serving)"},
      {"item": "ingredient2", "amount": "quantity2 (for one serving)"},
      ...
    ],
    "instructions": [
      "Step 1 description",
      "Step 2 description",
      ...
    ]
  }
}""";
    }
  }

  Future<void> _analyzeImageWithGemini(Uint8List imageBytes, bool isInitialAnalysis) async {
    if (isInitialAnalysis) {
      setState(() {
        _isLoading = true;
        _isCompleting = false;
        _loadingMessage = 'Analyzing ingredients in image...';
      });
    }

    try {
      print("Starting image analysis - isInitialAnalysis: $isInitialAnalysis");
      final apiKey = AppConfig.googleGeminiKey;
      if (apiKey.isEmpty) {
        throw Exception('Missing GOOGLE_GEMINI_KEY');
      }
      final endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

      final prompt = isInitialAnalysis
          ? """Analyze the image and identify any food, drinks, or edible items you can see with certainty. Try to read labels and get the best guess of what is in the image. Format your response as a JSON object with the following structure:

{
  "identified_ingredients": ["ingredient1", "ingredient2", ...]
}

List ONLY items that you can see with high confidence in the image. Do not include assumed ingredients or items that aren't visible."""
          : _getRecipeGenerationPrompt();

    final request = {
      "contents": [
        {
          "parts": [
            if (isInitialAnalysis) {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Encode(imageBytes)
              }
            },
            {
              "text": prompt
            }
          ]
        }
      ]
    };

      print("Sending API request for image analysis");
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final textResponse = responseData["candidates"][0]["content"]["parts"][0]["text"];
        
        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textResponse);
          if (jsonMatch != null) {
            final jsonResponse = jsonDecode(jsonMatch.group(0)!);
        
        if (isInitialAnalysis) {
              print("Processing initial analysis results");
              _identifiedIngredients = List<String>.from(
                jsonResponse['identified_ingredients'].map((i) => _toSentenceCase(i.toString()))
              );
              
              print("Identified ingredients: $_identifiedIngredients");
              
              if (_identifiedIngredients.isNotEmpty) {
                setState(() {
                  _loadingMessage = 'Generating recipe...';
                });
                await _analyzeImageWithGemini(imageBytes, false);
              } else {
                print("No ingredients detected, transitioning to tips screen");
                setState(() {
                  _loadingMessage = 'Finalizing results...';
                  _isCompleting = true;
                });
                
                await Future.delayed(const Duration(milliseconds: 1000));
                
                if (mounted) {
                  setState(() {
                    _messages.clear();
                    _isLoading = false;
                    _isCompleting = false;
                  });
                }
              }
            } else if (jsonResponse['recipe'] != null) {
              final recipe = jsonResponse['recipe'];
              final recipeName = recipe['name'];
              final ingredients = recipe['ingredients'];
              final instructions = recipe['instructions'];
              
              String formattedText = """**Recipe:**\n\n$recipeName\n\n**Ingredients:**\n""";
              
              for (var ingredient in ingredients) {
                formattedText += "* ${ingredient['amount']} ${_toSentenceCase(ingredient['item'])}\n";
              }
              
              formattedText += "\n**Instructions:**\n";
              for (int i = 0; i < instructions.length; i++) {
                formattedText += "${i + 1}. ${instructions[i]}\n";
              }
              
              print("Processing formatted recipe text");
              await _processResponseText(formattedText, isInitialAnalysis: true);
              
              final settings = Provider.of<AppSettings>(context, listen: false);
              if (settings.aiImageGenerationEnabled && recipeName != null) {
                print("Generating recipe image for: $recipeName");
                await _generateRecipeImage(recipeName);
              }
            }
          } else {
            throw Exception('No valid JSON found in response');
          }
        } catch (e) {
          print("Error parsing JSON response: $e");
          setState(() {
            _messages.add(Message(
                sender: "assistant",
                text: "An error occurred while processing the recipe."));
            _isLoading = false;
            _isCompleting = false;
          });
        }
      } else {
        throw Exception('Failed to analyze image');
      }
    } catch (e) {
      print("Error in _analyzeImageWithGemini: $e");
      setState(() {
        _messages.add(Message(
            sender: "assistant",
            text: "An error occurred while analyzing the image."));
        _isLoading = false;
        _isCompleting = false;
      });
    }
  }

  Future<void> _generateRecipeImage(String recipeName) async {
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (!settings.aiImageGenerationEnabled) return;
    
    setState(() {
      _isGeneratingImage = true;
      _isLoading = true;
    });
    _startLoadingMessages(true);

    final apiKey = AppConfig.openAiKey;
    if (apiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _isGeneratingImage = false;
          _isLoading = false;
        });
      }
      return;
    }
    final endpoint = "https://api.openai.com/v1/images/generations";

    // Get the current recipe text from messages
    String ingredients = "";
    String instructions = "";
    if (_messages.isNotEmpty && _messages.first.text != null) {
      final recipeText = _messages.first.text!;
      
      // Extract ingredients
      RegExp ingredientsRegex = RegExp(r'\*\*Ingredients:\*\*\n(.*?)(?=\n\*\*Instructions:|$)', dotAll: true);
      final ingredientsMatch = ingredientsRegex.firstMatch(recipeText);
      if (ingredientsMatch != null) {
        ingredients = ingredientsMatch.group(1)!.trim();
      }
      
      // Extract instructions
      RegExp instructionsRegex = RegExp(r'\*\*Instructions:\*\*\n(.*?)$', dotAll: true);
      final instructionsMatch = instructionsRegex.firstMatch(recipeText);
      if (instructionsMatch != null) {
        instructions = instructionsMatch.group(1)!.trim();
      }
    }

    final prompt = """Create a photorealistic image of what you think the following recipe looks like:

Key steps:
${instructions.split('\n').take(2).join('\n').replaceAll(RegExp(r'^\d+\.\s*'), '• ')}

    Make it look appetizing and professionally plated, like a high-end restaurant dish.
The image should be well-lit, with good composition, and be zoomed out to show the ENTIRE drink/meal.
If it is a comprehensive meal, make sure to include garnishes and plating elements on a clean, modern plate or bowl.
If there are less than 3 items, just put the ingredients on the plate. If it is a blended drink, just show a glass with the drink.
Do NOT include any text in the image.""";

    final request = {
      "model": "dall-e-2",
      "prompt": prompt,
      "n": 1,
      "size": "1024x1024",
      "response_format": "b64_json"
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["data"] != null && 
            responseData["data"].isNotEmpty && 
            responseData["data"][0]["b64_json"] != null) {
          
          // Set the image data
          final imageData = responseData["data"][0]["b64_json"];
          
          // Wait a moment to ensure loading bar has time to complete
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
          setState(() {
              _generatedImageBase64 = imageData;
              _mealTypeImages[_selectedMealType] = imageData;
              _lastRecipeName = recipeName;
              _isGeneratingImage = false;
            });
          }
          
          // Add another small delay before setting loading to false
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        print("Error generating image: ${response.body}");
        if (mounted) {
          setState(() {
            _isGeneratingImage = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error generating recipe image: $e");
      if (mounted) {
        setState(() {
          _isGeneratingImage = false;
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImageSection() {
    final settings = Provider.of<AppSettings>(context);
    
    if (_isLoading) {
      if (_isGeneratingImage && settings.aiImageGenerationEnabled && _mealTypeImages.containsKey(_selectedMealType)) {
        // Show cached image while generating new one
        return Image.memory(
          base64Decode(_mealTypeImages[_selectedMealType]!),
        fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      } else if (_currentImagePath != null) {
        // Show ingredients photo during initial loading
        final file = File(_currentImagePath!);
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      }
      return _buildFallbackImage();
    } else {
      // After loading, show the appropriate image
      if (settings.aiImageGenerationEnabled && _generatedImageBase64 != null) {
        return Image.memory(
          base64Decode(_generatedImageBase64!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      } else if (_currentImagePath != null) {
        final file = File(_currentImagePath!);
      return Image.file(
          file,
        fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      }
      return _buildFallbackImage();
    }
  }

  Widget _buildIngredientsSection() {
            return Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF8E44AD).withOpacity(0.2),
                                  ),
                                ),
              child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.kitchen,
                                          color: const Color(0xFF8E44AD),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Available Ingredients',
                    style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF8E44AD),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _identifiedIngredients.map((ingredient) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8E44AD).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            ingredient,
                                            style: TextStyle(
                                              color: const Color(0xFF8E44AD),
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
    );
  }

  Widget _buildMealTypeSelector() {
    return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _mealTypes.map((type) {
                                  bool isSelected = _selectedMealType == type;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
              onTap: () async {
                                        setState(() {
                                          _selectedMealType = type;
                                          _isLoading = true;
                  _loadingMessage = 'Generating new recipe...';
                });
                try {
                  await _regenerateRecipe();
                } catch (e) {
                  print("Error regenerating recipe: $e");
                  setState(() {
                    _isLoading = false;
                    _messages.add(Message(
                      sender: "assistant",
                      text: "Failed to generate recipe. Please try again.",
                    ));
                  });
                }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF8E44AD)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF8E44AD),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          type,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF8E44AD),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
    );
  }

  Widget _buildRecipeContent() {
    return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: MarkdownBody(
                                data: _messages.first.text!,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  h1: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    height: 1.5,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  h2: const TextStyle(
                                    color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                  h3: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.8,
                                  ),
                                  strong: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                  listBullet: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  horizontalRuleDecoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
        _buildNutritionSection(),
      ],
    );
  }

  Widget _buildNutritionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF1F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: const Color(0xFFE74C3C),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Calories',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_calories',
                  style: const TextStyle(
                    color: Color(0xFFE74C3C),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Macros Grid
          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  icon: Icons.fitness_center,
                  label: 'Protein',
                  value: '${_protein}g',
                  color: const Color(0xFF8E44AD),
                  bgColor: const Color(0xFFF3E5F5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  icon: Icons.agriculture,
                  label: 'Carbs',
                  value: '${_carbs}g',
                  color: const Color(0xFF3498DB),
                  bgColor: const Color(0xFFE3F2FD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  icon: Icons.water_drop,
                  label: 'Fats',
                  value: '${_fats}g',
                  color: const Color(0xFFF1C40F),
                  bgColor: const Color(0xFFFFF8E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Health Score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health score',
                            style: TextStyle(
                    color: Colors.grey[800],
                              fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _healthScore / 10,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getHealthScoreColor(_healthScore),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                          Text(
                      '$_healthScore/10',
                            style: TextStyle(
                        color: _getHealthScoreColor(_healthScore),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
                              fontSize: 14,
          ),
        ),
      ],
                      ),
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 8) return const Color(0xFF2ECC71); // Green
    if (score >= 6) return const Color(0xFFF1C40F); // Yellow
    if (score >= 4) return const Color(0xFFE67E22); // Orange
    return const Color(0xFFE74C3C); // Red
  }

  Widget _buildTipsSection() {
    return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF8E44AD).withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      color: const Color(0xFF8E44AD),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tips for Better Photos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8E44AD),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildTipItem('Spread out your ingredients on a clear surface'),
                                _buildTipItem('Ensure good lighting for better recognition'),
                                _buildTipItem('Take photos of raw ingredients like vegetables, meats, grains'),
                                _buildTipItem('Include multiple ingredients in one shot'),
                                _buildTipItem('Avoid taking photos of prepared meals'),
                              ],
                            ),
                          ),
    );
  }

  Widget _buildNewPhotoButton() {
    return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),  // Removed top padding
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  try {
                                    final pickedFile = await picker.pickImage(source: ImageSource.camera);
                                    if (pickedFile != null && mounted) {
                                      final settings = Provider.of<AppSettings>(context, listen: false);
                                      if (settings.multipleImagesEnabled) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MultipleImageScreen(firstImagePath: pickedFile.path),
                                          ),
                                          (route) => route.isFirst,
                                        );
                                      } else {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(initialImagePath: pickedFile.path),
                                          ),
                                          (route) => route.isFirst,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print("Error capturing image: $e");
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Error capturing image. Please try again.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFB39DDB),  // Softer purple
                                        const Color(0xFF7986CB),  // More blue presence
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7986CB).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                                      'Take New Photo',
                                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                  ],
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            );
  }
}

// ------------------ MULTIPLE IMAGE SCREEN --------------------
class MultipleImageScreen extends StatefulWidget {
  final String firstImagePath;
  const MultipleImageScreen({super.key, required this.firstImagePath});

  @override
  State<MultipleImageScreen> createState() => _MultipleImageScreenState();
}

class _MultipleImageScreenState extends State<MultipleImageScreen> {
  List<String?> _additionalImagePaths = List.filled(3, null);
  String? _secondImagePath;

  int get _totalImages => 1 + (_secondImagePath != null ? 1 : 0) + 
    _additionalImagePaths.where((path) => path != null).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Capture Ingredients',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                margin: const EdgeInsets.only(bottom: 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Counter
                    Text(
                      'Photos ($_totalImages/5)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Main Images Row
                    Row(
                      children: [
                        // First Image
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fridge',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
            ),
        ],
      ),
                                child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(widget.firstImagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Second Image
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pantry',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildImageContainer(
                                imagePath: _secondImagePath,
                                onTap: () async {
                                  final path = await _captureImage();
                                  if (path != null) {
                                    setState(() => _secondImagePath = path);
                                  }
                                },
                                height: 160,
                                label: 'Take Pantry Photo',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Additional Images Section
                    if (_secondImagePath != null) ...[
                      const SizedBox(height: 40),  // Added spacing before the additional photos section
                      Text(
                        'Additional Photos (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(3, (index) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index < 2 ? 12 : 0,
                              ),
                              child: _buildImageContainer(
                                imagePath: _additionalImagePaths[index],
                                onTap: _totalImages < 5 ? () async {
                                  final path = await _captureImage();
                                  if (path != null) {
                                    setState(() => _additionalImagePaths[index] = path);
                                  }
                                } : null,
                                height: 100,
                                label: 'Add Photo',
                                small: true,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                    
                    const Spacer(),
                    // Generate Recipe Button
                    if (_secondImagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),  // Added padding to move button up
                        child: GestureDetector(
                          onTap: () {
                            List<String> allPaths = [
                              widget.firstImagePath,
                              _secondImagePath!,
                              ..._additionalImagePaths.where((path) => path != null).cast<String>()
                            ];
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  initialImagePath: allPaths[0],
                                  secondImagePath: allPaths[1],
                                  additionalImagePaths: allPaths.length > 2 ? allPaths.sublist(2) : [],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFB39DDB),  // Softer purple
                                  const Color(0xFF7986CB),  // More blue presence
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7986CB).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Generate Recipe (${_totalImages} Photos)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer({
    String? imagePath,
    required VoidCallback? onTap,
    required double height,
    required String label,
    bool small = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Add remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
      setState(() {
                          if (imagePath == _secondImagePath) {
                            _secondImagePath = null;
    } else {
                            final index = _additionalImagePaths.indexOf(imagePath);
                            if (index != -1) {
                              _additionalImagePaths[index] = null;
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CustomPaint(
                painter: DashedBorderPainter(
                  color: Colors.grey[400]!,
                  strokeWidth: 1,
                  gap: 5.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.grey[600],
                        size: small ? 24 : 32,
                      ),
                      if (!small) const SizedBox(height: 12),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: small ? 12 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<String?> _captureImage() async {
    if (_totalImages >= 5) return null;
    
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      return pickedFile?.path;
    } catch (e) {
      print("Error capturing image: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error capturing image. Please try again.'),
          ),
        );
      }
      return null;
    }
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    this.color = const Color(0xFF8E44AD),
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = 12;
    final Path path = Path();
    
    // Create a rounded rectangle path
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    ));

    // Draw dashed border
    double dashWidth = 5;
    double dashSpace = gap;
    double distance = 0;
    bool shouldDraw = true;
    
    while (distance < size.width * 2 + size.height * 2) {
      if (shouldDraw) {
        // Top edge
        if (distance < size.width) {
          canvas.drawLine(
            Offset(distance, 0),
            Offset(min(distance + dashWidth, size.width), 0),
            dashedPaint,
          );
        }
        // Right edge
        else if (distance < size.width + size.height) {
          canvas.drawLine(
            Offset(size.width, distance - size.width),
            Offset(size.width, min(distance + dashWidth - size.width, size.height)),
            dashedPaint,
          );
        }
        // Bottom edge
        else if (distance < size.width * 2 + size.height) {
          canvas.drawLine(
            Offset(size.width - (distance - size.width - size.height), size.height),
            Offset(max(size.width - (distance + dashWidth - size.width - size.height), 0), size.height),
            dashedPaint,
          );
        }
        // Left edge
        else {
          canvas.drawLine(
            Offset(0, size.height - (distance - size.width * 2 - size.height)),
            Offset(0, max(size.height - (distance + dashWidth - size.width * 2 - size.height), 0)),
            dashedPaint,
          );
        }
      }
      distance += shouldDraw ? dashWidth : dashSpace;
      shouldDraw = !shouldDraw;
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap;
  }
}
