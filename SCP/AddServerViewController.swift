//
//  AddServerViewController.swift
//  SCP
//
//  Created by LD on 4/6/18.
//  Copyright © 2018 LD. All rights reserved.
//

import Eureka
import GenericPasswordRow

class AddServerViewController: FormViewController, Themeable {
    
    var serverForm: Form? = nil
    var editingItem: SSHServer?
    var editingItemJSON: String?
    var editingItemUUID: String?
    var keychain:Keychain? = nil;
    var currentTheme: Theme = .light {
        didSet {
            apply(theme: currentTheme)
        }
    }
    
    func apply(theme: Theme) {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = theme.navigationBarColor
        navigationBar?.titleTextAttributes = [.foregroundColor: theme.navigationTextColor]
        
        tabBarController?.tabBar.barTintColor = theme.navigationBarColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.cellSeparatorColor
        
        for cell in tableView.visibleCells {
            cell.apply(theme: currentTheme)
        }
        
        for row in form.allRows {
            row.baseCell.apply(theme: currentTheme)
            row.updateCell()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.apply(theme: currentTheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        currentTheme  = dark_mode ? .dark : .light
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keychain = Keychain()
        
        let dark_mode = (UserDefaults.standard.object(forKey: "dark_mode") as? Bool) ?? false
        currentTheme  = dark_mode ? .dark : .light
        
        if let detail = editingItemJSON {
            do {
                let jsonDecoder = JSONDecoder()
                let server = try jsonDecoder.decode(SSHServer.self, from: detail.data(using: .utf8)!)
                
                editingItem = server
            } catch let error {
                print("error: \(error)")
            }
        }
        
        serverForm = form +++ Section()
            <<< NameRow() { row in
                row.title = "Name"
                row.placeholder = "Name"
                row.tag = "name"
                
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                row.placeholderColor = self.currentTheme.cellDetailTextColor
                
                if editingItem != nil {
                    row.value = editingItem?.name
                }
                }.cellUpdate { cell,row in
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    row.placeholderColor = self.currentTheme.cellDetailTextColor
                    cell.apply(theme: self.currentTheme)
            }
            <<< TextRow() {
                $0.title = "Host"
                $0.placeholder = "URL or IP of Host"
                $0.tag = "host"
                
                $0.cell.textField?.autocorrectionType = UITextAutocorrectionType.no
                $0.cell.textField?.autocapitalizationType = UITextAutocapitalizationType.none
                $0.cell.textField?.textColor = self.currentTheme.cellMainTextColor
                $0.placeholderColor = self.currentTheme.cellDetailTextColor
                
                if editingItem != nil {
                    $0.value = editingItem?.host
                }
                }.cellUpdate { cell,row in
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    row.placeholderColor = self.currentTheme.cellDetailTextColor
                    cell.apply(theme: self.currentTheme)
            }
            <<< IntRow() {
                $0.title = "Port"
                $0.placeholder = "Defaults to 22"
                $0.tag = "port"
                $0.cell.textField?.textColor = self.currentTheme.cellMainTextColor
                $0.placeholderColor = self.currentTheme.cellDetailTextColor
                
                if editingItem != nil {
                    $0.value = editingItem?.port
                }
                }.cellUpdate { cell,row in
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    row.placeholderColor = self.currentTheme.cellDetailTextColor
                    cell.apply(theme: self.currentTheme)
            }
            <<< TextRow() {
                $0.title = "Username"
                $0.placeholder = "Defaults to root"
                $0.tag = "user"
                
                $0.cell.textField?.autocorrectionType = .no
                $0.cell.textField?.autocapitalizationType = .none
                $0.cell.textField?.textColor = self.currentTheme.cellMainTextColor
                $0.placeholderColor = self.currentTheme.cellDetailTextColor
                
                if editingItem != nil {
                    $0.value = editingItem?.user
                }
                }.cellUpdate { cell,row in
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    row.placeholderColor = self.currentTheme.cellDetailTextColor
                    cell.apply(theme: self.currentTheme)
            }
            +++ Section()
            <<< GenericPasswordRow() {
                $0.title = "Password"
                $0.placeholder = "password with our without keys"
                $0.tag = "pass"
                $0.cell.hintLabel = nil
                
                $0.cell.bgView?.backgroundColor = self.currentTheme.backgroundColor
                $0.cell.textField.backgroundColor = self.currentTheme.backgroundColor
                $0.cell.textField?.textColor = self.currentTheme.cellMainTextColor
                
                if editingItem != nil {
                    $0.value = editingItem?.pass
                }
                }.cellUpdate { cell,row in
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    cell.apply(theme: self.currentTheme)
            }
            <<< LabelRow() {
                $0.title = "Password and Key auth can be used together or separetly"
                $0.cell.textLabel?.numberOfLines = 0
            }
            +++ Section()
            <<< LabelRow() {
                $0.title = "Private Key"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< TextAreaRow() {
                $0.title = "Private Key"
                $0.placeholder = "Private key"
                $0.tag = "privatekey"
                
                $0.cell.textView.autocorrectionType = .no
                $0.cell.textView.autocapitalizationType = .none
                
                $0.cell.textView.backgroundColor = self.currentTheme.backgroundColor
                $0.cell.textView.textColor = self.currentTheme.cellMainTextColor
                $0.cell.placeholderLabel?.textColor = self.currentTheme.cellDetailTextColor
                
                if editingItem != nil {
                    $0.value = editingItem?.privkey
                }
            }
            <<< LabelRow() {
                $0.title = "Public Key"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< TextAreaRow() {
                $0.title = "Public Key"
                $0.placeholder = "Public key"
                $0.tag = "publickey"
                
                $0.cell.textView.autocorrectionType = .no
                $0.cell.textView.autocapitalizationType = .none
                
                $0.cell.textView.backgroundColor = self.currentTheme.backgroundColor
                $0.cell.textView.textColor = self.currentTheme.cellMainTextColor
                $0.cell.placeholderLabel?.textColor = self.currentTheme.cellDetailTextColor
                
                if editingItem != nil {
                    $0.value = editingItem?.pubkey
                }
            }
            <<< GenericPasswordRow() {
                $0.title = "Passprase"
                $0.placeholder = "leave empty if not needed"
                $0.tag = "passprase"
                $0.cell.hintLabel = nil
                
                $0.cell.bgView?.backgroundColor = self.currentTheme.backgroundColor
                $0.cell.textField.backgroundColor = self.currentTheme.backgroundColor
                $0.cell.textField.textColor = self.currentTheme.cellMainTextColor
                
                if editingItem != nil {
                    $0.value = editingItem?.prase
                }
                }.cellUpdate { cell,row in
                    row.cell.textField.textColor = self.currentTheme.cellMainTextColor
                    cell.apply(theme: self.currentTheme)
            }
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Add Server"
                if editingItem != nil {
                    $0.title = "Edit Server"
                }
                }.onCellSelection { cell, row in
                    do {
                        let nameRow: NameRow? = self.serverForm?.rowBy(tag: "name")
                        let portRow: IntRow? = self.serverForm?.rowBy(tag: "port")
                        let userRow: TextRow? = self.serverForm?.rowBy(tag: "user")
                        let hostRow: TextRow? = self.serverForm?.rowBy(tag: "host")
                        let passRow: GenericPasswordRow? = self.serverForm?.rowBy(tag: "pass")
                        
                        let privkey: TextAreaRow? = self.serverForm?.rowBy(tag: "privatekey")
                        let pubkey: TextAreaRow? = self.serverForm?.rowBy(tag: "publickey")
                        let prase: GenericPasswordRow? = self.serverForm?.rowBy(tag: "passprase")
                        
                        let server = SSHServer(name: nameRow?.value ?? "Unknown",
                                               host: hostRow?.value ?? "example.com",
                                               port: portRow?.value ?? 22,
                                               user: userRow?.value ?? "root",
                                               pass: passRow?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                               privkey: privkey?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                               pubkey: pubkey?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                               prase: prase?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        )
                        
                        let jsonEncoder = JSONEncoder()
                        let jsonData    = try jsonEncoder.encode(server)
                        let jsonString  = String(data: jsonData, encoding: .utf8)
                        
                        let uuid = self.editingItemUUID ?? UUID().uuidString
                        try self.keychain!.set(jsonString!, key: uuid)
                        
                        _ = self.navigationController?.popViewController(animated: true)
                    } catch let error {
                        print("error: \(error)")
                    }
        }
        
    }
    
}
