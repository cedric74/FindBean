void setup() {
  // put your setup code here, to run once:
  Bean.setBeanName("Cedric_Bean_1");
  
   // Bean Serial is at a fixed baud rate. Changing the value in Serial.begin() has no effect.
  Serial.begin();

   // Turn off the Bean's LED    
  Bean.setLed(0,0,0);  

}

void loop() {
  // put your main code here, to run repeatedly:

  // Get the temperature
  int temperature = Bean.getTemperature();

  // Returns the voltage with conversion of 0.01 V/unit
 uint16_t batteryReading =  Bean.getBatteryVoltage(); 
 
  int getBatterieLevel = Bean.getBatteryVoltage(); 
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" C");

  // Format the output like "Battery voltage: 2.60 V"
 String stringToPrint = String();
 stringToPrint = stringToPrint + "Battery voltage: " + batteryReading/100 + "." + batteryReading%100 + " V";
 Serial.println(stringToPrint);
  
  // Sleep for 1 minute, then read the temperature again
  Bean.sleep(60000);

}
