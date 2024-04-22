import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/pixabay.dart';
import '../models/pixabay.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageSearchTerm = '';
  String error = '';

  bool isLoading = false;

  final images = <PixabayModel>[];

  void fetchImages(String searchTerm) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(PixabayConfig.fetchImages(searchTerm)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        images.clear();

        for (var imageData in data['hits']) {
          images.add(PixabayModel.fromJson(imageData));
        }

        setState(() {
          isLoading = false;
          error = '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching images: $e');
      setState(() {
        error = 'Error fetching images: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Gallery App',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: images.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for images',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          fetchImages(imageSearchTerm);
                        },
                      ),
                    ),
                    onChanged: (value) {
                      imageSearchTerm = value;
                    },
                    onSubmitted: (value) {
                      fetchImages(value);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        isLoading
                            ? 'Loading images...'
                            : error.isEmpty
                                ? 'No images to display'
                                : error,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constrains) {
                if (constrains.maxWidth < 600) {
                  return ListView(
                    children: <Widget>[
                      ...images.map((image) {
                        return ImageContainer(image: image);
                      }),
                    ],
                  );
                }

                final crossAxisCount = constrains.maxWidth ~/ 200;
                final height = constrains.maxWidth / crossAxisCount;
                final width = constrains.maxWidth / crossAxisCount;

                return SingleChildScrollView(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      ...images.map((image) {
                        return ImageContainer(
                          width: width,
                          height: height,
                          image: image,
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ImageContainer extends StatelessWidget {
  final PixabayModel image;
  final double? width;
  final double? height;
  const ImageContainer({
    super.key,
    required this.image,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 0 + 24,
      child: InkWell(
        onTap: () {
          //
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    foregroundColor: Colors.white,
                  ),
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Image.network(
                      image.largeImageURL,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              fullscreenDialog: true,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  image.webformatURL,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.remove_red_eye, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${image.views}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const Icon(Icons.favorite, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${image.likes}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
