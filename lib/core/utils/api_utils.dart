/// Extracts a list from a dynamic API response body.
///
/// Handles the common backend shapes:
/// - a raw `List`
/// - `{ "data": [...] }`
/// - `{ "results": [...] }`
/// Returns an empty list for anything else.
List<dynamic> extractList(dynamic body) {
  if (body is List) return body;
  if (body is Map && body['data'] is List) return body['data'] as List;
  if (body is Map && body['results'] is List) return body['results'] as List;
  return const [];
}