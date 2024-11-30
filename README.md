# WeatherNow

WeatherNow is a weather forecasting application designed to provide real-time weather updates and detailed forecasts for user-selected locations. The app leverages API integration to fetch accurate weather data and supports notifications for significant weather changes.

---

## Table of Contents

- Features
- Setup Instructions
- API Documentation
- Development Guidelines
- Contributing
- License

---

## Features

- Real-Time Weather Updates: Get current weather conditions and forecasts.
- User-Selected Locations: Save, sync, and manage favorite locations.
- Push Notifications: Receive alerts about significant weather changes.
- Forecasts: View multi-day weather predictions.

---

## Setup Instructions

### Prerequisites

1. Xcode: Ensure you have Xcode installed on your macOS system.
2. Swift Package Manager (SPM): Used to manage dependencies.
3. API Key: Obtain an API key from OpenWeatherMap.

### Installation

1. Clone the repository:
```bash
   git clone https://github.com/your-repo/WeatherNow.git
   cd WeatherNow
```

2. Open the project in Xcode:
   open WeatherNow.xcodeproj

3. Build and run the app:
   - Select a simulator or a connected device.
   - Press Cmd + R to build and run the app.

---

## API Documentation

### Weather API Endpoints

The app integrates with the OpenWeatherMap API to fetch weather data.

1. Current Weather
   - Endpoint: /weather
   - Parameters:
     - lat: Latitude of the location.
     - lon: Longitude of the location.
     - appid: Your API key.
   - Example:
     https://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&appid=APIK_KEY

2. Weather Forecast
   - Endpoint: /forecast
   - Parameters:
     - lat: Latitude of the location.
     - lon: Longitude of the location.
     - appid: Your API key.
   - Example:
     https://api.openweathermap.org/data/2.5/forecast?lat=35&lon=139&appid=APIK_KEY
3. Reverse Geocoding
	-	Endpoint: /geo/1.0/reverse
	-	Description: Retrieves the location name and details (e.g., city or country) based on geographic coordinates.
	    -	Parameters:
	    -	lat: Latitude of the location.
	    -	lon: Longitude of the location.
	    -	limit: Maximum number of results to return (optional, default is 5).
	    -	appid: Your API key.
	-	Example:
https://api.openweathermap.org/geo/1.0/reverse?lat=35&lon=139&limit=1&appid=APIK_KEY


## Development Guidelines

### Code Structure

- Models: Contains WeatherItem, ForecastWeather, and other data representations, usually in charge of getting the information from the desired sources.
- ViewModels: Manages the app's business logic.
- Views: UI components built using UIKit programmatically using autolayout.
- Networking/API classes: Handles API requests and responses.


### Project Folder Structure

- API
    All related to networking is contained inside 
- Common
    Within the common folder, you can find shared models and views that, as the title suggests, can be used in different parts of the application
    
- Module
Within the Module folder, you can find subfolders containing everything related to the business logic, currently including location registration, the list of locations, and weather details.

- Resources
In the Resources folder, you can find files related to configurations (e.g., .plist files), localized text files, and assets.

- Utils
Contains various utilities such as standard helper classes, extensions, color definitions, and size configurations.

### Dependency

#### [Loadable](https://github.com/Davidedgmunoz/Loadable)

This project uses a custom-made dependency to simplify the handling of data models and view models. The goal is to reduce boilerplate code and streamline the implementation of classes that require data loading behaviors.

#### Key Features:
- **Abstraction for Data Sources**: Handles data loading regardless of whether the source is a network API or local storage.
- **State Management**: Maintains states such as `.idle`, `.loading`, `.loaded`, and `.error`, ensuring a clear flow of data handling.
- **Combine Integration**: Utilizes Combine to notify changes in state, making it easy to bind updates directly to the UI.

#### Purpose:
This dependency abstracts the common tasks associated with managing models and view models that involve data loading, allowing you to focus on implementing business logic instead of repetitive code.

#### Benefits:
- **Boilerplate Reduction**: Simplifies the process of adding specific behaviors to data-loading classes.
- **Reusability**: Can be applied to any model or view model that requires structured state management.
- **Scalability**: Easily extendable for additional use cases, like caching or advanced error handling.



