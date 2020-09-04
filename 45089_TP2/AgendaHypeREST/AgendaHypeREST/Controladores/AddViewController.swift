//
//  AddViewController.swift
//  AgendaHypeREST
//
//  Created by Tiago Marques on 24/02/2018.
//  Copyright © 2018 PowerX56. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class celuladistritos: UITableViewCell {
    @IBOutlet weak var textodistrito: UILabel!
}


class AddViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var txtnome: UITextField!
    @IBOutlet weak var txtapelido: UITextField!
    @IBOutlet weak var txttelefone: UITextField!
    
    @IBOutlet weak var botao: UIButton!
    @IBOutlet weak var txtlocalidade: UILabel!
    
    var localidadereal : String = "Lisboa"
    var editarvalido : Int = 0
    var idcontacto : Int = 0
    var arrayResultet:Array<AnyObject>?
    var quantidade:Int = 0
    var ArrayDicionario:[(titulo: String, body: String)] = []
    var statsfile:plistclasse?
    @IBOutlet weak var tabela: UITableView!
    var edited : Int = 0
    
    @IBOutlet weak var bttadd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsfile = plistclasse()
        statsfile?.loadstats()
        view.backgroundColor = statsfile?.ativarcor()
        tabela.backgroundColor = statsfile?.ativarcor()
        txtnome.delegate = self
        txtapelido.delegate = self
        txttelefone.delegate = self
        // Do any additional setup after loading the view.
        
        //cria um manager do tipo alamofire personalizado capaz de alterar o timeout
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 5
        manager.session.configuration.timeoutIntervalForResource = 5
        
        //verifica se tem internet atravez de um pedido a uma pagina, caso sim, obtem a lista de localidades de uma pagina JSON, senao pede a localidade ao utilizador
        manager.request("https://httpbin.org/get").responseString { response in
            print("Success: \(response.result.isSuccess)")
            if response.result.isSuccess == true{
                let url = URL(string: "http://centraldedados.pt/distritos.json")
                let data = try? Data(contentsOf: url!)
                self.arrayResultet = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Array<AnyObject>
                for d in self.arrayResultet! {
                    let idd = d["cod_distrito"]
                    let nomed = d["nome_distrito"]
                    self.ArrayDicionario.append((titulo: idd as! String, body: nomed as! String))
                    //print(d)
                    self.quantidade = self.quantidade + 1
                }
                self.tabela.reloadData()
            }else{
                repeat{
                    let alert = UIAlertController(title: "Sem internet", message: "Insira a localidade", preferredStyle: .alert)
                    
                    alert.addTextField { (textField) in
                        textField.text = "Localidade..."
                    }
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        let textFielddab = alert?.textFields![0]
                        self.localidadereal = "Lisboa"
                        self.localidadereal = (textFielddab?.text!)!
                        if self.localidadereal == "" {
                            self.localidadereal = "Lisboa"
                        }
                        self.txtnome.becomeFirstResponder()
                        self.edited = 1
                    }))
                    self.present(alert, animated: true, completion: nil)
                }while self.localidadereal == ""
                self.txtlocalidade.text = "localidade: " + self.localidadereal
            }
        }
        
        //se o utilizador abrir a view com o tipo editar, carrega os dados antigos para efetuar a alteracao
        if editarvalido == 1 {
            let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
            let predi = NSPredicate(format: "id == " + String(idcontacto))
            rq.predicate = predi
            
            do {
                let resp = try ctx.fetch(rq)
                
                for a in resp{
                    txtnome.text = a.nome
                    txtapelido.text = a.apelido
                    txttelefone.text = a.telemovel
                    if self.edited == 0 {
                        txtlocalidade.text = "localidade: " + a.localidade!
                        localidadereal = a.localidade!
                    }
                }
                
                try ctx.save()
                
            } catch  {
                
            }
            txtlocalidade.text = "localidade: " + localidadereal
            botao.setTitle("editar", for: .normal)
        }
    }

    //botao responsavel por adicionar, em primeiro lugar adiciona no coredata independente de ter internet ou nao, em seguida se tiver internet adiciona na base de dados atraves de um POST, caso seja editar, edita primeiro no coredata e no caso de existencia de internet, faz a alteracao na base de dados por POST
    @IBAction func bttaddclick(_ sender: Any) {
        if txtnome.text != "" && txtapelido.text != "" && txttelefone.text != "" && localidadereal != "" && telemovelvalido(telemovel: txttelefone.text!) == true {
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 5
            manager.session.configuration.timeoutIntervalForResource = 5
            if editarvalido == 0 {
                let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let ct1 = Contacto(context: ctx)
                let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
                var idsupreme : Int = 0
                do{
                    let resp = try ctx.fetch(rq)
                    for a in resp {
                        if idsupreme < a.id {
                            idsupreme = Int(a.id)
                        }
                    }
                } catch {
                    
                }
                
                idsupreme = idsupreme + 1
                
                
                ct1.id = Int16(idsupreme)
                ct1.nome = txtnome.text
                ct1.apelido = txtapelido.text
                ct1.telemovel = txttelefone.text
                ct1.localidade = localidadereal
                
                do {
                    try ctx.save()
                } catch {
                    
                }
                
                manager.request("https://httpbin.org/get").responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    if response.result.isSuccess == true{
                        //codigo para add online
                        self.statsfile?.addcontactoREST(nome: self.txtnome.text!, apelido: self.txtapelido.text!, telemovel: self.txttelefone.text!, localidade: self.localidadereal)
                    }
                }
                
            }else if editarvalido == 1 {
                let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
                let predi = NSPredicate(format: "id == " + String(idcontacto))
                
                rq.predicate = predi
                
                do {
                    let resp = try ctx.fetch(rq)
                    
                    resp[0].nome = txtnome.text
                    resp[0].apelido = txtapelido.text
                    resp[0].telemovel = txttelefone.text
                    resp[0].localidade = localidadereal

                    try ctx.save()
                    
                } catch  {
                    
                }
            }
            manager.request("https://httpbin.org/get").responseString { response in
                print("Success: \(response.result.isSuccess)")
                if response.result.isSuccess == true{
                    //codigo para editar online
                    self.statsfile?.editarcontactoREST(idc: String(self.idcontacto), nome: self.txtnome.text!, apelido: self.txtapelido.text!, telemovel: self.txttelefone.text!, localidade: self.localidadereal)
                }
            }
            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }else{
            if txtnome.text == "" {
                self.mensagem(msg: "Nome Vazio!")
            }else if txtapelido.text == "" {
                self.mensagem(msg: "Apelido Vazio!")
            }else if txttelefone.text == "" {
                self.mensagem(msg: "telefone Vazio!")
            }else if telemovelvalido(telemovel: txttelefone.text!) == false {
                self.mensagem(msg: "Telefone invalido!")
            }else if localidadereal == "" {
                self.mensagem(msg: "Localidade Vazio!")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quantidade
    }
    
    //adiciona as localidades se carregadas a tabela
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula2") as? celuladistritos
        cell!.textodistrito.text = ArrayDicionario[indexPath.row].body
        cell?.backgroundColor = statsfile?.ativarcor()
        return cell!
    }
    
    //altera a localidade conforme a seleccao na tabela
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! celuladistritos
        localidadereal = currentCell.textodistrito!.text!
        txtlocalidade.text = "localidade: " + localidadereal
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { 
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.txtlocalidade.text = "localidade: " + self.localidadereal
    }
    
    func telemovelvalido(telemovel: String) -> Bool {
        // regex numeros
        let regex = "^[0-9]*$"
        let telemovelTest = NSPredicate(format:"SELF MATCHES %@", regex)
        return telemovelTest.evaluate(with: telemovel)
    }

    func mensagem(msg: String) {
        let alert = UIAlertController(title: "Erro", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
