//
//  WeatherManager.swift
//  Clima
//
//  Created by BAHLCP on 04/06/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didWeatherUpdate(_ weatherManager: WeatherManager, weatherModel: WeatherModel)
    func didFailWithError(error : Error)
}

class WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=4bc88c615bd193ca684deb8468121b59"
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString="\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
        
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string : urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler:responseHandler(data:urlResponse:error:))
            task.resume()
        }
    }
    
    func responseHandler(data : Data? , urlResponse : URLResponse? , error : Error?){
        if error != nil {
            delegate?.didFailWithError(error: error!)
            return
        }
        
        if let safeData = data{
            if let weatherModel = parseJSON(safeData){
                delegate?.didWeatherUpdate(self, weatherModel: weatherModel)
            }
        }
    }
    
    func parseJSON(_ weatherData : Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherModel = WeatherModel(cityName: decodedData.name, conditionID: decodedData.weather[0].id, temprature: decodedData.main.temp)
        return weatherModel

        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    

}
