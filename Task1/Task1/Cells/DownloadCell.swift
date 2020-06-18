//
//  TrackCell.swift
//  Task1
//
//  Created by Bhanuja Tirumareddy on 17/06/20.
//  Copyright © 2020 Bhanuja Tirumareddy. All rights reserved.
//

import UIKit

//
// MARK: - Download Cell Delegate Protocol
//
protocol DownloadDelegate {
  func cancelTapped(_ cell: DownloadCell)
  func downloadTapped(_ cell: DownloadCell)
  func pauseTapped(_ cell: DownloadCell)
  func resumeTapped(_ cell: DownloadCell)
  func playTapped(_ cell: DownloadCell)
}
//
// MARK: - Download Cell
//
class DownloadCell: UITableViewCell {
  //
  // MARK: - IBOutlets
  //
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var downloadButton: UIButton!
  @IBOutlet weak var pauseButton: UIButton!
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var viewButton: UIButton!
    
  //
  // MARK: - Variables And Properties
  //
  /// Delegate identifies track for this cell, then
  /// passes this to a download service method.
  var delegate: DownloadDelegate?
  //
  // MARK: - IBActions
  //
  @IBAction func cancelTapped(_ sender: AnyObject) {
    delegate?.cancelTapped(self)
  }
  @IBAction func downloadTapped(_ sender: AnyObject) {
    delegate?.downloadTapped(self)
  }
  @IBAction func pauseOrResumeTapped(_ sender: AnyObject) {
    if(pauseButton.titleLabel?.text == "Pause") {
      delegate?.pauseTapped(self)
    } else {
      delegate?.resumeTapped(self)
    }
  }
    @IBAction func viewButtonTapped(_ sender: Any) {
        delegate?.playTapped(self)
    }
    //
  // MARK: - Internal Methods
  //
  func configure(track: Track, downloaded: Bool, download: Download?) {
    titleLabel.text = track.previewURL.absoluteString
    artistLabel.text = track.artist
    // Show/hide download controls Pause/Resume, Cancel buttons, progress info.
    var showDownloadControls = false
    // Non-nil Download object means a download is in progress.
    if let download = download {
      showDownloadControls = true
    let title = download.isDownloading ? "Pause" : "Resume"
      pauseButton.setTitle(title, for: .normal)
      progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
    }
    pauseButton.isHidden   = !showDownloadControls
    cancelButton.isHidden  = !showDownloadControls
    progressView.isHidden  = !showDownloadControls
    progressLabel.isHidden = !showDownloadControls
    viewButton.isHidden    = true
    // If the track is already downloaded, enable cell selection and hide the Download button.
    selectionStyle = downloaded ? UITableViewCell.SelectionStyle.gray : UITableViewCell.SelectionStyle.none
    downloadButton.isHidden = downloaded || showDownloadControls
  }
  func updateDisplay(progress: Float, totalSize : String) {
    progressView.progress = progress
    if progress == 1 {
        viewButton.isHidden   = false
        pauseButton.isHidden  = true
        cancelButton.isHidden = true
    }
    progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
  }
}
