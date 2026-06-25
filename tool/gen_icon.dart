// Generates the app icon (shield + keyhole) as PNGs for flutter_launcher_icons.
// Run: dart run tool/gen_icon.dart
//   -> assets/icon/icon.png       (1024, indigo bg + white shield + indigo keyhole)
//   -> assets/icon/foreground.png (1024, transparent + white shield, keyhole punched)

import 'dart:io';
import 'package:image/image.dart' as img;

const int size = 1024;
final indigo = img.ColorRgba8(63, 81, 181, 255); // #3F51B5
final white = img.ColorRgba8(255, 255, 255, 255);
final transparent = img.ColorRgba8(0, 0, 0, 0);

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // --- Legacy / full-bleed icon: indigo bg, white shield, indigo keyhole ---
  final icon = img.Image(width: size, height: size, numChannels: 4);
  img.fill(icon, color: indigo);
  _drawShield(icon, inset: 210, shield: white, keyhole: indigo);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(icon));

  // --- Adaptive foreground: transparent bg, white shield, transparent keyhole ---
  final fg = img.Image(width: size, height: size, numChannels: 4);
  // (already transparent)
  _drawShield(fg, inset: 300, shield: white, keyhole: transparent);
  File('assets/icon/foreground.png').writeAsBytesSync(img.encodePng(fg));

  // --- Windows tray icon (.ico, 256px downscaled set) ---
  final ico = img.copyResize(icon, width: 256, height: 256);
  File('assets/icon/app_icon.ico').writeAsBytesSync(img.encodeIco(ico));

  stdout.writeln(
      'Wrote assets/icon/icon.png, foreground.png, app_icon.ico');
}

void _drawShield(
  img.Image dst, {
  required double inset,
  required img.Color shield,
  required img.Color keyhole,
}) {
  final left = inset;
  final right = size - inset;
  final top = inset;
  final bottom = size - inset;
  final cx = (left + right) / 2;
  final w = right - left;
  final h = bottom - top;
  final midY = top + h * 0.45;

  // Shield body (pentagon: flat top, shoulders, taper to bottom point).
  img.fillPolygon(
    dst,
    vertices: [
      img.Point(left, top),
      img.Point(right, top),
      img.Point(right, midY),
      img.Point(cx, bottom),
      img.Point(left, midY),
    ],
    color: shield,
  );

  // Keyhole: circle + tapered stem, in the shield's upper-middle.
  final kcy = top + h * 0.40;
  final kr = w * 0.13;
  img.fillCircle(dst, x: cx.round(), y: kcy.round(), radius: kr.round(), color: keyhole);
  final stemTop = kcy + kr * 0.4;
  final stemBot = top + h * 0.66;
  img.fillPolygon(
    dst,
    vertices: [
      img.Point(cx - kr * 0.5, stemTop),
      img.Point(cx + kr * 0.5, stemTop),
      img.Point(cx + kr * 0.85, stemBot),
      img.Point(cx - kr * 0.85, stemBot),
    ],
    color: keyhole,
  );
}
