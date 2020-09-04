//
//  ListarViewController.swift
//  AgendaHypeREST
//
//  Created by Tiago Marques on 24/02/2018.
//  Copyright © 2018 PowerX56. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class lembretes: UITableViewCell {
    @IBOutlet weak var textotitulo: UILabel!
    @IBOutlet weak var botaoadd: UIButton!
}

class ListarViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var statsfile:plistclasse?
    var idcontacto: Int = 0
    var idnota : Int = 0
    var seraeditarnota : Int = 0

    @IBOutlet weak var nometxt: UILabel!
    @IBOutlet weak var contactotxt: UILabel!
    @IBOutlet weak var localidadetxt: UILabel!
    @IBOutlet weak var tabelalembrete: UITableView!
    
    @IBOutlet weak var editarclick: UIButton!
    
    var ArrayLembrete:[(idlembrete: Int, titulo: String)] = []
    var idsnotas:Array<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idsnotas.removeAll()
        statsfile = plistclasse()
        statsfile?.loadstats()
        view.backgroundColor = statsfile?.ativarcor()
        carregarcontacto()
        tabelalembrete.backgroundColor = statsfile?.ativarcor()
        
        //adiciona um botao manualmente para remover o contacto
        let RightButton = UIBarButtonItem(title: "Remover", style: .plain, target: self, action: #selector(self.someFunc))
        self.navigationItem.rightBarButtonItem = RightButton
    }
    
    //remove o contacto, e como os lembretes estao associados ao contacto, todos os lembretes com o idcontacto especifico tem de ser eliminados
    @objc func someFunc() {
        let refreshAlert = UIAlertController(title: "Eliminar", message: "Este contacto sera eliminado", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let ct : Contacto?
            var lb : Lembrete?
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 5
            manager.session.configuration.timeoutIntervalForResource = 5
            let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
            let predi = NSPredicate(format: "id == " + String(self.idcontacto))
            
                rq.predicate = predi
            
                do {
                    let resp = try ctx.fetch(rq)
                    
                    ct = resp[0]
                    
                    ctx.delete(ct!)
                    try ctx.save()
                    
                } catch  {
                    
                }
            
            let rq2: NSFetchRequest<Lembrete> = Lembrete.fetchRequest()
            let predi2 = NSPredicate(format: "idcontacto == " + String(self.idcontacto))
            
            rq2.predicate = predi2
            
            do {
                let resp2 = try ctx.fetch(rq2)
                
                for a in resp2{
                    lb = a
                    ctx.delete(lb!)
                }
                
                try ctx.save()
                
            } catch  {
                
            }
            manager.request("https://httpbin.org/get").responseString { response in
                print("Success: \(response.result.isSuccess)")
                if response.result.isSuccess == true{
                    //codigo para eliminar online
                    self.statsfile?.deletecontactoREST(idc: String(self.idcontacto))
                    self.statsfile?.deletevarioslembreteREST(idc: String(self.idcontacto))
                }
            }
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    //carrega os dados do lembrete dependendo se tem internet ou nao,se tiver verifica por novos registros primeiro
    func carregarcontacto() {
        ArrayLembrete.removeAll()
        idsnotas.removeAll()
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 5
        manager.session.configuration.timeoutIntervalForResource = 5
        
        manager.request("https://httpbin.org/get").responseString { response in
            print("Success: \(response.result.isSuccess)")
            if response.result.isSuccess == true{
                let ctx3 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let rq3: NSFetchRequest<Lembrete> = Lembrete.fetchRequest()
                do{
                    let resp3 = try ctx3.fetch(rq3)
                    for a in resp3 {
                        self.statsfile?.novidadesLembreteREST(idc: String(a.idcontacto), titulo: a.titulo!, conteudo: a.conteudo!)
                    }
                } catch {
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.carregarcontacto()
                    self.tabelalembrete.reloadData()
                }
            }
        }
        
        manager.request("https://httpbin.org/get").responseString { response in
            print("Success: \(response.result.isSuccess)")
            if response.result.isSuccess == true{
                //codigo para editar online
                self.idsnotas = (self.statsfile?.carregarlembretesREST(idsarray: self.idsnotas))!
            }
        }
        
        let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let rq: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        let predi = NSPredicate(format: "id == " + String(idcontacto))
        rq.predicate = predi
        
        do {
            let resp = try ctx.fetch(rq)
            
            for a in resp{
                nometxt.text = a.nome! + " " + a.apelido!
                contactotxt.text = a.telemovel
                localidadetxt.text = a.localidade
            }
            
            try ctx.save()
            
        } catch  {
            
        }
        
        let ctx2 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let rq2: NSFetchRequest<Lembrete> = Lembrete.fetchRequest()
        let predi2 = NSPredicate(format: "idcontacto == " + String(idcontacto))
        rq2.predicate = predi2
        
        do {
            let resp2 = try ctx2.fetch(rq2)
            
            for b in resp2{
                ArrayLembrete.append((idlembrete: Int(b.idlembrete),titulo: b.titulo!))
                idsnotas.append(Int(b.idlembrete))
            }
            
            try ctx2.save()
            
        } catch  {
            
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ArrayLembrete.count) + 1
    }
    
    //celula lembrete que adiciona os lembretes do contacto e no final adiciona um mais para caso o utilizador queira adicionar um novo lembrete
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celulalembrete") as! lembretes
        if indexPath.row < (ArrayLembrete.count){
            cell.textotitulo.isHidden = false
            cell.textotitulo.text = ArrayLembrete[indexPath.row].titulo
            cell.botaoadd.isHidden = true
        }else{
            cell.textotitulo.isHidden = true
            cell.botaoadd.isHidden = false
        }
        cell.backgroundColor = statsfile?.ativarcor()
        return cell
    }
    
    
    @IBAction func editarclickaction(_ sender: Any) {
            performSegue(withIdentifier: "editarsegue", sender: idcontacto)
    }
    
    @IBAction func botaoaddlembrete(_ sender: Any) {
            seraeditarnota = 0
            performSegue(withIdentifier: "notasegue", sender: idcontacto)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let d = segue.destination as? AddViewController {
            if let s = sender as? Int {
                d.idcontacto = s
                d.editarvalido = 1
            }
        }else if let d = segue.destination as? NotaViewController {
            if let s = sender as? Int {
                d.idcontacto = s
                d.editarouguardar = seraeditarnota
                d.idlembrete = idnota
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        idsnotas.removeAll()
        carregarcontacto()
        tabelalembrete.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= ArrayLembrete.count - 1 {
            seraeditarnota = 1
            idnota = idsnotas[indexPath.row]
            performSegue(withIdentifier: "notasegue", sender: idcontacto)
        }
    }

}
