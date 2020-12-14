//
//  TrackCell.swift
//  IMusic
//
//  Created by Андрей on 03.12.2020.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel  {
    var iconUrlString: String? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
}

class TrackCell: UITableViewCell {
    
    static let reuseId = "TrackCell"
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addTrackButton: UIButton!
    
    var cell: SearchViewModel.Cell?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trackImageView.image = nil
    }
    
    func set(viewModel: SearchViewModel.Cell) {
        
        self.cell = viewModel
        
        let savedTracks = UserDefaults.standard.savedTracks()
        let hasFavorite = savedTracks.firstIndex(where: { $0.trackName == self.cell?.trackName && $0.artistName == self.cell?.artistName }) != nil
        if hasFavorite {
            addTrackButton.isHidden = true
        } else {
            addTrackButton.isHidden = false
        }
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold, scale: .large)
        let largePlus = UIImage(systemName: "plus", withConfiguration: largeConfig)
        addButton.setImage(largePlus, for: .normal)
        
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
        
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
        
    }
    
    @IBAction func addTrackAction(_ sender: Any) {
        guard let cell = cell else { return }
        let defaults = UserDefaults.standard
        var listOfTracks = defaults.savedTracks()
        listOfTracks.append(cell)
        addTrackButton.isHidden = true
        
        do {
            let savedData = try NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false)
            defaults.setValue(savedData, forKey: UserDefaults.favouriteTrackKey)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
