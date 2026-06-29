// تطبيق "حارس" — نظام الإبلاغ عن حوادث السلامة المهنية
// مشروع تخرّج — هندسة السلامة المهنية
// ملف واحد قابل للتشغيل مباشرة. استبدل به محتوى lib/main.dart

import 'package:flutter/material.dart';

void main() => runApp(const HarithApp());

/* ============================ الألوان ============================ */
const cBg = Color(0xFFF4F5F2);
const cInk = Color(0xFF16181E);
const cAmber = Color(0xFFF2B600);
const cBorder = Color(0xFFE6E7E3);
const cMuted = Color(0xFF6B6F78);

/* ============================ نظام المخاطر ============================ */
const probLabels = ['', 'نادر', 'غير محتمل', 'ممكن', 'محتمل', 'شبه مؤكد'];
const sevLabels = ['', 'ضئيل', 'طفيف', 'متوسط', 'كبير', 'كارثي'];

class RiskInfo {
  final int score;
  final String level;
  final Color color;
  RiskInfo(this.score, this.level, this.color);
}

RiskInfo computeRisk(int p, int s) {
  final score = p * s;
  if (score >= 17) return RiskInfo(score, 'حرج', const Color(0xFFD6332B));
  if (score >= 10) return RiskInfo(score, 'عالي', const Color(0xFFEA6A1E));
  if (score >= 5) return RiskInfo(score, 'متوسط', const Color(0xFFF2B600));
  return RiskInfo(score, 'منخفض', const Color(0xFF1F9D55));
}

const incidentTypes = [
  'سقوط من ارتفاع',
  'انزلاق وتعثّر',
  'إصابة بآلة أو معدة',
  'سقوط أجسام',
  'صدمة كهربائية',
  'تسرّب مواد كيميائية',
  'حريق',
  'مركبات ومعدات ثقيلة',
  'حادث وشيك (Near Miss)',
];

Color statusColor(String s) {
  switch (s) {
    case 'جديد':
      return const Color(0xFFD6332B);
    case 'قيد المعالجة':
      return const Color(0xFFEA6A1E);
    default:
      return const Color(0xFF1F9D55);
  }
}

/* ============================ النموذج ============================ */
class Incident {
  String type, location, description, action, reporter, status, owner;
  DateTime datetime;
  int probability, severity, injuries, photos;
  DateTime? due;

  Incident({
    required this.type,
    required this.location,
    required this.datetime,
    required this.description,
    this.action = '',
    this.reporter = '',
    this.status = 'جديد',
    this.owner = '',
    this.probability = 1,
    this.severity = 1,
    this.injuries = 0,
    this.photos = 0,
    this.due,
  });

  RiskInfo get risk => computeRisk(probability, severity);
}

/* ============================ المخزن ============================ */
class IncidentStore extends ChangeNotifier {
  final List<Incident> items = [];

  void add(Incident i) {
    items.insert(0, i);
    notifyListeners();
  }

  void update() => notifyListeners();

