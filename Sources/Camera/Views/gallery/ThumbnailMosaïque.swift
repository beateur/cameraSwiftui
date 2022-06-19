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
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: galleryViewModel.selectedVideo) { _ in
            performCompletion()
        }
        .onChange(of: galleryViewModel.selectedImage) { _ in
            performCompletion()
        }
    }
    
    private var header: some View {
        Group {
            if galleryViewModel.libraryStatus != .authorized {
                Button {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
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
                            ThumbnailView(photo: Photo, size: UIScreen.main.bounds.size.width * 0.2475)
                                .onTapGesture {
                                    galleryViewModel.tapThumbnail(photo: Photo)
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    private var emptyPlaceHolder: some View {
        VStack {
            Text("0 photo/vidéo")
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
