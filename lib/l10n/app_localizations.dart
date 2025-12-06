import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Spare'**
  String get appTitle;

  /// No description provided for @brandProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Brand products'**
  String get brandProductsTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or code'**
  String get searchHint;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHigh;

  /// No description provided for @sortStockHigh.
  ///
  /// In en, this message translates to:
  /// **'Stock: High to Low'**
  String get sortStockHigh;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProducts;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access the app'**
  String get login_subtitle;

  /// No description provided for @login_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login_email_label;

  /// No description provided for @login_email_hint.
  ///
  /// In en, this message translates to:
  /// **'example@mail.com'**
  String get login_email_hint;

  /// No description provided for @login_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password_label;

  /// No description provided for @login_password_hint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get login_password_hint;

  /// No description provided for @login_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get login_required;

  /// No description provided for @login_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get login_remember_me;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login_button;

  /// No description provided for @login_signup_button.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get login_signup_button;

  /// No description provided for @login_with_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get login_with_google;

  /// No description provided for @login_continue_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get login_continue_as_guest;

  /// No description provided for @login_fix_errors_message.
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors in the form.'**
  String get login_fix_errors_message;

  /// No description provided for @login_invalid_credentials_message.
  ///
  /// In en, this message translates to:
  /// **'Invalid login credentials'**
  String get login_invalid_credentials_message;

  /// No description provided for @login_winch_not_approved_message.
  ///
  /// In en, this message translates to:
  /// **'Winch account is not activated yet.'**
  String get login_winch_not_approved_message;

  /// No description provided for @login_guest_name.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get login_guest_name;

  /// No description provided for @home_no_products_available.
  ///
  /// In en, this message translates to:
  /// **'No products are currently available'**
  String get home_no_products_available;

  /// No description provided for @home_no_search_results.
  ///
  /// In en, this message translates to:
  /// **'No results match your search'**
  String get home_no_search_results;

  /// No description provided for @home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for a part...'**
  String get home_search_hint;

  /// No description provided for @home_sort_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort results'**
  String get home_sort_tooltip;

  /// No description provided for @home_sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get home_sort_newest;

  /// No description provided for @home_sort_oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get home_sort_oldest;

  /// No description provided for @home_sort_price_low.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get home_sort_price_low;

  /// No description provided for @home_sort_price_high.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get home_sort_price_high;

  /// No description provided for @home_sort_stock_high.
  ///
  /// In en, this message translates to:
  /// **'Highest stock'**
  String get home_sort_stock_high;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nav_categories;

  /// No description provided for @nav_tow.
  ///
  /// In en, this message translates to:
  /// **'Tow'**
  String get nav_tow;

  /// No description provided for @nav_cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get nav_cart;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get nav_profile;

  /// No description provided for @common_language_toggle_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get common_language_toggle_tooltip;

  /// No description provided for @signup_title.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signup_title;

  /// No description provided for @signup_role_buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get signup_role_buyer;

  /// No description provided for @signup_role_seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get signup_role_seller;

  /// No description provided for @signup_role_tow.
  ///
  /// In en, this message translates to:
  /// **'Tow company'**
  String get signup_role_tow;

  /// No description provided for @signup_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signup_email_label;

  /// No description provided for @signup_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signup_password_label;

  /// No description provided for @signup_password_confirm_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get signup_password_confirm_label;

  /// No description provided for @signup_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get signup_name_label;

  /// No description provided for @signup_address_label.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get signup_address_label;

  /// No description provided for @signup_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get signup_phone_label;

  /// No description provided for @signup_store_name_label.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get signup_store_name_label;

  /// No description provided for @signup_cr_url_label.
  ///
  /// In en, this message translates to:
  /// **'Commercial registration image URL (Drive/Link)'**
  String get signup_cr_url_label;

  /// No description provided for @signup_tax_url_label.
  ///
  /// In en, this message translates to:
  /// **'Tax card image URL (Drive/Link)'**
  String get signup_tax_url_label;

  /// No description provided for @signup_note_upload_docs.
  ///
  /// In en, this message translates to:
  /// **'Note: You can upload files to Google Drive and send the links for review.'**
  String get signup_note_upload_docs;

  /// No description provided for @signup_company_name_label.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get signup_company_name_label;

  /// No description provided for @signup_area_label.
  ///
  /// In en, this message translates to:
  /// **'Coverage area'**
  String get signup_area_label;

  /// No description provided for @signup_base_cost_label.
  ///
  /// In en, this message translates to:
  /// **'Base service price (EGP)'**
  String get signup_base_cost_label;

  /// No description provided for @signup_price_per_km_label.
  ///
  /// In en, this message translates to:
  /// **'Price per km (EGP)'**
  String get signup_price_per_km_label;

  /// No description provided for @signup_lat_label.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get signup_lat_label;

  /// No description provided for @signup_lng_label.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get signup_lng_label;

  /// No description provided for @signup_pick_location_button.
  ///
  /// In en, this message translates to:
  /// **'Pick location (current location / manual)'**
  String get signup_pick_location_button;

  /// No description provided for @signup_tow_cr_url_label.
  ///
  /// In en, this message translates to:
  /// **'Commercial registration image URL (Drive/Link)'**
  String get signup_tow_cr_url_label;

  /// No description provided for @signup_tow_tax_url_label.
  ///
  /// In en, this message translates to:
  /// **'Tax card image URL (Drive/Link)'**
  String get signup_tow_tax_url_label;

  /// No description provided for @signup_password_too_short.
  ///
  /// In en, this message translates to:
  /// **'At least 4 characters'**
  String get signup_password_too_short;

  /// No description provided for @signup_number_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get signup_number_invalid;

  /// No description provided for @signup_passwords_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get signup_passwords_not_match;

  /// No description provided for @signup_banned_email_message.
  ///
  /// In en, this message translates to:
  /// **'A new account cannot be created with this email.\nThis account has been permanently banned by the administration.'**
  String get signup_banned_email_message;

  /// No description provided for @signup_tow_invalid_location_or_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid location/pricing data'**
  String get signup_tow_invalid_location_or_price;

  /// No description provided for @signup_tow_request_submitted.
  ///
  /// In en, this message translates to:
  /// **'Tow company request submitted for review'**
  String get signup_tow_request_submitted;

  /// No description provided for @signup_seller_request_submitted.
  ///
  /// In en, this message translates to:
  /// **'Seller registration request submitted for review'**
  String get signup_seller_request_submitted;

  /// No description provided for @signup_buyer_created.
  ///
  /// In en, this message translates to:
  /// **'Buyer account created successfully'**
  String get signup_buyer_created;

  /// No description provided for @signup_generic_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the account'**
  String get signup_generic_error;

  /// No description provided for @signup_email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email'**
  String get signup_email_already_in_use;

  /// No description provided for @signup_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Weak password, please choose a stronger one'**
  String get signup_weak_password;

  /// No description provided for @signup_account_already_exists.
  ///
  /// In en, this message translates to:
  /// **'Account already exists'**
  String get signup_account_already_exists;

  /// No description provided for @signup_submit_button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signup_submit_button;

  /// No description provided for @currency_egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currency_egp;

  /// No description provided for @common_invalid_url.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get common_invalid_url;

  /// No description provided for @common_image_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get common_image_load_failed;

  /// No description provided for @common_open_in_browser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get common_open_in_browser;

  /// No description provided for @common_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get common_preview;

  /// No description provided for @admin_earnings_title.
  ///
  /// In en, this message translates to:
  /// **'App earnings'**
  String get admin_earnings_title;

  /// No description provided for @admin_earnings_error_loading_orders.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading orders'**
  String get admin_earnings_error_loading_orders;

  /// No description provided for @admin_earnings_no_completed_orders.
  ///
  /// In en, this message translates to:
  /// **'There are no completed orders yet.'**
  String get admin_earnings_no_completed_orders;

  /// No description provided for @admin_earnings_no_completed_in_range.
  ///
  /// In en, this message translates to:
  /// **'There are no completed orders in the selected period.\nTry choosing another date range.'**
  String get admin_earnings_no_completed_in_range;

  /// No description provided for @admin_earnings_date_range_help.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get admin_earnings_date_range_help;

  /// No description provided for @admin_earnings_date_range_confirm.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get admin_earnings_date_range_confirm;

  /// No description provided for @admin_earnings_date_range_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get admin_earnings_date_range_cancel;

  /// No description provided for @admin_earnings_current_period_label.
  ///
  /// In en, this message translates to:
  /// **'Current display period'**
  String get admin_earnings_current_period_label;

  /// No description provided for @admin_earnings_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Earnings summary for selected period'**
  String get admin_earnings_summary_title;

  /// No description provided for @admin_earnings_summary_desc.
  ///
  /// In en, this message translates to:
  /// **'All figures below are calculated from completed orders within the selected period only.'**
  String get admin_earnings_summary_desc;

  /// No description provided for @admin_earnings_total_app_fee_label.
  ///
  /// In en, this message translates to:
  /// **'Total app earnings'**
  String get admin_earnings_total_app_fee_label;

  /// No description provided for @admin_earnings_change_period_button.
  ///
  /// In en, this message translates to:
  /// **'Change period'**
  String get admin_earnings_change_period_button;

  /// No description provided for @admin_earnings_chart_section_title.
  ///
  /// In en, this message translates to:
  /// **'Earnings performance in the selected period'**
  String get admin_earnings_chart_section_title;

  /// No description provided for @admin_earnings_chart_title.
  ///
  /// In en, this message translates to:
  /// **'App earnings curve (selected period)'**
  String get admin_earnings_chart_title;

  /// No description provided for @admin_earnings_chart_no_data.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to draw a chart for this period.'**
  String get admin_earnings_chart_no_data;

  /// No description provided for @admin_earnings_period_orders_count_title.
  ///
  /// In en, this message translates to:
  /// **'Completed orders in period'**
  String get admin_earnings_period_orders_count_title;

  /// No description provided for @admin_earnings_period_total_paid_title.
  ///
  /// In en, this message translates to:
  /// **'Total paid in period'**
  String get admin_earnings_period_total_paid_title;

  /// No description provided for @admin_earnings_period_app_fee_title.
  ///
  /// In en, this message translates to:
  /// **'App earnings in period'**
  String get admin_earnings_period_app_fee_title;

  /// No description provided for @admin_earnings_last_updated_prefix.
  ///
  /// In en, this message translates to:
  /// **'Last updated:'**
  String get admin_earnings_last_updated_prefix;

  /// No description provided for @admin_earnings_total_paid_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes shipping, discount and app fee'**
  String get admin_earnings_total_paid_subtitle;

  /// No description provided for @admin_earnings_total_items_title.
  ///
  /// In en, this message translates to:
  /// **'Total items value'**
  String get admin_earnings_total_items_title;

  /// No description provided for @admin_earnings_total_items_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Before shipping and discounts'**
  String get admin_earnings_total_items_subtitle;

  /// No description provided for @admin_earnings_total_discount_title.
  ///
  /// In en, this message translates to:
  /// **'Total discounts'**
  String get admin_earnings_total_discount_title;

  /// No description provided for @admin_earnings_total_app_fee_card_title.
  ///
  /// In en, this message translates to:
  /// **'Total app earnings (estimated)'**
  String get admin_earnings_total_app_fee_card_title;

  /// No description provided for @admin_earnings_total_app_fee_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculated as 5% of final order prices'**
  String get admin_earnings_total_app_fee_subtitle;

  /// No description provided for @admin_profile_earnings_button.
  ///
  /// In en, this message translates to:
  /// **'App earnings dashboard'**
  String get admin_profile_earnings_button;

  /// No description provided for @admin_profile_manage_orders_button.
  ///
  /// In en, this message translates to:
  /// **'Manage orders'**
  String get admin_profile_manage_orders_button;

  /// No description provided for @admin_profile_manage_tow_orders_button.
  ///
  /// In en, this message translates to:
  /// **'Manage tow requests'**
  String get admin_profile_manage_tow_orders_button;

  /// No description provided for @admin_profile_users_accounts_button.
  ///
  /// In en, this message translates to:
  /// **'User accounts'**
  String get admin_profile_users_accounts_button;

  /// No description provided for @admin_profile_tab_products_review.
  ///
  /// In en, this message translates to:
  /// **'Review products'**
  String get admin_profile_tab_products_review;

  /// No description provided for @admin_profile_tab_sellers_approval.
  ///
  /// In en, this message translates to:
  /// **'Approve sellers'**
  String get admin_profile_tab_sellers_approval;

  /// No description provided for @admin_profile_tab_tow_approval.
  ///
  /// In en, this message translates to:
  /// **'Approve tow companies'**
  String get admin_profile_tab_tow_approval;

  /// No description provided for @admin_profile_pending_sellers_title.
  ///
  /// In en, this message translates to:
  /// **'Seller registration requests (Pending)'**
  String get admin_profile_pending_sellers_title;

  /// No description provided for @admin_profile_pending_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Pending:'**
  String get admin_profile_pending_label_prefix;

  /// No description provided for @admin_profile_no_pending_sellers.
  ///
  /// In en, this message translates to:
  /// **'There are no seller requests under review.'**
  String get admin_profile_no_pending_sellers;

  /// No description provided for @admin_profile_products_panel_title.
  ///
  /// In en, this message translates to:
  /// **'Products review panel'**
  String get admin_profile_products_panel_title;

  /// No description provided for @admin_profile_no_pending_products.
  ///
  /// In en, this message translates to:
  /// **'There are no products under review.'**
  String get admin_profile_no_pending_products;

  /// No description provided for @admin_profile_uploaded_docs_title.
  ///
  /// In en, this message translates to:
  /// **'Uploaded documents:'**
  String get admin_profile_uploaded_docs_title;

  /// No description provided for @admin_profile_rejected_with_reason_prefix.
  ///
  /// In en, this message translates to:
  /// **'Rejected:'**
  String get admin_profile_rejected_with_reason_prefix;

  /// No description provided for @admin_tow_requests_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Tow companies requests (Pending)'**
  String get admin_tow_requests_pending_title;

  /// No description provided for @admin_tow_requests_no_pending.
  ///
  /// In en, this message translates to:
  /// **'There are no tow company requests under review.'**
  String get admin_tow_requests_no_pending;

  /// No description provided for @admin_tow_requests_account_owner_label.
  ///
  /// In en, this message translates to:
  /// **'Account owner:'**
  String get admin_tow_requests_account_owner_label;

  /// No description provided for @admin_tow_requests_service_price_prefix.
  ///
  /// In en, this message translates to:
  /// **'Base service price:'**
  String get admin_tow_requests_service_price_prefix;

  /// No description provided for @admin_tow_requests_price_per_km_prefix.
  ///
  /// In en, this message translates to:
  /// **'Price per km:'**
  String get admin_tow_requests_price_per_km_prefix;

  /// No description provided for @admin_tow_requests_location_label.
  ///
  /// In en, this message translates to:
  /// **'Location (lat, lng):'**
  String get admin_tow_requests_location_label;

  /// No description provided for @cart_delivery_fees_note.
  ///
  /// In en, this message translates to:
  /// **'Delivery fees may vary based on quantity and package size.'**
  String get cart_delivery_fees_note;

  /// No description provided for @cart_delivery_payment_note.
  ///
  /// In en, this message translates to:
  /// **'Currently available payment method: Cash on delivery.'**
  String get cart_delivery_payment_note;

  /// No description provided for @cart_electronic_payment_title.
  ///
  /// In en, this message translates to:
  /// **'Electronic payment'**
  String get cart_electronic_payment_title;

  /// No description provided for @cart_electronic_payment_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon – cards & e-wallets'**
  String get cart_electronic_payment_subtitle;

  /// No description provided for @cart_electronic_payment_soon_chip.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get cart_electronic_payment_soon_chip;

  /// No description provided for @cart_electronic_payment_soon_message.
  ///
  /// In en, this message translates to:
  /// **'Electronic payment will be available soon.'**
  String get cart_electronic_payment_soon_message;

  /// No description provided for @admin_common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get admin_common_cancel;

  /// No description provided for @admin_common_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get admin_common_reject;

  /// No description provided for @admin_common_approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get admin_common_approve;

  /// No description provided for @admin_products_error_loading.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading products'**
  String get admin_products_error_loading;

  /// No description provided for @admin_products_approve_success_prefix.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get admin_products_approve_success_prefix;

  /// No description provided for @admin_products_update_failed_prefix.
  ///
  /// In en, this message translates to:
  /// **'Update failed:'**
  String get admin_products_update_failed_prefix;

  /// No description provided for @admin_products_reject_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Reject product'**
  String get admin_products_reject_dialog_title;

  /// No description provided for @admin_products_reject_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get admin_products_reject_reason_label;

  /// No description provided for @admin_products_reject_reason_hint.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason (optional)'**
  String get admin_products_reject_reason_hint;

  /// No description provided for @admin_products_reject_reason_default.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get admin_products_reject_reason_default;

  /// No description provided for @admin_products_rejected_with_reason_prefix.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get admin_products_rejected_with_reason_prefix;

  /// No description provided for @admin_products_label_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get admin_products_label_id;

  /// No description provided for @admin_products_label_seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get admin_products_label_seller;

  /// No description provided for @admin_products_label_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get admin_products_label_brand;

  /// No description provided for @admin_products_label_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get admin_products_label_model;

  /// No description provided for @admin_products_label_years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get admin_products_label_years;

  /// No description provided for @admin_products_label_stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get admin_products_label_stock;

  /// No description provided for @admin_orders_title.
  ///
  /// In en, this message translates to:
  /// **'Manage orders'**
  String get admin_orders_title;

  /// No description provided for @admin_tow_orders_title.
  ///
  /// In en, this message translates to:
  /// **'Manage tow requests'**
  String get admin_tow_orders_title;

  /// No description provided for @admin_tow_orders_no_requests.
  ///
  /// In en, this message translates to:
  /// **'There are no tow requests yet.'**
  String get admin_tow_orders_no_requests;

  /// No description provided for @admin_tow_orders_status_cancelled_by_user_suffix.
  ///
  /// In en, this message translates to:
  /// **' • Cancelled by customer'**
  String get admin_tow_orders_status_cancelled_by_user_suffix;

  /// No description provided for @admin_tow_orders_status_cancelled_by_company_suffix.
  ///
  /// In en, this message translates to:
  /// **' • Cancelled by company'**
  String get admin_tow_orders_status_cancelled_by_company_suffix;

  /// No description provided for @admin_tow_orders_company_prefix.
  ///
  /// In en, this message translates to:
  /// **'Company:'**
  String get admin_tow_orders_company_prefix;

  /// No description provided for @admin_tow_orders_total_cost_prefix.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get admin_tow_orders_total_cost_prefix;

  /// No description provided for @admin_tow_orders_vehicle_label.
  ///
  /// In en, this message translates to:
  /// **'Vehicle:'**
  String get admin_tow_orders_vehicle_label;

  /// No description provided for @admin_tow_orders_plate_label.
  ///
  /// In en, this message translates to:
  /// **'Plate:'**
  String get admin_tow_orders_plate_label;

  /// No description provided for @admin_tow_orders_customer_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Customer phone:'**
  String get admin_tow_orders_customer_phone_label;

  /// No description provided for @admin_tow_orders_cancel_reason_title.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason (customer):'**
  String get admin_tow_orders_cancel_reason_title;

  /// No description provided for @admin_tow_orders_cancel_date_prefix.
  ///
  /// In en, this message translates to:
  /// **'Cancellation date:'**
  String get admin_tow_orders_cancel_date_prefix;

  /// No description provided for @brand_products_results_count_prefix.
  ///
  /// In en, this message translates to:
  /// **'Results:'**
  String get brand_products_results_count_prefix;

  /// No description provided for @admin_users_title.
  ///
  /// In en, this message translates to:
  /// **'User accounts'**
  String get admin_users_title;

  /// No description provided for @admin_users_tab_buyers.
  ///
  /// In en, this message translates to:
  /// **'Buyer accounts'**
  String get admin_users_tab_buyers;

  /// No description provided for @admin_users_tab_sellers.
  ///
  /// In en, this message translates to:
  /// **'Seller accounts'**
  String get admin_users_tab_sellers;

  /// No description provided for @admin_users_tab_winches.
  ///
  /// In en, this message translates to:
  /// **'Tow accounts'**
  String get admin_users_tab_winches;

  /// No description provided for @admin_users_no_buyer_accounts.
  ///
  /// In en, this message translates to:
  /// **'There are no buyer accounts.'**
  String get admin_users_no_buyer_accounts;

  /// No description provided for @admin_users_no_seller_accounts.
  ///
  /// In en, this message translates to:
  /// **'There are no seller accounts.'**
  String get admin_users_no_seller_accounts;

  /// No description provided for @admin_users_no_winch_accounts.
  ///
  /// In en, this message translates to:
  /// **'There are no tow accounts.'**
  String get admin_users_no_winch_accounts;

  /// No description provided for @admin_users_status_banned.
  ///
  /// In en, this message translates to:
  /// **'Permanently banned'**
  String get admin_users_status_banned;

  /// No description provided for @admin_users_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get admin_users_status_active;

  /// No description provided for @admin_users_status_frozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen / Inactive'**
  String get admin_users_status_frozen;

  /// No description provided for @admin_users_no_name.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get admin_users_no_name;

  /// No description provided for @admin_users_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get admin_users_email_label;

  /// No description provided for @admin_users_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get admin_users_phone_label;

  /// No description provided for @admin_users_store_label.
  ///
  /// In en, this message translates to:
  /// **'Store:'**
  String get admin_users_store_label;

  /// No description provided for @admin_users_freeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get admin_users_freeze;

  /// No description provided for @admin_users_unfreeze.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze'**
  String get admin_users_unfreeze;

  /// No description provided for @admin_users_unban_and_activate.
  ///
  /// In en, this message translates to:
  /// **'Unban / Activate'**
  String get admin_users_unban_and_activate;

  /// No description provided for @admin_users_permanent_ban_button.
  ///
  /// In en, this message translates to:
  /// **'Permanent ban'**
  String get admin_users_permanent_ban_button;

  /// No description provided for @admin_users_permanent_ban_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm permanent ban'**
  String get admin_users_permanent_ban_dialog_title;

  /// No description provided for @admin_users_permanent_ban_dialog_body_prefix.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently ban'**
  String get admin_users_permanent_ban_dialog_body_prefix;

  /// No description provided for @admin_users_permanent_ban_dialog_body_suffix.
  ///
  /// In en, this message translates to:
  /// **'?\nThe user will not be able to use this account or create a new one with the same email.'**
  String get admin_users_permanent_ban_dialog_body_suffix;

  /// No description provided for @admin_users_permanent_ban_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm ban'**
  String get admin_users_permanent_ban_confirm;

  /// No description provided for @buyer_profile_tab_my_orders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get buyer_profile_tab_my_orders;

  /// No description provided for @buyer_profile_tab_tow_requests.
  ///
  /// In en, this message translates to:
  /// **'Tow requests'**
  String get buyer_profile_tab_tow_requests;

  /// No description provided for @buyer_profile_go_shopping_button.
  ///
  /// In en, this message translates to:
  /// **'Go shopping'**
  String get buyer_profile_go_shopping_button;

  /// No description provided for @buyer_tow_cancel_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel tow request'**
  String get buyer_tow_cancel_dialog_title;

  /// No description provided for @buyer_tow_cancel_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason (optional)'**
  String get buyer_tow_cancel_reason_label;

  /// No description provided for @buyer_tow_cancel_reason_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: company is late / I managed on my own...'**
  String get buyer_tow_cancel_reason_hint;

  /// No description provided for @buyer_tow_cancel_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm cancellation'**
  String get buyer_tow_cancel_confirm_button;

  /// No description provided for @buyer_tow_cancel_success_message.
  ///
  /// In en, this message translates to:
  /// **'Tow request cancelled successfully'**
  String get buyer_tow_cancel_success_message;

  /// No description provided for @buyer_tow_cancel_error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel request:'**
  String get buyer_tow_cancel_error_prefix;

  /// No description provided for @buyer_tow_no_requests_message.
  ///
  /// In en, this message translates to:
  /// **'You have no tow requests yet.'**
  String get buyer_tow_no_requests_message;

  /// No description provided for @buyer_tow_status_new_suffix.
  ///
  /// In en, this message translates to:
  /// **'(new)'**
  String get buyer_tow_status_new_suffix;

  /// No description provided for @buyer_tow_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get buyer_tow_cancel_button;

  /// No description provided for @cart_title.
  ///
  /// In en, this message translates to:
  /// **'Shopping cart'**
  String get cart_title;

  /// No description provided for @cart_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_empty_title;

  /// No description provided for @cart_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cart_empty_message;

  /// No description provided for @cart_login_required_message.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first'**
  String get cart_login_required_message;

  /// No description provided for @cart_enter_name_message.
  ///
  /// In en, this message translates to:
  /// **'Please enter customer name'**
  String get cart_enter_name_message;

  /// No description provided for @cart_enter_address_message.
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get cart_enter_address_message;

  /// No description provided for @cart_enter_phone_message.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get cart_enter_phone_message;

  /// No description provided for @cart_quantity_exceeds_stock_prefix.
  ///
  /// In en, this message translates to:
  /// **'You cannot order more than available in stock'**
  String get cart_quantity_exceeds_stock_prefix;

  /// No description provided for @cart_coupon_enter_code_message.
  ///
  /// In en, this message translates to:
  /// **'Please enter the coupon code'**
  String get cart_coupon_enter_code_message;

  /// No description provided for @cart_coupon_invalid_message.
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get cart_coupon_invalid_message;

  /// No description provided for @cart_coupon_not_usable_message.
  ///
  /// In en, this message translates to:
  /// **'This coupon is inactive or expired'**
  String get cart_coupon_not_usable_message;

  /// No description provided for @cart_coupon_seller_mismatch_message.
  ///
  /// In en, this message translates to:
  /// **'No items in cart from the seller of this coupon'**
  String get cart_coupon_seller_mismatch_message;

  /// No description provided for @cart_coupon_applied_prefix.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied:'**
  String get cart_coupon_applied_prefix;

  /// No description provided for @cart_coupon_apply_error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Error applying coupon:'**
  String get cart_coupon_apply_error_prefix;

  /// No description provided for @cart_customer_section_title.
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get cart_customer_section_title;

  /// No description provided for @cart_customer_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cart_customer_name_label;

  /// No description provided for @cart_customer_address_label.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cart_customer_address_label;

  /// No description provided for @cart_customer_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get cart_customer_phone_label;

  /// No description provided for @cart_customer_alt_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Alternate phone'**
  String get cart_customer_alt_phone_label;

  /// No description provided for @cart_delivery_section_title.
  ///
  /// In en, this message translates to:
  /// **'Delivery location (optional)'**
  String get cart_delivery_section_title;

  /// No description provided for @cart_delivery_input_label.
  ///
  /// In en, this message translates to:
  /// **'Address or coordinates'**
  String get cart_delivery_input_label;

  /// No description provided for @cart_delivery_current_location_button.
  ///
  /// In en, this message translates to:
  /// **'My current location'**
  String get cart_delivery_current_location_button;

  /// No description provided for @cart_delivery_pick_on_map_button.
  ///
  /// In en, this message translates to:
  /// **'Pick from map'**
  String get cart_delivery_pick_on_map_button;

  /// No description provided for @cart_confirm_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get cart_confirm_dialog_title;

  /// No description provided for @cart_confirm_customer_label.
  ///
  /// In en, this message translates to:
  /// **'Customer:'**
  String get cart_confirm_customer_label;

  /// No description provided for @cart_confirm_address_label.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get cart_confirm_address_label;

  /// No description provided for @cart_confirm_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get cart_confirm_phone_label;

  /// No description provided for @cart_confirm_delivery_location_label.
  ///
  /// In en, this message translates to:
  /// **'Delivery location:'**
  String get cart_confirm_delivery_location_label;

  /// No description provided for @cart_confirm_items_count_label.
  ///
  /// In en, this message translates to:
  /// **'Items count:'**
  String get cart_confirm_items_count_label;

  /// No description provided for @cart_confirm_items_total_label.
  ///
  /// In en, this message translates to:
  /// **'Items total:'**
  String get cart_confirm_items_total_label;

  /// No description provided for @cart_confirm_shipping_label.
  ///
  /// In en, this message translates to:
  /// **'Shipping:'**
  String get cart_confirm_shipping_label;

  /// No description provided for @cart_confirm_discount_label.
  ///
  /// In en, this message translates to:
  /// **'Discount: -'**
  String get cart_confirm_discount_label;

  /// No description provided for @cart_confirm_grand_total_label.
  ///
  /// In en, this message translates to:
  /// **'Grand total:'**
  String get cart_confirm_grand_total_label;

  /// No description provided for @cart_confirm_note_label.
  ///
  /// In en, this message translates to:
  /// **'Note:'**
  String get cart_confirm_note_label;

  /// No description provided for @cart_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get cart_confirm_button;

  /// No description provided for @cart_order_created_prefix.
  ///
  /// In en, this message translates to:
  /// **'Order created'**
  String get cart_order_created_prefix;

  /// No description provided for @cart_cancel_all_items_message.
  ///
  /// In en, this message translates to:
  /// **'All items in cart have been cleared'**
  String get cart_cancel_all_items_message;

  /// No description provided for @categories_error_loading.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading categories'**
  String get categories_error_loading;

  /// No description provided for @categories_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for parts, brands, models...'**
  String get categories_search_hint;

  /// No description provided for @categories_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories_title;

  /// No description provided for @categories_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse parts by brand'**
  String get categories_subtitle;

  /// No description provided for @map_picker_title.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get map_picker_title;

  /// No description provided for @map_picker_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for an address or place...'**
  String get map_picker_search_hint;

  /// No description provided for @map_picker_no_results_message.
  ///
  /// In en, this message translates to:
  /// **'No results were found for this search.\nTry adjusting the address or checking your internet connection.'**
  String get map_picker_no_results_message;

  /// No description provided for @map_picker_pending_address.
  ///
  /// In en, this message translates to:
  /// **'Resolving address…'**
  String get map_picker_pending_address;

  /// No description provided for @map_picker_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Choose this location'**
  String get map_picker_confirm_button;

  /// No description provided for @product_details_title.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get product_details_title;

  /// No description provided for @product_details_added_to_cart_message.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart'**
  String get product_details_added_to_cart_message;

  /// No description provided for @product_details_brand_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Brand:'**
  String get product_details_brand_label_prefix;

  /// No description provided for @product_details_model_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Model:'**
  String get product_details_model_label_prefix;

  /// No description provided for @product_details_years_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Years:'**
  String get product_details_years_label_prefix;

  /// No description provided for @product_details_stock_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Available stock:'**
  String get product_details_stock_label_prefix;

  /// No description provided for @product_details_price_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Price:'**
  String get product_details_price_label_prefix;

  /// No description provided for @product_details_add_to_cart_button.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get product_details_add_to_cart_button;

  /// No description provided for @product_details_buy_now_button.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get product_details_buy_now_button;

  /// No description provided for @product_details_seller_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Seller:'**
  String get product_details_seller_label_prefix;

  /// No description provided for @profile_app_bar_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_app_bar_title;

  /// No description provided for @profile_winch_requests_button_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage tow requests (service provider panel)'**
  String get profile_winch_requests_button_tooltip;

  /// No description provided for @profile_winch_requests_button_label.
  ///
  /// In en, this message translates to:
  /// **'Tow requests'**
  String get profile_winch_requests_button_label;

  /// No description provided for @profile_logout_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_logout_tooltip;

  /// No description provided for @profile_login_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profile_login_tooltip;

  /// No description provided for @profile_greeting_prefix.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get profile_greeting_prefix;

  /// No description provided for @profile_role_label_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin (review only)'**
  String get profile_role_label_admin;

  /// No description provided for @profile_role_label_seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get profile_role_label_seller;

  /// No description provided for @profile_role_label_buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get profile_role_label_buyer;

  /// No description provided for @profile_role_label_winch.
  ///
  /// In en, this message translates to:
  /// **'Tow service provider'**
  String get profile_role_label_winch;

  /// No description provided for @profile_role_label_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profile_role_label_unknown;

  /// No description provided for @profile_mode_admin_label.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get profile_mode_admin_label;

  /// No description provided for @profile_mode_winch_label.
  ///
  /// In en, this message translates to:
  /// **'Tow service provider • Can shop from the store'**
  String get profile_mode_winch_label;

  /// No description provided for @profile_mode_prefix.
  ///
  /// In en, this message translates to:
  /// **'Mode:'**
  String get profile_mode_prefix;

  /// No description provided for @profile_mode_seller_label.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get profile_mode_seller_label;

  /// No description provided for @profile_mode_buyer_label.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get profile_mode_buyer_label;

  /// No description provided for @profile_role_chip_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Account role:'**
  String get profile_role_chip_label_prefix;

  /// No description provided for @profile_switch_to_buyer_button.
  ///
  /// In en, this message translates to:
  /// **'Switch to buyer'**
  String get profile_switch_to_buyer_button;

  /// No description provided for @profile_switch_to_seller_button.
  ///
  /// In en, this message translates to:
  /// **'Switch back to seller'**
  String get profile_switch_to_seller_button;

  /// No description provided for @profile_switched_to_buyer_message.
  ///
  /// In en, this message translates to:
  /// **'Switched to buyer mode'**
  String get profile_switched_to_buyer_message;

  /// No description provided for @profile_switched_to_seller_message.
  ///
  /// In en, this message translates to:
  /// **'Switched back to seller mode'**
  String get profile_switched_to_seller_message;

  /// No description provided for @profile_winch_hint_text.
  ///
  /// In en, this message translates to:
  /// **'This account is registered as a tow service provider, and you can also buy spare parts from the store using this account.'**
  String get profile_winch_hint_text;

  /// No description provided for @profile_pure_buyer_hint_text.
  ///
  /// In en, this message translates to:
  /// **'This account is registered as buyer only.'**
  String get profile_pure_buyer_hint_text;

  /// No description provided for @seller_coupons_title.
  ///
  /// In en, this message translates to:
  /// **'Discount coupons'**
  String get seller_coupons_title;

  /// No description provided for @seller_coupons_help_text.
  ///
  /// In en, this message translates to:
  /// **'Create and manage discount coupons for your store.'**
  String get seller_coupons_help_text;

  /// No description provided for @seller_coupons_create_button.
  ///
  /// In en, this message translates to:
  /// **'Create new coupon'**
  String get seller_coupons_create_button;

  /// No description provided for @seller_coupons_empty_message.
  ///
  /// In en, this message translates to:
  /// **'There are no coupons yet.'**
  String get seller_coupons_empty_message;

  /// No description provided for @seller_coupons_status_expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get seller_coupons_status_expired;

  /// No description provided for @seller_coupons_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get seller_coupons_status_active;

  /// No description provided for @seller_coupons_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get seller_coupons_status_inactive;

  /// No description provided for @seller_coupons_discount_percent_prefix.
  ///
  /// In en, this message translates to:
  /// **'Discount:'**
  String get seller_coupons_discount_percent_prefix;

  /// No description provided for @seller_coupons_expires_at_prefix.
  ///
  /// In en, this message translates to:
  /// **'Expires at:'**
  String get seller_coupons_expires_at_prefix;

  /// No description provided for @seller_coupons_no_expiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get seller_coupons_no_expiry;

  /// No description provided for @seller_coupons_toggle_tooltip_activate.
  ///
  /// In en, this message translates to:
  /// **'Activate coupon'**
  String get seller_coupons_toggle_tooltip_activate;

  /// No description provided for @seller_coupons_toggle_tooltip_deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate coupon'**
  String get seller_coupons_toggle_tooltip_deactivate;

  /// No description provided for @seller_coupons_delete_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete coupon'**
  String get seller_coupons_delete_tooltip;

  /// No description provided for @seller_coupons_delete_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete coupon'**
  String get seller_coupons_delete_dialog_title;

  /// No description provided for @seller_coupons_delete_dialog_message_prefix.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete coupon'**
  String get seller_coupons_delete_dialog_message_prefix;

  /// No description provided for @seller_coupons_delete_dialog_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get seller_coupons_delete_dialog_cancel_button;

  /// No description provided for @seller_coupons_delete_dialog_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get seller_coupons_delete_dialog_confirm_button;

  /// No description provided for @seller_coupons_created_snackbar_prefix.
  ///
  /// In en, this message translates to:
  /// **'Coupon created'**
  String get seller_coupons_created_snackbar_prefix;

  /// No description provided for @seller_coupons_create_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Create coupon'**
  String get seller_coupons_create_dialog_title;

  /// No description provided for @seller_coupons_code_label.
  ///
  /// In en, this message translates to:
  /// **'Code (example: SAVE10)'**
  String get seller_coupons_code_label;

  /// No description provided for @seller_coupons_code_required_error.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get seller_coupons_code_required_error;

  /// No description provided for @seller_coupons_code_no_spaces_error.
  ///
  /// In en, this message translates to:
  /// **'Code must not contain spaces'**
  String get seller_coupons_code_no_spaces_error;

  /// No description provided for @seller_coupons_percent_label.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get seller_coupons_percent_label;

  /// No description provided for @seller_coupons_percent_required_error.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get seller_coupons_percent_required_error;

  /// No description provided for @seller_coupons_percent_invalid_error.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 1 and 100'**
  String get seller_coupons_percent_invalid_error;

  /// No description provided for @seller_coupons_days_label.
  ///
  /// In en, this message translates to:
  /// **'Validity in days (optional)'**
  String get seller_coupons_days_label;

  /// No description provided for @seller_coupons_days_hint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for no expiry'**
  String get seller_coupons_days_hint;

  /// No description provided for @seller_coupons_form_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get seller_coupons_form_cancel_button;

  /// No description provided for @seller_coupons_form_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get seller_coupons_form_save_button;

  /// No description provided for @currencyEgp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currencyEgp;

  /// No description provided for @adminEarningsLastUpdatedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Last updated:'**
  String get adminEarningsLastUpdatedPrefix;

  /// No description provided for @sellerDashboardAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get sellerDashboardAllTime;

  /// No description provided for @sellerDashboardRangeFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get sellerDashboardRangeFromPrefix;

  /// No description provided for @sellerDashboardRangeToPrefix.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get sellerDashboardRangeToPrefix;

  /// No description provided for @sellerDashboardDateRangeHelp.
  ///
  /// In en, this message translates to:
  /// **'Select period to view your earnings'**
  String get sellerDashboardDateRangeHelp;

  /// No description provided for @sellerDashboardDateRangeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sellerDashboardDateRangeCancel;

  /// No description provided for @sellerDashboardDateRangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get sellerDashboardDateRangeConfirm;

  /// No description provided for @sellerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller dashboard'**
  String get sellerDashboardTitle;

  /// No description provided for @sellerDashboardUnknownSellerMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine seller identity for this account.'**
  String get sellerDashboardUnknownSellerMessage;

  /// No description provided for @sellerDashboardErrorLoadingOrders.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading orders.'**
  String get sellerDashboardErrorLoadingOrders;

  /// No description provided for @sellerDashboardNoCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'There are no completed orders yet.'**
  String get sellerDashboardNoCompletedOrders;

  /// No description provided for @sellerDashboardNoOrdersInRange.
  ///
  /// In en, this message translates to:
  /// **'There are no orders in the selected period.\nTry changing the date range.'**
  String get sellerDashboardNoOrdersInRange;

  /// No description provided for @sellerDashboardStatOrdersInPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed orders (in period)'**
  String get sellerDashboardStatOrdersInPeriodTitle;

  /// No description provided for @sellerDashboardStatItemsSoldTitle.
  ///
  /// In en, this message translates to:
  /// **'Total items sold'**
  String get sellerDashboardStatItemsSoldTitle;

  /// No description provided for @sellerDashboardStatItemsTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Items value (before discount)'**
  String get sellerDashboardStatItemsTotalTitle;

  /// No description provided for @sellerDashboardStatItemsTotalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based only on the prices you entered for products'**
  String get sellerDashboardStatItemsTotalSubtitle;

  /// No description provided for @sellerDashboardStatDiscountTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Total discounts on your items'**
  String get sellerDashboardStatDiscountTotalTitle;

  /// No description provided for @sellerDashboardStatDiscountTotalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes discounts and coupons in the period'**
  String get sellerDashboardStatDiscountTotalSubtitle;

  /// No description provided for @sellerDashboardStatNetInPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Net earnings after discounts (in period)'**
  String get sellerDashboardStatNetInPeriodTitle;

  /// No description provided for @sellerDashboardStatNetInPeriodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Does not include app commission 5% (charged to buyer)'**
  String get sellerDashboardStatNetInPeriodSubtitle;

  /// No description provided for @sellerDashboardChartSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Net earnings distribution by day'**
  String get sellerDashboardChartSectionTitle;

  /// No description provided for @sellerDashboardChartNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to draw a chart in the selected period.'**
  String get sellerDashboardChartNoData;

  /// No description provided for @sellerDashboardChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your net earnings by day'**
  String get sellerDashboardChartTitle;

  /// No description provided for @sellerDashboardCouponsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Coupon impact on your earnings (in period)'**
  String get sellerDashboardCouponsSectionTitle;

  /// No description provided for @sellerDashboardCouponsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total coupon discounts on your items in the selected period:'**
  String get sellerDashboardCouponsTotalLabel;

  /// No description provided for @sellerDashboardCouponsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No coupon codes were used on your items in the selected period.'**
  String get sellerDashboardCouponsEmptyMessage;

  /// No description provided for @sellerDashboardSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your store earnings summary'**
  String get sellerDashboardSummaryTitle;

  /// No description provided for @sellerDashboardSummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'All figures below are calculated from the original prices you entered for products before adding the 5% app commission.'**
  String get sellerDashboardSummaryDesc;

  /// No description provided for @sellerDashboardTotalNetAllTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Net earnings (all time)'**
  String get sellerDashboardTotalNetAllTimeLabel;

  /// No description provided for @sellerDashboardChangePeriodButton.
  ///
  /// In en, this message translates to:
  /// **'Change period'**
  String get sellerDashboardChangePeriodButton;

  /// No description provided for @sellerDashboardAllTimeButton.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get sellerDashboardAllTimeButton;

  /// No description provided for @sellerOrderTimelineCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get sellerOrderTimelineCreated;

  /// No description provided for @sellerOrderTimelinePrepared.
  ///
  /// In en, this message translates to:
  /// **'Prepared'**
  String get sellerOrderTimelinePrepared;

  /// No description provided for @sellerOrderTimelineWithCourier.
  ///
  /// In en, this message translates to:
  /// **'With courier'**
  String get sellerOrderTimelineWithCourier;

  /// No description provided for @sellerOrderTimelineDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get sellerOrderTimelineDelivered;

  /// No description provided for @sellerOrderTimelineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get sellerOrderTimelineCancelled;

  /// No description provided for @sellerOrderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get sellerOrderDetailsTitle;

  /// No description provided for @sellerOrderDetailsOrderCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Order code:'**
  String get sellerOrderDetailsOrderCodePrefix;

  /// No description provided for @sellerOrderDetailsBuyerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Buyer:'**
  String get sellerOrderDetailsBuyerPrefix;

  /// No description provided for @sellerOrderDetailsCreatedAtPrefix.
  ///
  /// In en, this message translates to:
  /// **'Created at:'**
  String get sellerOrderDetailsCreatedAtPrefix;

  /// No description provided for @sellerOrderDetailsCouponUsedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Coupon used:'**
  String get sellerOrderDetailsCouponUsedPrefix;

  /// No description provided for @sellerOrderDetailsBuyerNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer note:'**
  String get sellerOrderDetailsBuyerNoteTitle;

  /// No description provided for @sellerOrderDetailsFinancialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order financial summary'**
  String get sellerOrderDetailsFinancialSummaryTitle;

  /// No description provided for @sellerOrderDetailsTotalItemsAllSellersLabel.
  ///
  /// In en, this message translates to:
  /// **'Items total (all sellers)'**
  String get sellerOrderDetailsTotalItemsAllSellersLabel;

  /// No description provided for @sellerOrderDetailsShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get sellerOrderDetailsShippingLabel;

  /// No description provided for @sellerOrderDetailsTotalDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total discount'**
  String get sellerOrderDetailsTotalDiscountLabel;

  /// No description provided for @sellerOrderDetailsGrandTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Order grand total'**
  String get sellerOrderDetailsGrandTotalLabel;

  /// No description provided for @sellerOrderDetailsSellerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller-specific summary'**
  String get sellerOrderDetailsSellerSectionTitle;

  /// No description provided for @sellerOrderDetailsSellerItemsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Your items count'**
  String get sellerOrderDetailsSellerItemsCountLabel;

  /// No description provided for @sellerOrderDetailsSellerSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Your items subtotal (before discount)'**
  String get sellerOrderDetailsSellerSubtotalLabel;

  /// No description provided for @sellerOrderDetailsSellerDiscountShareLabel.
  ///
  /// In en, this message translates to:
  /// **'Your share of discount'**
  String get sellerOrderDetailsSellerDiscountShareLabel;

  /// No description provided for @sellerOrderDetailsSellerNetLabel.
  ///
  /// In en, this message translates to:
  /// **'Net value of your items in this order'**
  String get sellerOrderDetailsSellerNetLabel;

  /// No description provided for @sellerOrderDetailsCoordsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Coordinates:'**
  String get sellerOrderDetailsCoordsPrefix;

  /// No description provided for @sellerOrderDetailsItemsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your order items'**
  String get sellerOrderDetailsItemsSectionTitle;

  /// No description provided for @sellerOrderDetailsNoItemsForSellerMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no items assigned to you in this order.'**
  String get sellerOrderDetailsNoItemsForSellerMessage;

  /// No description provided for @sellerOrderDetailsUnitPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Unit price:'**
  String get sellerOrderDetailsUnitPricePrefix;

  /// No description provided for @sellerOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer orders'**
  String get sellerOrdersTitle;

  /// No description provided for @sellerOrdersNoOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no orders at the moment.'**
  String get sellerOrdersNoOrdersMessage;

  /// No description provided for @sellerOrdersUpdateStatusSuccessPrefix.
  ///
  /// In en, this message translates to:
  /// **'Order status updated to'**
  String get sellerOrdersUpdateStatusSuccessPrefix;

  /// No description provided for @sellerOrdersUpdateStatusErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status:'**
  String get sellerOrdersUpdateStatusErrorPrefix;

  /// No description provided for @sellerOrdersNoAvailableStatusesMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'No available statuses'**
  String get sellerOrdersNoAvailableStatusesMenuLabel;

  /// No description provided for @sellerOrdersStatusChangeNotAllowedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Status cannot be changed'**
  String get sellerOrdersStatusChangeNotAllowedTooltip;

  /// No description provided for @sellerOrdersStatusChangeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Update order status'**
  String get sellerOrdersStatusChangeTooltip;

  /// No description provided for @sellerOrdersSubtitleItemsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Items:'**
  String get sellerOrdersSubtitleItemsPrefix;

  /// No description provided for @sellerOrdersSubtitleNetPrefix.
  ///
  /// In en, this message translates to:
  /// **'• Your net earnings from order:'**
  String get sellerOrdersSubtitleNetPrefix;

  /// No description provided for @sellerOrdersFilterByStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by status:'**
  String get sellerOrdersFilterByStatusLabel;

  /// No description provided for @sellerOrdersFilterAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sellerOrdersFilterAllLabel;

  /// No description provided for @sellerOrdersFinalPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Final price:'**
  String get sellerOrdersFinalPricePrefix;

  /// No description provided for @sellerProfileNewProductSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new product'**
  String get sellerProfileNewProductSheetTitle;

  /// No description provided for @sellerProfileNewProductTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name (example: Front headlight)'**
  String get sellerProfileNewProductTitleLabel;

  /// No description provided for @sellerProfileNewProductPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sellerProfileNewProductPriceLabel;

  /// No description provided for @sellerProfileNewProductDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (example: Fits 2023–2025 same shape)'**
  String get sellerProfileNewProductDescLabel;

  /// No description provided for @sellerProfileNewProductBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get sellerProfileNewProductBrandLabel;

  /// No description provided for @sellerProfileNewProductModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get sellerProfileNewProductModelLabel;

  /// No description provided for @sellerProfileNewProductYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Compatible years'**
  String get sellerProfileNewProductYearsLabel;

  /// No description provided for @sellerProfileNewProductStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Available stock'**
  String get sellerProfileNewProductStockLabel;

  /// No description provided for @sellerProfileNewProductImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL (optional)'**
  String get sellerProfileNewProductImageLabel;

  /// No description provided for @sellerProfileNewProductImageHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get sellerProfileNewProductImageHint;

  /// No description provided for @sellerProfileFieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get sellerProfileFieldRequiredError;

  /// No description provided for @sellerProfileNewProductPriceInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get sellerProfileNewProductPriceInvalidError;

  /// No description provided for @sellerProfileNewProductStockInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get sellerProfileNewProductStockInvalidError;

  /// No description provided for @sellerProfileNewProductSelectYearSnack.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one year'**
  String get sellerProfileNewProductSelectYearSnack;

  /// No description provided for @sellerProfileNewProductSubmittedSnack.
  ///
  /// In en, this message translates to:
  /// **'Product submitted for review'**
  String get sellerProfileNewProductSubmittedSnack;

  /// No description provided for @sellerProfileNewProductSaveErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error while saving product:'**
  String get sellerProfileNewProductSaveErrorPrefix;

  /// No description provided for @sellerProfileNewProductSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get sellerProfileNewProductSubmitButton;

  /// No description provided for @sellerProfileNewProductInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Important note:'**
  String get sellerProfileNewProductInfoTitle;

  /// No description provided for @sellerProfileNewProductInfoBody.
  ///
  /// In en, this message translates to:
  /// **'The price you enter here is the seller price before the app commission.\nAn app commission of {percent}% will be added automatically when the product is shown to the buyer and in the cart.'**
  String sellerProfileNewProductInfoBody(String percent);

  /// No description provided for @sellerProfileNoProductsInTabMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no products in this tab yet.'**
  String get sellerProfileNoProductsInTabMessage;

  /// No description provided for @sellerProfileProductBrandPrefix.
  ///
  /// In en, this message translates to:
  /// **'Brand:'**
  String get sellerProfileProductBrandPrefix;

  /// No description provided for @sellerProfileProductModelPrefix.
  ///
  /// In en, this message translates to:
  /// **'Model:'**
  String get sellerProfileProductModelPrefix;

  /// No description provided for @sellerProfileProductPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Price:'**
  String get sellerProfileProductPricePrefix;

  /// No description provided for @sellerProfileProductStockPrefix.
  ///
  /// In en, this message translates to:
  /// **'Stock:'**
  String get sellerProfileProductStockPrefix;

  /// No description provided for @sellerProfileProductStatusApprovedLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get sellerProfileProductStatusApprovedLabel;

  /// No description provided for @sellerProfileProductStatusPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sellerProfileProductStatusPendingLabel;

  /// No description provided for @sellerProfileProductStatusRejectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get sellerProfileProductStatusRejectedLabel;

  /// No description provided for @sellerProfileAddProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get sellerProfileAddProductButton;

  /// No description provided for @sellerProfileTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sellerProfileTabPending;

  /// No description provided for @sellerProfileTabApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get sellerProfileTabApproved;

  /// No description provided for @sellerProfileTabRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get sellerProfileTabRejected;

  /// No description provided for @sellerProfileErrorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading products.'**
  String get sellerProfileErrorLoadingProducts;

  /// No description provided for @sellerProfileDashboardButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard & earnings'**
  String get sellerProfileDashboardButtonLabel;

  /// No description provided for @sellerProfileOrdersButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer orders'**
  String get sellerProfileOrdersButtonLabel;

  /// No description provided for @sellerProfileInventoryButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Inventory management'**
  String get sellerProfileInventoryButtonLabel;

  /// No description provided for @sellerProfileCouponsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount coupons'**
  String get sellerProfileCouponsButtonLabel;

  /// No description provided for @sellerProfileInventoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory management'**
  String get sellerProfileInventoryScreenTitle;

  /// No description provided for @sellerProfileRejectedEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no rejected products at the moment.'**
  String get sellerProfileRejectedEmptyMessage;

  /// No description provided for @sellerProfileRejectedPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Price:'**
  String get sellerProfileRejectedPricePrefix;

  /// No description provided for @sellerProfileRejectedReasonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason not specified'**
  String get sellerProfileRejectedReasonUnknown;

  /// No description provided for @sellerProfileRejectedReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason:'**
  String get sellerProfileRejectedReasonPrefix;

  /// No description provided for @towCompaniesAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby tow companies'**
  String get towCompaniesAppBarTitle;

  /// No description provided for @towCompaniesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no tow companies available at the moment.'**
  String get towCompaniesEmptyMessage;

  /// No description provided for @towCompaniesStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get towCompaniesStatusAvailable;

  /// No description provided for @towCompaniesStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get towCompaniesStatusUnavailable;

  /// No description provided for @towCompaniesDistancePrefix.
  ///
  /// In en, this message translates to:
  /// **'Approximate distance:'**
  String get towCompaniesDistancePrefix;

  /// No description provided for @towCompaniesKmSuffix.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get towCompaniesKmSuffix;

  /// No description provided for @towCompaniesBaseCostPrefix.
  ///
  /// In en, this message translates to:
  /// **'Base service price:'**
  String get towCompaniesBaseCostPrefix;

  /// No description provided for @towCompaniesPricePerKmPrefix.
  ///
  /// In en, this message translates to:
  /// **'Price per km:'**
  String get towCompaniesPricePerKmPrefix;

  /// No description provided for @towCompaniesCoordsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Location (lat, lng):'**
  String get towCompaniesCoordsPrefix;

  /// No description provided for @towLocationPickerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick location'**
  String get towLocationPickerAppBarTitle;

  /// No description provided for @towLocationPickerUseMyLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get towLocationPickerUseMyLocationButton;

  /// No description provided for @towLocationPickerChooseFromMapButton.
  ///
  /// In en, this message translates to:
  /// **'Choose from map'**
  String get towLocationPickerChooseFromMapButton;

  /// No description provided for @towLocationPickerLatitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get towLocationPickerLatitudeLabel;

  /// No description provided for @towLocationPickerLongitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get towLocationPickerLongitudeLabel;

  /// No description provided for @towLocationPickerSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get towLocationPickerSaveButton;

  /// No description provided for @towLocationPickerHintText.
  ///
  /// In en, this message translates to:
  /// **'Use your current location or open the map to pick a point.'**
  String get towLocationPickerHintText;

  /// No description provided for @towLocationPickerServiceDisabledSnack.
  ///
  /// In en, this message translates to:
  /// **'Enable location services first'**
  String get towLocationPickerServiceDisabledSnack;

  /// No description provided for @towLocationPickerPermissionDeniedSnack.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get towLocationPickerPermissionDeniedSnack;

  /// No description provided for @towLocationPickerPermissionDeniedForeverSnack.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied'**
  String get towLocationPickerPermissionDeniedForeverSnack;

  /// No description provided for @towLocationPickerInvalidCoordsSnack.
  ///
  /// In en, this message translates to:
  /// **'Enter valid coordinates'**
  String get towLocationPickerInvalidCoordsSnack;

  /// No description provided for @towMapPickerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose from map'**
  String get towMapPickerAppBarTitle;

  /// No description provided for @towMapPickerDoneActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get towMapPickerDoneActionLabel;

  /// No description provided for @towMapPickerDoneButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Use this point'**
  String get towMapPickerDoneButtonLabel;

  /// No description provided for @towMapOpenErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not open the map'**
  String get towMapOpenErrorSnack;

  /// No description provided for @towOperatorAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Tow panel'**
  String get towOperatorAppBarTitle;

  /// No description provided for @towOperatorAppBarTitleWithName.
  ///
  /// In en, this message translates to:
  /// **'{companyName} panel'**
  String towOperatorAppBarTitleWithName(String companyName);

  /// No description provided for @towOperatorCompanyNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not find the tow company linked to this account.\nIt may have been deleted or not configured correctly.'**
  String get towOperatorCompanyNotFoundMessage;

  /// No description provided for @towOperatorToggleOnlineTooltipOn.
  ///
  /// In en, this message translates to:
  /// **'Stop receiving requests'**
  String get towOperatorToggleOnlineTooltipOn;

  /// No description provided for @towOperatorToggleOnlineTooltipOff.
  ///
  /// In en, this message translates to:
  /// **'Start receiving requests'**
  String get towOperatorToggleOnlineTooltipOff;

  /// No description provided for @towOperatorTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get towOperatorTabActive;

  /// No description provided for @towOperatorTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get towOperatorTabHistory;

  /// No description provided for @towOperatorCoordsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Coordinates:'**
  String get towOperatorCoordsPrefix;

  /// No description provided for @towOperatorStatusOnlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online • receiving requests'**
  String get towOperatorStatusOnlineLabel;

  /// No description provided for @towOperatorStatusOfflineLabel.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get towOperatorStatusOfflineLabel;

  /// No description provided for @towOperatorOnlineSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Available now (online)'**
  String get towOperatorOnlineSwitchTitle;

  /// No description provided for @towOperatorOnlineSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customers can see your company and book'**
  String get towOperatorOnlineSwitchSubtitle;

  /// No description provided for @towOperatorOfflineWarning.
  ///
  /// In en, this message translates to:
  /// **'You are currently offline. Turn online to appear for nearby customers.'**
  String get towOperatorOfflineWarning;

  /// No description provided for @towOperatorNoRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'There are no requests yet.'**
  String get towOperatorNoRequestsYet;

  /// No description provided for @towOperatorActiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no active requests at the moment.'**
  String get towOperatorActiveEmpty;

  /// No description provided for @towOperatorHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no completed requests yet.'**
  String get towOperatorHistoryEmpty;

  /// No description provided for @towOperatorToggleButtonToOffline.
  ///
  /// In en, this message translates to:
  /// **'Set as unavailable'**
  String get towOperatorToggleButtonToOffline;

  /// No description provided for @towOperatorToggleButtonToOnline.
  ///
  /// In en, this message translates to:
  /// **'Set as available'**
  String get towOperatorToggleButtonToOnline;

  /// No description provided for @towOperatorRequestVehicleFallback.
  ///
  /// In en, this message translates to:
  /// **'Vehicle (no description)'**
  String get towOperatorRequestVehicleFallback;

  /// No description provided for @towOperatorRequestStatusNewSuffix.
  ///
  /// In en, this message translates to:
  /// **' • New'**
  String get towOperatorRequestStatusNewSuffix;

  /// No description provided for @towOperatorRequestFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get towOperatorRequestFromPrefix;

  /// No description provided for @towOperatorRequestToPrefix.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get towOperatorRequestToPrefix;

  /// No description provided for @towOperatorRequestToUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get towOperatorRequestToUnknown;

  /// No description provided for @towOperatorRequestTotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total service cost:'**
  String get towOperatorRequestTotalPrefix;

  /// No description provided for @towOperatorRequestPhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get towOperatorRequestPhonePrefix;

  /// No description provided for @towOperatorRequestClientLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Client location'**
  String get towOperatorRequestClientLocationButton;

  /// No description provided for @towOperatorRequestDestinationLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Drop-off location'**
  String get towOperatorRequestDestinationLocationButton;

  /// No description provided for @towOperatorMenuAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get towOperatorMenuAccept;

  /// No description provided for @towOperatorMenuOnWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get towOperatorMenuOnWay;

  /// No description provided for @towOperatorMenuDone.
  ///
  /// In en, this message translates to:
  /// **'Service completed'**
  String get towOperatorMenuDone;

  /// No description provided for @towOperatorMenuCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get towOperatorMenuCancel;

  /// No description provided for @towUnitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get towUnitKm;

  /// No description provided for @currencyEgpShort.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currencyEgpShort;

  /// No description provided for @towScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency tow service'**
  String get towScreenTitle;

  /// No description provided for @towScreenGpsEnableSnack.
  ///
  /// In en, this message translates to:
  /// **'Please enable location (GPS) from settings'**
  String get towScreenGpsEnableSnack;

  /// No description provided for @towScreenLocationPermissionDeniedSnack.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get towScreenLocationPermissionDeniedSnack;

  /// No description provided for @towScreenLocationFetchErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location:'**
  String get towScreenLocationFetchErrorSnack;

  /// No description provided for @towScreenLocationNotSetSnack.
  ///
  /// In en, this message translates to:
  /// **'Your location has not been set yet'**
  String get towScreenLocationNotSetSnack;

  /// No description provided for @towScreenSelectCompanySnack.
  ///
  /// In en, this message translates to:
  /// **'Please choose a tow company'**
  String get towScreenSelectCompanySnack;

  /// No description provided for @towScreenLoginRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in before requesting a tow'**
  String get towScreenLoginRequiredSnack;

  /// No description provided for @towScreenActiveTowExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active tow request'**
  String get towScreenActiveTowExistsTitle;

  /// No description provided for @towScreenActiveTowExistsBody.
  ///
  /// In en, this message translates to:
  /// **'You already have an active tow request.\nYou cannot create a new request before finishing or cancelling the current one from your account page (Tow requests section).'**
  String get towScreenActiveTowExistsBody;

  /// No description provided for @towScreenConfirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm request'**
  String get towScreenConfirmDialogTitle;

  /// No description provided for @towScreenConfirmCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company:'**
  String get towScreenConfirmCompanyLabel;

  /// No description provided for @towScreenConfirmMyLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'My location:'**
  String get towScreenConfirmMyLocationLabel;

  /// No description provided for @towScreenConfirmDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination:'**
  String get towScreenConfirmDestinationLabel;

  /// No description provided for @towScreenConfirmBaseCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Base cost:'**
  String get towScreenConfirmBaseCostLabel;

  /// No description provided for @towScreenConfirmKmTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total distance:'**
  String get towScreenConfirmKmTotalLabel;

  /// No description provided for @towScreenConfirmKmPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per km:'**
  String get towScreenConfirmKmPriceLabel;

  /// No description provided for @towScreenConfirmKmCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance cost:'**
  String get towScreenConfirmKmCostLabel;

  /// No description provided for @towScreenConfirmTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total service cost:'**
  String get towScreenConfirmTotalLabel;

  /// No description provided for @towScreenConfirmVehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle:'**
  String get towScreenConfirmVehicleLabel;

  /// No description provided for @towScreenConfirmPlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate:'**
  String get towScreenConfirmPlateLabel;

  /// No description provided for @towScreenConfirmProblemLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get towScreenConfirmProblemLabel;

  /// No description provided for @towScreenConfirmPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get towScreenConfirmPhoneLabel;

  /// No description provided for @towScreenDialogCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get towScreenDialogCancelButton;

  /// No description provided for @towScreenDialogConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get towScreenDialogConfirmButton;

  /// No description provided for @towScreenRequestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Tow request sent'**
  String get towScreenRequestSentTitle;

  /// No description provided for @towScreenRequestSentBodyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to:'**
  String get towScreenRequestSentBodyPrefix;

  /// No description provided for @towScreenCompanyPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Company phone number:'**
  String get towScreenCompanyPhoneLabel;

  /// No description provided for @towScreenCallCompanyButton.
  ///
  /// In en, this message translates to:
  /// **'Call company'**
  String get towScreenCallCompanyButton;

  /// No description provided for @towScreenCallErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer'**
  String get towScreenCallErrorSnack;

  /// No description provided for @towScreenNoCompanyPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'No phone number is registered for this company. Please contact them later through the app.'**
  String get towScreenNoCompanyPhoneHint;

  /// No description provided for @towScreenCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get towScreenCloseButton;

  /// No description provided for @towScreenSendErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request:'**
  String get towScreenSendErrorSnack;

  /// No description provided for @towScreenStepsStep1.
  ///
  /// In en, this message translates to:
  /// **'Set location'**
  String get towScreenStepsStep1;

  /// No description provided for @towScreenStepsStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose company'**
  String get towScreenStepsStep2;

  /// No description provided for @towScreenStepsStep3.
  ///
  /// In en, this message translates to:
  /// **'Vehicle details'**
  String get towScreenStepsStep3;

  /// No description provided for @towScreenStepsStep4.
  ///
  /// In en, this message translates to:
  /// **'Confirm request'**
  String get towScreenStepsStep4;

  /// No description provided for @towScreenLocationPendingWarning.
  ///
  /// In en, this message translates to:
  /// **'Your location is not set yet, use \"Use my location\" or pick from the map.'**
  String get towScreenLocationPendingWarning;

  /// No description provided for @towScreenLocationReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your location has been set successfully.'**
  String get towScreenLocationReadyMessage;

  /// No description provided for @towScreenCurrentLocationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'My current location'**
  String get towScreenCurrentLocationSectionTitle;

  /// No description provided for @towScreenCurrentCoordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Current coordinates'**
  String get towScreenCurrentCoordsLabel;

  /// No description provided for @towScreenUseMyLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get towScreenUseMyLocationButton;

  /// No description provided for @towScreenPickFromMapButton.
  ///
  /// In en, this message translates to:
  /// **'Choose from map'**
  String get towScreenPickFromMapButton;

  /// No description provided for @towScreenSelectedCompanyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Selected company:'**
  String get towScreenSelectedCompanyPrefix;

  /// No description provided for @towScreenSelectedCompanyDistancePrefix.
  ///
  /// In en, this message translates to:
  /// **'Distance to company:'**
  String get towScreenSelectedCompanyDistancePrefix;

  /// No description provided for @towScreenSelectedCompanyBaseCostPrefix.
  ///
  /// In en, this message translates to:
  /// **'Base service:'**
  String get towScreenSelectedCompanyBaseCostPrefix;

  /// No description provided for @towScreenSelectedCompanyKmPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Price per km:'**
  String get towScreenSelectedCompanyKmPricePrefix;

  /// No description provided for @towScreenSelectedCompanyChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get towScreenSelectedCompanyChangeButton;

  /// No description provided for @towScreenSelectedCompanyHintNoLocation.
  ///
  /// In en, this message translates to:
  /// **'After setting your location, we will suggest the nearest tow company automatically.'**
  String get towScreenSelectedCompanyHintNoLocation;

  /// No description provided for @towScreenSelectedCompanyHintChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose the tow company that suits you from the list.'**
  String get towScreenSelectedCompanyHintChoose;

  /// No description provided for @towScreenSelectedCompanyShowCompaniesButton.
  ///
  /// In en, this message translates to:
  /// **'Show companies'**
  String get towScreenSelectedCompanyShowCompaniesButton;

  /// No description provided for @towScreenDestinationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get towScreenDestinationSectionTitle;

  /// No description provided for @towScreenDestinationAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get towScreenDestinationAddressLabel;

  /// No description provided for @towScreenDestinationAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the address or pick it from the map'**
  String get towScreenDestinationAddressHint;

  /// No description provided for @towScreenDestinationMapButton.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get towScreenDestinationMapButton;

  /// No description provided for @towScreenDestinationOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'You can leave the destination empty and coordinate directly with the driver by phone.'**
  String get towScreenDestinationOptionalHint;

  /// No description provided for @towScreenCostsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Service costs'**
  String get towScreenCostsSectionTitle;

  /// No description provided for @towScreenCostsBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Base cost'**
  String get towScreenCostsBaseLabel;

  /// No description provided for @towScreenCostsKmTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total distance (to company + to destination)'**
  String get towScreenCostsKmTotalLabel;

  /// No description provided for @towScreenCostsKmPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per km'**
  String get towScreenCostsKmPriceLabel;

  /// No description provided for @towScreenCostsKmCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance cost'**
  String get towScreenCostsKmCostLabel;

  /// No description provided for @towScreenCostsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total service cost'**
  String get towScreenCostsTotalLabel;

  /// No description provided for @towScreenVehicleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information'**
  String get towScreenVehicleSectionTitle;

  /// No description provided for @towScreenVehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Make and model'**
  String get towScreenVehicleTypeLabel;

  /// No description provided for @towScreenVehicleTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Honda Civic'**
  String get towScreenVehicleTypeHint;

  /// No description provided for @towScreenRequiredFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get towScreenRequiredFieldError;

  /// No description provided for @towScreenPlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get towScreenPlateLabel;

  /// No description provided for @towScreenPlateHint.
  ///
  /// In en, this message translates to:
  /// **'Example: ABC-1234'**
  String get towScreenPlateHint;

  /// No description provided for @towScreenProblemLabel.
  ///
  /// In en, this message translates to:
  /// **'Problem description'**
  String get towScreenProblemLabel;

  /// No description provided for @towScreenProblemHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the problem… (optional)'**
  String get towScreenProblemHint;

  /// No description provided for @towScreenContactSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get towScreenContactSectionTitle;

  /// No description provided for @towScreenPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get towScreenPhoneLabel;

  /// No description provided for @towScreenPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+20 1xxxxxxxxx'**
  String get towScreenPhoneHint;

  /// No description provided for @towScreenPhoneInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get towScreenPhoneInvalidError;

  /// No description provided for @towScreenEtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival time'**
  String get towScreenEtaTitle;

  /// No description provided for @towScreenEtaValue.
  ///
  /// In en, this message translates to:
  /// **'15–25 minutes after request confirmation'**
  String get towScreenEtaValue;

  /// No description provided for @towScreenSubmitButtonSending.
  ///
  /// In en, this message translates to:
  /// **'Sending request...'**
  String get towScreenSubmitButtonSending;

  /// No description provided for @towScreenSubmitButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get towScreenSubmitButtonLabel;

  /// No description provided for @towScreenSubmitHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure your location is set and a tow company is selected before sending the request.'**
  String get towScreenSubmitHint;

  /// No description provided for @towScreenFloatingNearestCompanies.
  ///
  /// In en, this message translates to:
  /// **'Nearest companies'**
  String get towScreenFloatingNearestCompanies;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get bottomNavCategories;

  /// No description provided for @bottomNavTow.
  ///
  /// In en, this message translates to:
  /// **'Tow'**
  String get bottomNavTow;

  /// No description provided for @bottomNavCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get bottomNavCart;

  /// No description provided for @bottomNavAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get bottomNavAccount;

  /// No description provided for @currencyEgpPerKm.
  ///
  /// In en, this message translates to:
  /// **'EGP/km'**
  String get currencyEgpPerKm;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @cartAppTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Shopping cart'**
  String get cartAppTitlePrefix;

  /// No description provided for @cartAppTitleItemsSuffix.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get cartAppTitleItemsSuffix;

  /// No description provided for @cartItemDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get cartItemDeleteTooltip;

  /// No description provided for @orderSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummaryTitle;

  /// No description provided for @orderSummarySubtotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Items subtotal'**
  String get orderSummarySubtotalPrefix;

  /// No description provided for @orderSummaryItemsSuffix.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get orderSummaryItemsSuffix;

  /// No description provided for @orderSummaryShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get orderSummaryShippingLabel;

  /// No description provided for @orderSummaryDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get orderSummaryDiscountLabel;

  /// No description provided for @orderSummaryGrandTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get orderSummaryGrandTotalLabel;

  /// No description provided for @orderSummaryCouponSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Coupon code (optional)'**
  String get orderSummaryCouponSectionTitle;

  /// No description provided for @orderSummaryCouponFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon'**
  String get orderSummaryCouponFieldLabel;

  /// No description provided for @orderSummaryCouponApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get orderSummaryCouponApplyButton;

  /// No description provided for @orderSummaryNoteFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Order note (optional)'**
  String get orderSummaryNoteFieldLabel;

  /// No description provided for @orderSummarySubmittingLabel.
  ///
  /// In en, this message translates to:
  /// **'Creating order...'**
  String get orderSummarySubmittingLabel;

  /// No description provided for @orderSummarySubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get orderSummarySubmitButton;

  /// No description provided for @categoryTileItemCountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Products:'**
  String get categoryTileItemCountPrefix;

  /// No description provided for @productCardAddToCartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get productCardAddToCartTooltip;

  /// No description provided for @authOrDividerLabel.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDividerLabel;

  /// No description provided for @adminTowRequestsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading tow requests:'**
  String get adminTowRequestsErrorLoading;

  /// No description provided for @adminTowRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no tow requests yet.'**
  String get adminTowRequestsEmpty;

  /// No description provided for @adminTowRequestsItemTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get adminTowRequestsItemTitlePrefix;

  /// No description provided for @adminTowRequestsCompanyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Company:'**
  String get adminTowRequestsCompanyPrefix;

  /// No description provided for @adminTowRequestsStatusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get adminTowRequestsStatusPrefix;

  /// No description provided for @adminTowRequestsVehiclePlatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Vehicle / plate:'**
  String get adminTowRequestsVehiclePlatePrefix;

  /// No description provided for @adminTowRequestsPhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get adminTowRequestsPhonePrefix;

  /// No description provided for @adminTowRequestsTotalCostPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total service:'**
  String get adminTowRequestsTotalCostPrefix;

  /// No description provided for @adminTowRequestsFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get adminTowRequestsFromPrefix;

  /// No description provided for @adminTowRequestsToPrefix.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get adminTowRequestsToPrefix;

  /// No description provided for @adminTowRequestsProblemPrefix.
  ///
  /// In en, this message translates to:
  /// **'Problem:'**
  String get adminTowRequestsProblemPrefix;

  /// No description provided for @adminWinchAccountsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading tow accounts:'**
  String get adminWinchAccountsErrorLoading;

  /// No description provided for @adminWinchAccountsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tow accounts have been registered yet.'**
  String get adminWinchAccountsEmpty;

  /// No description provided for @adminWinchAccountsNoName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get adminWinchAccountsNoName;

  /// No description provided for @adminWinchAccountsNoArea.
  ///
  /// In en, this message translates to:
  /// **'No area'**
  String get adminWinchAccountsNoArea;

  /// No description provided for @adminWinchAccountsOnlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get adminWinchAccountsOnlineLabel;

  /// No description provided for @adminWinchAccountsOfflineLabel.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get adminWinchAccountsOfflineLabel;

  /// No description provided for @adminWinchAccountsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete tow account'**
  String get adminWinchAccountsDeleteTitle;

  /// No description provided for @adminWinchAccountsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete account \"{name}\"?'**
  String adminWinchAccountsDeleteMessage(String name);

  /// No description provided for @adminWinchAccountsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get adminWinchAccountsDeleteConfirm;

  /// No description provided for @adminWinchAccountsDeleteMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get adminWinchAccountsDeleteMenu;

  /// No description provided for @adminWinchAccountsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account {name} has been deleted'**
  String adminWinchAccountsDeleteSuccess(String name);

  /// No description provided for @adminWinchAccountsAreaPrefix.
  ///
  /// In en, this message translates to:
  /// **'Area:'**
  String get adminWinchAccountsAreaPrefix;

  /// No description provided for @adminWinchAccountsBaseCostPrefix.
  ///
  /// In en, this message translates to:
  /// **'Base service price:'**
  String get adminWinchAccountsBaseCostPrefix;

  /// No description provided for @adminWinchAccountsPricePerKmPrefix.
  ///
  /// In en, this message translates to:
  /// **'Price per km:'**
  String get adminWinchAccountsPricePerKmPrefix;

  /// No description provided for @adminWinchAccountsPhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get adminWinchAccountsPhonePrefix;

  /// No description provided for @adminOrdersErrorLoadingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders:'**
  String get adminOrdersErrorLoadingPrefix;

  /// No description provided for @adminOrdersRangePickerHelp.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get adminOrdersRangePickerHelp;

  /// No description provided for @adminOrdersRangePickerSave.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get adminOrdersRangePickerSave;

  /// No description provided for @adminOrdersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search: code / buyer / seller / product…'**
  String get adminOrdersSearchHint;

  /// No description provided for @adminOrdersClearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get adminOrdersClearSearchTooltip;

  /// No description provided for @adminOrdersRangeAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Range: All'**
  String get adminOrdersRangeAllLabel;

  /// No description provided for @adminOrdersPaginationRemoveRangeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear range'**
  String get adminOrdersPaginationRemoveRangeTooltip;

  /// No description provided for @adminOrdersPaginationNextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get adminOrdersPaginationNextTooltip;

  /// No description provided for @adminOrdersSortCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get adminOrdersSortCreatedDesc;

  /// No description provided for @adminOrdersSortCreatedAsc.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get adminOrdersSortCreatedAsc;

  /// No description provided for @adminOrdersSortTotalDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount: highest ↓'**
  String get adminOrdersSortTotalDesc;

  /// No description provided for @adminOrdersSortTotalAsc.
  ///
  /// In en, this message translates to:
  /// **'Amount: lowest ↑'**
  String get adminOrdersSortTotalAsc;

  /// No description provided for @adminOrdersResetFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get adminOrdersResetFiltersButton;

  /// No description provided for @adminOrdersMatchingCountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Matching orders:'**
  String get adminOrdersMatchingCountPrefix;

  /// No description provided for @adminOrdersNoMatchingMessage.
  ///
  /// In en, this message translates to:
  /// **'No matching orders'**
  String get adminOrdersNoMatchingMessage;

  /// No description provided for @adminOrdersBuyerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Buyer:'**
  String get adminOrdersBuyerPrefix;

  /// No description provided for @adminOrdersItemsCountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Items:'**
  String get adminOrdersItemsCountPrefix;

  /// No description provided for @adminOrdersGrandTotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get adminOrdersGrandTotalPrefix;

  /// No description provided for @adminOrdersGeoAddressPrefix.
  ///
  /// In en, this message translates to:
  /// **'Geo address:'**
  String get adminOrdersGeoAddressPrefix;

  /// No description provided for @adminOrdersTotalFooterPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get adminOrdersTotalFooterPrefix;

  /// No description provided for @adminOrdersPaginationFirstTooltip.
  ///
  /// In en, this message translates to:
  /// **'First page'**
  String get adminOrdersPaginationFirstTooltip;

  /// No description provided for @adminOrdersPaginationPrevTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get adminOrdersPaginationPrevTooltip;

  /// No description provided for @adminOrdersPaginationLastTooltip.
  ///
  /// In en, this message translates to:
  /// **'Last page'**
  String get adminOrdersPaginationLastTooltip;

  /// No description provided for @adminOrdersPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get adminOrdersPageLabel;

  /// No description provided for @sellerInventoryRestockDialogTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get sellerInventoryRestockDialogTitlePrefix;

  /// No description provided for @sellerInventoryRestockQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity to add'**
  String get sellerInventoryRestockQuantityLabel;

  /// No description provided for @sellerInventoryRestockQuantityInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number greater than zero'**
  String get sellerInventoryRestockQuantityInvalidError;

  /// No description provided for @sellerInventoryRestockQuantityTooBigError.
  ///
  /// In en, this message translates to:
  /// **'Value is too large'**
  String get sellerInventoryRestockQuantityTooBigError;

  /// No description provided for @sellerInventoryRestockAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get sellerInventoryRestockAddButton;

  /// No description provided for @sellerInventoryRestockSuccessPrefix.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get sellerInventoryRestockSuccessPrefix;

  /// No description provided for @sellerInventoryRestockSuccessInfix.
  ///
  /// In en, this message translates to:
  /// **'to the stock of'**
  String get sellerInventoryRestockSuccessInfix;

  /// No description provided for @sellerInventoryRestockErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to update stock:'**
  String get sellerInventoryRestockErrorPrefix;

  /// No description provided for @sellerInventoryErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get sellerInventoryErrorLoading;

  /// No description provided for @sellerInventoryEmptyForSeller.
  ///
  /// In en, this message translates to:
  /// **'No approved products for this seller yet'**
  String get sellerInventoryEmptyForSeller;

  /// No description provided for @sellerInventoryTotalStockPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total stock:'**
  String get sellerInventoryTotalStockPrefix;

  /// No description provided for @sellerInventoryTotalSoldPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total sold:'**
  String get sellerInventoryTotalSoldPrefix;

  /// No description provided for @sellerInventoryTotalRevenuePrefix.
  ///
  /// In en, this message translates to:
  /// **'Total revenue:'**
  String get sellerInventoryTotalRevenuePrefix;

  /// No description provided for @sellerInventoryEditStockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit stock'**
  String get sellerInventoryEditStockTooltip;

  /// No description provided for @sellerInventoryStockPrefix.
  ///
  /// In en, this message translates to:
  /// **'Stock:'**
  String get sellerInventoryStockPrefix;

  /// No description provided for @sellerInventorySoldPrefix.
  ///
  /// In en, this message translates to:
  /// **'Sold:'**
  String get sellerInventorySoldPrefix;

  /// No description provided for @sellerInventoryRevenuePrefix.
  ///
  /// In en, this message translates to:
  /// **'Revenue:'**
  String get sellerInventoryRevenuePrefix;

  /// No description provided for @sellerInventoryPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Price:'**
  String get sellerInventoryPricePrefix;

  /// No description provided for @sellerInventoryYearsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Fit years:'**
  String get sellerInventoryYearsPrefix;

  /// No description provided for @productReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get productReviewsTitle;

  /// No description provided for @productReviewsProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Product reviews'**
  String get productReviewsProductTitle;

  /// No description provided for @productReviewsSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller reviews'**
  String get productReviewsSellerTitle;

  /// No description provided for @productReviewsNoProductReviewsMessage.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this product yet'**
  String get productReviewsNoProductReviewsMessage;

  /// No description provided for @productReviewsNoSellerReviewsMessage.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this seller yet'**
  String get productReviewsNoSellerReviewsMessage;

  /// No description provided for @productReviewsBuyerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Buyer:'**
  String get productReviewsBuyerPrefix;

  /// No description provided for @catalogCanFulfillItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item \"{name}\" is not available in the catalog.'**
  String catalogCanFulfillItemNotFound(String name);

  /// No description provided for @catalogCanFulfillInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Current stock of \"{name}\" is only {stock}.'**
  String catalogCanFulfillInsufficientStock(String name, int stock);

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusPrepared.
  ///
  /// In en, this message translates to:
  /// **'Prepared'**
  String get orderStatusPrepared;

  /// No description provided for @orderStatusHandedToCourier.
  ///
  /// In en, this message translates to:
  /// **'Handed to courier'**
  String get orderStatusHandedToCourier;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @towStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get towStatusPending;

  /// No description provided for @towStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get towStatusAccepted;

  /// No description provided for @towStatusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get towStatusOnTheWay;

  /// No description provided for @towStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Service completed'**
  String get towStatusCompleted;

  /// No description provided for @towStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get towStatusCancelled;

  /// No description provided for @towStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get towStatusRejected;

  /// No description provided for @adminWinchTabWinchTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Tow:'**
  String get adminWinchTabWinchTitlePrefix;

  /// No description provided for @adminWinchTabStatusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get adminWinchTabStatusPrefix;

  /// No description provided for @adminWinchTabStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminWinchTabStatusApproved;

  /// No description provided for @adminWinchTabStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get adminWinchTabStatusPending;

  /// No description provided for @adminWinchTabMaxWinchesPrefix.
  ///
  /// In en, this message translates to:
  /// **'Allowed tow trucks:'**
  String get adminWinchTabMaxWinchesPrefix;

  /// No description provided for @adminWinchTabDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents:'**
  String get adminWinchTabDocsTitle;

  /// No description provided for @adminWinchTabMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get adminWinchTabMenuTooltip;

  /// No description provided for @adminWinchTabMenuApproveLabel.
  ///
  /// In en, this message translates to:
  /// **'Approve & set capacity'**
  String get adminWinchTabMenuApproveLabel;

  /// No description provided for @adminWinchTabApproveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tow account approved with capacity = {capacity}'**
  String adminWinchTabApproveSuccess(int capacity);

  /// No description provided for @adminWinchTabCapacityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set number of tow trucks in service'**
  String get adminWinchTabCapacityDialogTitle;

  /// No description provided for @adminWinchTabCapacityFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of tow trucks'**
  String get adminWinchTabCapacityFieldLabel;

  /// No description provided for @adminWinchTabDialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminWinchTabDialogSave;

  /// No description provided for @login_banned_message.
  ///
  /// In en, this message translates to:
  /// **'Your account has been permanently banned.\nYou can no longer sign in with this email.\nPlease contact the administration.'**
  String get login_banned_message;

  /// No description provided for @login_frozen_message.
  ///
  /// In en, this message translates to:
  /// **'Your account is temporarily suspended.\nPlease contact the administration for more details.'**
  String get login_frozen_message;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
