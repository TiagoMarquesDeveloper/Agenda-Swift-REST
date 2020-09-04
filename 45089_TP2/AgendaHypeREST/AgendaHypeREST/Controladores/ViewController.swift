//
//  ViewController.swift
//  AgendaHypeREST
//
//  Created by Tiago Marques on 24/02/2018.
//  Copyright © 2018 PowerX56. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class ViewController: UITableViewController,UISearchBarDelegate {

    var tamanhotabela : Int = 0
    var pesquisando = false
    var statsfile:plistclasse?
    var ids:Array<Int> = []
    var queryinject = 0
    
    @IBOutlet weak var barra: UINavigationItem!
    @IBOutlet var tabelareal: UITableView!
    @IBOutlet weak var pesquisa: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tamanhotabela = 0
        statsfile = plistclasse()
        statsfile?.loadstats()
        view.backgroundColor = statsfile?.ativarcor()
        pesquisa.delegate = self
        pesquisa.returnKeyType = UIReturnKeyType.done
        getdata()
    }
    
    //carrega os dados do coredata para a tabela, adicionando a quantidade de linhas a varaivel tamanhotabela e o idcontacto ao arrays de inteiros
    func carregardados() {
        tamanhotabela = 0
        ids.removeAll()
        let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        
        
        do{
            let resp = try ctx.fetch(rq)
            for a in resp {
                tamanhotabela = tamanhotabela + 1
                ids.append(Int(a.id))
            }
        } catch {
            
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tamanhotabela
    }
    
    //conforme o indexpath row, carrega do coredata o nome completo e o numero de telemovel e conforme o tipo de celula armazenada na plist, dispoe o estilo de celula
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        var nome : String = ""
        var contatotelemovel : String = ""
        
        do{
            let resp = try ctx.fetch(rq)
            nome = resp[indexPath.row].nome! + " " + resp[indexPath.row].apelido!
            contatotelemovel = resp[indexPath.row].telemovel!
        } catch {
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula")
        if statsfile?.devolvecellstat() == 0 {
                cell?.textLabel?.text = nome
                cell?.imageView?.image = nil
        }else if statsfile?.devolvecellstat() == 1 {
                cell?.textLabel?.text = nome + ": " + contatotelemovel
                cell?.imageView?.image = nil
        }else if statsfile?.devolvecellstat() == 2 {
                cell?.textLabel?.text = nome + ": " + contatotelemovel
                cell?.imageView?.image = #imageLiteral(resourceName: "perfil")
        }
        cell?.backgroundColor = statsfile?.ativarcor()
        return cell!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statsfile?.loadstats()
        view.backgroundColor = statsfile?.ativarcor()
        getdata()
        tabelareal.reloadData()
    }
    
    //envia o idcontacto para os detalhes
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "listarsegue", sender: ids[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let d = segue.destination as? ListarViewController {
            if let s = sender as? Int {
                d.idcontacto = s
            }
        }
    }
    
    //primeiro verifica se o utilizador tem acesso a internet, em caso afirmativo, primeiro faz a comparacao entre a sua coredata atual com a armazenada online, para o caso de encontrar registros diferentes, adiciona na base de dados remota, em seguida limpa o coredata por completo e descarrega a base de dados remota, para o caso do utilizador nao tiver acesso a internet no momento, simplesmente carrega o coredata offline, a funcao tambem e resposavel por apresentar a pesquisa caso esteja a ser feita
    func getdata() {
        tamanhotabela = 0
        ids.removeAll()
        barra.title = "Agenda - Conectando..."
        if queryinject == 0  {
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 5
            manager.session.configuration.timeoutIntervalForResource = 5
            
            manager.request("https://httpbin.org/get").responseString { response in
                print("Success: \(response.result.isSuccess)")
                if response.result.isSuccess == true{
                    let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
                    do{
                        let resp = try ctx.fetch(rq)
                        for a in resp {
                            self.statsfile?.novidadesContactoREST(nome: a.nome!, apelido: a.apelido!, telemovel: a.telemovel!, localidade: a.localidade!)
                        }
                    } catch {
                        
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.carregardados()
                    self.tabelareal.reloadData()
                }
            }
            
            manager.request("https://httpbin.org/get").responseString { response in
                print("Success: \(response.result.isSuccess)")
                if response.result.isSuccess == true{
                    self.ids = self.statsfile!.carregarREST(idsarray: self.ids)
                    self.carregardados()
                    self.tabelareal.reloadData()
                    self.barra.title = "Agenda - Conectado!"
                }else{
                    self.carregardados()
                    self.tabelareal.reloadData()
                    self.barra.title = "Agenda - fail!"
                }
            }
        }else if queryinject == 1 {
            let manager = Alamofire.SessionManager.default
            manager.request("https://httpbin.org/get").responseString { response in
                print("Success: \(response.result.isSuccess)")
                if response.result.isSuccess == true{
                    self.ids = self.statsfile!.carregarRESTSearch(idsarray: self.ids, tipo: String(describing: self.statsfile!.devolvesearchstat()), Valor: self.pesquisa.text!)
                        self.carregardados()
                        self.tabelareal.reloadData()
                    self.barra.title = "Agenda - Conectado!"
                }
            }
        }
    }
    
    //a alteracao do texto na barra de pesquisa fara com que a pesquisa inicie
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if pesquisa.text == nil || pesquisa.text == "" {
            pesquisando = false
            view.endEditing(true)
            queryinject = 0
            getdata()
            tabelareal.reloadData()
        }else{
            queryinject = 1
            getdata()
            tabelareal.reloadData()
            pesquisando = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        carregardados()
        tabelareal.reloadData()
    }

}
