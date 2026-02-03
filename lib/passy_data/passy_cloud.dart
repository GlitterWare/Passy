import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import 'loaded_account.dart';
import 'app_data.dart';
import 'synchronization.dart';

//#region Response models

//#region User

class PassyCloudResponse {
  final Map<String, dynamic> json;

  PassyCloudResponse(this.json);
}

class LoginResponse extends PassyCloudResponse {
  final String token;
  final String refresh;

  LoginResponse.fromJson(Map<String, dynamic> json)
      : token = json['token'] as String,
        refresh = json['refresh'] as String,
        super(json);
}

//#endregion

//#region Subscription

class Prices extends PassyCloudResponse {
  final String eur;
  final String gbp;
  final String usd;

  Prices.fromJson(Map<String, dynamic> json)
      : eur = json['eur'] as String,
        gbp = json['gbp'] as String,
        usd = json['usd'] as String,
        super(json);
}

class Plan extends PassyCloudResponse {
  final String service;
  final String plan;
  final String name;
  final Prices prices;

  Plan.fromJson(Map<String, dynamic> json)
      : service = json['service'] as String,
        plan = json['plan'] as String,
        name = json['name'] as String,
        prices = Prices.fromJson(json['prices']),
        super(json);
}

class PlansResponse extends PassyCloudResponse {
  final List<Plan> plans;

  PlansResponse.fromJson(Map<String, dynamic> json)
      : plans = (json['plans'] as Map<String, dynamic>)
            .values
            .map((e) => Plan.fromJson(e))
            .toList()
          ..sort((a, b) => a.plan == 'monthly'
              ? -2
              : a.plan == 'yearly'
                  ? -1
                  : 1),
        super(json);
}

class SubscriptionRequest extends PassyCloudResponse {
  final String url;

  SubscriptionRequest.fromJson(Map<String, dynamic> json)
      : url = json['url'] as String,
        super(json);
}

class Subscription extends PassyCloudResponse {
  final String id;
  final String service;
  final String paymentService;
  final String plan;
  final bool lifetime;
  final int? currentPeriodEnd; // UNIX time
  final bool cancelAtPeriodEnd;

  Subscription.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        service = json['service'] as String,
        paymentService = json['payment_service'] as String,
        plan = json['plan'] as String,
        lifetime = json['lifetime'] as bool,
        currentPeriodEnd = int.tryParse(json['current_period_end'] as String),
        cancelAtPeriodEnd = json['cancel_at_period_end'] as bool,
        super(json);
}

class SubscriptionStatus extends PassyCloudResponse {
  final Map<String, Subscription> subscriptions;

  SubscriptionStatus.fromJson(Map<String, dynamic> json)
      : subscriptions = (json['subscriptions'] as Map)
            .map((k, v) => MapEntry(k, Subscription.fromJson(v))),
        super(json);
}

class SubscriptionCancel extends PassyCloudResponse {
  final String service;

  SubscriptionCancel.fromJson(Map<String, dynamic> json)
      : service = json['service'] as String,
        super(json);
}

//#endregion

//#region Sync
class LockStatus extends PassyCloudResponse {
  final String status;
  final String lockedBy;
  final DateTime expiresAt;

  LockStatus.fromJson(Map<String, dynamic> json)
      : status = json['status'] as String,
        lockedBy = json['locked_by'] as String,
        expiresAt = DateTime.parse(json['expires_at'] as String),
        super(json);
}

class ReleaseStatus extends PassyCloudResponse {
  final String status;

  ReleaseStatus.fromJson(Map<String, dynamic> json)
      : status = json['status'] as String,
        super(json);
}

class FileUploadResult extends PassyCloudResponse {
  final String status;
  final String filename;
  final String path;
  final String hash;
  final DateTime updatedAt;

