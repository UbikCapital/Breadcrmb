/// Copyright (c) 2019 Sparktex, LLC

import CoreLocation
import Foundation
import ICONKit
import BigInt

// ICON services required for Breadcrmb
class IconServices{
  
  static let shared = IconServices()
  let iconService = ICONService(provider: "https://ctz.solidwallet.io/api/v3", nid: "0x1") // mainnet
  //let iconService = ICONService(provider: "https://bicon.net.solidwallet.io/api/v3", nid: "0x3") // testnet
  var wallet: Wallet!
  let scoreAddress = "cxb0f190b951acc10e9fa236817921140c75f6941a" // mainnet
  //let scoreAddress = "cx80a5a140d8a2e26a23187e8b3839f6d2ac2a6a47" // testnet
  var myBalance: Double!
  var myAddress: String!
  var firstTime = true
  
  init() {
    do{
      // load key
      let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
      let url = NSURL(fileURLWithPath: path)
      let jsonData = try Data(contentsOf: url.appendingPathComponent("iconkeystore")!)
      
      // decode key using pw stored locally on user device
      let decoder = JSONDecoder()
      let keystore = try decoder.decode(Keystore.self, from: jsonData)
      let password = UserDefaults.standard.string(forKey: "iconpass")
      self.wallet = try Wallet(keystore: keystore, password: password!)
      self.myBalance = updateBalance()
      self.myAddress = self.wallet.address
    }catch  {
      self.myBalance = 0.0
      // handle errors
    }
  }
  
// function to get balance and update in app
  func updateBalance() -> Double {
  let result = iconService.getBalance(address: wallet.address).execute()
    
    switch result {
    case .success(let balance):
      let newBalance = balance / BigUInt(100000000000000)
      let doubleBalance = Double(newBalance)
      let thisBalance = doubleBalance/10000.0
      self.myBalance = thisBalance
      return thisBalance
  
    case .failure(let error):
      return 0.0
    }
  }
  
  // function to write a location to the blockchain
  func writePlace(coordinates: CLLocationCoordinate2D, placeId: String, date: Date, name: String, address: String)-> String{
    let latitude = coordinates.latitude.description
    let longtitude = coordinates.longitude.description
    let thisDateString = Location.dateFormatter.string(from: date)
    let thisLocation = "(" + latitude + "," + longtitude + ")"
    let thisPlaceId = placeId
    let thisName = name
    let thisAddress = address
    
    do {
      let writeLocation = CallTransaction()
        .from(wallet.address)
        .to(scoreAddress)
        .stepLimit(1000000)
        .nid(self.iconService.nid)
        .nonce("0x1")
        .method("write_place")
        .params(["new_location": thisLocation, "placeId": thisPlaceId, "date": thisDateString, "name": thisName, "place_address": thisAddress])
      
      let signed = try SignedTransaction(transaction: writeLocation, privateKey: wallet.key.privateKey)
      let wrequest = iconService.sendTransaction(signedTransaction: signed)
      let wresponse = wrequest.execute()
      print(wresponse)
      let responseHash = try! wresponse.get()
      let newBalance = self.updateBalance()
      return responseHash
    } catch {
      let newBalance = self.updateBalance()
      return "none"
      // handle errors
    }
  }
  
    // function to write rating to blockchain
  func writeRating(placeId: String, rating: Int)-> String{
    let thisPlaceId = placeId
    let thisRating = rating.description
    
    do {
      let writeLocation = CallTransaction()
        .from(wallet.address)
        .to(scoreAddress)
        .stepLimit(1000000)
        .nid(self.iconService.nid)
        .nonce("0x1")
        .method("write_rating")
        .params(["placeId": thisPlaceId, "rating": thisRating])
      
      let signed = try SignedTransaction(transaction: writeLocation, privateKey: wallet.key.privateKey)
      let wrequest = iconService.sendTransaction(signedTransaction: signed)
      let wresponse = wrequest.execute()
      print(wresponse)
      let responseHash = try! wresponse.get()
      let newBalance = self.updateBalance()
      return responseHash
    } catch {
      let newBalance = self.updateBalance()
      return "none"
      // handle errors
    }
  }
  
}
