//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 12/05/2022.
//

import SwiftUI
import AVFoundation

public struct ThumbnailMosaïque: View {
    @EnvironmentObject var galleryViewModel: ImagePickerViewModel
    public var contentCompletion: ((UIImage?, AVAsset?)->())

    let gridItem = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public init(contentCompletion: @escaping(UIImage?, AVAsset?)->()) {
        self.contentCompletion = contentCompletion
    }

    public var body: some View {
        VStack(spacing: 1) {
            header
            corpus
        }
        .onChange(of: galleryViewModel.selectedVideo) { _ in
            performCompletion()
        }
        .onChange(of: galleryViewModel.selectedImage) { _ in
            performCompletion()
        }
    }
    
    private var header: some View {
        Group {
            Button {
//                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                galleryViewModel.openGallery()
            } label: {
                VStack(spacing: 8) {
                    Text("Accedez à votre gallerie")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .frame(width: UIScreen.main.bounds.width, height: 50)
                .background(Color.gray.opacity(0.6))
            }
        }
    }
    
    private var corpus: some View {
        Group {
            if galleryViewModel.fetchedElements.isEmpty {
                ScrollView {
                    emptyPlaceHolder
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: gridItem, spacing: 0.5) {
                        ForEach(galleryViewModel.fetchedElements, id: \.self) { Photo in
                            ZStack {
                                ThumbnailView(photo: Photo, size: UIScreen.main.bounds.size.width * 0.2475)
                                Color.white.opacity(0.05)
                                    .frame(width: UIScreen.main.bounds.size.width * 0.2475, height: UIScreen.main.bounds.size.width * 0.2475)
                                    .onTapGesture {
                                        print("tapped thumbn")
                                        galleryViewModel.tapThumbnail(photo: Photo)
                                    }
                            }
                                
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    // for better UX faire une page avec un p'tit bonhomme ptite animation "oh zut vous n'avez pas selectionné de photos
    private var emptyPlaceHolder: some View {
        VStack {
            Text("\(galleryViewModel.fetchedElements.count) photo/vidéo")
                .font(.title)
            Text("Ajoutez des photos depuis votre gallerie")
                .frame(width: UIScreen.main.bounds.width * 0.7)
        }
        .foregroundColor(Color.gray)
    }
    
    func performCompletion() {
        let image = galleryViewModel.selectedImage
        let video = galleryViewModel.selectedVideo
        
        contentCompletion(image, video)
    }
}
