//
// SineWaveModulationDemoView.swift
// SineWaveShapeDemo
//
// Created by CypherPoet on 5/6/21.
// ✌️
//

import SwiftUI
import SwiftUIStarterKit
import SwiftUISineWaveShape


struct SineWaveModulationDemoView {
    @State
    private var screenHeight: CGFloat = 0.0
    
    @State
    private var amplitudeSliderProgress: CGFloat = 0.5
    
    @State
    private var frequency: CGFloat = (Self.frequencyBounds.lowerBound + Self.frequencyBounds.upperBound) * 0.5
    
    @State
    private var phase: Angle = .zero
    
    @State
    private var modulationMode: SineWave.AmplitudeModulationMode = .center
    
    @ScaledMetric(relativeTo: .body)
    private var baseFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
    
    private static let frequencyBounds = ClosedRange<CGFloat>(uncheckedBounds: (lower: 1.0, upper: 30))
    private static let phaseBounds = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 2.0 * .pi))
}


// MARK: - Static Properties
extension SineWaveModulationDemoView {
    
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
extension SineWaveModulationDemoView: View {
    
    var body: some View {
        ZStack {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: baseFontSize) {
                    headerSection
                    
                    wavesSection
                        .frame(height: screenHeight * 0.46)
                    
                    controlsSection
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .readingFrameSize { newSize in
            screenHeight = newSize.height
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(
                .linear(duration: 0.40)
                    .repeatForever(autoreverses: false)
            ) {
                phase = .radians(2 * .pi)
            }
        }
    }
}


// MARK: - Computeds
extension SineWaveModulationDemoView {
    
    var continuousWaveAnimation: Animation? {
        Animations.continuousWaveSlide.repeatForever(autoreverses: false)
    }
    
    var amplitudeAnimation: Animation? { Animations.amplitudeChange }
    var phaseAnimation: Animation? { Animations.phaseShift }
}


// MARK: - View Content Builders
private extension SineWaveModulationDemoView {
    
    var backgroundGradient: some View {
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
        VStack(spacing: baseFontSize * 2) {
            Text("Modulated Sine Waves")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: baseFontSize * 1.2) {
                Text("Modulation Mode")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                
                Picker("View Mode", selection: $modulationMode) {
                    Text("Edges").tag(SineWave.AmplitudeModulationMode.edges)
                    Text("Center").tag(SineWave.AmplitudeModulationMode.center)
                    Text("None").tag(SineWave.AmplitudeModulationMode.none)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .foregroundColor(ThemeColors.primary)
        .padding(.horizontal)
        
    }
    
    var wavesSection: some View {
        SineWave(
            phase: phase,
            amplitudeRatio: amplitudeSliderProgress,
            frequency: frequency,
            amplitudeModulation: modulationMode
        )
        .stroke(Color(#colorLiteral(red: 0, green: 1, blue: 0.3313274682, alpha: 1)), lineWidth: 2)
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
//
//            VStack(spacing: 8) {
//                Slider(value: $phase.radians, in: Self.phaseBounds) {
//                    Text("Phase")
//                }
//
//                Text("Phase")
//            }
        }
        .font(.system(.headline, design: .rounded))
        .foregroundColor(ThemeColors.primary)
    }
}


// MARK: - Private Helpers
private extension SineWaveModulationDemoView {
}



#if DEBUG

// MARK: - Preview

struct SineWaveModulationDemoView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SineWaveModulationDemoView()
            
            SineWaveModulationDemoView()
                .preferredColorScheme(.dark)
        }
        .accentColor(ThemeColors.accent)
    }
}
#endif
