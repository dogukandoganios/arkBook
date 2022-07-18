//
//  secondViewController.swift
//  arkBook
//
//  Created by Doğukan Doğan on 17.06.2022.
//

import UIKit
import CoreData

class secondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imageImageView = UIImageView()
    var nameTextField = UITextField()
    var artisTextFied = UITextField()
    var dateTextFied = UITextField()
    var saveButton = UIButton()
    var chosenPaitng = ""
    var chosenID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPaitng != ""{
            
            saveButton.isHidden = true
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paints")
            let idString = chosenID?.uuidString
            fetchReguest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchReguest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchReguest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        nameTextField.text = name
                    }
                    if let artist = result.value(forKey: "artist") as? String{
                        artisTextFied.text = artist
                    }
                    if let date = result.value(forKey: "date") as? Int{
                        dateTextFied.text = String(date)
                    }
                    if let imageData = result.value(forKey: "image") as? Data{
                        imageImageView.image = UIImage(data: imageData)
                    }
                }
            }catch{
                
            }
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            imageImageView.image = UIImage(named: "selectimage")
            nameTextField.placeholder = "name"
            artisTextFied.placeholder = "artis"
            dateTextFied.placeholder = "date"
        }
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        imageImageView.layer.borderWidth = 1
        imageImageView.frame = CGRect(x: width * 0.5 - width * 0.45 / 2, y: height * 0.25 - height * 0.15 / 2, width: width * 0.45, height: height * 0.15)
        view.addSubview(imageImageView)
        
        imageImageView.isUserInteractionEnabled = true
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageImageView.addGestureRecognizer(imageGesture)
        
        
        nameTextField.textAlignment = .center
        nameTextField.layer.borderWidth = 1
        nameTextField.frame = CGRect(x: width * 0.5 - width * 0.4 / 2, y: height * 0.4 - height * 0.05 / 2, width: width * 0.4, height: height * 0.05)
        view.addSubview(nameTextField)
        
        
        artisTextFied.textAlignment = .center
        artisTextFied.layer.borderWidth = 1
        artisTextFied.frame = CGRect(x: width * 0.5 - width * 0.4 / 2, y: height * 0.5 - height * 0.05 / 2, width: width * 0.4, height: height * 0.05)
        view.addSubview(artisTextFied)
        
        
        dateTextFied.textAlignment = .center
        dateTextFied.layer.borderWidth = 1
        dateTextFied.frame = CGRect(x: width * 0.5 - width * 0.4 / 2, y: height * 0.6 - height * 0.05 / 2, width: width * 0.4, height: height * 0.05)
        view.addSubview(dateTextFied)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(UIColor.black, for: .normal)
        saveButton.layer.borderWidth = 1
        saveButton.frame = CGRect(x: width * 0.5 - width * 0.2 / 2, y: height * 0.77 - height * 0.1 / 2, width: width * 0.2, height: height * 0.1)
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(saveClick), for: UIControl.Event.touchUpInside)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardHidden))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageImageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardHidden() {
        view.endEditing(true)
    }
    
    @objc func saveClick() {
        
        let appDeleget = UIApplication.shared.delegate as! AppDelegate
        let context = appDeleget.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paints", into: context)
        
        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artisTextFied.text!, forKey: "artist")
        if let date = Int(dateTextFied.text!){
            newPainting.setValue(date, forKey: "date")
        }
        let data = imageImageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        newPainting.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("succes")
        }catch{
            print("fail")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

}
