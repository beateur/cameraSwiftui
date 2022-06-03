//
//  ThumbnailList.swift
//  CameraViews
//
//  Created by Bilel Hattay on 10/05/2022.
//

import SwiftUI

struct ThumbList: View {
    @EnvironmentObject var galleryViewModel: ImagePickerViewModel

    var body: some View {
        ThumbnailList
    }
    
    private var ThumbnailList: some View {
        VStack {
            Image(systemName: galleryViewModel.showPickerList ? "rectangle.fill" : "chevron.up")
                .resizable()
                .font(.system(size: 20, weight: .bold))
                .frame(width: 45, height: galleryViewModel.showPickerList ? 4 : 8)
                .padding(.vertical, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    
                    ForEach(galleryViewModel.fetchedElements, id: \.self) { Photo in
                        ThumbnailView(photo: Photo, size: UIScreen.main.bounds.size.height * 0.22)
                            .onTapGesture {
                                galleryViewModel.tapThumbnail(photo: Photo)
                            }
                    }
                    .padding(.leading)

                    if galleryViewModel.libraryStatus != .authorized {
                        VStack(spacing: 8) {
                            Text(galleryViewModel.libraryStatus == .denied ? "Acceder à votre gallerie" : "Plus de photos")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Button {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                            } label: {
                                Text(galleryViewModel.libraryStatus == .denied ? "Autoriser l'accès": "Sélectionner")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(Color.gray.opacity(0.9))
                                    .cornerRadius(12)
                            }

                        }
                        .padding()
                    }
                }
            }
            .frame(height: galleryViewModel.showPickerList ? UIScreen.main.bounds.size.height / 4 : 0)
            .opacity(galleryViewModel.showPickerList ? 1:0)
        }
        .background(Color.primary.opacity(galleryViewModel.showPickerList ? 0.08: 0.01))
        .gesture(
            DragGesture()
                .onChanged { value in

                }
                .onEnded{ value in
                    if value.translation.height > 0 && value.translation.height > UIScreen.main.bounds.size.height / 40 {
                        galleryViewModel.openPickerList()
                    }
                    
                    if value.translation.height < 0 && value.translation.height < -(UIScreen.main.bounds.size.height / 40) {
                        galleryViewModel.openPickerList()
                    }
                }
        ) // end gesture
    }
}
