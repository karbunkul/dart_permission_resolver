import 'dart:async';

import 'package:permission_resolver/permission_resolver.dart';
import 'package:test/test.dart';

typedef ResolverCallback = Future<bool> Function();

class TestContext {
  final bool isDev;
  final bool isDarkTheme;

  TestContext({required this.isDev, required this.isDarkTheme});
}

class DevelopmentPermission extends Permission<TestContext> {
  @override
  FutureOr<bool> request([TestContext? context]) => context?.isDev ?? false;
}

class DarkThemePermission extends Permission<TestContext> {
  @override
  FutureOr<bool> request([TestContext? context]) =>
      context?.isDarkTheme ?? false;
}

void main() {
  final ctxTrueTrue = TestContext(isDev: true, isDarkTheme: true);
  final ctxTrueFalse = TestContext(isDev: true, isDarkTheme: false);
  final ctxFalseFalse = TestContext(isDev: false, isDarkTheme: false);

  test('permission Reverse', () async {
    final dev = DevelopmentPermission();
    final reverseDev = Reverse(dev);

    expect(await dev.request(ctxTrueTrue), isTrue);
    expect(await reverseDev.request(ctxTrueTrue), isFalse);

    expect(await dev.request(ctxFalseFalse), isFalse);
    expect(await reverseDev.request(ctxFalseFalse), isTrue);
  });

  group('predicates', () {
    test('predicate Not', () async {
      final dev = DevelopmentPermission();
      final notDev = Not(dev);

      expect(await notDev.resolve(ctxTrueTrue), isFalse);
      expect(await notDev.resolve(ctxFalseFalse), isTrue);
    });

    test('predicate Every', () async {
      final every = Every([DevelopmentPermission(), DarkThemePermission()]);

      expect(await every.resolve(ctxTrueTrue), isTrue);
      expect(await every.resolve(ctxTrueFalse), isFalse);
      expect(await every.resolve(ctxFalseFalse), isFalse);
    });

    test('predicate Any', () async {
      final any = Any([DevelopmentPermission(), DarkThemePermission()]);

      expect(await any.resolve(ctxTrueTrue), isTrue);
      expect(await any.resolve(ctxTrueFalse), isTrue);
      expect(await any.resolve(ctxFalseFalse), isFalse);
    });

    test('predicate Single', () {
      final dev = DevelopmentPermission();
      final single = Single(dev);

      expect(single.permission, equals(dev));
    });
  });

  group('resolver instance', () {
    test('permission', () async {
      final resolver = PermissionResolver<TestContext>(ctxTrueFalse);

      expect(await resolver.permission(DevelopmentPermission()), isTrue);
      expect(await resolver.permission(DarkThemePermission()), isFalse);
    });

    test('every', () async {
      final resolverTrueTrue = PermissionResolver<TestContext>(ctxTrueTrue);
      final resolverTrueFalse = PermissionResolver<TestContext>(ctxTrueFalse);

      expect(await resolverTrueTrue.every([]), isTrue);
      expect(
        await resolverTrueTrue.every([
          DevelopmentPermission(),
          DarkThemePermission(),
        ]),
        isTrue,
      );
      expect(
        await resolverTrueFalse.every([
          DevelopmentPermission(),
          DarkThemePermission(),
        ]),
        isFalse,
      );
    });

    test('any', () async {
      final resolverTrueFalse = PermissionResolver<TestContext>(ctxTrueFalse);
      final resolverFalseFalse = PermissionResolver<TestContext>(ctxFalseFalse);

      expect(
        await resolverTrueFalse.any([
          DevelopmentPermission(),
          DarkThemePermission(),
        ]),
        isTrue,
      );
      expect(
        await resolverFalseFalse.any([
          DevelopmentPermission(),
          DarkThemePermission(),
        ]),
        isFalse,
      );
    });

    test('permissions directly without Single', () async {
      final resolver = PermissionResolver<TestContext>(ctxTrueFalse);

      final canAccess = await resolver.permissions(
        [
          DevelopmentPermission(),
          Reverse(DarkThemePermission()),
        ],
        mode: ControlMode.every,
      );

      expect(canAccess, isTrue);
    });
  });

  group('resolver static helpers', () {
    test('resolvePermission', () async {
      final isDev = await PermissionResolver.resolvePermission(
        context: ctxTrueFalse,
        permission: DevelopmentPermission(),
      );
      expect(isDev, isTrue);
    });

    test('resolveEvery', () async {
      final isEvery = await PermissionResolver.resolveEvery(
        context: ctxTrueTrue,
        predicates: [DevelopmentPermission(), DarkThemePermission()],
      );
      expect(isEvery, isTrue);
    });
  });
}
