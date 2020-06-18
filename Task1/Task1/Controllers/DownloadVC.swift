//
//  DownloadVC.swift
//  Task1
//
//  Created by Bhanuja Tirumareddy on 17/06/20.
//  Copyright © 2020 Bhanuja Tirumareddy. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit

//
// MARK: - Search View Controller
//
class DownloadVC: UIViewController {
    //
    // MARK: - Constants
    //
    
    /// Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let downloadService = DownloadService()
    let queryService = QueryService()
    
    //
    // MARK: - IBOutlets
    //
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var customUrlTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    //
    // MARK: - Variables And Properties
    //
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier:
            "Maersk.Task1.bgSession")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if customUrlTextField.text == "" || customUrlTextField.text!.isEmpty {
            return Utility.Shared.showSimpleAlert(OnViewController: self, Message: "Enter the valid url to download the backgroundTask!")
        }
        guard let url = URL(string: customUrlTextField.text!) else { return }
        let searchTrack = Track(name: "", artist: "\(self.searchResults.count)", previewURL: url, index: self.searchResults.count)
        self.searchResults.append(searchTrack)
        reloadTableView()
    }
    var searchResults: [Track] = []
    //
    // MARK: - Internal Methods
    
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    func playDownload(_ track: Track) {
        let url = localFilePath(for: track.previewURL)
        if url.absoluteString.contains(".mp3") || url.absoluteString.contains(".mp4") || url.absoluteString.contains(".m4a") {
            let playerViewController = AVPlayerViewController()
            present(playerViewController, animated: true, completion: nil)
            let player = AVPlayer(url: url)
            playerViewController.player = player
            player.play()
        }
        else {
            Utility.Shared.showSimpleAlert(OnViewController: self, Message: "Sorry preview not handled other than Audio/Video.")
        }
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    //
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.layer.cornerRadius = 10
        tableView.tableFooterView = UIView()
        downloadService.downloadsSession = downloadsSession
        let AIView = Utility.Shared.showActivityIndicatory(uiView: self.view)
        self.view.addSubview(AIView)
        queryService.getSearchResults(searchTerm: "test") { [weak self] results, errorMessage in
            AIView.removeFromSuperview()
            if let results = results {
                self?.searchResults = results
                self?.reloadTableView()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
                Utility.Shared.showSimpleAlert(OnViewController: self, Message: errorMessage)
            }
        }
        
    }
    // MARK: - Table View reload
    func reloadTableView() {
        self.searchResults.sort{ (A: Track, B: Track) in
            return A.index > B.index
        }
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
        self.customUrlTextField.text = ""
        
    }
}

// MARK: - Table View Data Source
//
extension DownloadVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DownloadCell = tableView.dequeueReusableCell(withIdentifier:AppConstants.cellIdentifiers.downloadcellIdentifier,
                                                               for: indexPath) as! DownloadCell
        // Delegate cell button tap events to this view controller.
        cell.delegate = self
        
        let track = searchResults[indexPath.row]
        cell.configure(track: track,
                       downloaded: track.downloaded,
                       download: downloadService.activeDownloads[track.previewURL])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
}
//
// MARK: - Table View Delegate
//
extension DownloadVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //When user taps cell, play the local file, if it's downloaded.
        let track = searchResults[indexPath.row]
        if track.downloaded {
            playDownload(track)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
}
// MARK: - Track Cell Delegate
//
extension DownloadVC: DownloadDelegate {
    func cancelTapped(_ cell: DownloadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.cancelDownload(track)
            reload(indexPath.row)
        }
    }
    func downloadTapped(_ cell: DownloadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.startDownload(track, vc: self)
            reload(indexPath.row)
        }
    }
    func pauseTapped(_ cell: DownloadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.pauseDownload(track)
            reload(indexPath.row)
        }
    }
    func resumeTapped(_ cell: DownloadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.resumeDownload(track)
            reload(indexPath.row)
        }
    }
    func playTapped(_ cell: DownloadCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            playDownload(track)
        }
    }
}
// MARK: - URL Session Delegate
//
extension DownloadVC: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

// MARK: - URL Session Download Delegate
//
extension DownloadVC: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else {
            return
        }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.track.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        if let index = download?.track.index {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard
            let url = downloadTask.originalRequest?.url,
            let download = downloadService.activeDownloads[url]  else {
                return
        }
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        DispatchQueue.main.async {
            if let Cell = self.tableView.cellForRow(at: IndexPath(row: (self.searchResults.count - download.track.index)-1,
                                                                  section: 0)) as? DownloadCell {
                Cell.updateDisplay(progress: download.progress, totalSize: totalSize)
            }
        }
    }
}