  FileUploadResult.fromJson(Map<String, dynamic> json)
      : status = json['status'] as String,
        filename = json['filename'] as String,
        path = json['path'] as String,
        hash = json['hash'] as String,
        updatedAt = DateTime.parse(json['updated_at'] as String),
        super(json);
}

class FileDownload {
  final String logicalPath; // logical path requested
  final int? contentLength; // total file size if known
  final int statusCode; // HTTP status
  final Map<String, String> headers;
  final List<int> bytes; // downloaded chunk

  FileDownload({
    required this.logicalPath,
    required this.statusCode,
    required this.headers,
    required this.bytes,
    this.contentLength,
  });
}

class FileDownloadResult {
  final String logicalPath; // logical path requested
  final String downloadPath; // local file path
  final int statusCode; // final HTTP status
  final Map<String, String> headers;

  FileDownloadResult({
    required this.logicalPath,
    required this.downloadPath,
    required this.statusCode,
    required this.headers,
  });
}

class FileDeleteResult extends PassyCloudResponse {
  final String status;
  final String path;

  FileDeleteResult.fromJson(Map<String, dynamic> json)
      : status = json['status'] as String,
        path = json['path'] as String,
        super(json);
}

class FileEntry extends PassyCloudResponse {
  final String path;
  final String type; // "dir" or "file"
  final int? size;
  final String? hash;
  final int? version;
  final DateTime? updatedAt;

  FileEntry.fromJson(Map<String, dynamic> json)
      : path = json['path'] as String,
        type = json['type'] as String,
        size = json['size'] != null ? int.parse(json['size'].toString()) : null,
        hash = json['hash'] as String?,
        version = json['version'] as int?,
        updatedAt = json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        super(json);
}

class FileList extends PassyCloudResponse {
  final List<FileEntry> entries;

  FileList.fromJson(Map<String, dynamic> json)
      : entries = (json['entries'] as List)
            .map((e) => FileEntry.fromJson(e))
            .toList(),
        super(json);
}

class StorageInfo extends PassyCloudResponse {
  final String userId;
  final int usedBytes;
  final int maxBytes;
  final int fileCount;
  final int dirCount;
  final DateTime updatedAt;

  StorageInfo.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'] as String,
        usedBytes = int.parse(json['used_bytes'].toString()),
        maxBytes = int.parse(json['max_bytes'].toString()),
        fileCount = json['file_count'] as int,
        dirCount = json['dir_count'] as int,
        updatedAt = DateTime.parse(json['updated_at'] as String),
        super(json);
}

//#endregion

//#endregion

class PassyCloudError implements Exception {
  final DateTime _timestamp = DateTime.now();
  final String source;
  final int statusCode;
  String _message = '';
  String get message => _message;
  String? _error;
  String? get error => _error;

  PassyCloudError(this.source, this.statusCode, String message) {
    try {
      Map<String, dynamic> json = jsonDecode(message);
      _error = json['error'] as String;
      _message = json['message'] as String;
    } catch (_) {
      _message = message;
    }
  }

  @override
  String toString() =>
      '${DateFormat('yyyy/MM/dd HH:mm:ss').format(_timestamp)} PassyCloudError($source, $statusCode) $message';
}

enum PassyCloudSyncStatus {
  unauthorized,
  forbidden,
  loginSuccess,
  downloadingAccount,
  downloadingFiles,
  uploadingAccount,
  uploadingFiles,
  synchronizing,
  success,
  completed,
}

enum SubscriptionPlan {
  monthly,
  yearly,
  lifetime,
}

SubscriptionPlan? parseSubscriptionPlan(String type) {
  switch (type) {
    case 'monthly':
      return SubscriptionPlan.monthly;
    case 'yearly':
      return SubscriptionPlan.yearly;
    case 'lifetime':
      return SubscriptionPlan.lifetime;
    default:
      return null;
  }
}

class PassyCloud {
  static const String baseUrl = 'https://api.glitterware.net/api/v1';
  static const int _maxErrors = 50;
  static final List<PassyCloudError> _errorLog = [];

