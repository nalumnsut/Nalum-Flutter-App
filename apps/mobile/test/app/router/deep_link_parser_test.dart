import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_app/app/router/deep_link_parser.dart';

void main() {
  const hosts = {'alumni.nsut.ac.in'};
  String? parse(String link) =>
      appLocationForLink(Uri.parse(link), trustedHosts: hosts);

  test('maps website dashboard URLs to app routes', () {
    const base = 'https://alumni.nsut.ac.in';
    expect(parse('$base/dashboard'), '/home');
    expect(parse('$base/dashboard/alumni'), '/directory');
    expect(parse('$base/dashboard/alumni?tab=my'), '/connections');
    expect(parse('$base/dashboard/alumni/65f0a1'), '/directory/65f0a1');
    expect(parse('$base/dashboard/chat/c1'), '/chat/c1');
    expect(parse('$base/dashboard/posts/p1'), '/posts/p1');
    expect(parse('$base/dashboard/posts/p1/edit'), '/posts/p1/edit');
    expect(parse('$base/dashboard/my-posts'), '/posts?tab=my');
    expect(parse('$base/dashboard/events/e1'), '/events/e1');
    expect(parse('$base/dashboard/host-event'), '/events/new');
    expect(parse('$base/dashboard/change-password'), '/settings/password');
    expect(parse('$base/map'), '/map');
  });

  test('passes app paths through (push payload routes)', () {
    expect(parse('/chat/c1'), '/chat/c1');
    expect(parse('/events'), '/events');
  });

  test('rejects untrusted hosts and other schemes', () {
    expect(parse('https://evil.example/dashboard/chat/c1'), isNull);
    expect(parse('javascript:alert(1)'), isNull);
    expect(parse('nalum://chat/c1'), isNull);
  });

  test('rejects odd segments instead of routing them', () {
    expect(parse('/chat/..%2F..%2Fsettings'), isNull);
    expect(parse('/posts/${'a' * 65}'), isNull);
  });

  test('leaves unknown website pages to the browser', () {
    expect(parse('https://alumni.nsut.ac.in/stories/campus-news'), isNull);
    expect(parse('https://alumni.nsut.ac.in/dashboard/unknown'), isNull);
  });
}
