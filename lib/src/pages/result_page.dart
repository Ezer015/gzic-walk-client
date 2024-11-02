import 'package:flutter/material.dart';

import '../service.dart';

class ResultPage extends StatefulWidget {
  final int imageID;

  const ResultPage({
    super.key,
    required this.imageID,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  static const List<({String name, String prompt})> _options = [
    (
      name: 'Facebook',
      prompt: '''
You have sight data in the format <name>:<description>. Based on this information, write Facebook posts that highlight each sight’s unique qualities in an engaging and inviting way. Make each post informative yet conversational, encouraging followers to interact. Follow these guidelines:

    Start with a short, eye-catching statement or question to draw readers in (e.g., 'Have you ever seen...', 'Dreaming of this view...', 'Ready for an adventure?').
    Use friendly, conversational language to describe what makes each sight special or worth visiting.
    Add a call to action to encourage interaction (e.g., 'Tag someone who’d love this!', 'Share if this is on your travel list!', 'Have you been here? Tell us your story!').
    Incorporate 1-3 relevant hashtags, and if appropriate, include an emoji to keep the tone light and engaging.

Examples:

    Input: Venice Canals: Known for romantic gondola rides and stunning waterways lined with charming architecture.
        Output: "Ever wanted to glide through the canals of Venice? 🛶✨ Imagine romantic gondola rides, historic architecture, and sunset views over the water. Tag someone you’d explore Venice with! #VeniceDreams #TravelBucketList"
    Input: Yosemite National Park: Home to majestic waterfalls, towering cliffs, and unforgettable scenic hikes.
        Output: "Nature lovers, this one’s for you! 🌲💦 Yosemite National Park is calling with its breathtaking waterfalls, scenic trails, and views that belong on a postcard. Who would you take on this adventure? #YosemiteNationalPark #NatureEscape"

Instructions: Create similar Facebook posts for each <name>:<description> pair, focusing on engaging language, vivid descriptions, and a friendly invitation to interact.
'''
    ),
    (
      name: 'Twitter',
      prompt: '''
You have data on various sights in the format <name>:<description>. Based on this information, create engaging Twitter posts to capture attention quickly and encourage engagement. The style should be concise, with a clear and captivating message for each sight. Follow these guidelines:

    Begin with a strong hook or intriguing fact.
    Use a conversational or slightly playful tone, appropriate for Twitter’s social atmosphere.
    Keep each tweet to 280 characters or less.
    Include a hashtag or two that relates to travel or the sight itself, and if relevant, add an emoji to enhance the tone.
    Add a call to action if possible (e.g., ‘RT if you’d go!’, ‘Would you visit?’, ‘What’s on your bucket list?’).

Examples:

    Input: Grand Canyon: An immense canyon in Arizona known for its stunning landscapes and incredible hikes.
        Output: "The Grand Canyon is calling! 🌄 Whether it’s the epic views or trails that excite you, this natural wonder is a must-see. Who's down for an adventure? #BucketList #TravelGoals"
    Input: Machu Picchu: An ancient Incan city nestled in the Andes mountains, celebrated for its historical significance and breathtaking views.
        Output: "Lost in time and surrounded by clouds… Machu Picchu is everything you'd expect and more! 🏔️ Ready to tick this off your bucket list? #Wanderlust #MachuPicchu"

Instructions: Generate similar Twitter copy for each <name>:<description> pair, focusing on brevity, strong visuals, and encouraging engagement.
'''
    ),
    (
      name: 'Instagram',
      prompt: '''
You have data on various sights formatted as <name>:<description>. Based on this data, write captivating Instagram captions that highlight the unique aspects of each sight and inspire followers to engage. Make the captions visually descriptive, adding a sense of wonder and excitement. Follow these guidelines:

    Start with a captivating opener to grab attention (e.g., 'Picture this...', 'Can you believe this view?', 'One word: WOW').
    Use descriptive language that evokes imagery or emotions to complement a photo of the sight.
    Include a lighthearted call to action (e.g., ‘Save this post for later!’, ‘Tag who you’d go with!’, ‘Double tap if this is on your list!’).
    Use up to 5 relevant hashtags for reach (e.g., #Wanderlust, #TravelGoals, #BucketList, #Explore).
    Keep the caption concise but expressive, ideally under 125 characters for the initial hook, with more detail or emoji emphasis if needed.

Examples:

    Input: Santorini: Famous for its white-washed buildings and stunning sunsets over the Aegean Sea.
        Output: "Santorini sunsets are pure magic.✨🌅 The blue roofs, the golden skies... it’s a scene from a dream! Who’s adding this to their travel list? #SantoriniDream #Wanderlust #SunsetLovers"
    Input: Great Wall of China: One of the most iconic structures in history, offering breathtaking views and rich cultural significance.
        Output: "Walking through history at the Great Wall of China 🇨🇳💫 A journey through time and stunning landscapes! Who’s up for the climb? #GreatWall #TravelGoals #AsiaAdventures"

Instructions: Generate Instagram captions for each <name>:<description> pair. Make each one visually inviting and add hashtags to boost engagement.
'''
    ),
  ];

  late final TextEditingController _nameController =
      TextEditingController(text: "");
  late final TextEditingController _descriptionController =
      TextEditingController(text: "");
  int? _id;
  String _name = "";
  String _description = "";

  String? _prompt = _options.first.prompt;
  bool _nameEditable = false;
  bool _recognitionCompleted = false;
  bool _generationCompleted = true;
  bool _imageAvailable = false;

  @override
  void initState() {
    super.initState();
    RemoteApi.getRecognitionResult(widget.imageID).then((sight) {
      if (sight == null) {
        setState(() {
          _recognitionCompleted = true;
          _nameEditable = true;
        });
        return;
      }
      setState(() {
        _nameController.text = sight.sightName;
        _descriptionController.text = sight.sightDescription;
        _id = sight.sightID;
        _name = sight.sightName;
        _description = sight.sightDescription;
        _recognitionCompleted = true;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Image
    var processedImage = AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: Image.network(
          RemoteApi.assembleUri(
            RemoteApiPath.image,
            pathParameter: widget.imageID.toString(),
          ).toString(),
          width: MediaQuery.of(context).size.width * 0.8,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => setState(() => _imageAvailable = true));
              return child;
            }
            return Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                ),
              ],
            );
          },
          errorBuilder: (context, error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => setState(() => _imageAvailable = false));
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.error,
                    color: Theme.of(context).colorScheme.error,
                    size: 50,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    // Buttons outside the Card
    var actions = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  if (!_recognitionCompleted || !_imageAvailable) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Processing not finished yet'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  if (_name == "") {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Name cannot be empty'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  if (_description == "") {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Description cannot be empty'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final recordID = await RemoteApi.createRecord(
                    imageID: widget.imageID,
                    sightID: _id,
                    sightName: _name,
                    copywriting: _description,
                  );
                  if (recordID == null) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create card'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  CollectionApi.addFavorite(recordID);
                  if (_id != null) {
                    CollectionApi.addDiscovery(
                      sightID: _id!,
                      recordID: recordID,
                    );
                  }

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Card created successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Name
    var nameField = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Stack(
                    children: [
                      TextField(
                        readOnly: !_nameEditable,
                        controller: _nameController,
                        maxLines: 1,
                        onChanged: (value) => setState(() => _name = value),
                        decoration: InputDecoration(
                          hintText:
                              _recognitionCompleted ? '' : '  Processing ...',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.2),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      if (_recognitionCompleted && !_nameEditable) ...[
                        Positioned.directional(
                          textDirection: Directionality.of(context),
                          end: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                setState(() => _nameEditable = true),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    var descriptionField = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How",
            style: TextStyle(
              fontSize: 12.0,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12.0),
            child: TextField(
              readOnly: !_recognitionCompleted,
              controller: _descriptionController,
              maxLines: 8,
              onChanged: (value) => setState(() => _description = value),
              decoration: InputDecoration(
                hintText: _recognitionCompleted ? '' : '  Processing ...',
                hintStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.2),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    var promptActionRow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text('Style',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).colorScheme.primary)),
          const SizedBox(width: 16.0),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _prompt,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.2),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
              ),
              items: [
                for (var option in _options)
                  DropdownMenuItem(
                    value: option.prompt,
                    child: Text(' ${option.name}'),
                  ),
              ],
              onChanged: (value) => setState(() => _prompt = value),
            ),
          ),
          IconButton(
            icon: _generationCompleted
                ? const Icon(Icons.send)
                : const Icon(Icons.hourglass_empty),
            onPressed: _generationCompleted
                ? () async {
                    setState(() {
                      _generationCompleted = false;
                    });
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final generatedTextID = await RemoteApi.generateCopywriting(
                        name: _name,
                        description: _description,
                        prompt: _prompt ?? _options.first.prompt);
                    if (generatedTextID == null) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to generate copywriting'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    int retryCount = 0;
                    const int maxRetries = 5;
                    while (retryCount < maxRetries) {
                      final copywritingResult =
                          await RemoteApi.getCopywriting(generatedTextID);
                      if (copywritingResult != null) {
                        setState(() {
                          _descriptionController.text = copywritingResult;
                          _description = copywritingResult;
                          _generationCompleted = true;
                        });
                        return;
                      }
                      retryCount++;
                      await Future.delayed(const Duration(seconds: 1));
                    }
                    setState(() => _generationCompleted = true);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to get generated copywriting'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 8,
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    processedImage,
                    const SizedBox(height: 12.0),
                    // Name
                    nameField,
                    // Description
                    descriptionField,
                    const SizedBox(height: 12.0),
                    // Prompt
                    promptActionRow,
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              actions,
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
