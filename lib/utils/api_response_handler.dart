import 'dart:developer' as developer;

/// Standardized API response handler for consistent data extraction
class ApiResponseHandler {
  /// Extract data from API response with multiple fallback patterns
  static T extractData<T>(
    dynamic responseData, {
    required String endpoint,
    List<String> possibleKeys = const ['data', 'result', 'response'],
  }) {
    developer.log('🔍 Extracting data from $endpoint');
    developer.log('📋 Response type: ${responseData.runtimeType}');
    developer.log('📋 Response data: $responseData');

    // If response is already the expected type, return it
    if (responseData is T) {
      developer.log('✅ Direct type match for $endpoint');
      return responseData;
    }

    // Handle standard API response format: {success: true, data: ...}
    if (responseData is Map<String, dynamic>) {
      developer.log('🗺 Response is Map, checking keys: ${responseData.keys.toList()}');
      
      // Check for success wrapper format first
      if (responseData.containsKey('success') && responseData.containsKey('data')) {
        if (responseData['data'] is T) {
          developer.log('✅ Found data in success wrapper for $endpoint');
          return responseData['data'];
        }
      }
      
      // Try each possible key
      for (String key in possibleKeys) {
        if (responseData.containsKey(key) && responseData[key] is T) {
          developer.log('✅ Found data in key "$key" for $endpoint');
          return responseData[key];
        }
      }
      
      // If no key worked, log available keys for debugging
      developer.log('❌ No matching key found for $endpoint. Available keys: ${responseData.keys.toList()}');
    }

    throw Exception('Unable to extract data from $endpoint response. Expected type: $T, Got: ${responseData.runtimeType}');
  }

  /// Extract list data with common patterns
  static List<T> extractList<T>(
    dynamic responseData, {
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    List<String> possibleKeys = const ['data', 'items', 'results', 'list'],
  }) {
    developer.log('📋 Extracting list from $endpoint');
    
    try {
      // Direct list
      if (responseData is List) {
        developer.log('✅ Direct list found for $endpoint');
        return responseData.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      }

      // Handle standard API response format: {success: true, data: [...]}
      if (responseData is Map<String, dynamic>) {
        // Check for success wrapper format first
        if (responseData.containsKey('success') && responseData.containsKey('data')) {
          if (responseData['data'] is List) {
            developer.log('✅ Found list in success wrapper for $endpoint');
            return (responseData['data'] as List)
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
        
        // Try other possible keys
        for (String key in possibleKeys) {
          if (responseData.containsKey(key) && responseData[key] is List) {
            developer.log('✅ Found list in key "$key" for $endpoint');
            return (responseData[key] as List)
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      }

      developer.log('❌ No list found in $endpoint response');
      return <T>[];
    } catch (e) {
      developer.log('❌ Error extracting list from $endpoint: $e');
      return <T>[];
    }
  }

  /// Check if API response indicates success
  static bool isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Log API response for debugging
  static void logResponse(String endpoint, dynamic response) {
    developer.log('🔍 API Response from $endpoint:');
    developer.log('📊 Status: ${response?.statusCode}');
    developer.log('📋 Data Type: ${response?.data?.runtimeType}');
    developer.log('📋 Data: ${response?.data}');
    if (response?.data is Map) {
      developer.log('🗝 Keys: ${(response.data as Map).keys.toList()}');
    }
  }
}