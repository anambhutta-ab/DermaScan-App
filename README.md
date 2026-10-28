# 🩺 DermaScan

<div align="center">

# AI-Powered Skin Disease Detection using Deep Learning

*A Flutter-based mobile application for intelligent skin disease screening using state-of-the-art Convolutional Neural Networks.*

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![TensorFlow](https://img.shields.io/badge/TensorFlow-2.x-orange?logo=tensorflow)
![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)

</div>

---

# 📖 Table of Contents

- [Overview](#overview)
- [Motivation](#motivation)
- [Key Features](#key-features)
- [Supported Diseases](#supported-diseases)
- [System Architecture](#system-architecture)
- [Application Workflow](#application-workflow)
- [Deep Learning Pipeline](#deep-learning-pipeline)
- [Model Architectures](#model-architectures)
- [Dataset](#dataset)
- [Image Preprocessing](#image-preprocessing)
- [Data Augmentation](#data-augmentation)
- [Training Strategy](#training-strategy)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Model Performance](#model-performance)
- [Future Improvements](#future-improvements)
- [Disclaimer](#disclaimer)

---

# Overview

Skin diseases affect millions of people worldwide, yet early diagnosis often remains inaccessible due to limited dermatological resources. **DermaScan** addresses this challenge by leveraging **Artificial Intelligence** and **Deep Learning** to assist users in identifying common skin diseases using images captured from a smartphone.

Unlike traditional multiclass classification systems, DermaScan employs **eight independent binary classification models**, each trained specifically to detect a single skin disease. This specialized approach improves classification accuracy while reducing confusion between visually similar diseases.

The application is developed using **Flutter**, enabling a modern cross-platform user experience, while **TensorFlow Lite** performs efficient on-device inference for real-time predictions without requiring an internet connection.

---

# Motivation

Early detection of skin diseases can significantly improve treatment outcomes and reduce healthcare costs. However, access to dermatologists may be limited due to geographical, financial, or infrastructural constraints.

DermaScan aims to bridge this gap by providing an accessible AI-assisted screening tool that allows users to:

- Perform preliminary skin disease screening.
- Receive instant AI-based predictions.
- Monitor previous prediction history.
- Encourage timely consultation with healthcare professionals.

The application is intended as a **clinical decision support system** rather than a replacement for professional medical diagnosis.

---

# Key Features

## AI-Based Disease Detection

- Deep learning powered diagnosis
- Real-time prediction
- TensorFlow Lite inference

## Image Acquisition

- Capture images using the device camera
- Upload existing images from gallery
- Automatic image preprocessing

## Intelligent Prediction

- Confidence score
- Binary disease classification
- Fast inference
- Optimized mobile deployment

## User Experience

- Modern Flutter interface
- Responsive design
- User profile management
- Prediction history
- Local storage using Hive

---

# Supported Diseases

DermaScan currently supports the following skin diseases.

| Disease | Deep Learning Model |
|----------|---------------------|
| Acne | ResNet50 |
| Actinic Keratosis | ResNet50 |
| Psoriasis | ResNet50 |
| Ringworm | ResNet50 |
| Warts | ResNet50 |
| Eczema | EfficientNetB2 |
| Melanoma | EfficientNetB3 |
| Basal Cell Carcinoma (BCC) | EfficientNetB3 |

Each disease is detected using an independently trained binary classification model, allowing the network to focus on disease-specific feature extraction and reducing inter-class confusion.

---

# System Architecture

```text
                        User
                          │
                          ▼
                Flutter Mobile Application
                          │
          ┌───────────────┴───────────────┐
          │                               │
      Camera Capture                 Gallery Upload
          │                               │
          └───────────────┬───────────────┘
                          ▼
                 Image Preprocessing
                          │
                          ▼
               Disease Selection Screen
                          │
                          ▼
            Corresponding TensorFlow Lite Model
                          │
                          ▼
               Binary Classification Model
                          │
                          ▼
               Prediction & Confidence Score
                          │
                          ▼
                Store Results using Hive
                          │
                          ▼
                   Display Prediction
```

---

# Application Workflow

The complete workflow of DermaScan is illustrated below:

1. User opens the application.
2. Selects a target skin disease.
3. Captures an image or uploads one from the gallery.
4. Image is resized and normalized.
5. The selected TensorFlow Lite model performs inference.
6. Confidence score is calculated.
7. Prediction result is displayed.
8. Prediction history is saved locally using Hive Database.

---

# Deep Learning Pipeline

```
Dataset Collection
        │
        ▼
Data Cleaning
        │
        ▼
Image Preprocessing
        │
        ▼
Data Augmentation
        │
        ▼
Train / Validation / Test Split
        │
        ▼
Transfer Learning
        │
        ▼
Fine-Tuning
        │
        ▼
Model Evaluation
        │
        ▼
TensorFlow Lite Conversion
        │
        ▼
Flutter Integration
```

---

# Model Architectures

Three state-of-the-art CNN architectures were employed.

## ResNet50

ResNet50 was used for:

- Acne
- Actinic Keratosis
- Psoriasis
- Ringworm
- Warts

ResNet50 utilizes **Residual Learning** with skip connections that mitigate the vanishing gradient problem and enable effective training of deeper neural networks.

---

## EfficientNetB2

EfficientNetB2 was selected for:

- Eczema

EfficientNetB2 balances depth, width, and image resolution using compound scaling, providing excellent performance while maintaining computational efficiency.

---

## EfficientNetB3

EfficientNetB3 was employed for:

- Melanoma
- Basal Cell Carcinoma

EfficientNetB3 offers improved feature extraction capability through increased network capacity, making it particularly suitable for detecting subtle lesion characteristics associated with malignant skin diseases.

---
# Dataset

The models were trained using curated dermatological image datasets collected from publicly available and research-approved sources. Each dataset underwent extensive preprocessing to ensure high-quality training samples and reliable model performance.

To improve classification accuracy, each disease was trained independently using a binary classification approach, where the model learns to distinguish between the target disease and healthy skin.

## Dataset Split

The dataset for each disease was divided using a **stratified 80:10:10 ratio** to preserve class distribution across all subsets.

| Dataset | Percentage |
|----------|-----------:|
| Training | 80% |
| Validation | 10% |
| Testing | 10% |

Stratified sampling ensured that both positive and negative classes remained proportionally represented in every subset, improving model generalization and reducing sampling bias.

---

# Image Preprocessing

Before training and inference, every image undergoes several preprocessing steps to standardize the input for the neural network.

## Training Preprocessing

- Resize image to the model input resolution
- Convert image to RGB format
- Normalize pixel values
- Convert image into tensors
- Apply preprocessing corresponding to the selected pretrained backbone

## Inference Preprocessing

When a user selects or captures an image:

1. Image is resized to the required input size.
2. Pixel values are normalized.
3. Image is converted into a tensor.
4. Tensor is passed to the TensorFlow Lite interpreter.
5. Prediction probabilities are returned.
6. The confidence score is displayed to the user.

---

# Data Augmentation

To improve robustness and minimize overfitting, online data augmentation was applied during training.

The following transformations were used:

- Random Rotation
- Horizontal Flip
- Random Zoom
- Width Shift
- Height Shift
- Brightness Adjustment
- Shearing
- Fill Mode (Nearest)

These augmentations expose the model to variations in orientation, lighting conditions, scale, and positioning, thereby improving its ability to generalize to unseen clinical images.

---

# Training Strategy

Each disease-specific model was trained independently using transfer learning and fine-tuning.

The training process consisted of two phases:

## Phase 1 — Transfer Learning

- Load pretrained CNN weights (ImageNet)
- Freeze backbone layers
- Train only the custom classification head

This enables rapid convergence while preserving generic visual features learned from large-scale datasets.

---

## Phase 2 — Fine-Tuning

After the classifier converged:

- Selected backbone layers were unfrozen.
- The network was retrained using a lower learning rate.
- Feature representations became specialized for dermatological images.

Fine-tuning significantly improved classification performance across all disease categories.

---

# Hyperparameters

| Parameter | Value |
|-----------|-------|
| Optimizer | Adam |
| Loss Function | Binary Cross-Entropy |
| Learning Rate | Adaptive |
| Batch Size | 32 |
| Transfer Learning | Yes |
| Fine-Tuning | Yes |
| Early Stopping | Enabled |
| ReduceLROnPlateau | Enabled |
| Data Augmentation | Enabled |

---

# Transfer Learning

Transfer learning allows the model to reuse feature representations learned from the ImageNet dataset.

Instead of training millions of parameters from scratch, pretrained CNNs provide rich low-level and high-level visual features such as:

- Edges
- Textures
- Colors
- Shapes
- Object structures

These pretrained features are then adapted to dermatological image classification through fine-tuning.

---

# Model Optimization

Several optimization techniques were incorporated to maximize predictive performance.

## Early Stopping

Training automatically stopped when the validation loss failed to improve for several consecutive epochs.

Benefits include:

- Reduced overfitting
- Faster training
- Better model generalization

---

## Reduce Learning Rate on Plateau

Whenever validation performance stagnated, the learning rate was reduced automatically.

This allowed the optimizer to make smaller and more precise weight updates near convergence.

---

## Fine-Tuning

After transfer learning, selected convolutional layers were unfrozen to adapt pretrained features specifically for skin lesion classification.

---

# TensorFlow Lite Deployment

Once training was completed, each Keras model was converted into TensorFlow Lite format.

Benefits of TensorFlow Lite include:

- Fast mobile inference
- Low memory consumption
- Small model size
- Offline prediction
- Reduced latency
- Efficient CPU execution

Each disease has its own optimized `.tflite` model integrated into the Flutter application.

---

# Local Storage

DermaScan uses **Hive**, a lightweight NoSQL database for Flutter, to store application data locally.

The following information is stored:

- User profile
- Prediction history
- Selected preferences
- Cached application data

All information remains on the user's device, enhancing privacy and enabling offline functionality.

---

# Evaluation Metrics

Each model was evaluated using multiple performance metrics to provide a comprehensive assessment of classification performance.

The evaluation metrics include:

- Accuracy
- Precision
- Recall (Sensitivity)
- Specificity
- F1-Score
- ROC Curve
- Area Under the Curve (AUC)

These metrics ensure balanced evaluation, particularly for medical image classification where false negatives and false positives carry significant importance.

---

# Model Performance

The proposed binary classification models achieved excellent predictive performance across all supported diseases.

## Performance Highlights

- High classification accuracy
- Strong precision and recall
- Excellent ROC-AUC values
- Robust generalization on unseen test images
- Fast mobile inference using TensorFlow Lite

The combination of transfer learning, fine-tuning, and disease-specific binary classifiers enabled DermaScan to achieve state-of-the-art results while maintaining computational efficiency suitable for mobile deployment.

---

# Project Structure

```text
DermaScan/
│
├── android/
├── ios/
├── assets/
│   ├── icons/
│   ├── images/
│   ├── models/
│   └── fonts/
│
├── lib/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   ├── providers/
│   ├── models/
│   ├── utils/
│   ├── constants/
│   ├── routes/
│   └── main.dart
│
├── test/
├── pubspec.yaml
├── README.md
└── LICENSE
```

---

# Installation

Clone the repository.

```bash
git clone https://github.com/yourusername/DermaScan.git
```

Navigate into the project directory.

```bash
cd DermaScan
```

Install Flutter dependencies.

```bash
flutter pub get
```

Run the application.

```bash
flutter run
```

---

# Requirements

## Software

- Flutter SDK
- Dart SDK
- Android Studio
- Visual Studio Code
- Python 3.x
- TensorFlow
- TensorFlow Lite

## Hardware

- Android device or emulator
- Minimum 4 GB RAM recommended
- Camera (optional but recommended)

---

# Running the Application

1. Launch the application.
2. Create or log into your profile.
3. Choose a skin disease category.
4. Capture or upload an image.
5. Wait for AI inference.
6. View the prediction and confidence score.
7. Access saved prediction history anytime.

---

# Future Work

Although DermaScan demonstrates promising performance in AI-assisted skin disease detection, several enhancements can further improve its clinical applicability and user experience.

Future developments include:

- Multi-disease classification using a single deep learning model.
- Skin lesion segmentation for precise localization of affected regions.
- Disease severity assessment and progression monitoring.
- Explainable AI through Grad-CAM++ visualizations to improve prediction transparency.
- Cloud synchronization and secure backup of user history.
- Integration with Electronic Health Record (EHR) systems.
- Teledermatology support for direct consultation with certified dermatologists.
- Multilingual user interface for broader accessibility.
- iOS deployment alongside Android support.
- Continuous model updates using larger and more diverse dermatological datasets.

---

# Research Contributions

The primary contributions of this work are summarized as follows:

- Developed **DermaScan**, a Flutter-based mobile application for AI-assisted skin disease detection.
- Proposed a **disease-specific binary classification framework** instead of a conventional multiclass approach, enabling improved discrimination between diseased and healthy skin.
- Trained and optimized **eight independent deep learning models** using transfer learning and fine-tuning techniques.
- Employed state-of-the-art CNN architectures, including **ResNet50**, **EfficientNetB2**, and **EfficientNetB3**, selected according to disease characteristics.
- Converted all trained models into **TensorFlow Lite** format for efficient on-device inference with low latency.
- Integrated local data management using **Hive Database**, enabling offline prediction history and enhanced privacy.
- Achieved excellent classification performance across all supported skin diseases, demonstrating the feasibility of deploying deep learning models on mobile devices for real-time dermatological screening.

---

# Security & Privacy

DermaScan has been designed with user privacy and data security as key considerations.

The application follows the following privacy principles:

- All AI inference is performed **locally on the user's device** using TensorFlow Lite.
- Images are **not uploaded to external servers** during prediction.
- User information and prediction history are stored securely using **Hive local database**.
- No personally identifiable medical information is shared with third parties.
- Users retain full control over their locally stored prediction history.
- The application is intended to support privacy-preserving mobile healthcare.

Future versions may include encrypted cloud synchronization and secure authentication mechanisms for enhanced data protection.

---

# Limitations

Despite achieving strong predictive performance, DermaScan has several limitations.

- The application currently supports only **eight skin diseases**.
- Predictions depend heavily on image quality, lighting conditions, and camera resolution.
- Performance may decrease for images containing multiple skin conditions simultaneously.
- The current system performs binary classification rather than comprehensive dermatological diagnosis.
- The models have been trained on curated datasets and may not fully represent all skin tones, ethnicities, or rare disease presentations.
- The application should not be considered a substitute for professional medical examination.

These limitations provide opportunities for future research and continuous model improvement.

---

# Disclaimer

**DermaScan is intended solely as an educational and preliminary screening tool.**

The predictions generated by the application are produced using deep learning models and should **not** be interpreted as professional medical advice, diagnosis, or treatment recommendations.

Users are strongly encouraged to consult a qualified dermatologist or healthcare professional for accurate diagnosis, clinical evaluation, and appropriate treatment. The developers assume no responsibility for medical decisions made based solely on the application's predictions.

---

# Authors

**DermaScan** was developed as a Final Year Project in the field of Artificial Intelligence and Medical Image Analysis.

**Development Team**

- **Laiba**
- **Anam Bhutta**

**Technologies Used**

- Flutter
- Dart
- Python
- TensorFlow
- TensorFlow Lite
- Keras
- Hive Database

---

# Acknowledgements

The authors would like to express their sincere gratitude to everyone who contributed to the successful completion of this project.

Special thanks to:

- The faculty members and supervisors for their continuous guidance and valuable feedback.
- The developers and contributors of **TensorFlow**, **TensorFlow Lite**, **Flutter**, and **Keras** for providing powerful open-source frameworks.
- The creators and maintainers of publicly available dermatological image datasets that enabled model training and evaluation.
- The open-source community for developing tools and resources that supported this research.
- All researchers whose work in deep learning, computer vision, and medical image analysis inspired and influenced the development of DermaScan.

Their contributions have played a significant role in making this project possible.

---