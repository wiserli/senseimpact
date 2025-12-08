import 'dart:convert';

import 'constants.dart' as RemoteConfigKeys;
import 'constants.dart' as RemoteConfigKeys;

/// [YOLOV8]
Map<String, dynamic> defaultModelConfig = {};

// Use the defaultModelConfig map first, then fall back to direct remote config calls if needed
final initialModelId = 1;

final initialModelName = "YOLOv9-tiny";

final initialModelCreatedAt = "2024-04-03T08:41:49.132Z";

final initialModelSize = 8.2;

final initialNumOfClasses = 80;

final initialModelType = "Object Detection";

final initialClasses = jsonEncode([
  "person",
  "bicycle",
  "car",
  "motorcycle",
  "airplane",
  "bus",
  "train",
  "truck",
  "boat",
  "traffic light",
  "fire hydrant",
  "stop sign",
  "parking meter",
  "bench",
  "bird",
  "cat",
  "dog",
  "horse",
  "sheep",
  "cow",
  "elephant",
  "bear",
  "zebra",
  "giraffe",
  "backpack",
  "umbrella",
  "handbag",
  "tie",
  "suitcase",
  "frisbee",
  "skis",
  "snowboard",
  "sports ball",
  "kite",
]);

final initialModelCreatedBy = "National Taipei University";

final initialModelLogoLink =
    "/storage/v1/object/public/public-models/Yolov9/Others/ntut_logo.png";

final initialTfliteModelFileName = "yolov9t_int8.tflite";

final initialTfliteModelFileLink =
    "/storage/v1/object/public/public_model_dev/Yolov9/Android/320/yolov9t_int8.tflite";

final initialMetadataFileName = "metadata.yaml";

final initialMetadataFileLink =
    "/storage/v1/object/public/public_model_dev/Yolov9/Android/320/metadata.yaml";

final initialMLModelModelFileName = "yolov9t.mlmodel";

final initialMLModelFileLink =
    "/storage/v1/object/public/public-models/Yolov9/IOS/yolov9t.mlmodel";

final initialLicense = "Apache-2.0";

final initialDefParams =
    "{iou: 0.5, cam_lens: 1, num_detect: 10, conf_thresh: 0.25, show_conf: false}";

final initialInputSize = 320;

final initialEncryptionSecretKey =
    '${const String.fromEnvironment('public_encryption_secret_key')}${const String.fromEnvironment('private_encryption_secret_key')}$initialModelName';

const Map<String, String> cocoTestImages = {
  "img1.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img1.jpg",
  "img2.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img2.jpg",
  "img3.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img3.jpg",
  "img4.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img4.jpg",
  "img5.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img5.jpg",
  "img6.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img6.jpg",
  "img7.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img7.jpg",
  "img8.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img8.jpg",
  "img9.jpg": "/storage/v1/object/public/app_assets/benchmark/coco16/img9.jpg",
  "img10.jpg":
      "/storage/v1/object/public/app_assets/benchmark/coco16/img10.jpg",
  "img11.jpg":
      "/storage/v1/object/public/app_assets/benchmark/coco16/img11.jpg",
};

/// [Chosen Model]
// String chosenModelName = "";
// String chosenTfliteModelFileName = "";
// String chosenTfliteModelFileLink = "";
// String chosenMetadataFileName = "";
// String chosenMetadataFileLink = "";
// String chosenMLModelModelFileName = "";
// String chosenMLModelFileLink = "";

/// [Chosen Model]
//chosenTfliteModelFileName = "yolov8n_int8_640.tflite";
//chosenTfliteModelFileLink = "/storage/v1/object/public/public-models/Test2/yolov8n_int8_640.tflite?t=2024-04-03T08%3A05%3A10.593Z";
//chosenMetadataFileName = "metadata.yaml";
//chosenMetadataFileLink = "/storage/v1/object/public/public-models/Test2/metadata.yaml?t=2024-04-03T08%3A06%3A00.466Z";
//chosenMLModelModelFileName = "yolov8n_1.mlmodel";
//chosenMLModelFileLink = "/storage/v1/object/public/public-models/Test/yolov8n_1.mlmodel?t=2024-04-03T08%3A41%3A49.132Z";

/// [YOLOV8_640]
// const initialTfliteModelFileName = "yolov8n_int8_640.tflite";
// const initialTfliteModelFileLink = "/storage/v1/object/public/public-models/Test2/yolov8n_int8_640.tflite?t=2024-04-03T08%3A05%3A10.593Z";
// const initialMetadataFileName = "metadata.yaml";
// const initialMetadataFileLink = "/storage/v1/object/public/public-models/Test2/metadata.yaml?t=2024-04-03T08%3A06%3A00.466Z";
// const initialMLModelModelFileName = "yolov8n_1.mlmodel";
// const initialMLModelFileLink = "/storage/v1/object/public/public-models/Test/yolov8n_1.mlmodel?t=2024-04-03T08%3A41%3A49.132Z";
// const initialInputSize = 640;

/// [YOLOV7_320]
// const initialTfliteModelFileName = "yolov7-tiny_int8.tflite";
// const initialTfliteModelFileLink = "/storage/v1/object/public/public-models/Yolov7/Android/yolov7-tiny_int8.tflite?t=2024-04-03T08%3A53%3A27.525Z";
// const initialMetadataFileName = "metadata.yaml";
// const initialMetadataFileLink = "/storage/v1/object/public/public-models/Yolov7/Android/metadata.yaml?t=2024-04-03T08%3A55%3A23.790Z";
// const initialMLModelModelFileName = "yolov8n_1.mlmodel";
// const initialMLModelFileLink = "/storage/v1/object/public/public-models/Test/yolov8n_1.mlmodel?t=2024-04-03T08%3A41%3A49.132Z";
// const initialInputSize = 320;

/// [YOLOV7]
// const initialTfliteModelFileName = "coco128.tflite";
// const initialTfliteModelFileLink = "/storage/v1/object/public/public-models/Yolov7/Android/coco128.tflite?t=2024-04-04T11%3A29%3A12.187Z";
// const initialMetadataFileName = "metadata.yaml";
// const initialMetadataFileLink = "/storage/v1/object/public/public-models/Yolov7/Android/metadata.yaml?t=2024-04-03T08%3A55%3A23.790Z";
// const initialMLModelModelFileName = "yolov8n_1.mlmodel";
// const initialMLModelFileLink = "/storage/v1/object/public/public-models/Test/yolov8n_1.mlmodel?t=2024-04-03T08%3A41%3A49.132Z";
// const initialInputSize = 320;
