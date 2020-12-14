//
//  TrackDetailView.swift
//  IMusic
//
//  Created by Андрей on 04.12.2020.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate {
    func moveBackForPreviouseTrack() -> SearchViewModel.Cell?
    func moveForwardForPreviouseTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniImageView: UIImageView!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    @IBOutlet weak var miniTrackName: UILabel!
    
    let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    // MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        
        setupGesture()
    }
    
    // MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        trackTitleLabel.text = viewModel.trackName
        miniTrackName.text = viewModel.trackName
        authorNameLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        observePalyerCurrentTime()
        
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
        miniImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func setupGesture() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissAllPan)))
    }
    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    // MARK: - Maximizing and minimizing gestures
    
    @objc private func handleTapMaximized() {
        self.tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .changed:
            handlePanChanget(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        @unknown default:
            print("@unknown default")
        }
    }
    
    @objc private func handleDismissAllPan(gesture: UIPanGestureRecognizer ) {
        switch gesture.state {
        case .changed:
            handlePanChangetDismiss(gesture: gesture)
        case .ended:
            handlePanEndedDismiss(gesture: gesture)
        @unknown default:
            print("@unknown default")
        }
    }
    
    private func handlePanChangetDismiss(gesture: UIPanGestureRecognizer ) {
        let translation = gesture.translation(in: self.superview)
        maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
    }
    
    private func handlePanEndedDismiss(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.maximizedStackView.transform = .identity
                        if translation.y > 50 {
                            self.tabBarDelegate?.minimizeTrackDetailController()
                        }
                       },
                       completion: nil)
    }
    
    private func handlePanChanget(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.transform = .identity
                        if translation.y < -200 || velocity.y < -500 {
                            self.tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
                        } else {
                            self.miniTrackView.alpha = 1
                            self.maximizedStackView.alpha = 0
                        }
                       },
                       completion: nil)
    }
    
    // MARK: - Time setup
    
    private func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observePalyerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            let durationTime = self?.player.currentItem?.duration
            let currentDurationTime = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time)
            
            self?.currentTimeLabel.text = time.toDisplayString()
            self?.durationLabel.text = "-\(currentDurationTime.toDisplayString())"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    // MARK: - Animations
    
    private func enlargeTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                self.trackImageView.transform = .identity
            },
            completion: nil)
    }
    
    private func reduceTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                let scale: CGFloat = 0.8
                self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: nil)
    }
    
    // MARK: - @IBAction
    
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func previousTrack(_ sender: Any) {
        guard let cellViewModel = delegate?.moveBackForPreviouseTrack() else { return }
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        guard let cellViewModel = delegate?.moveForwardForPreviouseTrack() else { return }
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            reduceTrackImageView()
        }
    }
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        self.tabBarDelegate?.minimizeTrackDetailController()
    }
}
