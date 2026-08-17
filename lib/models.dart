/// Ilova ma'lumot modellari. Barcha kontent assets/content.json dan o'qiladi.

class TestQuestion {
  final String question;
  final List<String> options;
  final int answer;
  final int moduleId;

  TestQuestion({
    required this.question,
    required this.options,
    required this.answer,
    this.moduleId = 0,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> j) {
    return TestQuestion(
      question: (j['q'] ?? '').toString(),
      options: (j['o'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      answer: (j['a'] as num? ?? 0).toInt(),
      moduleId: (j['mod'] as num? ?? 0).toInt(),
    );
  }
}

class ContentSection {
  final String heading;
  final String body;

  ContentSection({required this.heading, required this.body});

  factory ContentSection.fromJson(Map<String, dynamic> j) => ContentSection(
        heading: (j['h'] ?? '').toString(),
        body: (j['b'] ?? '').toString(),
      );
}

class ProtocolField {
  final String key;
  final String label;
  final String unit;

  ProtocolField({required this.key, required this.label, required this.unit});

  factory ProtocolField.fromJson(Map<String, dynamic> j) => ProtocolField(
        key: (j['k'] ?? '').toString(),
        label: (j['label'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
      );
}

class LabProtocol {
  final String formulaId;
  final String title;
  final String description;
  final List<ProtocolField> fields;
  final String resultLabel;
  final String resultUnit;
  final String norm;

  LabProtocol({
    required this.formulaId,
    required this.title,
    required this.description,
    required this.fields,
    required this.resultLabel,
    required this.resultUnit,
    required this.norm,
  });

  factory LabProtocol.fromJson(Map<String, dynamic> j) => LabProtocol(
        formulaId: (j['formulaId'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        description: (j['desc'] ?? '').toString(),
        fields: (j['fields'] as List<dynamic>? ?? const [])
            .map((e) => ProtocolField.fromJson(e as Map<String, dynamic>))
            .toList(),
        resultLabel: (j['resultLabel'] ?? 'Natija').toString(),
        resultUnit: (j['resultUnit'] ?? '').toString(),
        norm: (j['norm'] ?? '').toString(),
      );
}

class InteractiveTask {
  final String type; // 'order' | 'tf'
  final String title;
  final String prompt;
  final List<String> orderItems;
  final List<TfItem> tfItems;

  InteractiveTask({
    required this.type,
    required this.title,
    required this.prompt,
    required this.orderItems,
    required this.tfItems,
  });

  factory InteractiveTask.fromJson(Map<String, dynamic> j) {
    final type = (j['type'] ?? '').toString();
    final raw = j['items'] as List<dynamic>? ?? const [];
    return InteractiveTask(
      type: type,
      title: (j['title'] ?? '').toString(),
      prompt: (j['prompt'] ?? '').toString(),
      orderItems:
          type == 'order' ? raw.map((e) => e.toString()).toList() : const [],
      tfItems: type == 'tf'
          ? raw
              .map((e) => TfItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}

class TfItem {
  final String text;
  final bool answer;
  TfItem({required this.text, required this.answer});

  factory TfItem.fromJson(Map<String, dynamic> j) => TfItem(
        text: (j['t'] ?? '').toString(),
        answer: j['a'] == true,
      );
}

/// Virtual laboratoriya — uch xil ssenariy: choice_chain, organoleptik, sort.
class VirtualLab {
  final String type;
  final String title;
  final String intro;
  final List<VLabStep> steps; // choice_chain
  final List<VLabSample> samples; // organoleptik
  final List<String> sampleOptions; // organoleptik
  final List<String> groups; // sort
  final List<VLabItem> items; // sort

  VirtualLab({
    required this.type,
    required this.title,
    required this.intro,
    required this.steps,
    required this.samples,
    required this.sampleOptions,
    required this.groups,
    required this.items,
  });

  factory VirtualLab.fromJson(Map<String, dynamic> j) => VirtualLab(
        type: (j['type'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        intro: (j['intro'] ?? '').toString(),
        steps: (j['steps'] as List<dynamic>? ?? const [])
            .map((e) => VLabStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        samples: (j['samples'] as List<dynamic>? ?? const [])
            .map((e) => VLabSample.fromJson(e as Map<String, dynamic>))
            .toList(),
        sampleOptions: (j['options'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        groups: (j['groups'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        items: (j['items'] as List<dynamic>? ?? const [])
            .map((e) => VLabItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  int get taskCount {
    if (type == 'choice_chain') return steps.length;
    if (type == 'organoleptik') return samples.length;
    if (type == 'sort') return items.length;
    return 0;
  }
}

class VLabStep {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  VLabStep({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory VLabStep.fromJson(Map<String, dynamic> j) => VLabStep(
        question: (j['q'] ?? '').toString(),
        options: (j['o'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        answer: (j['a'] as num? ?? 0).toInt(),
        explanation: (j['exp'] ?? '').toString(),
      );
}

class VLabSample {
  final String name;
  final String rang;
  final String hid;
  final String tam;
  final int answer;
  final String explanation;

  VLabSample({
    required this.name,
    required this.rang,
    required this.hid,
    required this.tam,
    required this.answer,
    required this.explanation,
  });

  factory VLabSample.fromJson(Map<String, dynamic> j) => VLabSample(
        name: (j['name'] ?? '').toString(),
        rang: (j['rang'] ?? '').toString(),
        hid: (j['hid'] ?? '').toString(),
        tam: (j['tam'] ?? '').toString(),
        answer: (j['a'] as num? ?? 0).toInt(),
        explanation: (j['exp'] ?? '').toString(),
      );
}

class VLabItem {
  final String text;
  final int group;
  VLabItem({required this.text, required this.group});

  factory VLabItem.fromJson(Map<String, dynamic> j) => VLabItem(
        text: (j['t'] ?? '').toString(),
        group: (j['g'] as num? ?? 0).toInt(),
      );
}

class LearningModule {
  final int id;
  final String title;
  final String short;
  final String block;
  final int level; // 1 - boshlang'ich, 2 - o'rta, 3 - yuqori
  final List<ContentSection> sections;
  final List<TestQuestion> tests;
  final List<String> control;
  final List<InteractiveTask> interactive;
  final LabProtocol? protocol;
  final VirtualLab? vlab;

  LearningModule({
    required this.id,
    required this.title,
    required this.short,
    required this.block,
    required this.level,
    required this.sections,
    required this.tests,
    required this.control,
    required this.interactive,
    this.protocol,
    this.vlab,
  });

  factory LearningModule.fromJson(Map<String, dynamic> j) => LearningModule(
        id: (j['id'] as num).toInt(),
        title: (j['title'] ?? '').toString(),
        short: (j['short'] ?? '').toString(),
        block: (j['block'] ?? '').toString(),
        level: (j['level'] as num? ?? 1).toInt(),
        sections: (j['sections'] as List<dynamic>? ?? const [])
            .map((e) => ContentSection.fromJson(e as Map<String, dynamic>))
            .toList(),
        tests: (j['tests'] as List<dynamic>? ?? const [])
            .map((e) => TestQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        control: (j['control'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        interactive: (j['interactive'] as List<dynamic>? ?? const [])
            .map((e) => InteractiveTask.fromJson(e as Map<String, dynamic>))
            .toList(),
        protocol: j['protocol'] == null
            ? null
            : LabProtocol.fromJson(j['protocol'] as Map<String, dynamic>),
        vlab: j['vlab'] == null
            ? null
            : VirtualLab.fromJson(j['vlab'] as Map<String, dynamic>),
      );

  /// Modul ichidagi bosqichlar ro'yxati (traektoriya uchun).
  List<String> get stageKeys {
    final s = <String>['theory'];
    if (interactive.isNotEmpty) s.add('interactive');
    if (vlab != null) s.add('vlab');
    if (protocol != null) s.add('protocol');
    if (tests.isNotEmpty) s.add('test');
    return s;
  }
}

class AppContent {
  final String title;
  final String subtitle;
  final String source;
  final List<TestQuestion> diagnostic;
  final List<LearningModule> modules;

  AppContent({
    required this.title,
    required this.subtitle,
    required this.source,
    required this.diagnostic,
    required this.modules,
  });

  factory AppContent.fromJson(Map<String, dynamic> j) => AppContent(
        title: (j['title'] ?? '').toString(),
        subtitle: (j['subtitle'] ?? '').toString(),
        source: (j['source'] ?? '').toString(),
        diagnostic: (j['diagnostic'] as List<dynamic>? ?? const [])
            .map((e) => TestQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        modules: (j['modules'] as List<dynamic>? ?? const [])
            .map((e) => LearningModule.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  LearningModule? moduleById(int id) {
    for (final m in modules) {
      if (m.id == id) return m;
    }
    return null;
  }
}
