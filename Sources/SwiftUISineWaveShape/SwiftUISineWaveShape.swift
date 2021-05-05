import SwiftUI
import SwiftUIGeometryUtils
import UnitIntervalPropertyWrapper
import ClampedPropertyWrapper


public struct SineWave {
    public typealias HeightRatio = CGFloat
    public typealias Hertz = CGFloat
    
    
    public var phase: Angle
    
    
    /// Ratio of amplitude height to total height of the shape's bounding rect.
    @UnitInterval
    public var amplitudeRatio: HeightRatio
    
    
    /// Number of wave repetitions
    ///
    /// Frequency, measured in Hertz, is meant to define the number of wave repetitions
    /// per second. In the context of a single shape, we can translate that to repetitions
    /// within the rectangle bounds.
    @Clamped(within: 1.0...Hertz.infinity)
    public var frequency: Hertz = 1.0
    
    
    public var amplitudeModulation: AmplitudeModulationMode
    
    
    // MARK: - Init
    public init(
        phase: Angle = .zero,
        amplitudeRatio: HeightRatio = 0.25,
        frequency: Hertz = 1,
        amplitudeModulation: AmplitudeModulationMode = .none
    ) {
        self.phase = phase
        self.amplitudeRatio = amplitudeRatio
        self.frequency = frequency
        self.amplitudeModulation = amplitudeModulation
    }
}


// MARK: - Shape
extension SineWave: Shape {

    public func path(in rect: CGRect) -> Path {
        let rectWavelength = self.wavelength(in: rect)
        let rectHeight = rect.height
        
        
        let startingX = rect.minX
        let startPoint = wavePoint(
            at: startingX,
            inRect: rect,
            withWavelength: rectWavelength,
            andHeight: rectHeight
        )
                                   
        var path = Path()

        path.move(to: startPoint)
        
        for xPosition in stride(
            from: startingX,
            through: rect.maxX,
            by: 1.0
        ) {
            path.addLine(
                to: wavePoint(
                    at: CGFloat(xPosition),
                    inRect: rect,
                    withWavelength: rectWavelength,
                    andHeight: rectHeight
                )
            )
        }

        return path
    }
}


// MARK: - AnimatableData
extension SineWave {

    public var animatableData: AnimatablePair<
        Double,
        AnimatablePair<CGFloat, CGFloat>
    > {
        get {
            AnimatablePair(
                phase.radians,
                AnimatablePair(amplitudeRatio, frequency)
            )
        }
        set {
            phase = .radians(newValue.first)
            amplitudeRatio = newValue.second.first
            frequency = newValue.second.second
        }
    }
}


// MARK: - Computeds
extension SineWave {
    
    func wavelength(in rect: CGRect) -> CGFloat {
        let angularFrequency = (.pi * 2) * frequency
        
        return rect.width / angularFrequency
    }
}


extension CGFloat {
    
    func normalizedDistanceFromMidWidth(in rect: CGRect) -> CGFloat {
        let distanceFromMidWidth = self - rect.midX
        
        return distanceFromMidWidth / rect.midX
    }
}


// MARK: - Private Helpers
private extension SineWave {
    
    func amplitudeModulationFactor(for xPosition: CGFloat, in rect: CGRect) -> CGFloat {
        switch amplitudeModulation {
        case .none:
            return 1.0
        case .center:
            return abs(xPosition.normalizedDistanceFromMidWidth(in: rect))
        case .edges:
            return -(pow(xPosition.normalizedDistanceFromMidWidth(in: rect), 2)) + 1
        }
    }
    
  
    func wavePoint(
        at xPosition: CGFloat,
        inRect rect: CGRect,
        withWavelength rectWavelength: CGFloat,
        andHeight rectHeight: CGFloat
    ) -> CGPoint {
        let xPositionRelativeOfWavelength = xPosition / rectWavelength
        let sine = sin(xPositionRelativeOfWavelength + CGFloat(phase.radians))
        let midHeight: CGFloat = rectHeight / 2.0
        let maxAmplitudeHeight = midHeight * amplitudeRatio
        
        // Adjust the height so that it the line falls back within the rectangle's bounds.
        let viewBoundsHeightShift: CGFloat = midHeight
        
        let modulatedAmplitudeWeight = self.amplitudeModulationFactor(for: xPosition, in: rect)

        let unModulatedYPosition = (sine * maxAmplitudeHeight)
        let modulatedYPosition = unModulatedYPosition * modulatedAmplitudeWeight
        
        let finalYPosition = modulatedYPosition + viewBoundsHeightShift

        return CGPoint(x: xPosition, y: finalYPosition)
    }
}


extension SineWave {
    public enum AmplitudeModulationMode {
        case none
        
        /// "Modulates" amplitude at the center of the wave.
        ///
        /// This will create a shortened magnitude at the center, while increasingly elongating
        /// the magnitude towards the edges.
        case center
        
        
        /// "Modulates" amplitude at the edges of the wave.
        ///
        /// This will create a shortened magnitude at the edges, while increasingly elongating
        /// the magnitude towards the middle.
        case edges
    }
}



#if DEBUG

struct SineWave_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SineWave()
                .fill(Color.accentColor)
            
            SineWave(
            )
            .stroke(Color.pink, lineWidth: 10)
            .frame(width: 300, height: 200, alignment: .center)
            .background(Color.yellow)
            
            SineWave(
                phase: .radians(.pi / 6),
                amplitudeRatio: 0.75,
                frequency: 1,
                amplitudeModulation: .edges
            )
            .stroke(Color.pink, lineWidth: 10)
            
            
            SineWave(
                amplitudeRatio: 0.75,
                frequency: 8,
                amplitudeModulation: .edges
            )
            .stroke(Color.purple, lineWidth: 10)
            
            SineWave(
                amplitudeRatio: 0.75,
                frequency: 18,
                amplitudeModulation: .center
            )
            .stroke(Color.purple, lineWidth: 4)
            
            SineWave(
                amplitudeRatio: 0.75,
                frequency: 2,
                amplitudeModulation: .edges
            )
            .stroke(Color.pink, lineWidth: 10)
            .frame(width: 100)
            
            
            SineWave(
                amplitudeRatio: 0.75
//                frequency: 1
            )
            .stroke(Color.pink, lineWidth: 10)
            .frame(width: 629)
        }
        .frame(height: 200)
        .previewLayout(.sizeThatFits)
    }
}


#endif
