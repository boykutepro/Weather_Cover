//
//  WeatherTableViewCell.swift
//  MyWeather
//
//  Created by Thien Tung on 7/10/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//
import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static let identifier = "WeatherTableViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell",
                     bundle: nil)
    }

    func configure(with model: DailyWeatherEntry) {
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        let lowTemp = (model.temperatureLow-32)/1.8
        let lowTempFormatted = String(format: "%.0f", lowTemp)
        self.lowTempLabel.text = "\(lowTempFormatted)°"
        
        let highTemp = (model.temperatureHigh-32)/1.8
        let highTempFormatted = String(format: "%.0f", highTemp)
        self.highTempLabel.text = "\(highTempFormatted)°"
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.time)))
        self.iconImageView.contentMode = .scaleAspectFit

        let icon = model.icon.lowercased()
        if icon.contains("clear") {
            self.iconImageView.image = UIImage(named: "clear")
        }
        else if icon.contains("rain") {
            self.iconImageView.image = UIImage(named: "rain")
        }
        else {
            // cloud icon
            self.iconImageView.image = UIImage(named: "clear")
        }

    }

    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Monday
        return formatter.string(from: inputDate)
    }
    
}
