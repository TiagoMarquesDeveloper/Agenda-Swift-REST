//
//  NotaViewController.swift
//  AgendaHypeREST
//
//  Created by Tiago Marques on 24/02/2018.
//  Copyright © 2018 PowerX56. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class NotaViewController: UIViewController {

    var idcontacto : Int = 0
    var idlembrete : Int = 0
    var editarouguardar : Int = 0
    var statsfile:plistclasse?
    
    @IBOutlet weak var titulotxt: UITextField!
    @IBOutlet weak var conteudotxt: UITextView!
    @IBOutlet weak var addbtt: UIButton!
    
    
    //ajusta a actividade conforme seja adicionar ou alterar
    override func viewDidLoad() {
        super.viewDidLoad()
        statsfile = plistclasse()
        statsfile?.loadstats()
        view.backgroundColor = statsfile?.ativarcor()
        conteudotxt!.layer.borderWidth = 1
        conteudotxt!.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
        if editarouguardar == 1 {
            let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let rq: NSFetchRequest<Lembrete> = Lembrete.fetchRequest()
            let predi = NSPredicate(format: "idlembrete == " + String(idlembrete))
            rq.predicate = predi
            
            do {
                let resp = try ctx.fetch(rq)
                
                for a in resp{
                    titulotxt.text = a.titulo
                    conteudotxt.text = a.conteudo
                }
                
                try ctx.save()
                
            } catch  {
                
            }
            //adiciona um botao manualmente para remover o lembrete associado a funcao somefunc
            let RightButton = UIBarButtonItem(title: "Remover", style: .plain, target: self, action: #selector(self.someFunc))
            self.navigationItem.rightBarButtonItem = RightButton
            addbtt.setTitle("Editar", for: .normal)
        }else if editarouguardar == 0 {
            addbtt.setTitle("Adicionar", for: .normal)
        }
    
    }
    
    //remover o lembrete, primeiro efectua no coredata e caso tenha internet, no servidor
    @objc func someFunc() {
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 5
        manager.session.configuration.timeoutIntervalForResource = 5
    
        let refreshAlert = UIAlertController(title: "Eliminar", message: "Este contacto sera eliminado", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            var lb : Lembrete?
            let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let rq: NSFetchRequest<Lembrete> = Lembrete.fetchRequest()
            let predi = NSPredicate(format: "idlembrete == " + String(self.idlembrete))
            
            rq.predicate = predi
            
            do {
                let resp = try ctx.fetch(rq)
                
                lb = resp[0]
                
                ctx.delete(lb!)
                try ctx.save()
                
            } catch  {
                
            }
            
            manager.request("https://httpbin.org/get").responseString { response in
                print("Success: \(response.result.isSuccess)")
                if response.result.isSuccess == true{
                    //codigo para editar online
                    self.statsfile?.deletelembreteREST(idl: String(self.idlembrete))
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
    
    //funcao para adicionar/editar lembrete (coredata e REST)
    @IBAction func addbttclick(_ sender: Any) {
        if titulotxt.text != "" && conteudotxt.text != "" {
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 5
            manager.session.configuration.timeoutIntervalForResource = 5
            
            if editarouguardar == 0 {
                let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let lb1 = Lembrete(context: ctx)
                let rq: NSFetchRequest<Lembrete> = Lembrete.fetchRequest()
                var idsupreme : Int = 0
                do{
                    let resp = try ctx.fetch(rq)
                    for a in resp {
                        if idsupreme < a.idlembrete {
                            idsupreme = Int(a.idlembrete)
                        }
                    }
                } catch {
                    
                }
                
                idsupreme = idsupreme + 1
                
                
                lb1.idlembrete = Int16(idsupreme)
                lb1.idcontacto = Int16(idcontacto)
                lb1.titulo = titulotxt.text
                lb1.conteudo = conteudotxt.text
                do {
                    try ctx.save()
                } catch {
                    
                }
                
                manager.request("https://httpbin.org/get").responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    if response.result.isSuccess == true{
                        //codigo para adicionar online
                        self.statsfile?.addlembreteREST(idc: String(self.idcontacto), titulo: self.titulotxt.text!, conteudo: self.conteudotxt.text!)
                    }
                }
                
            }else if editarouguardar == 1 {
                let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let rq: NSFetchRequest<Lembrete> = Lembrete.fetchRequest()
                let predi = NSPredicate(format: "idlembrete == " + String(idlembrete))
                
                rq.predicate = predi
                
                do {
                    let resp = try ctx.fetch(rq)
                    
                    resp[0].idlembrete = Int16(idlembrete)
                    resp[0].idcontacto = Int16(idcontacto)
                    resp[0].titulo = titulotxt.text
                    resp[0].conteudo = conteudotxt.text
                    
                    try ctx.save()
                    
                } catch  {
                    
                }
                manager.request("https://httpbin.org/get").responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    if response.result.isSuccess == true{
                        //codigo para editar online
                        self.statsfile?.editarlembreteREST(idl: String(self.idlembrete), idc: String(self.idcontacto), titulo: self.titulotxt.text!, conteudo: self.conteudotxt.text!)
                    }
                }
            }
            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }else{
            if titulotxt.text == "" {
                self.mensagem(msg: "Titulo Vazio!")
            }else if conteudotxt.text == "" {
                self.mensagem(msg: "Conteudo Vazio!")
            }
        }
    }
    
    func mensagem(msg: String) {
        let alert = UIAlertController(title: "Erro", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
