//
//  cameraBalancer.swift
//  CameraViews
//
//  Created by Bilel Hattay on 07/05/2022.
//

import SwiftUI

import Foundation

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

private extension EnvironmentValues {
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}


public struct cameraBalancer: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @StateObject var cameraInstanceModel = cameraInstanceViewModel.shared
    @EnvironmentObject var defaultCameraModel: defaultViewModel
//    public var dismissCompletion: (()->())

    public init() {
//        self.dismissCompletion = dismissCompletion
    }

    public var body: some View {
        ZStack {
            GeometryReader { reader in
                let size = reader.size
                
                // MARK: switch between camera's possibilities
                defaultCamera()
                    .padding(.bottom, safeAreaInsets.bottom)
                    .environmentObject(cameraInstanceModel)
                    .environmentObject(defaultCameraModel)
                    .onTapGesture(count: 2) {
                        cameraInstanceModel.switchCamera()
                    }
                    .onAppear {
                        cameraInstanceModel.maxDuration = 30
                    }
                // MARK: progress bar
                cameraInstanceModel.progressBar(size: size)
                    
            }
            .onAppear(perform: cameraInstanceModel.checkPermission)
            .alert(isPresented: $cameraInstanceModel.alert) {
                Alert(title: Text("test title"))
            }
            .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
                if beginCountingGap {
                    gapOnDragTime += 0.01
                }
                cameraInstanceModel.makeProgression()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
