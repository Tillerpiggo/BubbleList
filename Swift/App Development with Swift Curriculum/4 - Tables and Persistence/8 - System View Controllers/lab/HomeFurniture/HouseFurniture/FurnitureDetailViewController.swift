
import UIKit

class FurnitureDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // PROPERTIES
    
    var furniture: Furniture?
    
    
    // @IBOUTLETS
    
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var furnitureTitleLabel: UILabel!
    @IBOutlet weak var furnitureDescriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    // VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    
    
    // METHODS
    
    func updateView() {
        guard let furniture = furniture else {return}
        if let imageData = furniture.imageData,
            let image = UIImage(data: imageData) {
            choosePhotoButton.setTitle("", for: .normal)
            
            imageView.image = image
            imageView.isHidden = false
        } else {
            choosePhotoButton.setTitle("Choose Image", for: .normal)
            choosePhotoButton.setImage(nil, for: .normal)
            
            imageView.image = nil
            imageView.isHidden = true
        }
        
        furnitureTitleLabel.text = furniture.name
        furnitureDescriptionLabel.text = furniture.description
    }
    
    // @IBACTIONS
    
    @IBAction func choosePhotoButtonTapped(_ sender: Any) {
        // Setup image picker
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        // Setup alert controller
        
        let alertController = UIAlertController(title: "Choose a Photo", message: nil, preferredStyle: .actionSheet)
        
        
        // Cancel action
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        // Camera action
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(cameraAction)
        }
        
        
        // Photo library action
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        
        
        // Present alert controller
        
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        guard let imageData = furniture?.imageData,
            let description = furniture?.description else { return }
        
        let activityController = UIActivityViewController(activityItems: [imageData, description], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender as? UIView
        
        present(activityController, animated: true, completion: nil)
    }
    
    
    // IMAGE PICKER DELEGATE METHODS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        furniture?.imageData = UIImagePNGRepresentation(image)
        dismiss(animated: true, completion: nil)
        self.updateView()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
