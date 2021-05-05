import SwiftUI


struct RootView {
}


// MARK: - `View` Body
extension RootView: View {

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Slider-Controlled Parameters",
                    destination: SliderControlledExampleView()
                )
                NavigationLink(
                    "Overlapping Waves",
                    destination: OverlappingWavesExampleView()
                )
                NavigationLink(
                    "Custom Amplitude Modulation",
                    destination: EmptyView()
                )
            }
            .navigationBarTitle(Text("Sine Wave Lines"))
        }
        .accentColor(ThemeColors.accent)
    }
}


// MARK: - Computeds
extension RootView {
}


// MARK: - View Content Builders
private extension RootView {
}


// MARK: - Private Helpers
private extension RootView {
}


#if DEBUG
// MARK: - Preview
struct RootView_Previews: PreviewProvider {

    static var previews: some View {
        RootView()
    }
}
#endif
