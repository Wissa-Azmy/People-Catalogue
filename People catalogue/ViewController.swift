//
//  ViewController.swift
//  People catalogue
//
//  Created by Wissa Azmy on 4/3/19.
//  Copyright © 2019 Wissa Azmy. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        if let peopleData = defaults.value(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                people = try jsonDecoder.decode([Person].self, from: peopleData)
            } catch {
                print("Error reading people's data.")
            }
        }
    }

    
    @objc private func addNewPerson() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        /*
         When you set self as the delegate,
         you'll need to conform not only to the UIImagePickerControllerDelegate protocol,
         but also the UINavigationControllerDelegate protocol
         */
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        saveData()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        if let peopleDate = try? jsonEncoder.encode(people) {
            defaults.set(peopleDate, forKey: "people")
        } else {
            print("Error saving people's data.")
        }
        
    }

}



extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PersonCell else {
            fatalError("Couldn't dequeue cell")
        }
        
        let person = people[indexPath.item]
        
        cell.personNameLbl.text = person.name
        let personImgURL = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.personImg.image = UIImage(contentsOfFile: personImgURL.path)
        
        cell.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.personImg.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Add Person name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let save = UIAlertAction(title: "Save", style: .default) { [weak self, ac] _ in
            if let newName = ac.textFields?[0].text {
                self?.people[indexPath.item].name = newName
                self?.saveData()
                self?.collectionView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(save)
        ac.addAction(cancel)
        
        present(ac, animated: true)
    }
}

