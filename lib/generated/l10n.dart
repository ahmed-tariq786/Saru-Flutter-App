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

  /// `Login / Register`
  String get loginRegister {
    return Intl.message(
      'Login / Register',
      name: 'loginRegister',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Login here`
  String get loginHere {
    return Intl.message('Login here', name: 'loginHere', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `By registering, you accept our`
  String get byRegisteringYouAcceptOur {
    return Intl.message(
      'By registering, you accept our',
      name: 'byRegisteringYouAcceptOur',
      desc: '',
      args: [],
    );
  }

  /// ` Terms and conditions`
  String get termsAndConditions {
    return Intl.message(
      ' Terms and conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// ` and `
  String get and {
    return Intl.message(' and ', name: 'and', desc: '', args: []);
  }

  /// `Privacy Policy.`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy.',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Please enter your last name`
  String get pleaseEnterYourLastName {
    return Intl.message(
      'Please enter your last name',
      name: 'pleaseEnterYourLastName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Please enter your first name`
  String get pleaseEnterYourFirstName {
    return Intl.message(
      'Please enter your first name',
      name: 'pleaseEnterYourFirstName',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Please create an account with your email address`
  String get pleaseCreateAnAccountWithYourEmailAddress {
    return Intl.message(
      'Please create an account with your email address',
      name: 'pleaseCreateAnAccountWithYourEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one uppercase letter, one lowercase letter, and one number`
  String get passwordMustContainAtLeastOneUppercaseLetterOneLowercase {
    return Intl.message(
      'Password must contain at least one uppercase letter, one lowercase letter, and one number',
      name: 'passwordMustContainAtLeastOneUppercaseLetterOneLowercase',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters long`
  String get passwordMustBeAtLeast8CharactersLong {
    return Intl.message(
      'Password must be at least 8 characters long',
      name: 'passwordMustBeAtLeast8CharactersLong',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pleaseEnterYourPassword {
    return Intl.message(
      'Please enter your password',
      name: 'pleaseEnterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get pleaseEnterAValidEmailAddress {
    return Intl.message(
      'Please enter a valid email address',
      name: 'pleaseEnterAValidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get pleaseEnterYourEmail {
    return Intl.message(
      'Please enter your email',
      name: 'pleaseEnterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Please Enter your credentials`
  String get pleaseEnterYourCredentials {
    return Intl.message(
      'Please Enter your credentials',
      name: 'pleaseEnterYourCredentials',
      desc: '',
      args: [],
    );
  }

  /// `New customer? `
  String get newCustomer {
    return Intl.message(
      'New customer? ',
      name: 'newCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Create your account here`
  String get createYourAccountHere {
    return Intl.message(
      'Create your account here',
      name: 'createYourAccountHere',
      desc: '',
      args: [],
    );
  }

  /// `Lost password? `
  String get lostPassword {
    return Intl.message(
      'Lost password? ',
      name: 'lostPassword',
      desc: '',
      args: [],
    );
  }

  /// `Recover password`
  String get recoverPassword {
    return Intl.message(
      'Recover password',
      name: 'recoverPassword',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Cart`
  String get cart {
    return Intl.message('Cart', name: 'cart', desc: '', args: []);
  }

  /// `Brands`
  String get brands {
    return Intl.message('Brands', name: 'brands', desc: '', args: []);
  }

  /// `Categories`
  String get categories {
    return Intl.message('Categories', name: 'categories', desc: '', args: []);
  }

  /// `home`
  String get home {
    return Intl.message('home', name: 'home', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Are you sure you want to logout?`
  String get areYouSureYouWantToLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'areYouSureYouWantToLogout',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Yes, Logout`
  String get yesLogout {
    return Intl.message('Yes, Logout', name: 'yesLogout', desc: '', args: []);
  }

  /// `Addresses`
  String get addresses {
    return Intl.message('Addresses', name: 'addresses', desc: '', args: []);
  }

  /// `No Addresses Added`
  String get noAddressesAdded {
    return Intl.message(
      'No Addresses Added',
      name: 'noAddressesAdded',
      desc: '',
      args: [],
    );
  }

  /// `You haven’t added any addresses yet. Add a new address to make checkout faster and easier.`
  String get youHaventAddedAnyAddressesYetAddANewAddress {
    return Intl.message(
      'You haven’t added any addresses yet. Add a new address to make checkout faster and easier.',
      name: 'youHaventAddedAnyAddressesYetAddANewAddress',
      desc: '',
      args: [],
    );
  }

  /// `Add a New Address`
  String get addANewAddress {
    return Intl.message(
      'Add a New Address',
      name: 'addANewAddress',
      desc: '',
      args: [],
    );
  }

  /// `Delete Address`
  String get deleteAddress {
    return Intl.message(
      'Delete Address',
      name: 'deleteAddress',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this address?`
  String get areYouSureYouWantToDeleteThisAddress {
    return Intl.message(
      'Are you sure you want to delete this address?',
      name: 'areYouSureYouWantToDeleteThisAddress',
      desc: '',
      args: [],
    );
  }

  /// `Yes, Delete`
  String get yesDelete {
    return Intl.message('Yes, Delete', name: 'yesDelete', desc: '', args: []);
  }

  /// `Address deleted successfully`
  String get addressDeletedSuccessfully {
    return Intl.message(
      'Address deleted successfully',
      name: 'addressDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while deleting the address. Please try again.`
  String get anErrorOccurredWhileDeletingTheAddressPleaseTryAgain {
    return Intl.message(
      'An error occurred while deleting the address. Please try again.',
      name: 'anErrorOccurredWhileDeletingTheAddressPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Set as default address`
  String get setAsDefaultAddress {
    return Intl.message(
      'Set as default address',
      name: 'setAsDefaultAddress',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number`
  String get pleaseEnterYourPhoneNumber {
    return Intl.message(
      'Please enter your phone number',
      name: 'pleaseEnterYourPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your Postal/Zip code`
  String get pleaseEnterYourPostalzipCode {
    return Intl.message(
      'Please enter your Postal/Zip code',
      name: 'pleaseEnterYourPostalzipCode',
      desc: '',
      args: [],
    );
  }

  /// `Postal/Zip Code`
  String get postalzipCode {
    return Intl.message(
      'Postal/Zip Code',
      name: 'postalzipCode',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `Please enter your country`
  String get pleaseEnterYourCountry {
    return Intl.message(
      'Please enter your country',
      name: 'pleaseEnterYourCountry',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `Please enter your city`
  String get pleaseEnterYourCity {
    return Intl.message(
      'Please enter your city',
      name: 'pleaseEnterYourCity',
      desc: '',
      args: [],
    );
  }

  /// `Apartment, suite, etc.`
  String get apartmentSuiteEtc {
    return Intl.message(
      'Apartment, suite, etc.',
      name: 'apartmentSuiteEtc',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Please enter your address`
  String get pleaseEnterYourAddress {
    return Intl.message(
      'Please enter your address',
      name: 'pleaseEnterYourAddress',
      desc: '',
      args: [],
    );
  }

  /// `Company`
  String get company {
    return Intl.message('Company', name: 'company', desc: '', args: []);
  }

  /// `Failed to add address`
  String get failedToAddAddress {
    return Intl.message(
      'Failed to add address',
      name: 'failedToAddAddress',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get addAddress {
    return Intl.message('Add Address', name: 'addAddress', desc: '', args: []);
  }

  /// `Edit Address`
  String get editAddress {
    return Intl.message(
      'Edit Address',
      name: 'editAddress',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `An unknown error occurred.`
  String get anUnknownErrorOccurred {
    return Intl.message(
      'An unknown error occurred.',
      name: 'anUnknownErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while updating the address. Please try again.`
  String get anErrorOccurredWhileUpdatingTheAddressPleaseTryAgain {
    return Intl.message(
      'An error occurred while updating the address. Please try again.',
      name: 'anErrorOccurredWhileUpdatingTheAddressPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `This customer account is already active.`
  String get thisCustomerAccountIsAlreadyActive {
    return Intl.message(
      'This customer account is already active.',
      name: 'thisCustomerAccountIsAlreadyActive',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address. The domain name is invalid.`
  String get pleaseEnterAValidEmailAddressTheDomainNameIs {
    return Intl.message(
      'Please enter a valid email address. The domain name is invalid.',
      name: 'pleaseEnterAValidEmailAddressTheDomainNameIs',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all required fields.`
  String get pleaseFillInAllRequiredFields {
    return Intl.message(
      'Please fill in all required fields.',
      name: 'pleaseFillInAllRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Please remove any HTML tags from your input.`
  String get pleaseRemoveAnyHtmlTagsFromYourInput {
    return Intl.message(
      'Please remove any HTML tags from your input.',
      name: 'pleaseRemoveAnyHtmlTagsFromYourInput',
      desc: '',
      args: [],
    );
  }

  /// `URLs are not allowed in this field.`
  String get urlsAreNotAllowedInThisField {
    return Intl.message(
      'URLs are not allowed in this field.',
      name: 'urlsAreNotAllowedInThisField',
      desc: '',
      args: [],
    );
  }

  /// `This customer account has been disabled. Please contact support.`
  String get thisCustomerAccountHasBeenDisabledPleaseContactSupport {
    return Intl.message(
      'This customer account has been disabled. Please contact support.',
      name: 'thisCustomerAccountHasBeenDisabledPleaseContactSupport',
      desc: '',
      args: [],
    );
  }

  /// `The information you entered is invalid. Please check and try again.`
  String get theInformationYouEnteredIsInvalidPleaseCheckAndTry {
    return Intl.message(
      'The information you entered is invalid. Please check and try again.',
      name: 'theInformationYouEnteredIsInvalidPleaseCheckAndTry',
      desc: '',
      args: [],
    );
  }

  /// `Authentication token is invalid. Please try logging in again.`
  String get authenticationTokenIsInvalidPleaseTryLoggingInAgain {
    return Intl.message(
      'Authentication token is invalid. Please try logging in again.',
      name: 'authenticationTokenIsInvalidPleaseTryLoggingInAgain',
      desc: '',
      args: [],
    );
  }

  /// `The requested information could not be found.`
  String get theRequestedInformationCouldNotBeFound {
    return Intl.message(
      'The requested information could not be found.',
      name: 'theRequestedInformationCouldNotBeFound',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot start or end with spaces. Please remove extra spaces.`
  String get passwordCannotStartOrEndWithSpacesPleaseRemoveExtra {
    return Intl.message(
      'Password cannot start or end with spaces. Please remove extra spaces.',
      name: 'passwordCannotStartOrEndWithSpacesPleaseRemoveExtra',
      desc: '',
      args: [],
    );
  }

  /// `Email already exists. Please use a different email or try logging in.`
  String get emailAlreadyExistsPleaseUseADifferentEmailOrTry {
    return Intl.message(
      'Email already exists. Please use a different email or try logging in.',
      name: 'emailAlreadyExistsPleaseUseADifferentEmailOrTry',
      desc: '',
      args: [],
    );
  }

  /// `This information is already in use. Please try a different value.`
  String get thisInformationIsAlreadyInUsePleaseTryADifferent {
    return Intl.message(
      'This information is already in use. Please try a different value.',
      name: 'thisInformationIsAlreadyInUsePleaseTryADifferent',
      desc: '',
      args: [],
    );
  }

  /// `The activation token is invalid or has expired. Please request a new one.`
  String get theActivationTokenIsInvalidOrHasExpiredPleaseRequest {
    return Intl.message(
      'The activation token is invalid or has expired. Please request a new one.',
      name: 'theActivationTokenIsInvalidOrHasExpiredPleaseRequest',
      desc: '',
      args: [],
    );
  }

  /// `Password is too long. Please use a shorter password.`
  String get passwordIsTooLongPleaseUseAShorterPassword {
    return Intl.message(
      'Password is too long. Please use a shorter password.',
      name: 'passwordIsTooLongPleaseUseAShorterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Name is too long. Please use a shorter name.`
  String get nameIsTooLongPleaseUseAShorterName {
    return Intl.message(
      'Name is too long. Please use a shorter name.',
      name: 'nameIsTooLongPleaseUseAShorterName',
      desc: '',
      args: [],
    );
  }

  /// `The input is too long. Please use fewer characters.`
  String get theInputIsTooLongPleaseUseFewerCharacters {
    return Intl.message(
      'The input is too long. Please use fewer characters.',
      name: 'theInputIsTooLongPleaseUseFewerCharacters',
      desc: '',
      args: [],
    );
  }

  /// `The input is too short. Please add more characters.`
  String get theInputIsTooShortPleaseAddMoreCharacters {
    return Intl.message(
      'The input is too short. Please add more characters.',
      name: 'theInputIsTooShortPleaseAddMoreCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Customer account not found. Please check your information or create a new account.`
  String get customerAccountNotFoundPleaseCheckYourInformationOrCreate {
    return Intl.message(
      'Customer account not found. Please check your information or create a new account.',
      name: 'customerAccountNotFoundPleaseCheckYourInformationOrCreate',
      desc: '',
      args: [],
    );
  }

  /// `Account creation limit reached. Please wait a few minutes before trying again.`
  String get accountCreationLimitReachedPleaseWaitAFewMinutesBefore {
    return Intl.message(
      'Account creation limit reached. Please wait a few minutes before trying again.',
      name: 'accountCreationLimitReachedPleaseWaitAFewMinutesBefore',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak. Please use a stronger password.`
  String get passwordIsTooWeakPleaseUseAStrongerPassword {
    return Intl.message(
      'Password is too weak. Please use a stronger password.',
      name: 'passwordIsTooWeakPleaseUseAStrongerPassword',
      desc: '',
      args: [],
    );
  }

  /// `Too many attempts. Please wait a moment before trying again.`
  String get tooManyAttemptsPleaseWaitAMomentBeforeTryingAgain {
    return Intl.message(
      'Too many attempts. Please wait a moment before trying again.',
      name: 'tooManyAttemptsPleaseWaitAMomentBeforeTryingAgain',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Please check your connection and try again.`
  String get networkErrorPleaseCheckYourConnectionAndTryAgain {
    return Intl.message(
      'Network error. Please check your connection and try again.',
      name: 'networkErrorPleaseCheckYourConnectionAndTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected error occurred.`
  String get unexpectedErrorOccurred {
    return Intl.message(
      'Unexpected error occurred.',
      name: 'unexpectedErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred. Please try again.`
  String get anUnexpectedErrorOccurredPleaseTryAgain {
    return Intl.message(
      'An unexpected error occurred. Please try again.',
      name: 'anUnexpectedErrorOccurredPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `No Orders Yet`
  String get noOrdersYet {
    return Intl.message(
      'No Orders Yet',
      name: 'noOrdersYet',
      desc: '',
      args: [],
    );
  }

  /// `You haven't placed any orders yet. Start shopping to see your orders here.`
  String get youHaventPlacedAnyOrdersYetStartShoppingToSee {
    return Intl.message(
      'You haven\'t placed any orders yet. Start shopping to see your orders here.',
      name: 'youHaventPlacedAnyOrdersYetStartShoppingToSee',
      desc: '',
      args: [],
    );
  }

  /// `Billing address`
  String get billingAddress {
    return Intl.message(
      'Billing address',
      name: 'billingAddress',
      desc: '',
      args: [],
    );
  }

  /// `Shipping address`
  String get shippingAddress {
    return Intl.message(
      'Shipping address',
      name: 'shippingAddress',
      desc: '',
      args: [],
    );
  }

  /// `Contact information`
  String get contactInformation {
    return Intl.message(
      'Contact information',
      name: 'contactInformation',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message('Payment', name: 'payment', desc: '', args: []);
  }

  /// `Free`
  String get free {
    return Intl.message('Free', name: 'free', desc: '', args: []);
  }

  /// `Shipping`
  String get shipping {
    return Intl.message('Shipping', name: 'shipping', desc: '', args: []);
  }

  /// `No items in this order.`
  String get noItemsInThisOrder {
    return Intl.message(
      'No items in this order.',
      name: 'noItemsInThisOrder',
      desc: '',
      args: [],
    );
  }

  /// `View Order Online`
  String get viewOrderOnline {
    return Intl.message(
      'View Order Online',
      name: 'viewOrderOnline',
      desc: '',
      args: [],
    );
  }

  /// `Refunded`
  String get refunded {
    return Intl.message('Refunded', name: 'refunded', desc: '', args: []);
  }

  /// `Partially Refunded`
  String get partiallyRefunded {
    return Intl.message(
      'Partially Refunded',
      name: 'partiallyRefunded',
      desc: '',
      args: [],
    );
  }

  /// `Voided`
  String get voided {
    return Intl.message('Voided', name: 'voided', desc: '', args: []);
  }

  /// `Authorized`
  String get authorized {
    return Intl.message('Authorized', name: 'authorized', desc: '', args: []);
  }

  /// `Partially Paid`
  String get partiallyPaid {
    return Intl.message(
      'Partially Paid',
      name: 'partiallyPaid',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Fulfilled`
  String get fulfilled {
    return Intl.message('Fulfilled', name: 'fulfilled', desc: '', args: []);
  }

  /// `Partially Fulfilled`
  String get partiallyFulfilled {
    return Intl.message(
      'Partially Fulfilled',
      name: 'partiallyFulfilled',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message('In Progress', name: 'inProgress', desc: '', args: []);
  }

  /// `On Hold`
  String get onHold {
    return Intl.message('On Hold', name: 'onHold', desc: '', args: []);
  }

  /// `Unfulfilled`
  String get unfulfilled {
    return Intl.message('Unfulfilled', name: 'unfulfilled', desc: '', args: []);
  }

  /// `Restocked`
  String get restocked {
    return Intl.message('Restocked', name: 'restocked', desc: '', args: []);
  }

  /// `Scheduled`
  String get scheduled {
    return Intl.message('Scheduled', name: 'scheduled', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Paid`
  String get paid {
    return Intl.message('Paid', name: 'paid', desc: '', args: []);
  }

  /// `Profile updated successfully`
  String get profileUpdatedSuccessfully {
    return Intl.message(
      'Profile updated successfully',
      name: 'profileUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update customer information. Please try again.`
  String get failedToUpdateCustomerInformationPleaseTryAgain {
    return Intl.message(
      'Failed to update customer information. Please try again.',
      name: 'failedToUpdateCustomerInformationPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred. Please try again later.`
  String get anUnexpectedErrorOccurredPleaseTryAgainLater {
    return Intl.message(
      'An unexpected error occurred. Please try again later.',
      name: 'anUnexpectedErrorOccurredPleaseTryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create customer account. Please try again.`
  String get failedToCreateCustomerAccountPleaseTryAgain {
    return Intl.message(
      'Failed to create customer account. Please try again.',
      name: 'failedToCreateCustomerAccountPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create customer. Please try again.`
  String get failedToCreateCustomerPleaseTryAgain {
    return Intl.message(
      'Failed to create customer. Please try again.',
      name: 'failedToCreateCustomerPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create access token. Please try again.`
  String get failedToCreateAccessTokenPleaseTryAgain {
    return Intl.message(
      'Failed to create access token. Please try again.',
      name: 'failedToCreateAccessTokenPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email or password. Please check your credentials and try again.`
  String get invalidEmailOrPasswordPleaseCheckYourCredentialsAndTry {
    return Intl.message(
      'Invalid email or password. Please check your credentials and try again.',
      name: 'invalidEmailOrPasswordPleaseCheckYourCredentialsAndTry',
      desc: '',
      args: [],
    );
  }

  /// `Failed to log in. Please try again.`
  String get failedToLogInPleaseTryAgain {
    return Intl.message(
      'Failed to log in. Please try again.',
      name: 'failedToLogInPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Too many login attempts. Please wait a few minutes before trying again.`
  String get tooManyLoginAttemptsPleaseWaitAFewMinutesBefore {
    return Intl.message(
      'Too many login attempts. Please wait a few minutes before trying again.',
      name: 'tooManyLoginAttemptsPleaseWaitAFewMinutesBefore',
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
