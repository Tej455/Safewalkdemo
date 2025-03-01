//
//  ContentView.swift
//  Safewalk
//
//  Created by Aryatej Reddy B on 2/28/25.
import SwiftUI
import MapKit
import CoreLocation
import UserNotifications
import MessageUI
import pandas as pd

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var emergencyTriggered = false
    @State private var showMessageCompose = false
    
    var body: some View {
        VStack {
            MapView(userLocation: locationManager.userLocation)
                .edgesIgnoringSafeArea(.all)
                .frame(height: 400)
            
            VStack(spacing: 20) {
                Text("SafeWalk")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button(action: {
                    emergencyTriggered.toggle()
                    sendEmergencyAlert()
                }) {
                    Text("Emergency Alert")
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    shareLiveLocation()
                }) {
                    Text("Share Live Location via SMS")
                        .frame(width: 250, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    func sendEmergencyAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Emergency Alert!"
        content.body = "Emergency triggered at your current location."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "emergencyAlert", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending alert: \(error.localizedDescription)")
            } else {
                print("Emergency alert triggered successfully.")
            }
        }
    }
    
    func shareLiveLocation() {
        guard let userLocation = locationManager.userLocation else { return }
        let locationMessage = "I'm sharing my live location:"
        import pandas as pd

        # Load the dataset
        file_path = "./data/Crime_Data_from_2020_to_Present.csv"
        df = pd.read_csv(file_path)

        # Select relevant columns
        df = df[["DATE OCC", "TIME OCC", "AREA NAME", "Crm Cd Desc", "LAT", "LON"]]

        # Convert "DATE OCC" to datetime format
        df["DATE OCC"] = pd.to_datetime(df["DATE OCC"])

        # Drop rows with missing location data
        df = df.dropna(subset=["LAT", "LON"])

        # Count crime occurrences per area
        crime_counts = df["AREA NAME"].value_counts()

        # Define "safe" and "unsafe" areas (threshold-based)
        safe_areas = crime_counts[crime_counts < 1000].index.tolist()
        unsafe_areas = crime_counts[crime_counts >= 1000].index.tolist()

        # Save processed data
        df.to_csv("./data/processed_crime_data.csv", index=False)

        print(f"Safe areas: {safe_areas}")
        print(f"Unsafe areas: {unsafe_areas}")

