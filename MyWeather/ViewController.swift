//
//  ViewController.swift
//  MyWeather
//
//  Created by Thien Tung on 7/10/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit
import CoreLocation

// custom cell: collection view
// API / request to get the data

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var table: UITableView!
    
    @IBOutlet weak var imageBackground: UIImageView!
    
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var current: CurrentWeather?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Register 2 cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)

        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false

        table.backgroundColor = .clear//UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        view.backgroundColor = .clear//UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }

    // Location

    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil  {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }

    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        print(long, lat)

        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]"

        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in

            // Validation
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }

            // Convert data to models/some object

            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error: \(error)")
            }

            guard let result = json else {
                return
            }

            let entries = result.daily.data

            self.models.append(contentsOf: entries)

            let current = result.currently
            self.current = current

            self.hourlyModels = result.hourly.data

            // Update user interface
            DispatchQueue.main.async {
                self.table.reloadData()
                if self.current!.temperature >= Double(30) {
                    self.imageBackground.image = UIImage(named: "sunny")
                } else if self.current!.temperature >= Double(20) {
                    self.imageBackground.image = UIImage(named: "cloudy")
                } else {
                    self.imageBackground.image = UIImage(named: "storm")
                }
                self.table.tableHeaderView = self.createTableHeader()
            }

        }).resume()
    }

    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width*2/3))

        headerView.backgroundColor = .clear//UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)

        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))

        headerView.addSubview(locationLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(summaryLabel)

        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center

        locationLabel.text = "Current Location"

        guard let currentWeather = self.current else {
            return UIView()
        }
        
        let currentTemp = (currentWeather.temperature-32)/1.8
        let currentTempFormatted = String(format: "%.0f", currentTemp)
        tempLabel.text = "\(currentTempFormatted)°"
        tempLabel.font = UIFont(name: "Helvetica", size: 78)
        summaryLabel.text = self.current?.summary

        return headerView
    }


    // Table

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 1 cell that is collectiontableviewcell
            return 1
        }
        // return models count
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.white.cgColor
            cell.configure(with: hourlyModels)
            cell.backgroundColor = .clear//UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
            return cell
        }

        // Continue
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = .clear//UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

