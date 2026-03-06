import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:pos_backend/config/env.dart';

/// Reads a cookie value from the incoming request by [name].
String? readCookieValue(Request request, String name) {
  final cookieString = request.headers['Cookie'];
  if (cookieString == null) return null;

  for (final cookie in cookieString.split('; ')) {
    final parts = cookie.split('=');
    if (parts.length == 2 && parts[0].trim() == name) {
      return parts[1].trim();
    }
  }

  return null;
}

/// Builds `Set-Cookie` header values for access and refresh tokens.
List<String> buildAuthSetCookieHeaders({
  required String accessToken,
  required String refreshToken,
}) {
  final accessCookie = Cookie('access_token', accessToken)
    ..httpOnly = true
    ..secure = Env.isProd
    ..path = '/'
    ..maxAge = Env.jwtExpiry.inSeconds
    ..sameSite = SameSite.lax;
  final refreshCookie = Cookie('refresh_token', refreshToken)
    ..httpOnly = true
    ..secure = Env.isProd
    ..path = '/'
    ..maxAge = Env.refreshJwtExpiry.inSeconds
    ..sameSite = SameSite.lax;

  return [accessCookie.toString(), refreshCookie.toString()];
}

/// Builds `Set-Cookie` header values that clear auth cookies.
List<String> buildClearAuthCookiesHeaders() {
  final clearAccessCookie = Cookie('access_token', '')
    ..httpOnly = true
    ..secure = Env.isProd
    ..path = '/'
    ..maxAge = 0
    ..sameSite = SameSite.lax;
  final clearRefreshCookie = Cookie('refresh_token', '')
    ..httpOnly = true
    ..secure = Env.isProd
    ..path = '/'
    ..maxAge = 0
    ..sameSite = SameSite.lax;
  return [clearAccessCookie.toString(), clearRefreshCookie.toString()];
}
