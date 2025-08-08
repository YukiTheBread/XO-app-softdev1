import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: OXBoard()));
}

/// บอกว่าจะวาด x หรือ o ที่ตำแหน่งนี้
class Mark {
  final Offset position;
  final String type; // 'O' or 'X'

  Mark({required this.position, required this.type});
}

/// The main board
class OXBoard extends StatefulWidget {
  const OXBoard({super.key});

  @override
  State<OXBoard> createState() => _OXBoardState();
}

class _OXBoardState extends State<OXBoard> {
  // A list to store the marks (x or o)
  List<Mark> _marks = <Mark>[];
  // The currently selected tool for drawing
  String _selectedTool = 'O';

  static const double _markSize = 100.0;

  /// Handles a tap down event on the drawing area.
  /// Converts the global tap position to a local position relative to the CustomPaint
  /// and adds a new Mark to the list.
  void _handleTap(Offset localPosition) {
    setState(() {
      // Create a new list instance to trigger `shouldRepaint` in BoardPainter,
      // ensuring the UI updates correctly.
      _marks = List<Mark>.from(_marks)
        ..add(Mark(position: localPosition, type: _selectedTool));
    });
  }

  /// Sets the currently selected drawing tool ('O' or 'X').
  void _selectTool(String tool) {
    setState(() {
      _selectedTool = tool;
    });
  }

  /// Clears all drawn marks from the board.
  void _clearBoard() {
    setState(() {
      // Create a new empty list instance to clear the board.
      _marks = <Mark>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OX Drawing Board'), centerTitle: true),
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Determine the size available for the custom paint area.
                final Size boardSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                return GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    // Find the render box of the current context to convert global to local coordinates.
                    final RenderBox? box =
                        context.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final Offset localPos = box.globalToLocal(
                        details.globalPosition,
                      );
                      _handleTap(localPos);
                    }
                  },
                  child: CustomPaint(
                    size: boardSize,
                    painter: BoardPainter(marks: _marks, markSize: _markSize),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () => _selectTool('O'),
                  icon: const Icon(Icons.circle_outlined),
                  label: const Text('Draw O'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTool == 'O'
                        ? Colors.blue.shade100
                        : null,
                    foregroundColor: _selectedTool == 'O'
                        ? Colors.blue.shade800
                        : null,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectTool('X'),
                  icon: const Icon(Icons.close),
                  label: const Text('Draw X'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTool == 'X'
                        ? Colors.red.shade100
                        : null,
                    foregroundColor: _selectedTool == 'X'
                        ? Colors.red.shade800
                        : null,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearBoard,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade800,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A CustomPainter for 3x3 grid and all the 'O' and 'X'
class BoardPainter extends CustomPainter {
  final List<Mark> marks;
  final double markSize;

  BoardPainter({required this.marks, required this.markSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the grid lines
    final Paint gridPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    //gridSize n x n
    final gridSize = 4;
    //

    final double cellWidth = size.width / gridSize;
    final double cellHeight = size.height / gridSize;

    // Draw vertical grid lines
    for (int i = 1; i < gridSize; i++) {
      final double x = cellWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal grid lines
    for (int i = 1; i < gridSize; i++) {
      final double y = cellHeight * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Paint for 'O'
    final Paint oPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Paint for 'X'
    final Paint xPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw each 'O' and 'X' mark based on its stored position and type
    for (final Mark mark in marks) {
      if (mark.type == 'O') {
        canvas.drawCircle(mark.position, markSize / 2, oPaint);
      } else if (mark.type == 'X') {
        final double halfSize = markSize / 2;
        canvas.drawLine(
          mark.position + Offset(-halfSize, -halfSize),
          mark.position + Offset(halfSize, halfSize),
          xPaint,
        );
        canvas.drawLine(
          mark.position + Offset(-halfSize, halfSize),
          mark.position + Offset(halfSize, -halfSize),
          xPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return oldDelegate.marks != marks || oldDelegate.markSize != markSize;
  }
}
