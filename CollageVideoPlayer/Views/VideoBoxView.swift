//
//  VideoBoxView.swift
//  CollageVideoPlayer
//
//  Created by Sheharyar on 26/03/2025.
//

import SwiftUI

struct VideoBoxView: View {
    let url: URL?
    let index: Int
    @Binding var isPlaying: Bool
    let action: () -> Void

    var body: some View {
        if let url = url {
            AVPlayerView(fileUrl: .constant(url), isPlaying: $isPlaying)
                .frame(width: 320, height: 200)
        } else {
            Button(action: action) {
                ZStack {
                    Rectangle()
                        .fill(Color.indigo.opacity(0.15))
                        .frame(width: UIScreen.main.bounds.width, height: 200)
                    VStack {
                        Image(systemName: "video.badge.plus")
                            .foregroundColor(Color.indigo)
                        
                        Text("Video \(index + 1)")
                            .font(.headline)
                            .foregroundColor(Color.indigo)
                    }.padding()
                }
            }
        }
    }
}
