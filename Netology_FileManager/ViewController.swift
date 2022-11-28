import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var currentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var currentDirectoryFilesURL: [URL] {
        return (try? FileManager.default.contentsOfDirectory(at: currentDirectoryURL, includingPropertiesForKeys: nil)) ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentDirectoryFilesURL)
        print(currentDirectoryFilesURL.count)
    }
    
    
    @IBAction func addImageButton(_ sender: Any) {
        print("Picker opened")
        imagePickerShown()
        
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentDirectoryFilesURL.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let itemURL = currentDirectoryFilesURL[indexPath.row]
        content.text = itemURL.deletingPathExtension().lastPathComponent
        
        var isFolder: ObjCBool = false
        _ = try? FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isFolder)
        if isFolder.boolValue {
            content.secondaryText = "Folder"
        } else {
            content.secondaryText = "File"
        }
        cell.contentConfiguration = content
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = "Files Manager"
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemURL = currentDirectoryFilesURL[indexPath.row]
            _ = try? FileManager.default.removeItem(at: itemURL)
            self.tableView.reloadData()
        }
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    
    func imagePickerShown(){
        var pickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        pickerConfiguration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: pickerConfiguration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.forEach { [weak self] result in
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, error in
                if error == nil {
                    if let destinationURL = self?.currentDirectoryURL.appendingPathComponent("\(Date())") {
                        _ = try? FileManager.default.replaceItemAt(destinationURL, withItemAt: url!)
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
            
        }
        picker.dismiss(animated: true, completion: .none)
    }
}
