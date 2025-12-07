// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Auto Spare';

  @override
  String get brandProductsTitle => 'Brand products';

  @override
  String get searchHint => 'Search by name or code';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceLow => 'Price: Low to High';

  @override
  String get sortPriceHigh => 'Price: High to Low';

  @override
  String get sortStockHigh => 'Stock: High to Low';

  @override
  String get noProducts => 'No products found';

  @override
  String get login_title => 'Welcome back';

  @override
  String get login_subtitle => 'Sign in to access the app';

  @override
  String get login_email_label => 'Email';

  @override
  String get login_email_hint => 'example@mail.com';

  @override
  String get login_password_label => 'Password';

  @override
  String get login_password_hint => '••••••••';

  @override
  String get login_required => 'Required';

  @override
  String get login_remember_me => 'Remember me';

  @override
  String get login_button => 'Sign in';

  @override
  String get login_signup_button => 'Create a new account';

  @override
  String get login_with_google => 'Continue with Google';

  @override
  String get login_continue_as_guest => 'Continue as guest';

  @override
  String get login_fix_errors_message => 'Please fix the errors in the form.';

  @override
  String get login_invalid_credentials_message => 'Invalid login credentials';

  @override
  String get login_winch_not_approved_message =>
      'Winch account is not activated yet.';

  @override
  String get login_guest_name => 'Guest';

  @override
  String get home_no_products_available =>
      'No products are currently available';

  @override
  String get home_no_search_results => 'No results match your search';

  @override
  String get home_search_hint => 'Search for a part...';

  @override
  String get home_sort_tooltip => 'Sort results';

  @override
  String get home_sort_newest => 'Newest first';

  @override
  String get home_sort_oldest => 'Oldest first';

  @override
  String get home_sort_price_low => 'Price: Low to High';

  @override
  String get home_sort_price_high => 'Price: High to Low';

  @override
  String get home_sort_stock_high => 'Highest stock';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_categories => 'Categories';

  @override
  String get nav_tow => 'Tow';

  @override
  String get nav_cart => 'Cart';

  @override
  String get nav_profile => 'My account';

  @override
  String get common_language_toggle_tooltip => 'Change language';

  @override
  String get signup_title => 'Create an account';

  @override
  String get signup_role_buyer => 'Buyer';

  @override
  String get signup_role_seller => 'Seller';

  @override
  String get signup_role_tow => 'Tow company';

  @override
  String get signup_email_label => 'Email';

  @override
  String get signup_password_label => 'Password';

  @override
  String get signup_password_confirm_label => 'Confirm password';

  @override
  String get signup_name_label => 'Name';

  @override
  String get signup_address_label => 'Address';

  @override
  String get signup_phone_label => 'Phone number';

  @override
  String get signup_store_name_label => 'Store name';

  @override
  String get signup_cr_url_label =>
      'Commercial registration image URL (Drive/Link)';

  @override
  String get signup_tax_url_label => 'Tax card image URL (Drive/Link)';

  @override
  String get signup_note_upload_docs =>
      'Note: You can upload files to Google Drive and send the links for review.';

  @override
  String get signup_company_name_label => 'Company name';

  @override
  String get signup_area_label => 'Coverage area';

  @override
  String get signup_base_cost_label => 'Base service price (EGP)';

  @override
  String get signup_price_per_km_label => 'Price per km (EGP)';

  @override
  String get signup_lat_label => 'Latitude';

  @override
  String get signup_lng_label => 'Longitude';

  @override
  String get signup_pick_location_button =>
      'Pick location (current location / manual)';

  @override
  String get signup_tow_cr_url_label =>
      'Commercial registration image URL (Drive/Link)';

  @override
  String get signup_tow_tax_url_label => 'Tax card image URL (Drive/Link)';

  @override
  String get signup_password_too_short => 'At least 4 characters';

  @override
  String get signup_number_invalid => 'Please enter a valid number';

  @override
  String get signup_passwords_not_match => 'Passwords do not match';

  @override
  String get signup_banned_email_message =>
      'A new account cannot be created with this email.\nThis account has been permanently banned by the administration.';

  @override
  String get signup_tow_invalid_location_or_price =>
      'Please enter valid location/pricing data';

  @override
  String get signup_tow_request_submitted =>
      'Tow company request submitted for review';

  @override
  String get signup_seller_request_submitted =>
      'Seller registration request submitted for review';

  @override
  String get signup_buyer_created => 'Buyer account created successfully';

  @override
  String get signup_generic_error =>
      'An error occurred while creating the account';

  @override
  String get signup_email_already_in_use =>
      'An account already exists for this email';

  @override
  String get signup_weak_password =>
      'Weak password, please choose a stronger one';

  @override
  String get signup_account_already_exists => 'Account already exists';

  @override
  String get signup_submit_button => 'Create account';

  @override
  String get currency_egp => 'EGP';

  @override
  String get common_invalid_url => 'Invalid URL';

  @override
  String get common_image_load_failed => 'Failed to load image';

  @override
  String get common_open_in_browser => 'Open in browser';

  @override
  String get common_preview => 'Preview';

  @override
  String get admin_earnings_title => 'App earnings';

  @override
  String get admin_earnings_error_loading_orders =>
      'An error occurred while loading orders';

  @override
  String get admin_earnings_no_completed_orders =>
      'There are no completed orders yet.';

  @override
  String get admin_earnings_no_completed_in_range =>
      'There are no completed orders in the selected period.\nTry choosing another date range.';

  @override
  String get admin_earnings_date_range_help => 'Select period';

  @override
  String get admin_earnings_date_range_confirm => 'Apply';

  @override
  String get admin_earnings_date_range_cancel => 'Cancel';

  @override
  String get admin_earnings_current_period_label => 'Current display period';

  @override
  String get admin_earnings_summary_title =>
      'Earnings summary for selected period';

  @override
  String get admin_earnings_summary_desc =>
      'All figures below are calculated from completed orders within the selected period only.';

  @override
  String get admin_earnings_total_app_fee_label => 'Total app earnings';

  @override
  String get admin_earnings_change_period_button => 'Change period';

  @override
  String get admin_earnings_chart_section_title =>
      'Earnings performance in the selected period';

  @override
  String get admin_earnings_chart_title =>
      'App earnings curve (selected period)';

  @override
  String get admin_earnings_chart_no_data =>
      'Not enough data to draw a chart for this period.';

  @override
  String get admin_earnings_period_orders_count_title =>
      'Completed orders in period';

  @override
  String get admin_earnings_period_total_paid_title => 'Total paid in period';

  @override
  String get admin_earnings_period_app_fee_title => 'App earnings in period';

  @override
  String get admin_earnings_last_updated_prefix => 'Last updated:';

  @override
  String get admin_earnings_total_paid_subtitle =>
      'Includes shipping, discount and app fee';

  @override
  String get admin_earnings_total_items_title => 'Total items value';

  @override
  String get admin_earnings_total_items_subtitle =>
      'Before shipping and discounts';

  @override
  String get admin_earnings_total_discount_title => 'Total discounts';

  @override
  String get admin_earnings_total_app_fee_card_title =>
      'Total app earnings (estimated)';

  @override
  String get admin_earnings_total_app_fee_subtitle =>
      'Calculated as 5% of final order prices';

  @override
  String get admin_profile_earnings_button => 'App earnings dashboard';

  @override
  String get admin_profile_manage_orders_button => 'Manage orders';

  @override
  String get admin_profile_manage_tow_orders_button => 'Manage tow requests';

  @override
  String get admin_profile_users_accounts_button => 'User accounts';

  @override
  String get admin_profile_tab_products_review => 'Review products';

  @override
  String get admin_profile_tab_sellers_approval => 'Approve sellers';

  @override
  String get admin_profile_tab_tow_approval => 'Approve tow companies';

  @override
  String get admin_profile_pending_sellers_title =>
      'Seller registration requests (Pending)';

  @override
  String get admin_profile_pending_label_prefix => 'Pending:';

  @override
  String get admin_profile_no_pending_sellers =>
      'There are no seller requests under review.';

  @override
  String get admin_profile_products_panel_title => 'Products review panel';

  @override
  String get admin_profile_no_pending_products =>
      'There are no products under review.';

  @override
  String get admin_profile_uploaded_docs_title => 'Uploaded documents:';

  @override
  String get admin_profile_rejected_with_reason_prefix => 'Rejected:';

  @override
  String get admin_tow_requests_pending_title =>
      'Tow companies requests (Pending)';

  @override
  String get admin_tow_requests_no_pending =>
      'There are no tow company requests under review.';

  @override
  String get admin_tow_requests_account_owner_label => 'Account owner:';

  @override
  String get admin_tow_requests_service_price_prefix => 'Base service price:';

  @override
  String get admin_tow_requests_price_per_km_prefix => 'Price per km:';

  @override
  String get admin_tow_requests_location_label => 'Location (lat, lng):';

  @override
  String get cart_delivery_fees_note =>
      'Delivery fees may vary based on quantity and package size.';

  @override
  String get cart_delivery_payment_note =>
      'Currently available payment method: Cash on delivery.';

  @override
  String get cart_electronic_payment_title => 'Electronic payment';

  @override
  String get cart_electronic_payment_subtitle =>
      'Coming soon – cards & e-wallets';

  @override
  String get cart_electronic_payment_soon_chip => 'Soon';

  @override
  String get cart_electronic_payment_soon_message =>
      'Electronic payment will be available soon.';

  @override
  String get admin_common_cancel => 'Cancel';

  @override
  String get admin_common_reject => 'Reject';

  @override
  String get admin_common_approve => 'Approve';

  @override
  String get admin_products_error_loading =>
      'An error occurred while loading products';

  @override
  String get admin_products_approve_success_prefix => 'Approved';

  @override
  String get admin_products_update_failed_prefix => 'Update failed:';

  @override
  String get admin_products_reject_dialog_title => 'Reject product';

  @override
  String get admin_products_reject_reason_label => 'Rejection reason';

  @override
  String get admin_products_reject_reason_hint => 'Rejection reason (optional)';

  @override
  String get admin_products_reject_reason_default => 'Not specified';

  @override
  String get admin_products_rejected_with_reason_prefix => 'Rejected';

  @override
  String get admin_products_label_id => 'ID';

  @override
  String get admin_products_label_seller => 'Seller';

  @override
  String get admin_products_label_brand => 'Brand';

  @override
  String get admin_products_label_model => 'Model';

  @override
  String get admin_products_label_years => 'Years';

  @override
  String get admin_products_label_stock => 'Stock';

  @override
  String get admin_orders_title => 'Manage orders';

  @override
  String get admin_tow_orders_title => 'Manage tow requests';

  @override
  String get admin_tow_orders_no_requests => 'There are no tow requests yet.';

  @override
  String get admin_tow_orders_status_cancelled_by_user_suffix =>
      ' • Cancelled by customer';

  @override
  String get admin_tow_orders_status_cancelled_by_company_suffix =>
      ' • Cancelled by company';

  @override
  String get admin_tow_orders_company_prefix => 'Company:';

  @override
  String get admin_tow_orders_total_cost_prefix => 'Total:';

  @override
  String get admin_tow_orders_vehicle_label => 'Vehicle:';

  @override
  String get admin_tow_orders_plate_label => 'Plate:';

  @override
  String get admin_tow_orders_customer_phone_label => 'Customer phone:';

  @override
  String get admin_tow_orders_cancel_reason_title =>
      'Cancellation reason (customer):';

  @override
  String get admin_tow_orders_cancel_date_prefix => 'Cancellation date:';

  @override
  String get brand_products_results_count_prefix => 'Results:';

  @override
  String get admin_users_title => 'User accounts';

  @override
  String get admin_users_tab_buyers => 'Buyer accounts';

  @override
  String get admin_users_tab_sellers => 'Seller accounts';

  @override
  String get admin_users_tab_winches => 'Tow accounts';

  @override
  String get admin_users_no_buyer_accounts => 'There are no buyer accounts.';

  @override
  String get admin_users_no_seller_accounts => 'There are no seller accounts.';

  @override
  String get admin_users_no_winch_accounts => 'There are no tow accounts.';

  @override
  String get admin_users_status_banned => 'Permanently banned';

  @override
  String get admin_users_status_active => 'Active';

  @override
  String get admin_users_status_frozen => 'Frozen / Inactive';

  @override
  String get admin_users_no_name => 'No name';

  @override
  String get admin_users_email_label => 'Email';

  @override
  String get admin_users_phone_label => 'Phone';

  @override
  String get admin_users_store_label => 'Store:';

  @override
  String get admin_users_freeze => 'Freeze';

  @override
  String get admin_users_unfreeze => 'Unfreeze';

  @override
  String get admin_users_unban_and_activate => 'Unban / Activate';

  @override
  String get admin_users_permanent_ban_button => 'Permanent ban';

  @override
  String get admin_users_permanent_ban_dialog_title => 'Confirm permanent ban';

  @override
  String get admin_users_permanent_ban_dialog_body_prefix =>
      'Are you sure you want to permanently ban';

  @override
  String get admin_users_permanent_ban_dialog_body_suffix =>
      '?\nThe user will not be able to use this account or create a new one with the same email.';

  @override
  String get admin_users_permanent_ban_confirm => 'Confirm ban';

  @override
  String get buyer_profile_tab_my_orders => 'My orders';

  @override
  String get buyer_profile_tab_tow_requests => 'Tow requests';

  @override
  String get buyer_profile_go_shopping_button => 'Go shopping';

  @override
  String get buyer_tow_cancel_dialog_title => 'Cancel tow request';

  @override
  String get buyer_tow_cancel_reason_label => 'Cancellation reason (optional)';

  @override
  String get buyer_tow_cancel_reason_hint =>
      'Example: company is late / I managed on my own...';

  @override
  String get buyer_tow_cancel_confirm_button => 'Confirm cancellation';

  @override
  String get buyer_tow_cancel_success_message =>
      'Tow request cancelled successfully';

  @override
  String get buyer_tow_cancel_error_prefix => 'Failed to cancel request:';

  @override
  String get buyer_tow_no_requests_message => 'You have no tow requests yet.';

  @override
  String get buyer_tow_status_new_suffix => '(new)';

  @override
  String get buyer_tow_cancel_button => 'Cancel request';

  @override
  String get cart_title => 'Shopping cart';

  @override
  String get cart_empty_title => 'Your cart is empty';

  @override
  String get cart_empty_message => 'Cart is empty';

  @override
  String get cart_login_required_message => 'Please sign in first';

  @override
  String get cart_enter_name_message => 'Please enter customer name';

  @override
  String get cart_enter_address_message => 'Please enter address';

  @override
  String get cart_enter_phone_message => 'Please enter phone number';

  @override
  String get cart_quantity_exceeds_stock_prefix =>
      'You cannot order more than available in stock';

  @override
  String get cart_coupon_enter_code_message => 'Please enter the coupon code';

  @override
  String get cart_coupon_invalid_message => 'Invalid coupon code';

  @override
  String get cart_coupon_not_usable_message =>
      'This coupon is inactive or expired';

  @override
  String get cart_coupon_seller_mismatch_message =>
      'No items in cart from the seller of this coupon';

  @override
  String get cart_coupon_applied_prefix => 'Coupon applied:';

  @override
  String get cart_coupon_apply_error_prefix => 'Error applying coupon:';

  @override
  String get cart_customer_section_title => 'Customer details';

  @override
  String get cart_customer_name_label => 'Name';

  @override
  String get cart_customer_address_label => 'Address';

  @override
  String get cart_customer_phone_label => 'Phone';

  @override
  String get cart_customer_alt_phone_label => 'Alternate phone';

  @override
  String get cart_delivery_section_title => 'Delivery location (optional)';

  @override
  String get cart_delivery_input_label => 'Address or coordinates';

  @override
  String get cart_delivery_current_location_button => 'My current location';

  @override
  String get cart_delivery_pick_on_map_button => 'Pick from map';

  @override
  String get cart_confirm_dialog_title => 'Confirm order';

  @override
  String get cart_confirm_customer_label => 'Customer:';

  @override
  String get cart_confirm_address_label => 'Address:';

  @override
  String get cart_confirm_phone_label => 'Phone:';

  @override
  String get cart_confirm_delivery_location_label => 'Delivery location:';

  @override
  String get cart_confirm_items_count_label => 'Items count:';

  @override
  String get cart_confirm_items_total_label => 'Items total:';

  @override
  String get cart_confirm_shipping_label => 'Shipping:';

  @override
  String get cart_confirm_discount_label => 'Discount: -';

  @override
  String get cart_confirm_grand_total_label => 'Grand total:';

  @override
  String get cart_confirm_note_label => 'Note:';

  @override
  String get cart_confirm_button => 'Confirm';

  @override
  String get cart_order_created_prefix => 'Order created';

  @override
  String get cart_cancel_all_items_message =>
      'All items in cart have been cleared';

  @override
  String get categories_error_loading =>
      'An error occurred while loading categories';

  @override
  String get categories_search_hint => 'Search for parts, brands, models...';

  @override
  String get categories_title => 'Categories';

  @override
  String get categories_subtitle => 'Browse parts by brand';

  @override
  String get map_picker_title => 'Choose destination';

  @override
  String get map_picker_search_hint => 'Search for an address or place...';

  @override
  String get map_picker_no_results_message =>
      'No results were found for this search.\nTry adjusting the address or checking your internet connection.';

  @override
  String get map_picker_pending_address => 'Resolving address…';

  @override
  String get map_picker_confirm_button => 'Choose this location';

  @override
  String get product_details_title => 'Product details';

  @override
  String get product_details_added_to_cart_message => 'Product added to cart';

  @override
  String get product_details_brand_label_prefix => 'Brand:';

  @override
  String get product_details_model_label_prefix => 'Model:';

  @override
  String get product_details_years_label_prefix => 'Years:';

  @override
  String get product_details_stock_label_prefix => 'Available stock:';

  @override
  String get product_details_price_label_prefix => 'Price:';

  @override
  String get product_details_add_to_cart_button => 'Add to cart';

  @override
  String get product_details_buy_now_button => 'Buy now';

  @override
  String get product_details_seller_label_prefix => 'Seller:';

  @override
  String get profile_app_bar_title => 'Profile';

  @override
  String get profile_winch_requests_button_tooltip =>
      'Manage tow requests (service provider panel)';

  @override
  String get profile_winch_requests_button_label => 'Tow requests';

  @override
  String get profile_logout_tooltip => 'Sign out';

  @override
  String get profile_login_tooltip => 'Sign in';

  @override
  String get profile_greeting_prefix => 'Welcome';

  @override
  String get profile_role_label_admin => 'Admin (System Management)';

  @override
  String get profile_role_label_seller => 'Seller';

  @override
  String get profile_role_label_buyer => 'Buyer';

  @override
  String get profile_role_label_winch => 'Tow service provider';

  @override
  String get profile_role_label_unknown => 'Unknown';

  @override
  String get profile_mode_admin_label => 'Admin dashboard';

  @override
  String get profile_mode_winch_label =>
      'Tow service provider • Can shop from the store';

  @override
  String get profile_mode_prefix => 'Mode:';

  @override
  String get profile_mode_seller_label => 'Seller';

  @override
  String get profile_mode_buyer_label => 'Buyer';

  @override
  String get profile_role_chip_label_prefix => 'Account role:';

  @override
  String get profile_switch_to_buyer_button => 'Switch to buyer';

  @override
  String get profile_switch_to_seller_button => 'Switch back to seller';

  @override
  String get profile_switched_to_buyer_message => 'Switched to buyer mode';

  @override
  String get profile_switched_to_seller_message =>
      'Switched back to seller mode';

  @override
  String get profile_winch_hint_text =>
      'This account is registered as a tow service provider, and you can also buy spare parts from the store using this account.';

  @override
  String get profile_pure_buyer_hint_text =>
      'This account is registered as buyer only.';

  @override
  String get seller_coupons_title => 'Discount coupons';

  @override
  String get seller_coupons_help_text =>
      'Create and manage discount coupons for your store.';

  @override
  String get seller_coupons_create_button => 'Create new coupon';

  @override
  String get seller_coupons_empty_message => 'There are no coupons yet.';

  @override
  String get seller_coupons_status_expired => 'Expired';

  @override
  String get seller_coupons_status_active => 'Active';

  @override
  String get seller_coupons_status_inactive => 'Inactive';

  @override
  String get seller_coupons_discount_percent_prefix => 'Discount:';

  @override
  String get seller_coupons_expires_at_prefix => 'Expires at:';

  @override
  String get seller_coupons_no_expiry => 'No expiry date';

  @override
  String get seller_coupons_toggle_tooltip_activate => 'Activate coupon';

  @override
  String get seller_coupons_toggle_tooltip_deactivate => 'Deactivate coupon';

  @override
  String get seller_coupons_delete_tooltip => 'Delete coupon';

  @override
  String get seller_coupons_delete_dialog_title => 'Delete coupon';

  @override
  String get seller_coupons_delete_dialog_message_prefix =>
      'Are you sure you want to delete coupon';

  @override
  String get seller_coupons_delete_dialog_cancel_button => 'Cancel';

  @override
  String get seller_coupons_delete_dialog_confirm_button => 'Delete';

  @override
  String get seller_coupons_created_snackbar_prefix => 'Coupon created';

  @override
  String get seller_coupons_create_dialog_title => 'Create coupon';

  @override
  String get seller_coupons_code_label => 'Code (example: SAVE10)';

  @override
  String get seller_coupons_code_required_error => 'Required';

  @override
  String get seller_coupons_code_no_spaces_error =>
      'Code must not contain spaces';

  @override
  String get seller_coupons_percent_label => 'Discount %';

  @override
  String get seller_coupons_percent_required_error => 'Required';

  @override
  String get seller_coupons_percent_invalid_error =>
      'Enter a value between 1 and 100';

  @override
  String get seller_coupons_days_label => 'Validity in days (optional)';

  @override
  String get seller_coupons_days_hint => 'Leave empty for no expiry';

  @override
  String get seller_coupons_form_cancel_button => 'Cancel';

  @override
  String get seller_coupons_form_save_button => 'Save';

  @override
  String get currencyEgp => 'EGP';

  @override
  String get adminEarningsLastUpdatedPrefix => 'Last updated:';

  @override
  String get sellerDashboardAllTime => 'All time';

  @override
  String get sellerDashboardRangeFromPrefix => 'From';

  @override
  String get sellerDashboardRangeToPrefix => 'to';

  @override
  String get sellerDashboardDateRangeHelp =>
      'Select period to view your earnings';

  @override
  String get sellerDashboardDateRangeCancel => 'Cancel';

  @override
  String get sellerDashboardDateRangeConfirm => 'Apply';

  @override
  String get sellerDashboardTitle => 'Seller dashboard';

  @override
  String get sellerDashboardUnknownSellerMessage =>
      'Unable to determine seller identity for this account.';

  @override
  String get sellerDashboardErrorLoadingOrders =>
      'An error occurred while loading orders.';

  @override
  String get sellerDashboardNoCompletedOrders =>
      'There are no completed orders yet.';

  @override
  String get sellerDashboardNoOrdersInRange =>
      'There are no orders in the selected period.\nTry changing the date range.';

  @override
  String get sellerDashboardStatOrdersInPeriodTitle =>
      'Completed orders (in period)';

  @override
  String get sellerDashboardStatItemsSoldTitle => 'Total items sold';

  @override
  String get sellerDashboardStatItemsTotalTitle =>
      'Items value (before discount)';

  @override
  String get sellerDashboardStatItemsTotalSubtitle =>
      'Based only on the prices you entered for products';

  @override
  String get sellerDashboardStatDiscountTotalTitle =>
      'Total discounts on your items';

  @override
  String get sellerDashboardStatDiscountTotalSubtitle =>
      'Includes discounts and coupons in the period';

  @override
  String get sellerDashboardStatNetInPeriodTitle =>
      'Net earnings after discounts (in period)';

  @override
  String get sellerDashboardStatNetInPeriodSubtitle =>
      'Does not include app commission 5% (charged to buyer)';

  @override
  String get sellerDashboardChartSectionTitle =>
      'Net earnings distribution by day';

  @override
  String get sellerDashboardChartNoData =>
      'Not enough data to draw a chart in the selected period.';

  @override
  String get sellerDashboardChartTitle => 'Your net earnings by day';

  @override
  String get sellerDashboardCouponsSectionTitle =>
      'Coupon impact on your earnings (in period)';

  @override
  String get sellerDashboardCouponsTotalLabel =>
      'Total coupon discounts on your items in the selected period:';

  @override
  String get sellerDashboardCouponsEmptyMessage =>
      'No coupon codes were used on your items in the selected period.';

  @override
  String get sellerDashboardSummaryTitle => 'Your store earnings summary';

  @override
  String get sellerDashboardSummaryDesc =>
      'All figures below are calculated from the original prices you entered for products before adding the 5% app commission.';

  @override
  String get sellerDashboardTotalNetAllTimeLabel => 'Net earnings (all time)';

  @override
  String get sellerDashboardChangePeriodButton => 'Change period';

  @override
  String get sellerDashboardAllTimeButton => 'All time';

  @override
  String get sellerOrderTimelineCreated => 'Created';

  @override
  String get sellerOrderTimelinePrepared => 'Prepared';

  @override
  String get sellerOrderTimelineWithCourier => 'With courier';

  @override
  String get sellerOrderTimelineDelivered => 'Delivered';

  @override
  String get sellerOrderTimelineCancelled => 'Cancelled';

  @override
  String get sellerOrderDetailsTitle => 'Order details';

  @override
  String get sellerOrderDetailsOrderCodePrefix => 'Order code:';

  @override
  String get sellerOrderDetailsBuyerPrefix => 'Buyer:';

  @override
  String get sellerOrderDetailsCreatedAtPrefix => 'Created at:';

  @override
  String get sellerOrderDetailsCouponUsedPrefix => 'Coupon used:';

  @override
  String get sellerOrderDetailsBuyerNoteTitle => 'Buyer note:';

  @override
  String get sellerOrderDetailsFinancialSummaryTitle =>
      'Order financial summary';

  @override
  String get sellerOrderDetailsTotalItemsAllSellersLabel =>
      'Items total (all sellers)';

  @override
  String get sellerOrderDetailsShippingLabel => 'Shipping';

  @override
  String get sellerOrderDetailsTotalDiscountLabel => 'Total discount';

  @override
  String get sellerOrderDetailsGrandTotalLabel => 'Order grand total';

  @override
  String get sellerOrderDetailsSellerSectionTitle => 'Seller-specific summary';

  @override
  String get sellerOrderDetailsSellerItemsCountLabel => 'Your items count';

  @override
  String get sellerOrderDetailsSellerSubtotalLabel =>
      'Your items subtotal (before discount)';

  @override
  String get sellerOrderDetailsSellerDiscountShareLabel =>
      'Your share of discount';

  @override
  String get sellerOrderDetailsSellerNetLabel =>
      'Net value of your items in this order';

  @override
  String get sellerOrderDetailsCoordsPrefix => 'Coordinates:';

  @override
  String get sellerOrderDetailsItemsSectionTitle => 'Your order items';

  @override
  String get sellerOrderDetailsNoItemsForSellerMessage =>
      'There are no items assigned to you in this order.';

  @override
  String get sellerOrderDetailsUnitPricePrefix => 'Unit price:';

  @override
  String get sellerOrdersTitle => 'Customer orders';

  @override
  String get sellerOrdersNoOrdersMessage =>
      'There are no orders at the moment.';

  @override
  String get sellerOrdersUpdateStatusSuccessPrefix => 'Order status updated to';

  @override
  String get sellerOrdersUpdateStatusErrorPrefix => 'Failed to update status:';

  @override
  String get sellerOrdersNoAvailableStatusesMenuLabel =>
      'No available statuses';

  @override
  String get sellerOrdersStatusChangeNotAllowedTooltip =>
      'Status cannot be changed';

  @override
  String get sellerOrdersStatusChangeTooltip => 'Update order status';

  @override
  String get sellerOrdersSubtitleItemsPrefix => 'Items:';

  @override
  String get sellerOrdersSubtitleNetPrefix => '• Your net earnings from order:';

  @override
  String get sellerOrdersFilterByStatusLabel => 'Filter by status:';

  @override
  String get sellerOrdersFilterAllLabel => 'All';

  @override
  String get sellerOrdersFinalPricePrefix => 'Final price:';

  @override
  String get sellerProfileNewProductSheetTitle => 'Add new product';

  @override
  String get sellerProfileNewProductTitleLabel =>
      'Product name (example: Front headlight)';

  @override
  String get sellerProfileNewProductPriceLabel => 'Price';

  @override
  String get sellerProfileNewProductDescLabel =>
      'Description (example: Fits 2023–2025 same shape)';

  @override
  String get sellerProfileNewProductBrandLabel => 'Brand';

  @override
  String get sellerProfileNewProductModelLabel => 'Model';

  @override
  String get sellerProfileNewProductYearsLabel => 'Compatible years';

  @override
  String get sellerProfileNewProductStockLabel => 'Available stock';

  @override
  String get sellerProfileNewProductImageLabel => 'Image URL (optional)';

  @override
  String get sellerProfileNewProductImageHint => 'https://...';

  @override
  String get sellerProfileFieldRequiredError => 'Required';

  @override
  String get sellerProfileNewProductPriceInvalidError => 'Invalid price';

  @override
  String get sellerProfileNewProductStockInvalidError => 'Invalid value';

  @override
  String get sellerProfileNewProductSelectYearSnack =>
      'Please select at least one year';

  @override
  String get sellerProfileNewProductSubmittedSnack =>
      'Product submitted for review';

  @override
  String get sellerProfileNewProductSaveErrorPrefix =>
      'Error while saving product:';

  @override
  String get sellerProfileNewProductSubmitButton => 'Submit for review';

  @override
  String get sellerProfileNewProductInfoTitle => 'Important note:';

  @override
  String sellerProfileNewProductInfoBody(String percent) {
    return 'The price you enter here is the seller price before the app commission.\nAn app commission of $percent% will be added automatically when the product is shown to the buyer and in the cart.';
  }

  @override
  String get sellerProfileNoProductsInTabMessage =>
      'There are no products in this tab yet.';

  @override
  String get sellerProfileProductBrandPrefix => 'Brand:';

  @override
  String get sellerProfileProductModelPrefix => 'Model:';

  @override
  String get sellerProfileProductPricePrefix => 'Price:';

  @override
  String get sellerProfileProductStockPrefix => 'Stock:';

  @override
  String get sellerProfileProductStatusApprovedLabel => 'Approved';

  @override
  String get sellerProfileProductStatusPendingLabel => 'Pending';

  @override
  String get sellerProfileProductStatusRejectedLabel => 'Rejected';

  @override
  String get sellerProfileAddProductButton => 'Add product';

  @override
  String get sellerProfileTabPending => 'Pending';

  @override
  String get sellerProfileTabApproved => 'Approved';

  @override
  String get sellerProfileTabRejected => 'Rejected';

  @override
  String get sellerProfileErrorLoadingProducts =>
      'An error occurred while loading products.';

  @override
  String get sellerProfileDashboardButtonLabel => 'Dashboard & earnings';

  @override
  String get sellerProfileOrdersButtonLabel => 'Customer orders';

  @override
  String get sellerProfileInventoryButtonLabel => 'Inventory management';

  @override
  String get sellerProfileCouponsButtonLabel => 'Discount coupons';

  @override
  String get sellerProfileInventoryScreenTitle => 'Inventory management';

  @override
  String get sellerProfileRejectedEmptyMessage =>
      'There are no rejected products at the moment.';

  @override
  String get sellerProfileRejectedPricePrefix => 'Price:';

  @override
  String get sellerProfileRejectedReasonUnknown =>
      'Rejection reason not specified';

  @override
  String get sellerProfileRejectedReasonPrefix => 'Rejection reason:';

  @override
  String get towCompaniesAppBarTitle => 'Nearby tow companies';

  @override
  String get towCompaniesEmptyMessage =>
      'There are no tow companies available at the moment.';

  @override
  String get towCompaniesStatusAvailable => 'Available';

  @override
  String get towCompaniesStatusUnavailable => 'Unavailable';

  @override
  String get towCompaniesDistancePrefix => 'Approximate distance:';

  @override
  String get towCompaniesKmSuffix => 'km';

  @override
  String get towCompaniesBaseCostPrefix => 'Base service price:';

  @override
  String get towCompaniesPricePerKmPrefix => 'Price per km:';

  @override
  String get towCompaniesCoordsPrefix => 'Location (lat, lng):';

  @override
  String get towLocationPickerAppBarTitle => 'Pick location';

  @override
  String get towLocationPickerUseMyLocationButton => 'Use my location';

  @override
  String get towLocationPickerChooseFromMapButton => 'Choose from map';

  @override
  String get towLocationPickerLatitudeLabel => 'Latitude';

  @override
  String get towLocationPickerLongitudeLabel => 'Longitude';

  @override
  String get towLocationPickerSaveButton => 'Save';

  @override
  String get towLocationPickerHintText =>
      'Use your current location or open the map to pick a point.';

  @override
  String get towLocationPickerServiceDisabledSnack =>
      'Enable location services first';

  @override
  String get towLocationPickerPermissionDeniedSnack =>
      'Location permission denied';

  @override
  String get towLocationPickerPermissionDeniedForeverSnack =>
      'Location permission is permanently denied';

  @override
  String get towLocationPickerInvalidCoordsSnack => 'Enter valid coordinates';

  @override
  String get towMapPickerAppBarTitle => 'Choose from map';

  @override
  String get towMapPickerDoneActionLabel => 'Done';

  @override
  String get towMapPickerDoneButtonLabel => 'Use this point';

  @override
  String get towMapOpenErrorSnack => 'Could not open the map';

  @override
  String get towOperatorAppBarTitle => 'Tow panel';

  @override
  String towOperatorAppBarTitleWithName(String companyName) {
    return '$companyName panel';
  }

  @override
  String get towOperatorCompanyNotFoundMessage =>
      'Could not find the tow company linked to this account.\nIt may have been deleted or not configured correctly.';

  @override
  String get towOperatorToggleOnlineTooltipOn => 'Stop receiving requests';

  @override
  String get towOperatorToggleOnlineTooltipOff => 'Start receiving requests';

  @override
  String get towOperatorTabActive => 'Active';

  @override
  String get towOperatorTabHistory => 'History';

  @override
  String get towOperatorCoordsPrefix => 'Coordinates:';

  @override
  String get towOperatorStatusOnlineLabel => 'Online • receiving requests';

  @override
  String get towOperatorStatusOfflineLabel => 'Offline';

  @override
  String get towOperatorOnlineSwitchTitle => 'Available now (online)';

  @override
  String get towOperatorOnlineSwitchSubtitle =>
      'Customers can see your company and book';

  @override
  String get towOperatorOfflineWarning =>
      'You are currently offline. Turn online to appear for nearby customers.';

  @override
  String get towOperatorNoRequestsYet => 'There are no requests yet.';

  @override
  String get towOperatorActiveEmpty =>
      'There are no active requests at the moment.';

  @override
  String get towOperatorHistoryEmpty => 'There are no completed requests yet.';

  @override
  String get towOperatorToggleButtonToOffline => 'Set as unavailable';

  @override
  String get towOperatorToggleButtonToOnline => 'Set as available';

  @override
  String get towOperatorRequestVehicleFallback => 'Vehicle (no description)';

  @override
  String get towOperatorRequestStatusNewSuffix => ' • New';

  @override
  String get towOperatorRequestFromPrefix => 'From:';

  @override
  String get towOperatorRequestToPrefix => 'To:';

  @override
  String get towOperatorRequestToUnknown => 'Not specified';

  @override
  String get towOperatorRequestTotalPrefix => 'Total service cost:';

  @override
  String get towOperatorRequestPhonePrefix => 'Phone:';

  @override
  String get towOperatorRequestClientLocationButton => 'Client location';

  @override
  String get towOperatorRequestDestinationLocationButton => 'Drop-off location';

  @override
  String get towOperatorMenuAccept => 'Accept request';

  @override
  String get towOperatorMenuOnWay => 'On the way';

  @override
  String get towOperatorMenuDone => 'Service completed';

  @override
  String get towOperatorMenuCancel => 'Cancel';

  @override
  String get towUnitKm => 'km';

  @override
  String get currencyEgpShort => 'EGP';

  @override
  String get towScreenTitle => 'Emergency tow service';

  @override
  String get towScreenGpsEnableSnack =>
      'Please enable location (GPS) from settings';

  @override
  String get towScreenLocationPermissionDeniedSnack =>
      'Location permission denied';

  @override
  String get towScreenLocationFetchErrorSnack => 'Failed to get location:';

  @override
  String get towScreenLocationNotSetSnack =>
      'Your location has not been set yet';

  @override
  String get towScreenSelectCompanySnack => 'Please choose a tow company';

  @override
  String get towScreenLoginRequiredSnack =>
      'You must be logged in before requesting a tow';

  @override
  String get towScreenActiveTowExistsTitle => 'Active tow request';

  @override
  String get towScreenActiveTowExistsBody =>
      'You already have an active tow request.\nYou cannot create a new request before finishing or cancelling the current one from your account page (Tow requests section).';

  @override
  String get towScreenConfirmDialogTitle => 'Confirm request';

  @override
  String get towScreenConfirmCompanyLabel => 'Company:';

  @override
  String get towScreenConfirmMyLocationLabel => 'My location:';

  @override
  String get towScreenConfirmDestinationLabel => 'Destination:';

  @override
  String get towScreenConfirmBaseCostLabel => 'Base cost:';

  @override
  String get towScreenConfirmKmTotalLabel => 'Total distance:';

  @override
  String get towScreenConfirmKmPriceLabel => 'Price per km:';

  @override
  String get towScreenConfirmKmCostLabel => 'Distance cost:';

  @override
  String get towScreenConfirmTotalLabel => 'Total service cost:';

  @override
  String get towScreenConfirmVehicleLabel => 'Vehicle:';

  @override
  String get towScreenConfirmPlateLabel => 'Plate:';

  @override
  String get towScreenConfirmProblemLabel => 'Description:';

  @override
  String get towScreenConfirmPhoneLabel => 'Phone:';

  @override
  String get towScreenDialogCancelButton => 'Cancel';

  @override
  String get towScreenDialogConfirmButton => 'Confirm';

  @override
  String get towScreenRequestSentTitle => 'Tow request sent';

  @override
  String get towScreenRequestSentBodyPrefix => 'Your request has been sent to:';

  @override
  String get towScreenCompanyPhoneLabel => 'Company phone number:';

  @override
  String get towScreenCallCompanyButton => 'Call company';

  @override
  String get towScreenCallErrorSnack => 'Could not open dialer';

  @override
  String get towScreenNoCompanyPhoneHint =>
      'No phone number is registered for this company. Please contact them later through the app.';

  @override
  String get towScreenCloseButton => 'Close';

  @override
  String get towScreenSendErrorSnack => 'Failed to send request:';

  @override
  String get towScreenStepsStep1 => 'Set location';

  @override
  String get towScreenStepsStep2 => 'Choose company';

  @override
  String get towScreenStepsStep3 => 'Vehicle details';

  @override
  String get towScreenStepsStep4 => 'Confirm request';

  @override
  String get towScreenLocationPendingWarning =>
      'Your location is not set yet, use \"Use my location\" or pick from the map.';

  @override
  String get towScreenLocationReadyMessage =>
      'Your location has been set successfully.';

  @override
  String get towScreenCurrentLocationSectionTitle => 'My current location';

  @override
  String get towScreenCurrentCoordsLabel => 'Current coordinates';

  @override
  String get towScreenUseMyLocationButton => 'Use my location';

  @override
  String get towScreenPickFromMapButton => 'Choose from map';

  @override
  String get towScreenSelectedCompanyPrefix => 'Selected company:';

  @override
  String get towScreenSelectedCompanyDistancePrefix => 'Distance to company:';

  @override
  String get towScreenSelectedCompanyBaseCostPrefix => 'Base service:';

  @override
  String get towScreenSelectedCompanyKmPricePrefix => 'Price per km:';

  @override
  String get towScreenSelectedCompanyChangeButton => 'Change';

  @override
  String get towScreenSelectedCompanyHintNoLocation =>
      'After setting your location, we will suggest the nearest tow company automatically.';

  @override
  String get towScreenSelectedCompanyHintChoose =>
      'Choose the tow company that suits you from the list.';

  @override
  String get towScreenSelectedCompanyShowCompaniesButton => 'Show companies';

  @override
  String get towScreenDestinationSectionTitle => 'Destination';

  @override
  String get towScreenDestinationAddressLabel => 'Address (optional)';

  @override
  String get towScreenDestinationAddressHint =>
      'Enter the address or pick it from the map';

  @override
  String get towScreenDestinationMapButton => 'Map';

  @override
  String get towScreenDestinationOptionalHint =>
      'You can leave the destination empty and coordinate directly with the driver by phone.';

  @override
  String get towScreenCostsSectionTitle => 'Service costs';

  @override
  String get towScreenCostsBaseLabel => 'Base cost';

  @override
  String get towScreenCostsKmTotalLabel =>
      'Total distance (to company + to destination)';

  @override
  String get towScreenCostsKmPriceLabel => 'Price per km';

  @override
  String get towScreenCostsKmCostLabel => 'Distance cost';

  @override
  String get towScreenCostsTotalLabel => 'Total service cost';

  @override
  String get towScreenVehicleSectionTitle => 'Vehicle information';

  @override
  String get towScreenVehicleTypeLabel => 'Make and model';

  @override
  String get towScreenVehicleTypeHint => 'Example: Honda Civic';

  @override
  String get towScreenRequiredFieldError => 'This field is required';

  @override
  String get towScreenPlateLabel => 'License plate';

  @override
  String get towScreenPlateHint => 'Example: ABC-1234';

  @override
  String get towScreenProblemLabel => 'Problem description';

  @override
  String get towScreenProblemHint => 'Briefly describe the problem… (optional)';

  @override
  String get towScreenContactSectionTitle => 'Contact information';

  @override
  String get towScreenPhoneLabel => 'Phone number';

  @override
  String get towScreenPhoneHint => '+20 1xxxxxxxxx';

  @override
  String get towScreenPhoneInvalidError => 'Please enter a valid phone number';

  @override
  String get towScreenEtaTitle => 'Estimated arrival time';

  @override
  String get towScreenEtaValue => '15–25 minutes after request confirmation';

  @override
  String get towScreenSubmitButtonSending => 'Sending request...';

  @override
  String get towScreenSubmitButtonLabel => 'Send request';

  @override
  String get towScreenSubmitHint =>
      'Make sure your location is set and a tow company is selected before sending the request.';

  @override
  String get towScreenFloatingNearestCompanies => 'Nearest companies';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavCategories => 'Categories';

  @override
  String get bottomNavTow => 'Tow';

  @override
  String get bottomNavCart => 'Cart';

  @override
  String get bottomNavAccount => 'My account';

  @override
  String get currencyEgpPerKm => 'EGP/km';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get cartAppTitlePrefix => 'Shopping cart';

  @override
  String get cartAppTitleItemsSuffix => 'items';

  @override
  String get cartItemDeleteTooltip => 'Remove item';

  @override
  String get orderSummaryTitle => 'Order summary';

  @override
  String get orderSummarySubtotalPrefix => 'Items subtotal';

  @override
  String get orderSummaryItemsSuffix => 'items';

  @override
  String get orderSummaryShippingLabel => 'Shipping';

  @override
  String get orderSummaryDiscountLabel => 'Discount';

  @override
  String get orderSummaryGrandTotalLabel => 'Grand total';

  @override
  String get orderSummaryCouponSectionTitle => 'Coupon code (optional)';

  @override
  String get orderSummaryCouponFieldLabel => 'Enter coupon';

  @override
  String get orderSummaryCouponApplyButton => 'Apply';

  @override
  String get orderSummaryNoteFieldLabel => 'Order note (optional)';

  @override
  String get orderSummarySubmittingLabel => 'Creating order...';

  @override
  String get orderSummarySubmitButton => 'Place order';

  @override
  String get categoryTileItemCountPrefix => 'Products:';

  @override
  String get productCardAddToCartTooltip => 'Add to cart';

  @override
  String get authOrDividerLabel => 'or';

  @override
  String get adminTowRequestsErrorLoading =>
      'An error occurred while loading tow requests:';

  @override
  String get adminTowRequestsEmpty => 'There are no tow requests yet.';

  @override
  String get adminTowRequestsItemTitlePrefix => 'Request';

  @override
  String get adminTowRequestsCompanyPrefix => 'Company:';

  @override
  String get adminTowRequestsStatusPrefix => 'Status:';

  @override
  String get adminTowRequestsVehiclePlatePrefix => 'Vehicle / plate:';

  @override
  String get adminTowRequestsPhonePrefix => 'Phone:';

  @override
  String get adminTowRequestsTotalCostPrefix => 'Total service:';

  @override
  String get adminTowRequestsFromPrefix => 'From:';

  @override
  String get adminTowRequestsToPrefix => 'To:';

  @override
  String get adminTowRequestsProblemPrefix => 'Problem:';

  @override
  String get adminWinchAccountsErrorLoading => 'Error loading tow accounts:';

  @override
  String get adminWinchAccountsEmpty =>
      'No tow accounts have been registered yet.';

  @override
  String get adminWinchAccountsNoName => 'No name';

  @override
  String get adminWinchAccountsNoArea => 'No area';

  @override
  String get adminWinchAccountsOnlineLabel => 'Online';

  @override
  String get adminWinchAccountsOfflineLabel => 'Offline';

  @override
  String get adminWinchAccountsDeleteTitle => 'Delete tow account';

  @override
  String adminWinchAccountsDeleteMessage(String name) {
    return 'Are you sure you want to permanently delete account \"$name\"?';
  }

  @override
  String get adminWinchAccountsDeleteConfirm => 'Confirm delete';

  @override
  String get adminWinchAccountsDeleteMenu => 'Delete account';

  @override
  String adminWinchAccountsDeleteSuccess(String name) {
    return 'Account $name has been deleted';
  }

  @override
  String get adminWinchAccountsAreaPrefix => 'Area:';

  @override
  String get adminWinchAccountsBaseCostPrefix => 'Base service price:';

  @override
  String get adminWinchAccountsPricePerKmPrefix => 'Price per km:';

  @override
  String get adminWinchAccountsPhonePrefix => 'Phone:';

  @override
  String get adminOrdersErrorLoadingPrefix => 'Error loading orders:';

  @override
  String get adminOrdersRangePickerHelp => 'Select date range';

  @override
  String get adminOrdersRangePickerSave => 'Apply';

  @override
  String get adminOrdersSearchHint =>
      'Search: code / buyer / seller / product…';

  @override
  String get adminOrdersClearSearchTooltip => 'Clear';

  @override
  String get adminOrdersRangeAllLabel => 'Range: All';

  @override
  String get adminOrdersPaginationRemoveRangeTooltip => 'Clear range';

  @override
  String get adminOrdersPaginationNextTooltip => 'Next page';

  @override
  String get adminOrdersSortCreatedDesc => 'Newest first';

  @override
  String get adminOrdersSortCreatedAsc => 'Oldest first';

  @override
  String get adminOrdersSortTotalDesc => 'Amount: highest ↓';

  @override
  String get adminOrdersSortTotalAsc => 'Amount: lowest ↑';

  @override
  String get adminOrdersResetFiltersButton => 'Reset filters';

  @override
  String get adminOrdersMatchingCountPrefix => 'Matching orders:';

  @override
  String get adminOrdersNoMatchingMessage => 'No matching orders';

  @override
  String get adminOrdersBuyerPrefix => 'Buyer:';

  @override
  String get adminOrdersItemsCountPrefix => 'Items:';

  @override
  String get adminOrdersGrandTotalPrefix => 'Total:';

  @override
  String get adminOrdersGeoAddressPrefix => 'Geo address:';

  @override
  String get adminOrdersTotalFooterPrefix => 'Total:';

  @override
  String get adminOrdersPaginationFirstTooltip => 'First page';

  @override
  String get adminOrdersPaginationPrevTooltip => 'Previous page';

  @override
  String get adminOrdersPaginationLastTooltip => 'Last page';

  @override
  String get adminOrdersPageLabel => 'Page';

  @override
  String get sellerInventoryRestockDialogTitlePrefix => 'Restock';

  @override
  String get sellerInventoryRestockQuantityLabel => 'Quantity to add';

  @override
  String get sellerInventoryRestockQuantityInvalidError =>
      'Enter a valid number greater than zero';

  @override
  String get sellerInventoryRestockQuantityTooBigError => 'Value is too large';

  @override
  String get sellerInventoryRestockAddButton => 'Add';

  @override
  String get sellerInventoryRestockSuccessPrefix => 'Added';

  @override
  String get sellerInventoryRestockSuccessInfix => 'to the stock of';

  @override
  String get sellerInventoryRestockErrorPrefix => 'Failed to update stock:';

  @override
  String get sellerInventoryErrorLoading => 'Error loading products';

  @override
  String get sellerInventoryEmptyForSeller =>
      'No approved products for this seller yet';

  @override
  String get sellerInventoryTotalStockPrefix => 'Total stock:';

  @override
  String get sellerInventoryTotalSoldPrefix => 'Total sold:';

  @override
  String get sellerInventoryTotalRevenuePrefix => 'Total revenue:';

  @override
  String get sellerInventoryEditStockTooltip => 'Edit stock';

  @override
  String get sellerInventoryStockPrefix => 'Stock:';

  @override
  String get sellerInventorySoldPrefix => 'Sold:';

  @override
  String get sellerInventoryRevenuePrefix => 'Revenue:';

  @override
  String get sellerInventoryPricePrefix => 'Price:';

  @override
  String get sellerInventoryYearsPrefix => 'Fit years:';

  @override
  String get productReviewsTitle => 'Reviews';

  @override
  String get productReviewsProductTitle => 'Product reviews';

  @override
  String get productReviewsSellerTitle => 'Seller reviews';

  @override
  String get productReviewsNoProductReviewsMessage =>
      'No reviews for this product yet';

  @override
  String get productReviewsNoSellerReviewsMessage =>
      'No reviews for this seller yet';

  @override
  String get productReviewsBuyerPrefix => 'Buyer:';

  @override
  String catalogCanFulfillItemNotFound(String name) {
    return 'Item \"$name\" is not available in the catalog.';
  }

  @override
  String catalogCanFulfillInsufficientStock(String name, int stock) {
    return 'Current stock of \"$name\" is only $stock.';
  }

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusPrepared => 'Prepared';

  @override
  String get orderStatusHandedToCourier => 'Handed to courier';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get towStatusPending => 'Pending review';

  @override
  String get towStatusAccepted => 'Accepted';

  @override
  String get towStatusOnTheWay => 'On the way';

  @override
  String get towStatusCompleted => 'Service completed';

  @override
  String get towStatusCancelled => 'Cancelled';

  @override
  String get towStatusRejected => 'Rejected';

  @override
  String get adminWinchTabWinchTitlePrefix => 'Tow:';

  @override
  String get adminWinchTabStatusPrefix => 'Status:';

  @override
  String get adminWinchTabStatusApproved => 'Approved';

  @override
  String get adminWinchTabStatusPending => 'Pending review';

  @override
  String get adminWinchTabMaxWinchesPrefix => 'Allowed tow trucks:';

  @override
  String get adminWinchTabDocsTitle => 'Documents:';

  @override
  String get adminWinchTabMenuTooltip => 'Actions';

  @override
  String get adminWinchTabMenuApproveLabel => 'Approve & set capacity';

  @override
  String adminWinchTabApproveSuccess(int capacity) {
    return 'Tow account approved with capacity = $capacity';
  }

  @override
  String get adminWinchTabCapacityDialogTitle =>
      'Set number of tow trucks in service';

  @override
  String get adminWinchTabCapacityFieldLabel => 'Number of tow trucks';

  @override
  String get adminWinchTabDialogSave => 'Save';

  @override
  String get login_banned_message =>
      'Your account has been permanently banned.\nYou can no longer sign in with this email.\nPlease contact the administration.';

  @override
  String get login_frozen_message =>
      'Your account is temporarily suspended.\nPlease contact the administration for more details.';

  @override
  String get towScreenRoleNotAllowedTitle =>
      'Tow service is not available for this account';

  @override
  String get towScreenSellerNotAllowedBody =>
      'You are currently signed in as a seller, and seller accounts cannot request a tow truck.\nPlease switch to buyer mode to use this service.';

  @override
  String get towScreenAdminNotAllowedBody =>
      'Admin accounts cannot request tow trucks.\nPlease create or use a buyer account to use this service.';

  @override
  String get towScreenRoleNotAllowedGoProfileButton => 'Go to my profile';
}
