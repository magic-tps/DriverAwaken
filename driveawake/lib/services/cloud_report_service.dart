import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/cloud_trip_report.dart';
import '../models/trip_session_summary.dart';
import 'account_session.dart';

class CloudReportService implements AccountSession {
  CloudReportService._();
  static final instance = CloudReportService._();

  FirebaseAuth? _auth;
  FirebaseFirestore? _store;
  Future<void>? _initialization;
  User? get user => _auth?.currentUser;
  @override
  bool get signedIn => user != null;

  @override
  Future<void> initialize() =>
      _initialization ??= _initialize().catchError((Object error) {
        _initialization = null;
        throw error;
      });

  Future<void> _initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('La copia en la nube está disponible en Android.');
    }
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _store = FirebaseFirestore.instance;
    // SQLite is the offline source of truth. Do not retain other accounts'
    // cloud reports in a second on-disk cache on this device.
    _store!.settings = const Settings(persistenceEnabled: false);
  }

  @override
  Future<void> signIn(
    String email,
    String password, {
    required bool register,
  }) async {
    await initialize();
    if (register) {
      await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } else {
      await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await initialize();
    await _auth!.sendPasswordResetEmail(email: email.trim());
  }

  CollectionReference<Map<String, dynamic>> _reports() {
    final uid = user?.uid;
    if (uid == null) {
      throw StateError('Inicia sesión para consultar tus copias.');
    }
    return _store!.collection('users').doc(uid).collection('reports');
  }

  Future<List<CloudTripReport>> load() async {
    final snapshot = await _reports()
        .orderBy('startedAtMs', descending: true)
        .limit(100)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 20));
    return snapshot.docs
        .map((doc) => CloudTripReport.decode(doc.id, doc.data()))
        .toList();
  }

  Future<int> backup(List<TripSessionSummary> trips) async {
    final collection = _reports();
    for (var start = 0; start < trips.length; start += 200) {
      final batch = _store!.batch();
      for (final trip in trips.skip(start).take(200)) {
        batch.set(collection.doc(CloudTripReport.documentId(trip)), {
          ...CloudTripReport.encode(trip),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit().timeout(const Duration(seconds: 30));
    }
    return trips.length;
  }

  Future<void> deleteReport(String id) =>
      _reports().doc(id).delete().timeout(const Duration(seconds: 20));

  Future<void> signOut() => _auth!.signOut();

  Future<void> deleteAccount(String password) async {
    final current = user;
    if (current == null || current.email == null) {
      throw StateError('Inicia sesión de nuevo.');
    }
    await current.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: current.email!, password: password),
    );
    final collection = _reports();
    while (true) {
      final page = await collection
          .limit(200)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 20));
      if (page.docs.isEmpty) break;
      final batch = _store!.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit().timeout(const Duration(seconds: 30));
    }
    await current.delete();
  }

  static String friendlyError(Object error) {
    if (error is TimeoutException) {
      return 'No llegó la confirmación del servidor. Si estabas guardando o borrando, la operación puede completarse al volver la conexión. Actualiza la lista para comprobarlo.';
    }
    if (error is UnsupportedError) {
      return error.message ?? 'Plataforma no disponible.';
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'invalid-email' => 'Revisa el correo electrónico.',
        'email-already-in-use' =>
          'Este correo ya tiene cuenta. Usa Iniciar sesión.',
        'weak-password' => 'Usa una contraseña de al menos 6 caracteres.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'Correo o contraseña incorrectos.',
        'network-request-failed' || 'unavailable' =>
          'No hay conexión con la nube. Tus informes locales siguen disponibles.',
        'too-many-requests' =>
          'Demasiados intentos. Espera un momento y vuelve a probar.',
        'operation-not-allowed' || 'configuration-not-found' =>
          'El acceso con correo todavía no está habilitado en Firebase.',
        'permission-denied' =>
          'No se pudo acceder a tus copias. Inicia sesión de nuevo o revisa la configuración del servicio.',
        'requires-recent-login' =>
          'Vuelve a iniciar sesión antes de eliminar la cuenta.',
        _ =>
          'No se pudo completar la operación en la nube. Inténtalo de nuevo.',
      };
    }
    return 'No se pudo conectar con la nube. La app y los informes locales siguen disponibles.';
  }
}
