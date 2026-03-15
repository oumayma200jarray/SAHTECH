import 'package:flutter/material.dart';
import 'package:sahtek/widgets/buttons.dart';
import 'package:easy_localization/easy_localization.dart';

class ScoreConstantPage extends StatefulWidget {
  const ScoreConstantPage({Key? key}) : super(key: key);

  @override
  State<ScoreConstantPage> createState() => _ScoreConstantPageState();
}

class _ScoreConstantPageState extends State<ScoreConstantPage> {
  int? _douleurScore;

  // Section 2: Activité
  final Map<String, int> _activiteSelections = {};
  int? _positionMainScore;

  // Section 3: Mobilités
  int? _elevationAntScore;

  int _forceScore = 0;

  int get _activiteNiveauScore =>
      _activiteSelections.values.fold(0, (sum, pts) => sum + pts);

  int get _totalScore {
    int total = 0;
    total += _douleurScore ?? 0;
    total += _activiteNiveauScore;
    total += _positionMainScore ?? 0;
    total += _elevationAntScore ?? 0;
    total += _forceScore;
    return total;
  }

  void _resetAll() {
    setState(() {
      _douleurScore = null;
      _activiteSelections.clear();
      _positionMainScore = null;
      _elevationAntScore = null;
      _forceScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'constant_score_title'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'total_score_label'.tr(
                  namedArgs: {'score': _totalScore.toString()},
                ),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSection(
              title: 'douleur_section_title'.tr(),
              icon: Icons.personal_injury_outlined,
              children: [
                _buildRadioTile(
                  'no_pain'.tr(),
                  15,
                  _douleurScore,
                  (v) => setState(() => _douleurScore = v),
                ),
                _buildRadioTile(
                  'slight_pain'.tr(),
                  10,
                  _douleurScore,
                  (v) => setState(() => _douleurScore = v),
                ),
                _buildRadioTile(
                  'moderate_pain'.tr(),
                  5,
                  _douleurScore,
                  (v) => setState(() => _douleurScore = v),
                ),
                _buildRadioTile(
                  'severe_pain'.tr(),
                  0,
                  _douleurScore,
                  (v) => setState(() => _douleurScore = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'daily_activity_section_title'.tr(),
              icon: Icons.accessibility_new,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'activity_level_sub'.tr(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCheckboxTile(
                  'no_work_discomfort'.tr(),
                  4,
                  _activiteSelections.containsKey('travail'),
                  (val) {
                    setState(() {
                      if (val == true)
                        _activiteSelections['travail'] = 4;
                      else
                        _activiteSelections.remove('travail');
                    });
                  },
                ),
                _buildCheckboxTile(
                  'leisure_sports'.tr(),
                  4,
                  _activiteSelections.containsKey('loisirs'),
                  (val) {
                    setState(() {
                      if (val == true)
                        _activiteSelections['loisirs'] = 4;
                      else
                        _activiteSelections.remove('loisirs');
                    });
                  },
                ),
                _buildCheckboxTile(
                  'no_sleep_discomfort'.tr(),
                  2,
                  _activiteSelections.containsKey('sommeil'),
                  (val) {
                    setState(() {
                      if (val == true)
                        _activiteSelections['sommeil'] = 2;
                      else
                        _activiteSelections.remove('sommeil');
                    });
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'hand_position_sub'.tr(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildRadioTile(
                  'hand_waist'.tr(),
                  2,
                  _positionMainScore,
                  (v) => setState(() => _positionMainScore = v),
                ),
                _buildRadioTile(
                  'hand_xyphoid'.tr(),
                  4,
                  _positionMainScore,
                  (v) => setState(() => _positionMainScore = v),
                ),
                _buildRadioTile(
                  'hand_neck'.tr(),
                  6,
                  _positionMainScore,
                  (v) => setState(() => _positionMainScore = v),
                ),
                _buildRadioTile(
                  'hand_skull'.tr(),
                  8,
                  _positionMainScore,
                  (v) => setState(() => _positionMainScore = v),
                ),
                _buildRadioTile(
                  'hand_above_head'.tr(),
                  10,
                  _positionMainScore,
                  (v) => setState(() => _positionMainScore = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'mobility_section_title'.tr(),
              icon: Icons.sync_problem,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'anterior_elevation_sub'.tr(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildChipSelection(
                  {
                    '0-30° (${'pts_label'.tr(namedArgs: {'count': '0'})})': 0,
                    '31-60° (${'pts_label'.tr(namedArgs: {'count': '2'})})': 2,
                    '61-90° (${'pts_label'.tr(namedArgs: {'count': '4'})})': 4,
                    '91-120° (${'pts_label'.tr(namedArgs: {'count': '6'})})': 6,
                    '121-150° (${'pts_label'.tr(namedArgs: {'count': '8'})})':
                        8,
                    '151-180° (${'pts_label'.tr(namedArgs: {'count': '10'})})':
                        10,
                  },
                  _elevationAntScore,
                  (val) => setState(() => _elevationAntScore = val),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: buttonIn(
                        'reset_button'.tr(),
                        _resetAll,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buttonC('save_button'.tr(), () {
                        // Supprimer les alertes précédentes avant de vérifier
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        if (_douleurScore == null ||
                            _positionMainScore == null ||
                            _elevationAntScore == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('mandatory_questions_error'.tr()),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Cacher aussi avant de partir
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        Navigator.pushNamed(context, '/accueil');
                      }, width: double.infinity),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0D54F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRadioTile(
    String label,
    int value,
    int? groupValue,
    ValueChanged<int?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<int>(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        secondary: Text(
          'pts_label'.tr(namedArgs: {'count': value.toString()}),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
      ),
    );
  }

  Widget _buildCheckboxTile(
    String label,
    int pts,
    bool isSelected,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontSize: 13)),
        secondary: Text(
          'pts_label'.tr(namedArgs: {'count': pts.toString()}),
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        value: isSelected,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        activeColor: Colors.blue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildChipSelection(
    Map<String, int> values,
    int? selectedValue,
    ValueChanged<int> onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.entries
          .map(
            (entry) => ChoiceChip(
              label: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 11,
                  color: selectedValue == entry.value
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
              selected: selectedValue == entry.value,
              onSelected: (selected) {
                if (selected) onSelected(entry.value);
              },
              selectedColor: Colors.blue,
              backgroundColor: const Color(0xFFF8FAFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            ),
          )
          .toList(),
    );
  }
}
