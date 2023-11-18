//
//  ContentView.swift
//  SleepApp
//
//  Created by Chommanee Rujijanakul on 18/11/2566 BE.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.05)
                Text("Dairy coffee intake").font(.headline)
                Stepper("\(coffeeAmount.formatted()) cup(s)", value: $coffeeAmount, in: 0...5)
            }
            .navigationTitle("BetterSleep")
            .toolbar{
                Button("Calculate", action: calBedtime)
            }
            .alert(alertTitle,isPresented: $showingAlert){
                Button("Ok") {}
            } message: {
                Text(alertMessage)
            }
            
        }
        
    }
    
    func calBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (component.hour ?? 0) * 60 * 60
            
            let minite = (component.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour+minite), estimatedSleep: sleepAmount, coffee: Double(sleepAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your Ideal bedtime is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch{
            alertTitle = "Sorry"
            alertMessage = "There was a mistake in calculating your bed time"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
