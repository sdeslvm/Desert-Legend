import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct DesertLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        DesertProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct DesertBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct DesertProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var sparkleOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    startAnimations()
                }
        }
    }

    private func startAnimations() {
        // Shimmer animation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.0
        }

        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }

        // Sparkle animation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            sparkleOffset = 1.0
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
            sparkleOverlay(in: geometry)
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        ZStack {
            // Основной фон
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#1A1D23").opacity(0.8),
                            Color(hex: "#2C3038").opacity(0.9),
                            Color(hex: "#1A1D23").opacity(0.8),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: height)

            // Песочная текстура фона
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#8B7355").opacity(0.3),
                            Color.clear,
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: height * 2
                    )
                )
                .frame(height: height)

            // Внешняя рамка
            RoundedRectangle(cornerRadius: height / 2)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#D4AF37").opacity(0.4),
                            Color(hex: "#8B7355").opacity(0.6),
                            Color(hex: "#D4AF37").opacity(0.4),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)
        .scaleEffect(pulseScale)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Основной прогресс
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FF8C42"),  // Оранжевый песчаный
                            Color(hex: "#FFB74D"),  // Золотистый
                            Color(hex: "#FFA726"),  // Янтарный
                            Color(hex: "#FF8C42"),  // Обратно к оранжевому
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)

            // Движущийся shimmer эффект
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0),
                            .init(color: Color.white.opacity(0.6), location: 0.5),
                            .init(color: Color.clear, location: 1),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .mask(
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: width, height: height)
                )
                .offset(x: shimmerOffset * width * 1.5)

            // Верхний глянцевый блик
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.1),
                            Color.clear,
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height * 0.6)
                .offset(y: -height * 0.2)

            // Песочные частицы эффект
            ForEach(0..<3, id: \.self) { index in
                sandParticle(index: index, width: width, height: height)
            }
        }
        .mask(
            RoundedRectangle(cornerRadius: height / 2)
                .frame(width: width, height: height)
        )
        .modifier(ProgressShadowModifier())
        .animation(.easeOut(duration: 0.3), value: value)
    }

    private func sparkleOverlay(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Случайные блестящие точки
            ForEach(0..<5, id: \.self) { index in
                sparklePoint(index: index, width: width, height: height)
            }
        }
    }

    private func sandParticle(index: Int, width: CGFloat, height: CGFloat) -> some View {
        let xOffset = (width * 0.2) + (CGFloat(index) * width * 0.3)
        let yOffset = sin(sparkleOffset * .pi * 2 + Double(index)) * height * 0.15
        let scale = 0.5 + sin(sparkleOffset * .pi * 4 + Double(index)) * 0.3

        return Circle()
            .fill(Color(hex: "#FFD54F").opacity(0.7))
            .frame(width: height * 0.3, height: height * 0.3)
            .offset(x: xOffset, y: yOffset)
            .scaleEffect(scale)
            .opacity(value > 0 ? 0.8 : 0)
    }

    private func sparklePoint(index: Int, width: CGFloat, height: CGFloat) -> some View {
        let xOffset =
            (width * CGFloat(index) / 5.0) + sin(sparkleOffset * .pi * 3 + Double(index)) * 10
        let yOffset = cos(sparkleOffset * .pi * 2 + Double(index)) * height * 0.3
        let scale = 0.5 + sin(sparkleOffset * .pi * 6 + Double(index)) * 0.5
        let opacity = value > CGFloat(index) / 5.0 ? 0.9 : 0

        return Circle()
            .fill(Color.white)
            .frame(width: 2, height: 2)
            .offset(x: xOffset, y: yOffset)
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

struct ProgressShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(hex: "#FF8C42").opacity(0.4), radius: 8, y: 0)
            .shadow(color: Color(hex: "#FFB74D").opacity(0.3), radius: 12, y: 0)
    }
}

// MARK: - Превью

#Preview("Vertical") {
    DesertLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    DesertLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
