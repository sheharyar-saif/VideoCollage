//
//  AVPlayerView.swift
//  CollageVideoPlayer
//
//  Created by Sheharyar on 26/03/2025.
//


import SwiftUI
import AVKit

struct AVPlayerView: UIViewControllerRepresentable {
    
    @Binding var fileUrl: URL!
    @Binding var isPlaying: Bool

    private var player: AVPlayer {
        return AVPlayer(url: fileUrl)
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.player = player
        playerController.allowsPictureInPicturePlayback = true
        playerController.showsPlaybackControls = false  // Hide all controls
        playerController.videoGravity = .resizeAspectFill // Set video to aspect fill
        
        if isPlaying {
            playerController.player?.play()
        } else {
            playerController.player?.pause()
        }
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false  // Hide all controls
        controller.videoGravity = .resizeAspectFill // Set video to aspect fill
        return controller
    }
}