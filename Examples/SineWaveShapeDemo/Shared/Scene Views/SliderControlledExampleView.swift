import SwiftUI
import SwiftUIStarterKit
import SwiftUISineWaveShape


struct SliderControlledExampleView {
    @State
    private var screenHeight: CGFloat = 0.0
    
    @State
    private var amplitudeSliderProgress: CGFloat = 0.5
    
    @State
    private var frequency: CGFloat = Self.frequencyBounds.lowerBound
    
    @State
    private var phase: Angle = .zero
    
    
    private static let frequencyBounds = ClosedRange<CGFloat>(uncheckedBounds: (lower: 1.0, upper: 30))
    private static let phaseBounds = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 2.0 * .pi))
}


// MARK: - Static Properties
extension SliderControlledExampleView {
    
    enum Animations {
        static let continuousWaveSlide = Animation
            .linear(duration: 2.0)
        
        static let amplitudeChange = Animation
            .easeOut(duration: 0.4)
        
        static let phaseShift = Animation
            .easeOut(duration: 0.7)
    }
}


// MARK: - `View` Body
extension SliderControlledExampleView: View {
    
    var body: some View {
        ZStack {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 32.0) {
                    headerSection
                    
                    wavesSection
                    
                    Spacer()
                    
                    controlsSection
                        .padding(.horizontal)
                }
            }
        }
        .readingFrameSize { newSize in
            screenHeight = newSize.height
        }
        .navigationBarHidden(true)
    }
}


// MARK: - Computeds
extension SliderControlledExampleView {
    
    var continuousWaveAnimation: Animation? {
        Animations.continuousWaveSlide.repeatForever(autoreverses: false)
    }
    
    var amplitudeAnimation: Animation? { Animations.amplitudeChange }
    var phaseAnimation: Animation? { Animations.phaseShift }
}


// MARK: - View Content Builders
private extension SliderControlledExampleView {
    
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
        Text("Sine Wave Lines")
            .font(.system(.largeTitle, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(ThemeColors.accent)
    }
    
    
    var wavesSection: some View {
        VStack {
            AutoWavingView(strokeColor: ThemeColors.primary)
                .frame(height: screenHeight * 0.05)
            
            ZStack {
                ForEach(0..<5) { waveIndex in
                    SineWave(
                        phase: .radians(phase.radians + Double(waveIndex) * 10.0),
                        amplitudeRatio: amplitudeSliderProgress,
                        frequency: frequency
                    )
                    .stroke(ThemeColors.accent, lineWidth: 12)
                    .opacity(Double(waveIndex) / 5.0)
//                    .offset(x: 0.0, y: CGFloat(waveIndex) * 10.0)
                    .animation(amplitudeAnimation, value: amplitudeSliderProgress)
                    .animation(amplitudeAnimation, value: frequency)
                    .animation(phaseAnimation, value: phase)
                }
            }
            .frame(height: screenHeight * 0.25)
            
            AutoWavingView(strokeColor: ThemeColors.primary)
                .frame(height: screenHeight * 0.05)
        }
    }
    
    
    var controlsSection: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Slider(value: $amplitudeSliderProgress) {
                    Text("Amplitude")
                }
                
                Text("Amplitude")
            }
            
            VStack(spacing: 8) {
                Slider(value: $frequency, in: Self.frequencyBounds) {
                    Text("Frequency")
                }
                
                Text("Frequency")
            }
            
            VStack(spacing: 8) {
                Slider(value: $phase.radians, in: Self.phaseBounds) {
                    Text("Phase")
                }
                
                Text("Phase")
            }
        }
        .font(.system(.headline, design: .rounded))
    }
}


// MARK: - Private Helpers
private extension SliderControlledExampleView {
}



// MARK: - AutoWavingView
private extension SliderControlledExampleView {
    
    struct AutoWavingView: View {
        var amplitudeRatio: CGFloat
        var frequency: CGFloat
        var strokeColor: Color
        
        init(
            amplitudeRatio: CGFloat = 0.5,
            frequency: CGFloat = 30,
            strokeColor: Color
        ) {
            self.amplitudeRatio = amplitudeRatio
            self.frequency = frequency
            self.strokeColor = strokeColor
        }

        
        @State
        private var phase: Angle = .zero
        
        
        static let waveAnimation = Animation.linear(duration: 0.3)
        
        
        var body: some View {
            SineWave(
                phase: phase,
                amplitudeRatio: amplitudeRatio,
                frequency: frequency
            )
            .stroke(strokeColor, lineWidth: 2)
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(Self.waveAnimation.repeatForever(autoreverses: false)) {
                        phase.radians = -2.0 * .pi
                    }
                }
            }
        }
    }
}


#if DEBUG

// MARK: - Preview

struct SineWaveDemoView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SliderControlledExampleView()
            
            SliderControlledExampleView()
                .preferredColorScheme(.dark)
        }
        .accentColor(ThemeColors.accent)
    }
}
#endif
