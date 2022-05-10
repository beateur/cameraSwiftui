import SwiftUI

#if !os(macOS)
@available(iOS 14, *)
public struct Camera: View {
    @Environment var defaultCameraModel: defaultViewModel
    
//    init() {
//        defaultCameraModel = defaultViewModel(record: Circle().fill(Color.blue).frame(width: 72, height: 72) as! AnyView, filters: Rectangle().fill(Color.white).frame(width: 10, height: 40) as! AnyView)
//    }
    
    public var body: some View {
        VStack {
            entete
            ZStack {
                Color.red
                content
                OverlayedComponents
            }
        }
    }
    
    private var entete: some View {
        defaultCameraModel.entete(dismisselement: Image(systemName: "xmark").resizable().frame(width: 15, height: 15) as! AnyView, nextelement: Image(systemName: "arrow.right").resizable().frame(width: 30, height: 10) as! AnyView) {
            print("dismissed")
        } next: {
            print("nexted")
        }
    }
    
    private var content: some View {
        VStack { }
    }
    
    private var OverlayedComponents: some View {
        VStack {
            topComponents
            Spacer()
            bottomComponents
        }
    }
    
    private var bottomComponents: some View {
        HStack {
            Spacer()
            defaultCameraModel.galleryButton()
            Spacer()
            defaultCameraModel.recordButton()
            Spacer()
            defaultCameraModel.filterButton()
            Spacer()
        }
    }
    
    private var topComponents: some View {
        HStack {
            Spacer()
            defaultCameraModel.flashElement()
            Spacer()
            defaultCameraModel.cameraInversion()
        }
    }
}
#endif
