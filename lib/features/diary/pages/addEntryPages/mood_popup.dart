import 'package:flutter/material.dart';

class MoodPopup extends StatelessWidget {
  final String? currentMood;
  final Function(String) onMoodSelected;
  final VoidCallback onMorePressed;

  const MoodPopup({
    super.key,
    required this.currentMood,
    required this.onMoodSelected,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.22, // Konumlandırma
          top: 110, // Pop-up'ın üstten uzaklığı
          child: CustomPaint(
            painter: _PopupBubblePainter(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.55, // Genişlik azaltıldı
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Boşluk azaltıldı
              decoration: BoxDecoration(
                color: Colors.white, // Varsayılan beyaz renk
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve Daha Butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Günün nasıl?",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: onMorePressed,
                        child: const Text(
                          "DAHA",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Emojiler: 2 satır
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final emoji in ["😐", "😊", "😁", "😍", "😌"])
                            GestureDetector(
                              onTap: () {
                                onMoodSelected(emoji);
                                Navigator.pop(context);
                              },
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10), // Satır arası mesafe azaltıldı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final emoji in ["😢", "😡", "😟", "😭", "😱"])
                            GestureDetector(
                              onTap: () {
                                onMoodSelected(emoji);
                                Navigator.pop(context);
                              },
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopupBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white // Varsayılan beyaz renk
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(350, 0); // Üçgen başlangıcı
    path.lineTo(360, -10); // Üçgenin alt ucu
    path.lineTo(370, 0); // Üçgen bitişi
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}