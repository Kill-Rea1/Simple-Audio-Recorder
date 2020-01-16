//
//  ListController.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 15.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit

final class ListController: UITableViewController {
    
    // MARK:- SessionFlowDelegate
    weak var delegate: SessionFlowDelegate?
        
    func sessionHasChanged() {
        guard let cell = tableView.cellForRow(at: .init(row: 1, section: index ?? -1)) as? PlayerCell else { return }
        cell.changeSessionActivity()
    }
    
    func getRecords() {
        records = []
        playingRecord = nil
        index = nil
        Record.fetchRecords().forEach { (record) in
            records.append([record])
        }
        tableView.reloadData()
    }
    
    // MARK:- Properties
    private var playingRecord: Record?
    private var index: Int?
    
    private let listCell = "recordCellId"
    private let playerCell = "playerCellId"
    private var records = [[Record]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK:- Private Methods
    private func setup() {
        tableView.register(ListCell.self, forCellReuseIdentifier: listCell)
        tableView.register(PlayerCell.self, forCellReuseIdentifier: playerCell)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        getRecords()
    }
    
    // MARK:- TableView Methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 1 {
            return 128
        }
        return 64
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return records.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: playerCell, for: indexPath) as! PlayerCell
            cell.animate(to: 1)
            cell.record = records[indexPath.section][0]
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: listCell, for: indexPath) as! ListCell
        cell.record = records[indexPath.section][0]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 || indexPath.section == index ?? -1 {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        tableView.beginUpdates()
        if playingRecord != nil {
            records[index!].removeLast()
            let playerIndexPath = IndexPath(row: 1, section: index!)
            guard let cell = tableView.cellForRow(at: playerIndexPath) as? PlayerCell else { return }
            cell.animate(to: 0)
            tableView.deleteRows(at: [playerIndexPath], with: .top)
        }
        playingRecord = records[indexPath.section][0]
        index = indexPath.section
        records[indexPath.section].append(playingRecord!)
        let newIndexPath = IndexPath(row: records[indexPath.section].count - 1, section: indexPath.section)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.endUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- PlayerCellDelegate
extension ListController: PlayerCellDelegate {
    func deleteRecord() {
        Record.deleteRecord(at: index!)
        records.remove(at: index!)
        let indexSet = IndexSet(arrayLiteral: index!)
        tableView.deleteSections(indexSet, with: .fade)
        playingRecord = nil
        index = nil
    }
}