  void seed() {
    final d = [
      ['سقوط من ارتفاع', 'موقع البرج A — الطابق 6', DateTime(2026, 6, 22, 9, 15), 4, 5, 'جديد', 1, 'سقط عامل أثناء العمل على السقالة بسبب عدم تثبيت حزام الأمان.', 'إخلاء العامل ونقله للعيادة وإيقاف العمل.', 'أحمد العتيبي'],
      ['تسرّب مواد كيميائية', 'مستودع الكيماويات — القسم 3', DateTime(2026, 6, 18, 14, 40), 4, 4, 'قيد المعالجة', 0, 'تسرّب من برميل مذيبات بسبب تلف الصمام.', 'عزل المنطقة واستخدام مواد الامتصاص.', 'محمد القحطاني'],
      ['انزلاق وتعثّر', 'ممر الإنتاج الرئيسي', DateTime(2026, 6, 10, 11, 5), 2, 3, 'مغلق', 1, 'انزلاق عامل بسبب زيت على الأرضية.', 'تنظيف فوري ووضع لافتة تحذير.', 'سعد الدوسري'],
      ['صدمة كهربائية', 'غرفة اللوحات الكهربائية', DateTime(2026, 5, 28, 8, 20), 3, 5, 'قيد المعالجة', 1, 'ملامسة لوحة غير معزولة أثناء الصيانة.', 'فصل التيار وإسعاف العامل.', 'فهد الشمري'],
      ['حادث وشيك (Near Miss)', 'ساحة المناولة', DateTime(2026, 5, 15, 16, 30), 4, 2, 'مغلق', 0, 'كاد جسم يسقط من الرافعة على عامل.', 'إعادة تثبيت الحمولة ومراجعة الإجراءات.', 'ناصر الحربي'],
      ['مركبات ومعدات ثقيلة', 'بوابة الشحن', DateTime(2026, 4, 25, 10, 0), 4, 5, 'جديد', 2, 'اصطدام رافعة شوكية بعامل في منطقة غير محددة المسارات.', 'تحديد مسارات المشاة وإيقاف المعدة.', 'عبدالله المالكي'],
      ['إصابة بآلة أو معدة', 'خط التجميع رقم 2', DateTime(2026, 4, 12, 9, 45), 3, 4, 'مغلق', 1, 'انحشار يد عامل في آلة بدون حاجز وقائي.', 'إيقاف الآلة وتركيب حواجز.', 'تركي العنزي'],
      ['حريق', 'مستودع المواد القابلة للاشتعال', DateTime(2026, 3, 30, 19, 20), 2, 5, 'مغلق', 0, 'اشتعال محدود بسبب تماس كهربائي.', 'إخماد فوري بالطفايات وإخلاء.', 'ماجد البقمي'],
    ];
    for (final r in d) {
      items.add(Incident(
        type: r[0] as String,
        location: r[1] as String,
        datetime: r[2] as DateTime,
        probability: r[3] as int,
        severity: r[4] as int,
        status: r[5] as String,
        injuries: r[6] as int,
        description: r[7] as String,
        action: r[8] as String,
        reporter: r[9] as String,
      ));
    }
  }
}

final store = IncidentStore()..seed();

/* ============================ التطبيق ============================ */
class HarithApp extends StatelessWidget {
  const HarithApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حارس',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cBg,
        colorScheme: ColorScheme.fromSeed(seedColor: cAmber, primary: cInk),
        fontFamily: 'Roboto',
      ),
      // فرض اتجاه RTL على كامل التطبيق
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int idx = 0;

  void goTo(int i) => setState(() => idx = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreen(),
      ReportScreen(onDone: () => goTo(2)),
      const IncidentsScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[idx]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: cInk,
          indicatorColor: cAmber,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: goTo,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.dashboard, color: cInk),
                label: 'لوحة المعلومات'),
            NavigationDestination(
                icon: Icon(Icons.add_circle_outline, color: Colors.white70),
                selectedIcon: Icon(Icons.add_circle, color: cInk),
                label: 'بلاغ جديد'),
            NavigationDestination(
                icon: Icon(Icons.list_alt_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.list_alt, color: cInk),
                label: 'البلاغات'),
          ],
        ),
      ),
    );
  }
}

