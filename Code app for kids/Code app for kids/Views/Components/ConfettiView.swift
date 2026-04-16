import SwiftUI

struct ConfettiView: View {
    let isActive: Bool
    private let pieces: [ConfettiPiece] = (0..<40).map { _ in ConfettiPiece.random() }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .offset(
                            x: piece.xOffset * geo.size.width * 0.5,
                            y: isActive ? geo.size.height + 50 : -50
                        )
                        .rotationEffect(.degrees(isActive ? 360 : 0))
                        .opacity(isActive ? 1 : 0)
                        .animation(
                            .easeOut(duration: piece.duration).delay(piece.delay),
                            value: isActive
                        )
                        .position(x: geo.size.width / 2, y: 0)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let xOffset: CGFloat
    let duration: Double
    let delay: Double

    static func random() -> ConfettiPiece {
        let palette: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return ConfettiPiece(
            color: palette.randomElement() ?? .yellow,
            size: CGFloat.random(in: 6...12),
            xOffset: CGFloat.random(in: -1...1),
            duration: Double.random(in: 1.0...2.0),
            delay: Double.random(in: 0...0.3)
        )
    }
}