  static List<PassyCloudError> get recentErrors => List.unmodifiable(_errorLog);

  static void _logError(PassyCloudError error) {
    if (error.statusCode == 409) return; // ignore lock conflict
    if (error.source == '/stripe/status') {
      if (error.statusCode == 429) return; // ignore rate limit
    }
    if (_errorLog.length >= _maxErrors) _errorLog.removeAt(0);
    _errorLog.add(error);
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    String? deviceId,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (deviceId != null) 'X-Device-ID': deviceId,
    };

    http.Response response;
    if (method == 'POST') {
      response = await http.post(uri,
          headers: headers, body: body != null ? jsonEncode(body) : null);
    } else if (method == 'GET') {
      response = await http.get(uri, headers: headers);
    } else {
      throw ArgumentError('Unsupported method $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    } else {
      final error = PassyCloudError(path, response.statusCode, response.body);
      _logError(error);
      throw error;
    }
  }

  //#region User endpoints
  static Future<void> register({
    required String email,
    required String password,
    bool acceptPrivacy = false,
    bool acceptTerms = false,
  }) =>
      _request('POST', '/user/register', body: {
        'email': email,
        'password': password,
        'accept_privacy': acceptPrivacy,
        'accept_terms': acceptTerms,
      });

  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async =>
      LoginResponse.fromJson(await _request('POST', '/user/login',
          body: {'email': email, 'password': password}));

  static Future<void> requestLoginCode({required String email}) async =>
      await _request('POST', '/user/login/code/request',
          body: {'email': email});

  static Future<LoginResponse> loginWithCode({
    required String email,
    required String code,
  }) async =>
      LoginResponse.fromJson(await _request('POST', '/user/login/code',
          body: {'email': email, 'code': code}));

  static Future<LoginResponse> refresh({
    required String refreshToken,
  }) async =>
      LoginResponse.fromJson(
          await _request('POST', '/user/refresh', token: refreshToken));

  static Future<void> requestPasswordChange({required String email}) =>
      _request('POST', '/user/passwordChange/request', body: {'email': email});

