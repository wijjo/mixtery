//
//  ViewController.swift
//  Mixtery
//
//  Created by Steve Cooper on 1/8/15.
//  Copyright (c) 2015 Steve Cooper. All rights reserved.
//

import UIKit
import MediaPlayer

private func timeIntervalToString(time: NSTimeInterval) -> String {
    let seconds = Int(time)
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
}

private func displayTimeInterval(bbi: UIBarButtonItem, time: NSTimeInterval) {
    let newText = timeIntervalToString(time)
    if bbi.title != newText {
        bbi.title = newText
    }
}

private struct ViewControllerDebugProperties {
    // Limit # of songs in collection: nil or number <= 0 plays all songs
    var maxSongs: Int?

    // Skip to last few seconds to debug transitions if not nil.
    var playLastSeconds: Int?
}

class ViewController: UIViewController, SCSCMusicPlayerControllerDelegate {

    //=== Configuration properties

    // Truncate title at # of characters
    private let maxSongTitleLength = 40

    //=== Debug properties

    private let debug = ViewControllerDebugProperties(maxSongs: nil, playLastSeconds: nil)

    //=== Runtime properties

    private var songs: [MPMediaItem]!
    private var placeholderImage: UIImage!
    private var nowPlayingCounter = 0
    private var player: SCSCMusicPlayerController!
    private var collection: MPMediaItemCollection?

    //=== Control outlets

    @IBOutlet private weak var uiLabel: MarqueeLabel!
    @IBOutlet private weak var uiCoverImage: UIImageView!
    @IBOutlet private weak var uiPlayButton: UIBarButtonItem!
    @IBOutlet weak var uiDuration: UIBarButtonItem!
    @IBOutlet weak var uiElapsed: UIBarButtonItem!
    
    //=== UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeholderImage = UIImage(named: "placeholder")
        self.player = SCSCMusicPlayerController(delegate: self)
        self.generateCollection()
        self.playCollection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func generateCollection() {
        self.songs = MPMediaQuery.songsQuery().items as [MPMediaItem]
        if !songs.isEmpty {
            self.songs.shuffle()
            if let maxSongs = self.debug.maxSongs {
                if maxSongs > 0 && maxSongs < self.songs.count {
                    self.songs = Array(self.songs[0..<maxSongs])
                }
            }
            self.collection = MPMediaItemCollection(items: self.songs)
        }
    }

    private func playCollection() {
        if let collection = self.collection {
            self.player.setQueueWithItemCollection(collection)
            self.player.play()
        }
    }

    //=== SCSCMusicPlayerControllerDelegate

    func musicPlayerControllerNotification(
            event: SCSCMusicPlayerControllerEvent,
            player: SCSCMusicPlayerController) {
        switch event {
        case .ChangedNowPlaying:
            self.debug("Now playing")
            self.displaySongInfo(player.nowPlayingItem, index: player.indexOfNowPlayingItem)
            displayTimeInterval(self.uiDuration, player.nowPlayingItem.playbackDuration)
            displayTimeInterval(self.uiElapsed, 0)
            self.displayArtworkForItem(player.nowPlayingItem)
            if let playLastSeconds = self.debug.playLastSeconds {
                self.player.player.currentPlaybackTime = player.nowPlayingItem.playbackDuration - NSTimeInterval(playLastSeconds)
            }
        case .ChangedPlaybackState:
            self.debug("Playback state")
            self.updateControlsForPlaybackState(player.playbackState)
            if self.player.playbackState == .Stopped && self.player.nowPlayingItem == nil {
                self.playCollection()
            }
        case .ChangedElapsedTime:
            displayTimeInterval(self.uiElapsed, player.currentPlaybackTime)
        }
    }

    //=== Control actions

    @IBAction func playButtonAction(sender: AnyObject) {
        switch self.player.playbackState {
        case .Playing:
            self.player.pause()
        default:
            self.player.play()
        }
    }

    @IBAction func backButtonAction(sender: AnyObject) {
        if self.songs.count > 0 {
            self.player.skipToPreviousItem()
        }
    }

    @IBAction func forwardButtonAction(sender: AnyObject) {
        if self.songs.count > 0 {
            self.player.skipToNextItem()
        }
    }

    //=== Private methods

    private func displaySongInfo(item: MPMediaItem, index: Int) {
        self.uiLabel.text = "#\(index+1) of \(self.songs.count) - \(item.artist) - \(item.albumTitle) - \(item.title)"
    }

    private func displayArtworkForItem(item: MPMediaItem) {
        var image: UIImage?
        if let artwork =  item.valueForKey(
                MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            image = artwork.imageWithSize(artwork.bounds.size)
            println("Using artwork image")
        }
        if image == nil {
            println("Using placeholder image")
            image = self.placeholderImage
        }
        self.uiCoverImage.image = image
    }

    private func updateControlsForPlaybackState(playbackState: MPMusicPlaybackState) {
        switch playbackState {
        case .Interrupted:
            break
        case .Paused:
            self.uiPlayButton.image = UIImage(named: "play")
        case .Playing:
            self.uiPlayButton.image = UIImage(named: "pause")
        case .SeekingBackward:
            break
        case .SeekingForward:
            break
        case .Stopped:
            self.uiPlayButton.image = UIImage(named: "play")
        }
    }

    private func debug(label: String) {
        let elapsed = timeIntervalToString(self.player.currentPlaybackTime)
        let state = "\(self.player.playbackStateString)(\(self.player.playbackState.rawValue))"
        let song = self.player.nowPlayingItem?.artist != nil
            ? "\(self.player.nowPlayingItem.artist) - \(self.player.nowPlayingItem.title)"
            : "(no song)"
        println("DEBUG[\(label)]: \(elapsed) \(state) \(song)")
    }
}
