import 'package:flutter/material.dart';

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => CustomTimePickerDialog(initialTime: initialTime),
  );
}

class CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePickerDialog({required this.initialTime});

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late TimeOfDay selectedTime;
  late bool isAm;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    isAm = selectedTime.period == DayPeriod.am;
  }

  void _handleTimeChanged(TimeOfDay newTime) {
    setState(() {
      selectedTime = newTime;
    });
  }

  void _toggleAmPm(bool am) {
    if (isAm != am) {
      final newHour = (selectedTime.hour + 12) % 24;
      setState(() {
        selectedTime = TimeOfDay(hour: newHour, minute: selectedTime.minute);
        isAm = am;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timePicker = TimePickerDialog(
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        height: 420,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _AmPmButton(
                        selected: isAm,
                        label: 'AM',
                        onPressed: () => _toggleAmPm(true),
                      ),
                      const SizedBox(height: 10),
                      _AmPmButton(
                        selected: !isAm,
                        label: 'PM',
                        onPressed: () => _toggleAmPm(false),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        timePickerTheme: const TimePickerThemeData(
                          dialHandColor: Colors.black,
                          dialBackgroundColor: Colors.white,
                          entryModeIconColor: Colors.black,
                        ),
                      ),
                      child: TimePickerDialog(
                        initialTime: selectedTime,
                        initialEntryMode: TimePickerEntryMode.dial,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedTime),
                  child: const Text('OK'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _AmPmButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onPressed;

  const _AmPmButton({
    required this.selected,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.black : Colors.grey[300],
        foregroundColor: selected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