/* ============================ لوحة المعلومات ============================ */
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final items = store.items;
        final total = items.length;
        final open = items.where((x) => x.status != 'مغلق').length;
        final critical = items.where((x) => x.risk.level == 'حرج').length;
        final injuries = items.fold<int>(0, (a, x) => a + x.injuries);

        // عدّ حسب النوع
        final byType = <String, int>{};
        for (final x in items) {
          byType[x.type] = (byType[x.type] ?? 0) + 1;
        }
        final typeEntries = byType.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final maxType =
            typeEntries.isEmpty ? 1 : typeEntries.first.value;

        // عدّ حسب المستوى
        final levels = {'منخفض': 0, 'متوسط': 0, 'عالي': 0, 'حرج': 0};
        for (final x in items) {
          levels[x.risk.level] = levels[x.risk.level]! + 1;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Head('لوحة المعلومات', 'نظرة عامة على أداء السلامة'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _StatCard('إجمالي البلاغات', '$total', Icons.assignment, const Color(0xFF2B6CB0))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard('بلاغات مفتوحة', '$open', Icons.schedule, const Color(0xFFEA6A1E))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatCard('مخاطر حرجة', '$critical', Icons.gpp_maybe, const Color(0xFFD6332B))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard('إجمالي الإصابات', '$injuries', Icons.warning_amber, const Color(0xFFB7791F))),
            ]),
            const SizedBox(height: 16),
            _Card(
              title: 'البلاغات حسب النوع',
              child: Column(
                children: typeEntries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      SizedBox(
                          width: 130,
                          child: Text(e.key,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis)),
                      Expanded(
                        child: Container(
                          height: 18,
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: e.value / maxType,
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: cInk,
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${e.value}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ]),
                  );
                }).toList(),
              ),
            ),
            _Card(
              title: 'توزيع مستوى الخطورة',
              child: Column(
                children: levels.entries.map((e) {
                  final c = computeRisk(
                          e.key == 'حرج'
                              ? 5
                              : e.key == 'عالي'
                                  ? 3
                                  : e.key == 'متوسط'
                                      ? 2
                                      : 1,
                          e.key == 'حرج'
                              ? 5
                              : e.key == 'عالي'
                                  ? 4
                                  : e.key == 'متوسط'
                                      ? 3
                                      : 1)
                      .color;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                            color: c, borderRadius: BorderRadius.circular(4))),
                    title: Text(e.key, style: const TextStyle(fontSize: 13.5)),
                    trailing: Text('${e.value}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* ============================ نموذج بلاغ جديد ============================ */
class ReportScreen extends StatefulWidget {
  final VoidCallback onDone;
  const ReportScreen({super.key, required this.onDone});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _form = GlobalKey<FormState>();
  String? type;
  final loc = TextEditingController();
  final desc = TextEditingController();
  final action = TextEditingController();
  final reporter = TextEditingController();
  final injuries = TextEditingController(text: '0');
  DateTime when = DateTime.now();
  int p = 0, s = 0;
  int photos = 0;

  @override
  void dispose() {
    loc.dispose();
    desc.dispose();
    action.dispose();
    reporter.dispose();
    injuries.dispose();
    super.dispose();
  }

  void submit() {
    final ok = _form.currentState!.validate();
    if (type == null || p == 0 || s == 0 || !ok) {
      if (p == 0 || s == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('حدّد مستوى الخطورة من المصفوفة')));
      }
      setState(() {});
      return;
    }
    store.add(Incident(
      type: type!,
      location: loc.text,
      datetime: when,
      description: desc.text,
      action: action.text,
      reporter: reporter.text,
      injuries: int.tryParse(injuries.text) ?? 0,
      probability: p,
      severity: s,
      photos: photos,
    ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: cInk, content: Text('تم إرسال البلاغ بنجاح')));
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final r = (p > 0 && s > 0) ? computeRisk(p, s) : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _Head('بلاغ حادث جديد', 'عبّئ تفاصيل الحادث بدقّة'),
        const SizedBox(height: 16),
        Form(
          key: _form,
          child: _Card(
            title: 'معلومات الحادث',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: _dec('نوع الحادث *'),
                items: incidentTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => type = v),
                validator: (v) => v == null ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: loc,
                decoration: _dec('الموقع *', icon: Icons.place_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: when,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030));
                  if (d == null) return;
                  if (!context.mounted) return;
                  final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(when));
                  setState(() => when = DateTime(
                      d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0));
                },
                child: InputDecorator(
                  decoration: _dec('التاريخ والوقت',
                      icon: Icons.event_outlined),
                  child: Text(fmtDate(when)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: desc,
                maxLines: 3,
                decoration: _dec('وصف الحادث *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: injuries,
                    keyboardType: TextInputType.number,
                    decoration: _dec('عدد المصابين'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: reporter,
                    decoration: _dec('اسم المُبلِّغ'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: action,
                maxLines: 2,
                decoration: _dec('الإجراء الفوري المتّخذ'),
              ),
            ]),
          ),
        ),
        _Card(
          title: 'تقييم المخاطر',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('اختر خانة من المصفوفة لتحديد الاحتمالية والشدّة',
                style: TextStyle(fontSize: 12, color: cMuted)),
            const SizedBox(height: 10),
            RiskMatrix(
                p: p,
                s: s,
                onPick: (np, ns) => setState(() {
                      p = np;
                      s = ns;
                    })),
            if (r != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: r.color.withOpacity(0.08),
                  border: Border.all(color: r.color),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('مستوى الخطورة',
                            style: TextStyle(fontSize: 12, color: cMuted)),
                        Text(r.level,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: r.color)),
                      ]),
                      Text('الدرجة: ${r.score}',
                          style: const TextStyle(fontSize: 14)),
                    ]),
              ),
            ],
          ]),
        ),
        _Card(
          title: 'المرفقات (صور)',
          child: Column(children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => photos++),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(photos == 0 ? 'إرفاق صورة' : 'أُرفقت $photos صورة'),
            ),
            const SizedBox(height: 4),
            const Text('(النسخة الأساسية تجريبية — لالتقاط صور حقيقية أضف حزمة image_picker)',
                style: TextStyle(fontSize: 11, color: cMuted)),
          ]),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
              backgroundColor: cInk,
              padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: submit,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('إرسال البلاغ', style: TextStyle(fontSize: 15)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/* مصفوفة المخاطر التفاعلية */
class RiskMatrix extends StatelessWidget {
  final int p, s;
  final void Function(int, int) onPick;
  const RiskMatrix({super.key, required this.p, required this.s, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final sv in [5, 4, 3, 2, 1])
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            SizedBox(
                width: 52,
                child: Text(sevLabels[sv],
                    style: const TextStyle(fontSize: 10, color: cMuted),
                    textAlign: TextAlign.center)),
            for (final pr in [1, 2, 3, 4, 5])
              Expanded(child: _cell(pr, sv)),
          ]),
        ),
      Row(children: [
        const SizedBox(width: 52),
        for (final pr in [1, 2, 3, 4, 5])
          Expanded(
              child: Text(probLabels[pr],
                  style: const TextStyle(fontSize: 9, color: cMuted),
                  textAlign: TextAlign.center)),
      ]),
    ]);
  }

  Widget _cell(int pr, int sv) {
    final r = computeRisk(pr, sv);
    final on = p == pr && s == sv;
    return GestureDetector(
      onTap: () => onPick(pr, sv),
      child: Container(
        height: 38,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? r.color : r.color.withOpacity(0.22),
          border: Border.all(color: r.color, width: 1.4),
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Text('${r.score}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: on ? Colors.white : r.color)),
      ),
    );
  }
}

