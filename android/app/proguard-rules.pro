# Keep SLF4J classes
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep Pusher classes
-keep class com.pusher.** { *; }
-dontwarn com.pusher.**

# Keep FlutterToast classes
-keep class io.github.ponnamkarthik.toast.** { *; }
-dontwarn io.github.ponnamkarthik.toast.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes with @Keep annotation
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}