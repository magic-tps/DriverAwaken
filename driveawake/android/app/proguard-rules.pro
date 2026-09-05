# TensorFlow Lite interpreter and delegates used from Flutter plugins.
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# ML Kit face detection is invoked through its Android libraries.
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }
-dontwarn com.google.android.gms.internal.mlkit_vision_face.**

# Flutter generated plugin registration must remain discoverable.
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
