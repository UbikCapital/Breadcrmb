/// Copyright (c) 2019 Sparktex, LLC

import UIKit
import ICONKit

class WelcomeViewController: UIViewController, UITextFieldDelegate{
  
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
  
    override func viewDidLoad() {
    super.viewDidLoad()
    passwordField.delegate = self as UITextFieldDelegate
  }
    @IBAction func submitPressed(_ sender: Any) {
      let passwordText = passwordField.text
      print(passwordText)
      print(passwordText?.count)
      
      if(passwordText!.count < 1){
          // don't do anything as there is no password
      }else{
        
      let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
      let url = NSURL(fileURLWithPath: path)
      let pathComponent = url.appendingPathComponent("iconkeystore")
      let wallet = Wallet(privateKey: nil)
      
      do {
        // create wallet with user password. Store user password locally
        UserDefaults.standard.set(passwordText, forKey: "iconpass")
        try wallet.generateKeystore(password: passwordText!)
        try wallet.save(filepath: pathComponent!)
        let iconService = IconServices.shared
        iconService.firstTime = true
        self.performSegue(withIdentifier: "submitSegue", sender: self)
          print("completed")
      } catch {
        print("errors")
        // handle errors
      }
      }
    }
  
  // Hide the keyboard when the return key pressed
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
 
  // limit password to 16 characters or less
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentText = textField.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }
    
    let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
    
    return updatedText.count <= 16
  }
  
  // limit password to 16 characters or less
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentText = textView.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }
    
    let changedText = currentText.replacingCharacters(in: stringRange, with: text)
    
    return changedText.count <= 16
  }
  
}
