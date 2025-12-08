/* 
- onboarding_skip_click
- onboarding_done_click
- home_page
  - initial_model_download_click
  - intial_model_download_success
  - initial_model_download_failure
  - get_started_clicked
  - camera_switch_rear
  - camera_switch_front
  - camera_switch_ipcam
  - paramter_tunning_button
  - screenshot_click
  - screenshot_gallery
  - screenshot_share
  - dashboard_click
  - dashboard_bottom_sheet_view
  - dashboard_server_turn_on
  - dashboard_server_turn_off
- image_detection_page
  - paramter_tunning_button
  - image_upload_click
  - image_upload_success
  - image_upload_failure
- models_page`
  - public_model_tab
  - private_model_tab
  - shared_model_tab
  - download_model_click
  - deploy_model_click
  - share_model_click
  - delete_model_click
  - delete_model_device_click
  - upload_model
  - model_info_pageview
    - request_to_public_model_click
  - share/unshare_click
  - signup_clicked
  - signin_clicked
  - guest_signin_clicked
  - shared_model_accept_click
  - shared_model_reject_click
- profile_page
  - about_yolovx_click
  - help_discuss_click
  - notifications_click
  - accounts_setting_click
  - request_feature_click
  - share_ur_feedback_click
  - get_api_key_click
  - delete_account_click
  - logout_click
- about_yolovx_pageview
  - websitle_link_click
  - linkedin_link_click
  - community_link_clicked
  - terms_condition_clicked
- notifications_pageview
- accounts_settings_pageview
  - image_updated
  - account_details_updated
- request_feature_pageview
  - request_feature_submit_click
- share_ur_feeedback_pageview
  - feeback_submit_click
- get_api_key_pageview
  - api_key_copy_click
- delete_account_model
  - delete_account_button_click
  - delete_account_cancel_click
- logout_model
  - logout_button_click
  - logout_cancel_click
- sign_up_pageview
  - verification_clicked
  - create_account_button_clicked
  - create_account_fail
  - create_account_success
- sign_in_pageview
  - forgot_password_click
    - forgot_password_modal
      - forgot_password_sumit_button_click
      - forgot_password_cancel_click
  - signin_success
  - signin_failure
- verification_pageview
  - verify_passcode_click
  - resend_passcode_click
    - resend_passcode_model
    - resend_passcode_button_click
  - verify_passcode_success
  - verify_passcode_failure
  - signup_button_click
  - signup_successful
  - signup_failure
- guest_signin_pageview
  - guest_sinin_success
  - guest_signin_failure
- upgrade_account_button_click
 */

class UserEvents {
  static const String appOpened = 'app_opened';

  static const String onboardingSkipClick = 'onboarding_skip_click';

  ///OK
  static const String onboardingDoneClick = 'onboarding_done_click';

  ///OK

  // Home Page Events
  static const String homePageView = 'home_page';

  ///OK
  static const String ipCamPageView = 'ipcam_page';
  static const String initialModelDownloadClick =
      'initial_model_download_click';

  ///OK9 ||
  static const String initialModelDownloadSuccess =
      'intial_model_download_success';

  ///OK |
  static const String initialModelDeploy = 'intial_model_deploy';

  ///OK |
  static const String initialModelDownloadFailure =
      'initial_model_download_failure';

  ///OK |
  static const String errorInInsertingPublicModel =
      'error_in_inserting_public_model';
  static const String getStartedClicked = 'get_started_clicked';

  ///OK |
  static const String cameraSwitchRear = 'camera_switch_rear';
  static const String cameraSwitchFront = 'camera_switch_front';
  static const String cameraSwitchIpCam = 'camera_switch_ipcam';
  static const String dashboardClick = 'dashboard_click';
  static const String dashboardBottomSheetView = 'dashboard_bottom_sheet_view';
  static const String dashboardServerTurnOn = 'dashboard_server_turn_on';
  static const String dashboardServerTurnOff = 'dashboard_server_turn_off';
  static const String urlCopyClick = 'url_copy_click';
  static const String parameterTuningButton = 'paramter_tunning_button';
  static const String objectTrackingTurnOn = 'object_tracking_turn_on';
  static const String objectTrackingTurnOff = 'object_tracking_turn_off';
  static const String resetTrackerClicked = 'reset_tracker_clicked';
  static const String trackingAlgorithmChanged = 'tracking_algorithm_changed';
  static const String objectCountingTurnOn = 'object_counting_turn_on';
  static const String objectCountingTurnOff = 'object_counting_turn_off';
  static const String resetCounterClicked = 'reset_counter_clicked';
  static const String counterLabelChanged = 'counter_label_changed';