/* ============================ سجلّ البلاغات ============================ */
class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});
  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  String fStatus = 'الكل';
  String q = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final rows = store.items.where((x) {
          if (fStatus != 'الكل' && x.status != fStatus) return false;
          if (q.isNotEmpty && !('${x.type} ${x.location}').contains(q)) {
            return false;
          }
          return true;
        }).toList();

        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Head('سجلّ البلاغات', '${rows.length} بلاغ'),
              const SizedBox(height: 12),
              TextField(
                decoration: _dec('بحث بالنوع أو الموقع…',
                    icon: Icons.search),
                onChanged: (v) => setState(() => q = v),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                for (final st in ['الكل', 'جديد', 'قيد المعالجة', 'مغلق'])
                  ChoiceChip(
                    label: Text(st),
                    selected: fStatus == st,
                    onSelected: (_) => setState(() => fStatus = st),
                  ),
              ]),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _IncidentTile(rows[i]),
            ),
          ),
        ]);
      },
    );
  }
}

class _IncidentTile extends StatelessWidget {
  final Incident inc;
  const _IncidentTile(this.inc);

  @override
  Widget build(BuildContext context) {
    final r = inc.risk;
    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(inc: inc))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: cBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            Container(width: 5, color: r.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                        child: Text(inc.type,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15))),
                    _chip(inc.status, statusColor(inc.status)),
                  ]),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 14, color: cMuted),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(inc.location,
                            style: const TextStyle(
                                fontSize: 12.5, color: cMuted))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _chip(r.level, r.color),
                    const Spacer(),
                    Text(fmtDate(inc.datetime),
                        style: const TextStyle(fontSize: 11, color: cMuted)),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/* ============================ تفاصيل البلاغ ============================ */
