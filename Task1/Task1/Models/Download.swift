//
//  Download.swift
//  Task1
//
//  Created by Bhanuja Tirumareddy on 17/06/20.
//  Copyright © 2020 Bhanuja Tirumareddy. All rights reserved.
//

import Foundation

class Download {
  //
  // MARK: - Variables And Properties
  var isDownloading = false
  var progress: Float = 0
  var resumeData: Data?
  var task: URLSessionDownloadTask?
  var track: Track
  // MARK: - Initialization
  //
  init(track: Track) {
    self.track = track
  }
}
