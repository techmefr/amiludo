import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';

extension DieFaceOps on DieDesign {
  DieDesign withFace(int index, DieFaceContent face) => copyWith(
    faces: [
      for (var i = 0; i < faces.length; i++) i == index ? face : faces[i],
    ],
  );

  DieDesign numbered(int from, int to, {int start = 1}) => copyWith(
    faces: [
      for (var i = 0; i < faces.length; i++)
        i >= from && i <= to
            ? DieFaceContent(value: '${start + i - from}', color: faces[i].color)
            : faces[i],
    ],
  );

  DieDesign filled(int from, int to, DieFaceContent face) => copyWith(
    faces: [
      for (var i = 0; i < faces.length; i++)
        i >= from && i <= to ? face : faces[i],
    ],
  );

  DieDesign duplicated(int index) {
    if (faces.length >= maxDieFaces) return this;
    return copyWith(faces: [...faces]..insert(index + 1, faces[index]));
  }

  DieDesign removedFace(int index) {
    if (faces.length <= minDieFaces) return this;
    return copyWith(faces: [...faces]..removeAt(index));
  }

  DieDesign moved(int from, int to) {
    if (from < 0 || from >= faces.length || to < 0 || to >= faces.length) {
      return this;
    }
    final next = [...faces];
    next.insert(to, next.removeAt(from));
    return copyWith(faces: next);
  }
}
