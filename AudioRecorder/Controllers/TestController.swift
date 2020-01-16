//
//  TestController.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 16.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit
import AVFoundation

class TestController: UITableViewController {
    weak var delegate: SessionFlowDelegate?
        
    func sessionHasChanged() {
        if audioSession == nil { return }
        do {
            audioPlayer.stop()
            try audioSession.setActive(false)
            audioSession = nil
        } catch {
            print("err")
        }
    }
    
    private var playingRecord: Record?
    private var index: Int?
    
    private let cellId = "recordCellId"
    private var records = [[Record]]()
    private var audioSession: AVAudioSession!
    private var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.register(TestCell.self, forCellReuseIdentifier: cellId)
        tableView.delaysContentTouches = false
        tableView.refreshControl = rc
        Record.fetchRecords().forEach { (record) in
            records.append([record])
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 1 {
            return 300
        }
        return 64
    }
    
    @objc
    private func handleRefresh() {
        Record.fetchRecords().forEach { (record) in
            records.append([record])
        }
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func setupSession() {
        if audioSession != nil { return }
        audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setActive(true)
            try audioSession.setCategory(.playback, mode: .default)
        } catch let err {
            print(err)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return records.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.item == 2 {
//
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TestCell
//        let cell = tableView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListCell
        cell.record = records[indexPath.section][0]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if playingRecord != nil {
            records[index!].removeLast()
            tableView.deleteRows(at: [.init(row: 1, section: index!)], with: .automatic)
        }
        playingRecord = records[indexPath.section][0]
        index = indexPath.section
        records[indexPath.section].append(playingRecord!)
        let newIndexPath = IndexPath(row: records[indexPath.section].count - 1, section: indexPath.section)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}

extension TestController: ListCellDelegate, AVAudioPlayerDelegate {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return .init(width: view.frame.width, height: 64)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
    
    func updateIcon() {
        if let item = Record.fetchRecords().firstIndex(where: { $0.fileUrl == playingRecord?.fileUrl }) {
            guard let cell = tableView.cellForRow(at: .init(item: 0, section: item)) as? TestCell else { return }
            cell.isPlaying = false
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateIcon()
    }
    
    func startPlaying(with url: String) {
        updateIcon()
        delegate?.startPlaying()
        setupSession()
        do {
            try audioSession.setCategory(.playback)
            audioPlayer = try AVAudioPlayer(contentsOf: FileManager.getDocumentsPath().appendingPathComponent(url))
            audioPlayer.delegate = self
            audioPlayer.volume = 1
            audioPlayer.play()
            playingRecord = Record.fetchRecords().first { $0.fileUrl == url }
        } catch let err{
            print(err)
        }
    }
    
    func actionButtonDidTapped(toPlay: Bool, fileUrl: String) {
        if playingRecord == nil {
            startPlaying(with: fileUrl)
        } else if playingRecord?.fileUrl == fileUrl && toPlay {
            audioPlayer.play()
        } else if playingRecord?.fileUrl != fileUrl {
            startPlaying(with: fileUrl)
        } else {
            audioPlayer.pause()
        }
    }
}
