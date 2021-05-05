import SwiftUI
import SwiftUIStarterKit
import SwiftUISineWaveShape


struct OverlappingWavesExampleView {
    @State
    private var screenHeight: CGFloat = 0.0

    @State
    private var phase: Angle = .zero

    @State
    private var amplitudeRatio: SineWave.HeightRatio = 0.0
    
    @ScaledMetric(relativeTo: .body)
    private var baseFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
    
//    private static let phaseBounds = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 2.0 * .pi))
    
    private static let waveColors: [Color] = [
        .blue,
        .pink,
        .yellow,
        .orange,
        .green,
        .red,
        .purple,
        ThemeColors.accent,
        ThemeColors.primary,
        ThemeColors.secondary1,
        ThemeColors.secondary2,
        ThemeColors.secondary3,
    ]
}


// MARK: - Static Properties
extension OverlappingWavesExampleView {
    
    enum Animations {
        static let continuousWaveSlide = Animation
            .easeInOut(duration: 1.3)
    }
}


// MARK: - `View` Body
extension OverlappingWavesExampleView: View {
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            headerSection
            
            VStack {
                Spacer()
                
                wavesSection
                    .frame(height: screenHeight * 0.25)
                
                Spacer()
            }
            .padding(.top)
        }
        .readingFrameSize { newSize in
            screenHeight = newSize.height
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(
                    .easeInOut(duration: 0.9)
                    .repeatForever(autoreverses: true)
                ) {
                    phase.radians = -2.0 * .pi
                    amplitudeRatio = (.pi / 2.0)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


// MARK: - Computeds
extension OverlappingWavesExampleView {
    
    var amplitudeShiftAnimation: Animation? {
        Animations.continuousWaveSlide.repeatForever(autoreverses: true)
    }
}


// MARK: - View Content Builders
private extension OverlappingWavesExampleView {
    
    var backgroundGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(
                colors: [
                    ThemeColors.background1,
                    .clear,
                ]
            ),
            center: .center,
            startRadius: 0,
            endRadius: screenHeight * 2.5
        )
    }
    
    
    var headerSection: some View {
        Text("Overlapping Waves")
            .font(.system(.largeTitle, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(ThemeColors.accent)
    }
    
    
    var wavesSection: some View {
        return ZStack {
            ForEach(0..<5) { waveIndex in
                SineWave(
                    phase: .radians(self.phase.radians * Double(waveIndex)),
                    amplitudeRatio: (sin(amplitudeRatio) * 1.5) + 0.2,
                    frequency: CGFloat(Double(waveIndex) + 1.0)
                )
                .stroke(Self.waveColors.randomElement()!, lineWidth: baseFontSize / 3.0)
                .opacity(0.73)
            }
        }
        .mask(waveMaskView)
    }
    
    
    var waveMaskView: some View {
        LinearGradient(
            gradient: Gradient(
                stops: [
                    Gradient.Stop(color: .clear, location: 0.0),
                    Gradient.Stop(color: .white.opacity(0.25), location: 0.2),
                    Gradient.Stop(color: .white, location: 0.5),
                    Gradient.Stop(color: .white.opacity(0.2), location: 0.75),
                    Gradient.Stop(color: .clear, location: 1.0),
                ]
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}


// MARK: - Private Helpers
private extension OverlappingWavesExampleView {
    
    struct OverlappingWaveView: View {
        var phase: Angle = .zero
        
        var amplitudeRatio: SineWave.HeightRatio = 0.0
        
        @ScaledMetric(relativeTo: .body)
        private var baseFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
        
        var waveColor: Color
        
        var body: some View {
            SineWave(
                phase: phase,
                amplitudeRatio: amplitudeRatio,
                frequency: 6
            )
            .stroke(waveColor, lineWidth: baseFontSize / 3.0)
            .opacity(0.73)
        }
    }
}



#if DEBUG

// MARK: - Preview

struct OverlappingWavesExampleView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OverlappingWavesExampleView()
            
            OverlappingWavesExampleView()
                .preferredColorScheme(.dark)
        }
        .accentColor(ThemeColors.accent)
    }
}
#endif
