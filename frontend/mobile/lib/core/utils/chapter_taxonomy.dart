import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

/// Parses bundled assets/chapters.yaml into a flat subject → chapters map
/// (order preserved, dedupped across paper_1/paper_2 splits).
class ChapterTaxonomy {
  final Map<String, List<String>> _flat;

  const ChapterTaxonomy._(this._flat);

  static Future<ChapterTaxonomy> load() async {
    final raw = await rootBundle.loadString('assets/chapters.yaml');
    final doc = loadYaml(raw);
    final Map<String, List<String>> out = {};
    if (doc is YamlMap) {
      for (final entry in doc.entries) {
        final subject = entry.key as String;
        final value = entry.value;
        final seen = <String>{};
        final chapters = <String>[];
        if (value is YamlList) {
          for (final c in value) {
            final s = c.toString();
            if (seen.add(s)) chapters.add(s);
          }
        } else if (value is YamlMap) {
          for (final paperEntry in value.entries) {
            final paperList = paperEntry.value;
            if (paperList is YamlList) {
              for (final c in paperList) {
                final s = c.toString();
                if (seen.add(s)) chapters.add(s);
              }
            }
          }
        }
        out[subject] = chapters;
      }
    }
    return ChapterTaxonomy._(out);
  }

  List<String> get subjects => _flat.keys.toList(growable: false);

  List<String> chaptersOf(String subject) => _flat[subject] ?? const <String>[];

  bool isValid(String subject, String chapter) =>
      _flat[subject]?.contains(chapter) ?? false;
}
