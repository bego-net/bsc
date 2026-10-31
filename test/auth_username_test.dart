import 'package:bible_study/models/app_user.dart';
import 'package:bible_study/repositories/fake_auth_repository.dart';
import 'package:bible_study/repositories/firebase_auth_repository.dart';
import 'package:bible_study/state/auth_state.dart';
import 'package:bible_study/utils/auth_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Username validation & hidden email building', () {
    test('usernameToEmail builds email with the single constant domain', () {
      expect(usernameToEmail('john_doe'), 'john_doe@$kEmailDomain');
      expect(usernameToEmail('alice123'), 'alice123@$kEmailDomain');
      expect(kEmailDomain, 'biblestudy.invalid');
    });

    test('isValidUsername validates correctly', () {
      // Valid usernames
      expect(isValidUsername('abc'), isTrue);
      expect(isValidUsername('user_123'), isTrue);
      expect(isValidUsername('a_very_long_user_na'), isTrue); // 19 chars
      expect(isValidUsername('12345678901234567890'), isTrue); // 20 chars

      // Invalid usernames
      expect(isValidUsername('ab'), isFalse); // Too short (< 3)
      expect(isValidUsername('a_very_long_username_over_limit'), isFalse); // > 20
      expect(isValidUsername('User_Name'), isFalse); // Uppercase not allowed
      expect(isValidUsername('user name'), isFalse); // Spaces not allowed
      expect(isValidUsername('user@domain'), isFalse); // Special characters not allowed
      expect(isValidUsername('user!'), isFalse);
    });
  });

  group('FakeAuthRepository username authentication', () {
    late FakeAuthRepository authRepo;

    setUp(() {
      authRepo = FakeAuthRepository();
    });

    test('signup creates user document with role=member and mustChangePassword=false', () async {
      final user = await authRepo.signUp(
        name: 'Grace Hopper',
        username: 'grace_h',
        password: 'password123',
      );

      expect(user.name, 'Grace Hopper');
      expect(user.username, 'grace_h');
      expect(user.email, 'grace_h@biblestudy.invalid');
      expect(user.role, 'member');
      expect(user.mustChangePassword, isFalse);

      final current = await authRepo.getCurrentUser();
      expect(current?.uid, user.uid);
      expect(current?.username, 'grace_h');
      expect(current?.role, 'member');
    });

    test('duplicate signup with same username is rejected', () async {
      await authRepo.signUp(
        name: 'User One',
        username: 'duplicate_user',
        password: 'password123',
      );

      expect(
        () => authRepo.signUp(
          name: 'User Two',
          username: 'duplicate_user',
          password: 'password456',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Username already taken'),
        )),
      );
    });

    test('login with correct credentials succeeds', () async {
      authRepo.seedUser(
        name: 'David',
        username: 'david_king',
        password: 'securepassword',
      );

      final user = await authRepo.logIn(
        username: 'david_king',
        password: 'securepassword',
      );

      expect(user.username, 'david_king');
      expect(user.name, 'David');
      expect(authRepo.currentUserId, user.uid);
    });

    test('wrong login rejected: wrong username and wrong password yield identical message', () async {
      authRepo.seedUser(
        name: 'David',
        username: 'david_king',
        password: 'securepassword',
      );

      // Wrong username
      expect(
        () => authRepo.logIn(
          username: 'nonexistent',
          password: 'securepassword',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Incorrect username or password. Please try again.',
        )),
      );

      // Wrong password
      expect(
        () => authRepo.logIn(
          username: 'david_king',
          password: 'wrongpassword',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Incorrect username or password. Please try again.',
        )),
      );
    });

    test('forced password change flow', () async {
      // Leader resets password and marks mustChangePassword = true
      authRepo.seedUser(
        name: 'Martha',
        username: 'martha_b',
        password: 'tempPassword1',
        mustChangePassword: true,
      );

      final user = await authRepo.logIn(
        username: 'martha_b',
        password: 'tempPassword1',
      );
      expect(user.mustChangePassword, isTrue);

      final authState = AuthState(authRepository: authRepo);
      // Wait for AuthState to initialize
      await Future<void>.delayed(Duration.zero);
      expect(authState.mustChangePassword, isTrue);

      // User submits new password on forced change screen
      final success = await authState.completePasswordChange('newPassword123');
      expect(success, isTrue);
      expect(authState.mustChangePassword, isFalse);
      expect(authState.user?.mustChangePassword, isFalse);

      // Verify user can now log in with the new password
      await authRepo.logOut();
      final reLoggedIn = await authRepo.logIn(
        username: 'martha_b',
        password: 'newPassword123',
      );
      expect(reLoggedIn.mustChangePassword, isFalse);
    });

    test('profile update cannot change role or username', () async {
      authRepo.seedUser(
        name: 'Peter',
        username: 'peter_rock',
        password: 'password123',
        role: 'member',
      );

      await authRepo.logIn(
        username: 'peter_rock',
        password: 'password123',
      );

      final authState = AuthState(authRepository: authRepo);
      await Future<void>.delayed(Duration.zero);

      // Updating name succeeds
      final ok = await authState.updateName('Simon Peter');
      expect(ok, isTrue);
      expect(authState.user?.name, 'Simon Peter');
      expect(authState.user?.username, 'peter_rock');
      expect(authState.user?.role, 'member');

      // The app user model / repo provides no mechanism to elevate role to admin
      expect(authState.isAdmin, isFalse);
    });
  });

  group('AppUser model serialization', () {
    test('preserves username and mustChangePassword across toMap and fromMap', () {
      final now = DateTime(2026, 10, 31);
      final user = AppUser(
        uid: 'user_123',
        name: 'Test Member',
        email: 'testmember@biblestudy.invalid',
        username: 'testmember',
        role: 'member',
        createdAt: now,
        mustChangePassword: true,
      );

      final map = user.toMap();
      expect(map['username'], 'testmember');
      expect(map['mustChangePassword'], isTrue);

      final parsed = AppUser.fromMap('user_123', map);
      expect(parsed.uid, 'user_123');
      expect(parsed.name, 'Test Member');
      expect(parsed.username, 'testmember');
      expect(parsed.mustChangePassword, isTrue);
    });
  });
}
