//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 09/06/2022.
//

import SwiftUI
import AVFoundation

public enum playingMode {
    case play, pause, stop
}

public struct PlayerContainerViewCaller: View {
    let player: AVPlayer
    let gravity: PlayerGravity
    let replay: Bool
    
    var observer: NSObjectProtocol!
    var onEnd: (AVPlayer)->()
    
    @State var videoPlaying = true

    public init(asset: AVAsset, gravity: PlayerGravity, replay: Bool, onEnd: @escaping(AVPlayer)->()) {
        self.gravity = gravity
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        self.player = player
        self.replay = replay
        self.onEnd = onEnd
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            print("notification")
            PlayerViewModel.shared.loopVideo(videoPlayer: player)
        }
    }
    
    public var body: some View {
        ZStack {
            let playerVM = PlayerViewModel()
            PlayerContainerView(player: player, gravity: gravity, replay: replay) {
                videoPlaying = false
                onEnd(player)
            }
            .onAppear {
                print("onappear et play")
                playerVM.play(player: player)
                videoPlaying = true
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(observer)
                playerVM.stopVideo(player: player)
                videoPlaying = false
            }
//            if !videoPlaying {
//                Button {
//                    PlayerViewModel.shared.play(player: player)
//                    videoPlaying = true
//                } label: {
//                    Image(systemName: "play.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 36, height: 36)
//                }
//            }
        }
        .onDisappear {
        }
    }
}
