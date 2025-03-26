//
//  HomeView.swift
//  CollageVideoPlayer
//
//  Created by Sheharyar on 25/03/2025.
//

import SwiftUI
import AVKit
import PhotosUI
import MobileCoreServices
import AVFoundation

struct HomeView: View {
    @State private var videoURLs: [URL?] = Array(repeating: nil, count: 3)
    @State private var selectedIndex: Int? = nil
    @State private var isVideoPickerPresented = false
    @State private var players: [AVPlayer] = []
    @State private var isPlaying = false
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    @State private var showExportSuccess = false
    @State private var showExportError = false
    @State private var exportError: String = ""
    @State private var selectedVideoIndex: Int? = nil
    
    var body: some View {
        VStack {
            Text("Video Collage Maker")
                .font(.title)
                .bold()
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        VideoBoxView(url: videoURLs[index], index: index, isPlaying: $isPlaying, action: {
                            selectedIndex = index
                            isVideoPickerPresented = true
                        })
                    }
                }
            }
            
            HStack {
                if !videoURLs.allSatisfy({ $0 == nil }) {
                    Button(action: togglePlayback) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color.indigo)
                    }
                    .padding()
                }
                
                if videoURLs.allSatisfy({ $0 != nil }) && !isExporting {
                    Button(action: exportCollagedVideo) {
                        Text("Export Video")
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            
            if isExporting {
                VStack {
                    ProgressView(value: exportProgress, total: 1.0)
                        .tint(.indigo)
                    Text("Exporting... \(Int(exportProgress * 100))%")
                }
                .padding()
            } else  if showExportSuccess {
                Text("Video exported successfully!")
                    .foregroundColor(.green)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showExportSuccess = false
                        }
                    }
            }
            
            if showExportError {
                Text("Error: \(exportError)")
                    .foregroundColor(.red)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showExportError = false
                        }
                    }
            }
        }
        .sheet(isPresented: $isVideoPickerPresented) {
            VideoPicker(selectedURL: Binding(
                get: { videoURLs[selectedIndex ?? 0] },
                set: { newURL in
                    if let newURL = newURL {
                        videoURLs[selectedIndex ?? 0] = newURL
                        setupPlayers()
                    }
                }
            ))
        }
    }
    
    private func setupPlayers() {
        players = videoURLs.compactMap { url in
            guard let url = url else { return nil }
            let player = AVPlayer(url: url)
            player.actionAtItemEnd = .none
            return player
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            players.forEach { $0.pause() }
        } else {
            players.forEach { $0.play() }
            players.forEach { $0.seek(to: .zero) }
        }
        isPlaying.toggle()
    }
    
    private func showExportError(message: String) {
        exportError = message
        showExportError = true
        isExporting = false
    }
    
    private func saveVideoToPhotoLibrary(_ url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Video saved to photo library")
                    showExportSuccess = true
                } else if let error = error {
                    print("Error saving video: \(error.localizedDescription)")
                    showExportError(message: "Failed to save to Photos: \(error.localizedDescription)")
                }
                
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
    
    private func exportCollagedVideo() {
        isExporting = true
        exportProgress = 0
        
        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()
        
        let collageSize = CGSize(width: 1080, height: 1920)
        videoComposition.renderSize = collageSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        var videoTracks: [AVAssetTrack] = []
        var assets: [AVAsset] = []
        var instructions: [AVMutableVideoCompositionLayerInstruction] = []
        
        for url in videoURLs.compactMap({ $0 }) {
            let asset = AVAsset(url: url)
            if let track = asset.tracks(withMediaType: .video).first {
                assets.append(asset)
                videoTracks.append(track)
            }
        }
        
        guard videoTracks.count == 3 else {
            showExportError(message: "Please select exactly 3 videos.")
            return
        }
        
        let minDuration = assets.map { $0.duration }.min() ?? CMTimeMake(value: 5, timescale: 1)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: minDuration)
        
        let positions: [CGRect] = [
            CGRect(x: 0, y: 0, width: 1080, height: 640),
            CGRect(x: 0, y: 640, width: 1080, height: 640),
            CGRect(x: 0, y: 1280, width: 1080, height: 640)
        ]
        
        for (index, asset) in assets.enumerated() {
            guard let videoTrack = asset.tracks(withMediaType: .video).first else { continue }
            
            let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? compositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: minDuration), of: videoTrack, at: .zero)
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack!)
            
            let naturalSize = videoTrack.naturalSize
            let videoAspectRatio = naturalSize.width / naturalSize.height
            let targetAspectRatio = positions[index].width / positions[index].height
            
            var scaleTransform: CGAffineTransform
            if videoAspectRatio > targetAspectRatio {
                let scale = positions[index].height / naturalSize.height
                let scaledWidth = naturalSize.width * scale
                let xOffset = (scaledWidth - positions[index].width) / 2
                scaleTransform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: -xOffset, y: 0)
            } else {
                let scale = positions[index].width / naturalSize.width
                let scaledHeight = naturalSize.height * scale
                let yOffset = (scaledHeight - positions[index].height) / 2
                scaleTransform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: -yOffset)
            }
            
            let finalTransform = scaleTransform.concatenating(CGAffineTransform(translationX: positions[index].origin.x, y: positions[index].origin.y))
            
            layerInstruction.setTransform(finalTransform, at: .zero)
            instructions.append(layerInstruction)
        }
        
        instruction.layerInstructions = instructions
        videoComposition.instructions = [instruction]
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            showExportError(message: "Failed to create export session")
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("collaged_video.mov")
        
        exportSession.outputURL = tempURL
        exportSession.outputFileType = .mov
        exportSession.videoComposition = videoComposition
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    self.saveVideoToPhotoLibrary(tempURL)
                case .failed:
                    if let error = exportSession.error {
                        self.showExportError(message: "Export failed: \(error.localizedDescription)")
                    }
                case .cancelled:
                    self.showExportError(message: "Export cancelled")
                default:
                    break
                }
                self.isExporting = false
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if exportSession.status == .exporting {
                self.exportProgress = Double(exportSession.progress)
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    HomeView()
}
