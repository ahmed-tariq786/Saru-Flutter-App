class SearchSuggestions {
  final String text;

  SearchSuggestions({required this.text});

  factory SearchSuggestions.fromJson(String json) {
    return SearchSuggestions(
      text: json,
    );
  }
}
