final class PixabayConfig {
  static const String pixabayUrl = 'https://pixabay.com/api';
  static const String key = '43475296-7783bd839a17dad6293d2114b';
  static const String imageType = 'photo';

  static const String searchImages =
      '$pixabayUrl/?key=$key&image_type=$imageType&q=';

  static String fetchImages(String searchTerm) {
    return '$searchImages$searchTerm';
  }
}
