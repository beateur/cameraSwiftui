//
//  File.swift
//  
//
//  Created by Bilel Hattay on 02/02/2023.
//

import Foundation
import UIKit
import Photos

public final class FilesManager {
    public static let shared = FilesManager()
    
    public func converttoFile(asset: AVAsset?, image: UIImage?, completion: @escaping(URL, Int)->()) {
        let contentID = UUID().uuidString

        if let video = asset {
            assettoFile(video, path: "", videoName: contentID) { url, _ in
                return completion(url, 1)
            }
        } else if let image = image {
            imagetoFile(path: "", imageName: contentID, image: image) { url, _ in
                return completion(url, 0)
            }
        }
    }
    
    private func assettoFile(_ asset: AVAsset, path: String, videoName: String, completion: @escaping(URL, String)->()) {
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            
        if let filepath = paths.first?.appendingPathComponent("\(videoName).mp4") {
            do {
                do {
                    try FileManager.default.removeItem(at: filepath)
                } catch {
                    // il n'y avait pas de file ici donc ct ok
                }
                
                exportSession!.outputURL = filepath.standardized
                exportSession!.outputFileType = .mp4
                exportSession!.shouldOptimizeForNetworkUse = true
                
                let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
                let range = CMTimeRangeMake(start: start, duration: asset.duration)

                exportSession!.timeRange = range

                exportSession!.exportAsynchronously {
                    switch exportSession!.status {
                    case .failed:
                        print("%@", exportSession?.error?.localizedDescription)
                    case .cancelled:
                        print("Export canceled")
                    case .completed:
                        //Video conversion finished
                        let storagePath = path + filepath.lastPathComponent
                        completion(filepath, storagePath)
                    default:
                        break
                    }
                }
            } catch {
                print("catched \(error.localizedDescription)")
            }
        }
    }
    
    // le path c'est exemple /Publications/ImageName et imageName c'est le fichier qui va être append
    private func imagetoFile(path: String, imageName: String, image: UIImage, completion: @escaping(URL, String)->()) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let filepath = paths.first?.appendingPathComponent("\(imageName).jpeg") {
            do {
                try image.jpegData(compressionQuality: 0.25)?.write(to: filepath, options: .atomic)
                let storagePath = path + filepath.lastPathComponent
                
                completion(filepath, storagePath)
            } catch {
                
            }
        }
    }
}
