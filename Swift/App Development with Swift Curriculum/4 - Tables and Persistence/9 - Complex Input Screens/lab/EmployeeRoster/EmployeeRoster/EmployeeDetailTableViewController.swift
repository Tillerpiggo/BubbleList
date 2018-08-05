
import UIKit

class EmployeeDetailTableViewController: UITableViewController, UITextFieldDelegate, EmployeeTypeDelegate {
    
    var isEditingBirthday: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    struct PropertyKeys {
        static let unwindToListIndentifier = "UnwindToListSegue"
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var employeeTypeLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    var employee: Employee?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    
    func updateView() {
        if let employee = employee {
            navigationItem.title = employee.name
            nameTextField.text = employee.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dobLabel.text = dateFormatter.string(from: employee.dateOfBirth)
            dobLabel.textColor = .black
            employeeTypeLabel.text = employee.employeeType.description()
            employeeTypeLabel.textColor = .black
            datePicker.date = employee.dateOfBirth
        } else {
            navigationItem.title = "New Employee"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let name = nameTextField.text, let employeeType = self.employee?.employeeType {
            employee = Employee(name: name, dateOfBirth: datePicker.date, employeeType: employeeType)
            performSegue(withIdentifier: PropertyKeys.unwindToListIndentifier, sender: self)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        employee = nil
        performSegue(withIdentifier: PropertyKeys.unwindToListIndentifier, sender: self)
    }
    
    @IBAction func valueChanged(_ sender: UIDatePicker) {
        dobLabel.text = formatDate(sender.date)
    }
    
    func didSelect(employeeType: EmployeeType) {
        self.employee?.employeeType = employeeType
        employeeTypeLabel.text = employeeType.description()
        employeeTypeLabel.textColor = .black
    }
    
    // MARK: - Text Field Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            isEditingBirthday = !isEditingBirthday
            dobLabel.textColor = .black
            dobLabel.text = formatDate(datePicker.date)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 2 {
            return 44
        } else {
            return isEditingBirthday ? 216 : 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? EmployeeTypeTableViewController else { return }
        destinationViewController.delegate = self
    }

}