  static Future<void> confirmPasswordChange({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _request('POST', '/user/passwordChange', body: {
        'email': email,
        'code': code,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

  static Future<void> requestEmailChange({
    required String token,
    required String newEmail,
  }) =>
      _request('POST', '/user/emailChange/request',
          token: token, body: {'new_email': newEmail});

  static Future<void> confirmEmailChange({
    required String token,
    required String oldEmailCode,
    required String newEmailCode,
  }) =>
      _request('POST', '/user/emailChange', token: token, body: {
        'old_email_code': oldEmailCode,
        'new_email_code': newEmailCode,
      });
  //#endregion

  //#region Subscription endpoints
  static Future<PlansResponse> getPlans() async =>
      PlansResponse.fromJson(await _request('GET', '/stripe/plans/passy'));

  static Future<SubscriptionRequest> subscribe({
    required String token,
    required SubscriptionPlan plan,
  }) async =>
      SubscriptionRequest.fromJson(await _request('POST', '/stripe/subscribe',
          token: token, body: {'service': 'passy', 'plan': plan.name}));

  static Future<SubscriptionStatus> subscriptionStatus(
          {required String token}) async =>
      SubscriptionStatus.fromJson(
          await _request('POST', '/user/subscription/status', token: token));

  static Future<SubscriptionCancel> cancelSubscription(
          {required String token, required String service}) async =>
      SubscriptionCancel.fromJson(await _request(
          'POST', '/user/subscription/cancel',
          token: token, body: {'service': service}));
  //#endregion

  //#region Sync endpoints
  static Future<Map<String, dynamic>> lock(
          {required String token, required String deviceId}) =>
      _request('POST', '/sync/lock', token: token, deviceId: deviceId);

  static Future<Map<String, dynamic>> releaseLock(
          {required String token, required String deviceId}) =>
      _request('POST', '/sync/lock/release', token: token, deviceId: deviceId);

  static Future<FileUploadResult> uploadFile({
    required String token,
    required String deviceId,
    required File file,
    required String logicalPath,
    required String expectedHash,
  }) async {
    const path = '/sync/files/upload';
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['X-Device-ID'] = deviceId
      ..files.add(await http.MultipartFile.fromPath('file', file.path))
      ..fields['path'] = logicalPath
      ..fields['expected_hash'] = expectedHash;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return FileUploadResult.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final error = PassyCloudError(path, response.statusCode, response.body);
      _logError(error);
      throw error;
    }
  }

  static Future<void> uploadDirectory({
    required String token,
    required String deviceId,
    required Directory dir,
    required String remotePath,
    required FutureOr<String> Function(List<int>) calculateHash,
    int maxRetries = 3,
    bool recursive = true,
    void Function(File file, int attempt, bool success)? onFileDone,
  }) async {
    if (!dir.existsSync()) {
      throw ArgumentError('Directory does not exist: ${dir.path}');
    }

    final files = dir.listSync(recursive: recursive).whereType<File>();
    for (final file in files) {
      final relative = file.path.substring(dir.path.length);
      final remoteFilePath = '$remotePath$relative';

      int attempt = 0;
      bool success = false;
      while (attempt < maxRetries && !success) {
        attempt++;
        try {
          final hash = await calculateHash(await file.readAsBytes());
          await uploadFile(
              token: token,
              deviceId: deviceId,
              file: file,
              logicalPath: remoteFilePath,
              expectedHash: hash);
          await Future.delayed(const Duration(milliseconds: 100));
          success = true;
          onFileDone?.call(file, attempt, true);
        } catch (e) {
          if (e is PassyCloudError) {
            if (e.statusCode == HttpStatus.locked) rethrow;
          }
          if (attempt >= maxRetries) {
            onFileDone?.call(file, attempt, false);
            rethrow;
          }
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    }
  }

  static Future<FileDownload> downloadFile({
    required String token,
    required String deviceId,
    required String logicalPath,
    required FutureOr<String> Function(List<int> bytes) calculateHash,
    int? start, // byte offset to resume from
    int? end, // optional end offset
  }) async {
    final path = '/sync/files/download?path=$logicalPath';
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'X-Device-ID': deviceId,
    };

    // Add Range header if resuming
    if (start != null) {
      headers['Range'] = end != null ? 'bytes=$start-$end' : 'bytes=$start-';
    }

    final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 206) {
      if (calculateHash(response.bodyBytes) != response.headers['hash']) {
        final error =
            PassyCloudError(path, 1, 'Hash mismatch for file $logicalPath');
        _logError(error);
        throw error;
      }
      return FileDownload(
        logicalPath: logicalPath,
        statusCode: response.statusCode,
        headers: response.headers,
        bytes: response.bodyBytes,
        contentLength: int.tryParse(response.headers['content-length'] ?? ''),
      );
    } else {
      final error = PassyCloudError(path, response.statusCode, response.body);
      _logError(error);
      throw error;
    }
  }

  static Future<FileDownloadResult> downloadFileToPath({
    required String token,
    required String deviceId,
    required String logicalPath,
    required String downloadPath,
    required FutureOr<String> Function(List<int> bytes) calculateHash,
    void Function(int received, int? total)? onProgress,
    int maxRetries = 3,
  }) async {
    final path = '/sync/files/download?path=$logicalPath';
    final uri = Uri.parse('$baseUrl$path');
    final file = File(downloadPath);
    int attempt = 0;

    while (true) {
      attempt++;
      final existingLength = file.existsSync() ? file.lengthSync() : 0;

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'X-Device-ID': deviceId,
      };
      if (existingLength > 0) {
        headers['Range'] = 'bytes=$existingLength-';
      }

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers);

      try {
        final streamed = await request.send();

        if (streamed.statusCode == 200 || streamed.statusCode == 206) {
          final dir = file.parent;
          if (!dir.existsSync()) {
            dir.createSync(recursive: true);
          }

          final totalLength =
              int.tryParse(streamed.headers['content-length'] ?? '');
          final sink = file.openWrite(
            mode: existingLength > 0 ? FileMode.append : FileMode.write,
          );

          int received = existingLength;
          await for (final chunk in streamed.stream) {
            received += chunk.length;
            sink.add(chunk);
            if (onProgress != null) {
              onProgress(received,
                  totalLength != null ? existingLength + totalLength : null);
            }
          }

          await sink.close();

          if (calculateHash(await file.readAsBytes()) !=
              streamed.headers['hash']) {
            final error =
                PassyCloudError(path, 1, 'Hash mismatch for file $logicalPath');
            file.deleteSync();
            _logError(error);
            throw error;
          }

          return FileDownloadResult(
            logicalPath: logicalPath,
            downloadPath: downloadPath,
            statusCode: streamed.statusCode,
            headers: streamed.headers,
          );
        } else {
          String body = utf8.decode(await (streamed.stream.first));
          final error = PassyCloudError(path, streamed.statusCode,
              body.isEmpty ? 'Download failed' : body);
          _logError(error);
          throw error;
        }
      } catch (e) {
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  static Future<void> downloadDirectory({
    required String token,
    required String deviceId,
    required String logicalPath,
    required Directory localDir,
    required FutureOr<String> Function(List<int> bytes) calculateHash,
    int maxRetries = 3,
    void Function(String remoteFile, File localFile, int attempt, bool success)?
        onFileDone,
  }) async {
    if (!localDir.existsSync()) {
      localDir.createSync(recursive: true);
    }

    // List remote files
    final listing =
        await listFiles(token: token, deviceId: deviceId, path: logicalPath);

    for (final entry in listing.entries) {
      if (entry.type != 'file') continue;
      final localFile = File('${localDir.path}/${entry.path.split('/').last}');
      await downloadFileToPath(
        token: token,
        deviceId: deviceId,
        logicalPath: entry.path,
        downloadPath: localFile.path,
        calculateHash: calculateHash,
        maxRetries: maxRetries,
      );
      onFileDone?.call(entry.path, localFile, 0, true);
    }
  }

  static Future<FileDeleteResult> deleteFile({
    required String token,
    required String deviceId,
    required String path,
  }) async =>
      FileDeleteResult.fromJson(await _request('POST', '/sync/files/delete',
          token: token, deviceId: deviceId, query: {'path': path}));

  static Future<FileList> listFiles({
    required String token,
    required String deviceId,
    required String path,
  }) async =>
      FileList.fromJson(await _request('GET', '/sync/files/list',
          token: token, deviceId: deviceId, query: {'path': path}));

  static Future<void> reset(
          {required String token, required String deviceId}) async =>
      await _request('POST', '/sync/files/reset',
          token: token, deviceId: deviceId);

  static Future<StorageInfo> info({required String token}) async =>
      StorageInfo.fromJson(
          await _request('GET', '/sync/files/info', token: token));
  //#endregion

  //#region Synchronization helpers
  static Future<void> _retryUpload(
    File file,
    String remotePath,
    String token,
    String deviceId,
    FutureOr<String> Function(List<int> bytes) calculateHash,
    void Function(File file, int attempt, bool success)? onFileUploaded,
    int maxRetries,
  ) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      attempt++;
      try {
        await uploadFile(
          token: token,
          deviceId: deviceId,
          file: file,
          logicalPath: remotePath,
          expectedHash: await calculateHash(await file.readAsBytes()),
        );
        onFileUploaded?.call(file, attempt, true);
        return;
      } catch (e) {
        if (attempt >= maxRetries) {
          onFileUploaded?.call(file, attempt, false);
          rethrow;
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  static Future<void> _retryDelete(
    String remotePath,
    String token,
    String deviceId,
    void Function(String log)? onError,
    int maxRetries,
  ) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      attempt++;
      try {
        await deleteFile(
          token: token,
          deviceId: deviceId,
          path: remotePath,
        );
        return;
      } catch (e) {
        if (attempt >= maxRetries) {
          onError?.call('Failed to delete remote file $remotePath: $e');
          rethrow;
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }
  //#endregion

  /// Synchronize a local account with its remote counterpart.
  ///
  /// Downloads `/passy/accounts/{username}` into a temporary directory,
  /// loads it as a `LoadedAccount`, runs synchronization, uploads
  /// changes and deletes the temporary directory afterwards.
  static Future<void> synchronize({
    required String token,
    required LoadedAccount account,
    required FutureOr<String> Function(List<int> bytes) calculateHash,
    void Function(SynchronizationResults results)? onComplete,
    void Function(String log)? onError,
    int maxRetries = 3,
    void Function(File file, int attempt, bool success)? onFileUploaded,
    void Function(String remoteFile, File localFile, int attempt, bool success)?
        onFileDownloaded,
    void Function(PassyCloudSyncStatus status)? onSyncProgress,
  }) async {
    //#region 1. Log in and acquire lock
    try {
      await lock(token: token, deviceId: account.deviceId);
    } catch (e) {
      if (e is! PassyCloudError) {
        // Ignore connection errors
        if (e is http.ClientException || e is SocketException) {
          return;
        } else {
          rethrow;
        }
      }
      // Ignore lock conflicts
      if (e.statusCode == HttpStatus.conflict ||
          e.statusCode == HttpStatus.locked) {
        return;
      } else if (e.statusCode == HttpStatus.unauthorized) {
        // Update progress
        onSyncProgress?.call(PassyCloudSyncStatus.unauthorized);
      } else if (e.statusCode == HttpStatus.forbidden) {
        // Update progress
        onSyncProgress?.call(PassyCloudSyncStatus.forbidden);
      }
      rethrow;
    }
    //#endregion

    // Update progress
    onSyncProgress?.call(PassyCloudSyncStatus.loginSuccess);

    //#region 2. Build local filesystem
    final localDir = Directory(
      p.join(await Locator.getPlatformSpecificCachePath(), 'Passy', 'accounts',
          account.username),
    );

    if (!localDir.existsSync()) {
      throw StateError('Local account folder does not exist: ${localDir.path}');
    }

    final tmpDir = await Directory.systemTemp.createTemp(
        'passy_cloud_sync_${account.username}_${DateTime.now().millisecondsSinceEpoch}');
    final tmpFilesDir = Directory(p.join(tmpDir.path, 'files'));

    final localHistoryFile = File(p.join(localDir.path, 'history.sha512'));
    final localFileSyncFile =
        File(p.join(localDir.path, 'file_sync_history.sha512'));
    //#endregion

    try {
      final remotePath = '/passy/accounts/${account.username}';
      bool needsMainSync = false;
      bool needsFilesSync = false;

      //#region 3. Compare hashes
      try {
        final localHistoryDigest = account.historyHash;
        final localFileSyncDigest = account.fileSyncHistoryHash;

        //#region 3.1 Compare local hashes
        if (localHistoryFile.existsSync()) {
          final stored = await localHistoryFile.readAsBytes();
          if (!const ListEquality().equals(stored, localHistoryDigest.bytes)) {
            needsMainSync = true;
            await localHistoryFile.writeAsBytes(localHistoryDigest.bytes);
          }
        }

        if (localFileSyncFile.existsSync()) {
          final stored = await localFileSyncFile.readAsBytes();
          if (!const ListEquality().equals(stored, localFileSyncDigest.bytes)) {
            needsMainSync = true;
            needsFilesSync = true;
            await localFileSyncFile.writeAsBytes(localFileSyncDigest.bytes);
          }
        }
        //#endregion

        //#region 3.2 Compare remote hashes
        try {
          for (final remoteName in [
            if (!needsMainSync) 'history.sha512',
            if (!needsFilesSync) 'file_sync_history.sha512'
          ]) {
            final remoteFile = await downloadFile(
              token: token,
              deviceId: account.deviceId,
              logicalPath: '$remotePath/$remoteName',
              calculateHash: calculateHash,
            );

            final remoteBytes = remoteFile.bytes;
            if (remoteName == 'history.sha512' &&
                !const ListEquality()
                    .equals(remoteBytes, localHistoryDigest.bytes)) {
              needsMainSync = true;
              break;
            }
            if (remoteName == 'file_sync_history.sha512' &&
                !const ListEquality()
                    .equals(remoteBytes, localFileSyncDigest.bytes)) {
              needsMainSync = true;
              needsFilesSync = true;
              break;
            }
          }
        } catch (_) {
          needsMainSync = true;
          needsFilesSync = true;
        }
        //#endregion
      } catch (e) {
        // If anything goes wrong, assume main folder needs to be downloaded
        needsMainSync = true;
      }
      //#endregion

      //#region 4. Download remote account folder
      try {
        //#region 4.1 Compare remote account folder
        final mainList = await listFiles(
            token: token, deviceId: account.deviceId, path: remotePath);
        for (final entry in mainList.entries) {
          final name = p.basename(entry.path);
          const allowedNames = ['version.txt'];
          if (!allowedNames.contains(name)) continue;
          final localFile = File(p.join(localDir.path, name));
          if (!localFile.existsSync() ||
              localFile.statSync().size != entry.size) {
            needsMainSync = true;
            needsFilesSync = true;
            break;
          }
        }
        //#endregion

        //#region 4.2 Download remote account folder
        if (needsMainSync) {
          // Update status
          onSyncProgress?.call(PassyCloudSyncStatus.downloadingAccount);

          await downloadDirectory(
            token: token,
            deviceId: account.deviceId,
            logicalPath: remotePath,
            localDir: tmpDir,
            onFileDone: onFileDownloaded,
            calculateHash: calculateHash,
            maxRetries: maxRetries,
          );
          if (needsFilesSync) {
            // Update status
            onSyncProgress?.call(PassyCloudSyncStatus.downloadingFiles);
            await tmpFilesDir.create(recursive: true);

            await downloadDirectory(
              token: token,
              deviceId: account.deviceId,
              logicalPath: '$remotePath/files',
              localDir: tmpFilesDir,
              onFileDone: onFileDownloaded,
              calculateHash: calculateHash,
              maxRetries: maxRetries,
            );
          }
        }
        //#endregion
      } catch (e, s) {
        throw Exception(
            'Remote account folder not found or listing failed: $e\n$s');
      }
      //#endregion

      //#region 5. Synchronize with remote account
      if (needsMainSync) {
        //#region 5.1 Generate cloud account
        bool tmpDirEmpty = tmpDir.listSync().none((f) => f is File);
        if (tmpDirEmpty) {
          // Update status
          onSyncProgress?.call(PassyCloudSyncStatus.uploadingAccount);
          await localDir.list(recursive: false).forEach((f) async {
            if (f is! File) return;
            String fileName = p.basename(f.path);
            if (fileName == 'file_index.enc') return;
            if (fileName == 'file_sync_history.enc') return;
            if (fileName == 'file_sync_history.sha512') return;
            await f.copy(p.join(tmpDir.path, fileName));
          });
        }
        //#endregion

        //#region 5.2 Run local synchronization

        // Update status
        onSyncProgress?.call(PassyCloudSyncStatus.synchronizing);

        LoadedAccount remoteAcc;
        try {
          remoteAcc = await account.loadFromPath(path: tmpDir.path);
        } catch (e) {
          if (e.toString().contains('account version')) {
            final error = PassyCloudError('convertLegacyAccount', 1,
                'Account version mismatch - this error will disappear once you upgrade Passy on this device.');
            _logError(error);
            throw error;
          }
          rethrow;
        }

        final synLocal = account.getSynchronization(
            onComplete: onComplete, onError: onError);
        final synRemote = remoteAcc.getSynchronization(
            onComplete: onComplete, onError: onError);

        if (synLocal == null || synRemote == null) {
          throw StateError('Could not create synchronization sessions');
        }

        final adr = await synRemote.host(address: '127.0.0.1');
        if (adr == null) {
          throw StateError('Could not obtain host address');
        }

        await synLocal.connect(adr);
        await synLocal.close();
        await synRemote.close();

        await localHistoryFile.writeAsBytes(account.historyHash.bytes);
        await localHistoryFile
            .copy(p.join(tmpDir.path, p.basename(localHistoryFile.path)));
        //#endregion

        //#region 5.3 Upload synchronized account files

        // Update status
        onSyncProgress?.call(PassyCloudSyncStatus.uploadingAccount);

        for (var entry in tmpDir.listSync(followLinks: false)) {
          if (entry is File) {
            final fileName = p.basename(entry.path);
            await _retryUpload(
              entry,
              '$remotePath/$fileName',
              token,
              account.deviceId,
              calculateHash,
              onFileUploaded,
              maxRetries,
            );
          }
        }
        //#endregion

        if (needsFilesSync) {
          //#region 5.4 Sync files/ subfolder
          FileList filesList = await listFiles(
              token: token,
              deviceId: account.deviceId,
              path: '$remotePath/files');
          bool uploadingFiles = false;

          final remoteMap = {
            for (final e in filesList.entries.where((e) => e.type == 'file'))
              p.relative(e.path, from: remotePath): e.size
          };

          final localMap = {
            for (final f
                in tmpFilesDir.listSync(recursive: true).whereType<File>())
              p.relative(f.path, from: tmpFilesDir.parent.path): f
          };

          final combinedKeys = remoteMap.keys.toSet()..addAll(localMap.keys);

          for (final rel in combinedKeys) {
            final remoteSize = remoteMap[rel];
            final uploadFile = localMap[rel];

            if (uploadFile == null) {
              await _retryDelete('$remotePath/$rel', token, account.deviceId,
                  onError, maxRetries);
              continue;
            }
            if (remoteSize == await uploadFile.length()) continue;
            if (!uploadingFiles) {
              uploadingFiles = true;
              onSyncProgress?.call(PassyCloudSyncStatus.uploadingFiles);
            }
            // Renew lock for each upload to avoid expiration
            await lock(token: token, deviceId: account.deviceId);
            await _retryUpload(
              uploadFile,
              '$remotePath/$rel',
              token,
              account.deviceId,
              calculateHash,
              onFileUploaded,
              maxRetries,
            );
          }
          //#endregion

          //#region 5.5 Upload new file sync history hash
          await localFileSyncFile
              .writeAsBytes(account.fileSyncHistoryHash.bytes);
          await _retryUpload(
            localFileSyncFile,
            '$remotePath/${p.basename(localFileSyncFile.path)}',
            token,
            account.deviceId,
            calculateHash,
            onFileUploaded,
            maxRetries,
          );
          //#endregion
        }
      }
      //#endregion

      // Update status
      onSyncProgress?.call(PassyCloudSyncStatus.success);
    } finally {
      //#region 6. Release lock
      await releaseLock(token: token, deviceId: account.deviceId);
      if (tmpDir.existsSync()) {
        await tmpDir.delete(recursive: true);
      }
      // Update status
      onSyncProgress?.call(PassyCloudSyncStatus.completed);
      //#endregion
    }
  }
}