  ///OK |
  static const String screenshotClick = 'screenshot_click';

  ///OK |
  static const String screenshotGallery = 'screenshot_gallery';

  ///OK |
  static const String screenshotShare = 'screenshot_share';

  ///OK

  // Image Detection Page Events
  static const String imageDetectionPageView = 'image_detection_page'; //R
  static const String imageUploadClick = 'image_upload_click';

  ///OK |
  static const String imageUploadSuccess = 'image_upload_success';

  ///OK |
  static const String imageUploadFailure = 'image_upload_failure';

  ///OK |

  // Models Page Events
  static const String modelsPageView = 'models_page';
  static const String publicModelTab = 'public_model_tab';
  static const String privateModelTab = 'private_model_tab';
  static const String sharedModelTab = 'shared_model_tab';
  static const String downloadModelClick = 'download_model_click';
  static const String deployModelClick = 'deploy_model_click';
  static const String shareModelClick = 'share_model_click';
  static const String deleteModelClick = 'delete_model_click';
  static const String deleteModelDeviceClick = 'delete_model_device_click';

  ///OK |
  static const String uploadModel = 'upload_model';
  static const String addModelClick = 'add_model_click';
  static const String modelUploadPageView = 'model_upload_pageview'; //R
  static const String serverDown = 'server_down';
  static const String modelInfoPageView = 'model_info_pageview'; //R
  static const String requestToPublicModelClick =
      'request_to_public_model_click';
  static const String shareUnshareClick = 'share/unshare_click';
  static const String signupClicked = 'signup_clicked';
  static const String signinClicked = 'signin_clicked';
  static const String guestSigninClicked = 'guest_signin_clicked';
  static const String sharedModelAcceptClick = 'shared_model_accept_click';
  static const String sharedModelRejectClick = 'shared_model_reject_click';
  static const String uploadModelFailureInfoClick =
      'upload_model_failure_info_click';
  static const String contactUsClick = 'contact_us_click';

  // Profile Page Events
  static const String profilePageView = 'profile_page'; //R
  static const String aboutYolovxClick = 'about_yolovx_click';
  static const String helpDiscussClick = 'help_discuss_click';
  static const String notificationsClick = 'notifications_click';
  static const String accountsSettingClick = 'accounts_setting_click';
  static const String requestFeatureClick = 'request_feature_click';
  static const String shareYourFeedbackClick = 'share_ur_feedback_click';
  static const String getApiKeyClick = 'get_api_key_click';
  static const String deleteAccountClick = 'delete_account_click';
  static const String logoutClick = 'logout_click';
  static const String whatsNewClicked = 'whats_new_click';
  static const String ipcameraSettingsClicked = 'ip_camera_settings_click';
  static const String aiBenchmarkingClick = 'ai_benchmarking_click';
  static const String manageTeamClicked = 'manage_team_clicked';

  // Other Page Views
  static const String aboutYolovxPageView = 'about_yolovx_pageview'; //R
  static const String websiteLinkClick = 'websitle_link_click';
  static const String linkedinLinkClick = 'linkedin_link_click';
  static const String communityLinkClicked = 'community_link_clicked';
  static const String termsConditionClicked = 'terms_condition_clicked';
  static const String aiBenchmarkingPageView = 'ai_benchmarking_pageview';
  static const String notificationsPageView = 'notifications_pageview'; //R
  static const String accountsSettingsPageView =
      'accounts_settings_pageview'; //R
  static const String imageUpdated = 'image_updated';
  static const String accountDetailsUpdated = 'account_details_updated';
  static const String whatsNewPageView = 'whats_new_pageview'; //R
  static const String ipcameraSettingsPageView =
      'ip_camera_settings_pageview'; //R
  static const String screenshotGalleryPageView = 'screenshot_pageview'; //R
  static const String screenshotDisplayPageView =
      'screenshot_display_pageview'; //R

