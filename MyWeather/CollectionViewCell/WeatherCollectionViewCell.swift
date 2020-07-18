//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by Thien Tung on 7/10/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    static let identifier = "WeatherCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell",
                     bundle: nil)
    }

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!

    
    func configure(with model: HourlyWeatherEntry) {
        let temp = (model.temperature-32)/1.8
        let tempFormatted = String(format: "%.0f", temp)
        self.tempLabel.text = tempFormatted
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage(named: "clear")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
