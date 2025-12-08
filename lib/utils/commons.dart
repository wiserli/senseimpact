class DatabaseTables {
  static const String userInfo = 'user_info_dev_safe_view';
  // static const String userInfoSafeView = 'user_info_dev_safe_view';

  /// Changed the table name to dev make it as it was before pushing to production
  static const String publicModels = 'public_model_safe_view';
  static const String privateModels = 'private_model_dev';
  static const String sharedModels = 'shared_model_dev';
  static const String guestUserInfo = 'guest_user_info_dev';
  static const String deletedModels = 'deleted_model_dev';
  static const String featureRequests = 'feature_request_form_dev';
  static const String benchmarkInfo = 'benchmark_info_dev';
  static const String benchmarkModels = 'benchmark_model_dev';
  static const String mobileModels = 'mobile_models_dev';
  static const String userJourney = 'user_journey_dev';
  static const String modelAnalytics = 'model_analytics_dev';
}

class StorageBuckets {
  static const String publicModels = 'public_model_dev';
  static const String privateModels = 'private_model_dev';
  static const String userAssets = 'user_assets_dev';
}

class LocalDatabaseTables {
  static const String localPrivateModels = 'localPrivateModels';
  static const String localSharedModels = 'localSharedModels';
  static const String localPublicModels = 'publicModels';
  static const String localNotifications = 'notifications';
}
