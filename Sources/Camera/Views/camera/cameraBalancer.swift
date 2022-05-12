//
//  cameraBalancer.swift
//  CameraViews
//
//  Created by Bilel Hattay on 07/05/2022.
//

import SwiftUI

public struct cameraBalancer: View {
    @StateObject var cameraInstanceModel = cameraInstanceViewModel.shared

    public init() {
        
    }

    public var body: some View {
        ZStack {
            GeometryReader { reader in
                let size = reader.size
                
                // MARK: switch between camera's possibilities
                defaultCamera()
                    .environmentObject(cameraInstanceModel)
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
            
    }
}

struct cameraBalancer_Previews: PreviewProvider {
    static var previews: some View {
        cameraBalancer()
    }
}