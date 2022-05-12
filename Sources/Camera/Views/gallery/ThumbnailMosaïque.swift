//
//  SwiftUIView.swift
//  
//
//  Created by Bilel Hattay on 12/05/2022.
//

import SwiftUI

struct ThumbnailMosaïque: View {
    @EnvironmentObject var galleryViewModel: ImagePickerViewModel

    let gridItem = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        VStack {
            if galleryViewModel.libraryStatus != .authorized {
                VStack(spacing: 8) {
                    Text("Accedez à votre gallerie")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .frame(width: UIScreen.main.bounds.width, height: 50)
                .background(Color.gray.opacity(0.6))
                .onTapGesture {
                    galleryViewModel.fetchElements()
                }
            }

            if galleryViewModel.fetchedElements.isEmpty {
                emptyPlaceHolder
            } else {
                ScrollView {
                    LazyVGrid(columns: gridItem, spacing: 0.5) {
                        ForEach(galleryViewModel.fetchedElements, id: \.self) { Photo in
                            ThumbnailView(photo: Photo)
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
