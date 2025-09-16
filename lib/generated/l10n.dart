// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `BEST SELLER`
  String get BestSeller {
    return Intl.message('BEST SELLER', name: 'BestSeller', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Add to Cart`
  String get atc {
    return Intl.message('Add to Cart', name: 'atc', desc: '', args: []);
  }

  /// `Descriptions`
  String get Description {
    return Intl.message(
      'Descriptions',
      name: 'Description',
      desc: '',
      args: [],
    );
  }

  /// `Specifications`
  String get Specifications {
    return Intl.message(
      'Specifications',
      name: 'Specifications',
      desc: '',
      args: [],
    );
  }

  /// `See Less`
  String get seeLess {
    return Intl.message('See Less', name: 'seeLess', desc: '', args: []);
  }

  /// `See More`
  String get seeMore {
    return Intl.message('See More', name: 'seeMore', desc: '', args: []);
  }

  /// `Out of Stock`
  String get outOfStock {
    return Intl.message('Out of Stock', name: 'outOfStock', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Recommended Products`
  String get recommendedProducts {
    return Intl.message(
      'Recommended Products',
      name: 'recommendedProducts',
      desc: '',
      args: [],
    );
  }

  /// `Suggestions`
  String get suggestions {
    return Intl.message('Suggestions', name: 'suggestions', desc: '', args: []);
  }

  /// `Products`
  String get products {
    return Intl.message('Products', name: 'products', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `No Suggestions Found`
  String get noSuggestionsFound {
    return Intl.message(
      'No Suggestions Found',
      name: 'noSuggestionsFound',
      desc: '',
      args: [],
    );
  }

  /// `Try searching with different keywords`
  String get trySearchingWithDifferentKeywords {
    return Intl.message(
      'Try searching with different keywords',
      name: 'trySearchingWithDifferentKeywords',
      desc: '',
      args: [],
    );
  }

  /// `No products found`
  String get noProductsFound {
    return Intl.message(
      'No products found',
      name: 'noProductsFound',
      desc: '',
      args: [],
    );
  }

  /// `Recently Searched`
  String get recentlySearched {
    return Intl.message(
      'Recently Searched',
      name: 'recentlySearched',
      desc: '',
      args: [],
    );
  }

  /// `Search the products`
  String get searchTheProducts {
    return Intl.message(
      'Search the products',
      name: 'searchTheProducts',
      desc: '',
      args: [],
    );
  }

  /// `All products`
  String get allProducts {
    return Intl.message(
      'All products',
      name: 'allProducts',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message('View All', name: 'viewAll', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Showing`
  String get showing {
    return Intl.message('Showing', name: 'showing', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Filter By`
  String get filterBy {
    return Intl.message('Filter By', name: 'filterBy', desc: '', args: []);
  }

  /// `Bag`
  String get bag {
    return Intl.message('Bag', name: 'bag', desc: '', args: []);
  }

  /// `item(s))`
  String get items {
    return Intl.message('item(s))', name: 'items', desc: '', args: []);
  }

  /// `Your cart is empty`
  String get yourCartIsEmpty {
    return Intl.message(
      'Your cart is empty',
      name: 'yourCartIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations!`
  String get congratulations {
    return Intl.message(
      'Congratulations!',
      name: 'congratulations',
      desc: '',
      args: [],
    );
  }

  /// ` You've got free shipping!`
  String get youveGotFreeShipping {
    return Intl.message(
      ' You\'ve got free shipping!',
      name: 'youveGotFreeShipping',
      desc: '',
      args: [],
    );
  }

  /// `Want Free Shipping?`
  String get wantFreeShipping {
    return Intl.message(
      'Want Free Shipping?',
      name: 'wantFreeShipping',
      desc: '',
      args: [],
    );
  }

  /// ` Add `
  String get add {
    return Intl.message(' Add ', name: 'add', desc: '', args: []);
  }

  /// ` more`
  String get kdMore {
    return Intl.message(' more', name: 'kdMore', desc: '', args: []);
  }

  /// `Add some products to your cart`
  String get addSomeProductsToYourCart {
    return Intl.message(
      'Add some products to your cart',
      name: 'addSomeProductsToYourCart',
      desc: '',
      args: [],
    );
  }

  /// `Shop Now`
  String get shopNow {
    return Intl.message('Shop Now', name: 'shopNow', desc: '', args: []);
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message('Subtotal', name: 'subtotal', desc: '', args: []);
  }

  /// `You Saved: `
  String get youSaved {
    return Intl.message('You Saved: ', name: 'youSaved', desc: '', args: []);
  }

  /// `Checkout`
  String get checkout {
    return Intl.message('Checkout', name: 'checkout', desc: '', args: []);
  }

  /// `Oops! Nothing here yet.`
  String get oopsNothingHereYet {
    return Intl.message(
      'Oops! Nothing here yet.',
      name: 'oopsNothingHereYet',
      desc: '',
      args: [],
    );
  }

  /// `Check back later or explore other categories.`
  String get checkBackLaterOrExploreOtherCategories {
    return Intl.message(
      'Check back later or explore other categories.',
      name: 'checkBackLaterOrExploreOtherCategories',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favorites {
    return Intl.message('Favorites', name: 'favorites', desc: '', args: []);
  }

  /// `YOU MAY ALSO LIKE`
  String get youMayAlsoLike {
    return Intl.message(
      'YOU MAY ALSO LIKE',
      name: 'youMayAlsoLike',
      desc: '',
      args: [],
    );
  }

  /// `About Saru`
  String get aboutSaru {
    return Intl.message('About Saru', name: 'aboutSaru', desc: '', args: []);
  }

  /// `Sort By`
  String get sortBy {
    return Intl.message('Sort By', name: 'sortBy', desc: '', args: []);
  }

  /// `Best selling`
  String get bestSelling {
    return Intl.message(
      'Best selling',
      name: 'bestSelling',
      desc: '',
      args: [],
    );
  }

  /// `Featured`
  String get featured {
    return Intl.message('Featured', name: 'featured', desc: '', args: []);
  }

  /// `New`
  String get newProducts {
    return Intl.message('New', name: 'newProducts', desc: '', args: []);
  }

  /// `Low to high`
  String get lowToHigh {
    return Intl.message('Low to high', name: 'lowToHigh', desc: '', args: []);
  }

  /// `High to low`
  String get highToLow {
    return Intl.message('High to low', name: 'highToLow', desc: '', args: []);
  }

  /// `In Stock`
  String get inStock {
    return Intl.message('In Stock', name: 'inStock', desc: '', args: []);
  }

  /// `Availability`
  String get availability {
    return Intl.message(
      'Availability',
      name: 'availability',
      desc: '',
      args: [],
    );
  }

  /// `Relevance`
  String get relevance {
    return Intl.message('Relevance', name: 'relevance', desc: '', args: []);
  }

  /// `Coupon code`
  String get couponCode {
    return Intl.message('Coupon code', name: 'couponCode', desc: '', args: []);
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Search Brands`
  String get searchBrands {
    return Intl.message(
      'Search Brands',
      name: 'searchBrands',
      desc: '',
      args: [],
    );
  }

  /// `Best Seller`
  String get bestSeller {
    return Intl.message('Best Seller', name: 'bestSeller', desc: '', args: []);
  }

  /// `Explore Our Products`
  String get exploreOurProducts {
    return Intl.message(
      'Explore Our Products',
      name: 'exploreOurProducts',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
