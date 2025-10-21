import 'package:flutter/material.dart';

class ScheduleSelector extends StatelessWidget {
  final List<String> days;
  final List<String> times;
  final Set<String> selectedSlots;
  final Function(String, String) onToggle;

  const ScheduleSelector({
    super.key,
    required this.days,
    required this.times,
    required this.selectedSlots,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 2.5,
      ),
      itemCount: days.length * times.length,
      itemBuilder: (context, index) {
        final day = days[index ~/ times.length];
        final time = times[index % times.length];
        final key = "$day - $time";
        final selected = selectedSlots.contains(key);

        return GestureDetector(
          onTap: () => onToggle(day, time),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? Colors.orange.shade300 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Center(
              child: Text(
                "$day\n$time",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }
}