class DetailScreen extends StatefulWidget {
  final Incident inc;
  const DetailScreen({super.key, required this.inc});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final owner = TextEditingController(text: widget.inc.owner);
  late final corr = TextEditingController();

  void setStatus(String st) {
    widget.inc.status = st;
    widget.inc.owner = owner.text;
    store.update();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final inc = widget.inc;
    final r = inc.risk;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(inc.type),
        foregroundColor: cInk,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          _chip('${r.level} · ${r.score}', r.color),
          const SizedBox(width: 8),
          _chip(inc.status, statusColor(inc.status)),
        ]),
        const SizedBox(height: 16),
        _row('الموقع', inc.location),
        _row('التاريخ والوقت', fmtDate(inc.datetime)),
        _row('المُبلِّغ', inc.reporter.isEmpty ? '—' : inc.reporter),
        _row('عدد المصابين', '${inc.injuries}'),
        const SizedBox(height: 14),
        const _Label('وصف الحادث'),
        Text(inc.description, style: const TextStyle(height: 1.7)),
        if (inc.action.isNotEmpty) ...[
          const SizedBox(height: 12),
          const _Label('الإجراء الفوري'),
          Text(inc.action, style: const TextStyle(height: 1.7)),
        ],
        const Divider(height: 32),
        const _Label('الإجراء التصحيحي والمتابعة'),
        const SizedBox(height: 8),
        TextField(
            controller: owner,
            decoration: _dec('المسؤول عن التنفيذ')),
        const SizedBox(height: 12),
        TextField(
            controller: corr,
            maxLines: 2,
            decoration: _dec('الإجراء التصحيحي المطلوب')),
        const SizedBox(height: 20),
        Row(children: [
          if (inc.status != 'قيد المعالجة')
            Expanded(
              child: OutlinedButton(
                onPressed: () => setStatus('قيد المعالجة'),
                child: const Text('بدء المعالجة'),
              ),
            ),
          if (inc.status != 'قيد المعالجة') const SizedBox(width: 10),
          if (inc.status != 'مغلق')
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: cInk),
                onPressed: () => setStatus('مغلق'),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('إغلاق البلاغ'),
              ),
            ),
        ]),
        const SizedBox(height: 20),
      ]),
    );
  }
}

/* ============================ مكوّنات مساعدة ============================ */
String fmtDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}/${two(d.month)}/${two(d.day)} · ${two(d.hour)}:${two(d.minute)}';
}

InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: cBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: cBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: cAmber, width: 2)),
    );

Widget _chip(String text, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: c, fontWeight: FontWeight.bold, fontSize: 11.5)),
    );

Widget _row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: cMuted, fontSize: 13.5)),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
    );

class _Head extends StatelessWidget {
  final String title, sub;
  const _Head(this.title, this.sub);
  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(sub, style: const TextStyle(color: cMuted, fontSize: 13.5)),
      ]);
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cMuted,
                letterSpacing: 0.5)),
      );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color tone;
  const _StatCard(this.label, this.value, this.icon, this.tone);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: cBorder),
            borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: tone.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: tone, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(label,
                      style: const TextStyle(fontSize: 12, color: cMuted),
                      overflow: TextOverflow.ellipsis),
                ]),
          ),
        ]),
      );
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: cBorder),
            borderRadius: BorderRadius.circular(13)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          child,
        ]),
      );
}
