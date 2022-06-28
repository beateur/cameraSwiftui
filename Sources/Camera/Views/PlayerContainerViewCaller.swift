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
    let videoThumnail: UIImage!
    let player: AVPlayer!
    let gravity: PlayerGravity!
    let play: Bool
    
    @State var observer: NSObjectProtocol!
    var onEnd: (AVPlayer)->()
    
    @State var videoPlaying = true
    let playerVM = PlayerViewModel()
    public init(asset: AVAsset, gravity: PlayerGravity, play: Bool, onEnd: @escaping(AVPlayer)->()) {
        self.play = play
        self.onEnd = onEnd

        switch play {
        case true:
            self.gravity = gravity
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            
            self.player = player
            
            self.videoThumnail = nil
        case false:
            self.gravity = nil
            self.player = nil
            
            self.videoThumnail = asset.asImage()
        }
    }
    
    public var body: some View {
        ZStack {
            GeometryReader { reader in
                let readsize = reader.size
                
                switch play {
                case true:
                    if let player = player {
                        PlayerContainerView(player: player, gravity: gravity) {
                            videoPlaying = false
                            onEnd(player)
                        }
                        .onAppear {
                            print("onappear et play")
                            playerVM.play(player: player)
                            observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
                                print("notification")
                                playerVM.loopVideo(videoPlayer: player)
                            }
                            videoPlaying = true
                        }
                        .onDisappear {
                            print("disappeared and stop")
                            playerVM.stopVideo(player: player)
                            videoPlaying = false
                            if let observer = observer {
                                NotificationCenter.default.removeObserver(observer as Any)
                            }
                        }
                    }
                case false:
                    if let img = videoThumnail {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: img)
                                .centerCropped()
                                .frame(width: readsize.width, height: readsize.height)
                            
                            Image(systemName: "video.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: readsize.width / 8, height: readsize.height / 8)
                                .padding(5)
                        }
                    }
                }
            }
        }
    }
}

private extension AVAsset {
    
    func asImage() -> UIImage? {
        let timestamp = CMTime(seconds: .zero, preferredTimescale: 60)
        let generator = AVAssetImageGenerator(asset: self)
        generator.appliesPreferredTrackTransform = true
        guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) else {
            print("return nill")
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
}

private extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}
