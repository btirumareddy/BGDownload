//
//  Track.swift
//  Task1
//
//  Created by Bhanuja Tirumareddy on 17/06/20.
//  Copyright © 2020 Bhanuja Tirumareddy. All rights reserved.
//

import Foundation.NSURL

class Track {
  let artist: String
  let index: Int
  let name: String
  let previewURL: URL
  // MARK: - Variables And Properties
  var downloaded = false
  // MARK: - Initialization
  //
  init(name: String, artist: String, previewURL: URL, index: Int) {
    self.name = name
    self.artist = artist
    self.previewURL = previewURL
    self.index = index
  }
}