  // IP Camera Settings Event
  static const String addIPCameraButtonClicked = 'add_ip_camera_button_clicked';
  static const String addCameraButtonClicked = 'add_camera_button_clicked';
  static const String linkNotWorkingStillAddYesClicked =
      'link_not_working_still_add_yes_clicked';
  static const String linkNotWorkingStillAddNoClicked =
      'link_not_working_still_add_no_clicked';
  static const String editCameraButtonClicked = 'edit_camera_button_clicked';
  static const String updateCameraButtonClicked =
      'update_camera_button_clicked';
  static const String deleteCameraButtonClicked =
      'delete_camera_button_clicked';

  // Request Feature Events
  static const String requestFeaturePageView = 'request_feature_pageview'; //R
  static const String requestFeatureSubmitClick =
      'request_feature_submit_click';

  static const String shareYourFeedbackPageView =
      'share_ur_feeedback_pageview'; //R
  static const String feedbackSubmitClick = 'feeback_submit_click';

  // API Key Events
  static const String getApiKeyPageView = 'get_api_key_pageview'; //R
  static const String apiKeyCopyClick = 'api_key_copy_click';

  // Delete Account Events
  static const String deleteAccountModel = 'delete_account_model';
  static const String deleteAccountButtonClick = 'delete_account_button_click';
  static const String deleteAccountCancelClick = 'delete_account_cancel_click';

  // Logout Events
  static const String logoutModel = 'logout_model';
  static const String logoutButtonClick = 'logout_button_click';
  static const String logoutCancelClick = 'logout_cancel_click';

  // Sign Up Events
  static const String signUpPageView = 'sign_up_pageview'; //R
  static const String verificationClicked = 'verification_clicked';
  static const String createAccountButtonClicked =
      'create_account_button_clicked';
  static const String createAccountFail = 'create_account_fail';
  static const String createAccountSuccess = 'create_account_success';

  // Sign In Events
  static const String signInPageView = 'sign_in_pageview'; //R
  static const String forgotPasswordClick = 'forgot_password_click';
  static const String forgotPasswordModal = 'forgot_password_modal';
  static const String forgotPasswordSubmitButtonClick =
      'forgot_password_sumit_button_click';
  static const String forgotPasswordCancelClick =
      'forgot_password_cancel_click';
  static const String signinSuccess = 'signin_success';
  static const String signinFailure = 'signin_failure';

  // Verification Events
  static const String verificationPageView = 'verification_pageview'; //R
  static const String verifyPasscodeClick = 'verify_passcode_click';
  static const String resendPasscodeClick = 'resend_passcode_click';
  static const String resendPasscodeModel = 'resend_passcode_model';
  static const String resendPasscodeButtonClick =
      'resend_passcode_button_click';
  static const String verifyPasscodeSuccess = 'verify_passcode_success';
  static const String verifyPasscodeFailure = 'verify_passcode_failure';

  // Create Password Events
  static const String signupButtonClick = 'signup_button_click';
  static const String signupSuccessful = 'signup_successful';
  static const String signupFailure = 'signup_failure';

  // Guest Sign-in Events
  static const String guestSigninPageView = 'guest_signin_pageview'; //R
  static const String guestSigninSuccess = 'guest_signin_success';
  static const String guestSigninFailure = 'guest_signin_failure';

  // Upgrade Account Event
  static const String upgradeAccountButtonClick =
      'upgrade_account_button_click';

  // Upgrade Subscription Event //not in use for now
  static const String upgradeSubscriptionButtonClick =
      'upgrade_subscription_button_click';

  // No internet Connection Page Event
  static const String noInternetPageView = 'no_internet_pageview'; //R
  static const String noInternetRetryButtonClicked =
      'no_internet_retry_button_clicked';
  static const String noInternetContinueButtonClicked =
      'no_internet_continue_button_clicked';
}
