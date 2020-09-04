//
//  corprojeto.swift
//  AgendaHype
//
//  Created by PowerX56 on 2/7/18.
//  Copyright © 2018 PowerX56. All rights reserved.
//

//CLASSE RESPONSAVEL PELA A MATERIA PLIST E SERVIDOR REST

import UIKit
import SystemConfiguration
import CoreData
import Alamofire

extension UIColor{
    class func MudarCor(red: Int, green: Int, blue: Int, alpha: Int) -> UIColor{
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        let newAlpha = CGFloat(alpha)/100
        return UIColor(red: newRed, green: newGreen ,blue: newBlue , alpha: newAlpha)
    }
}

class plistclasse {
    private var red:Int
    private var green:Int
    private var blue:Int
    private var statcell:Int
    private var statsearch:Int
    
    init() {
        self.red = 255
        self.green = 255
        self.blue = 255
        self.statcell = 0
        self.statsearch = 0
    }
    
    init(red:Int,green:Int, blue:Int, cellget:Int,searchget:Int) {
        self.red = red
        self.green = green
        self.blue = blue
        self.statcell = cellget
        self.statsearch = searchget
    }
    
    func devolvered() -> Float {
        return Float(self.red)
    }
    
    func devolvegreen() -> Float {
        return Float(self.green)
    }
    
    func devolveblue() -> Float {
        return Float(self.blue)
    }
    
    func absorvered(red:Float) {
        self.red = Int(red)
    }
    
    func absorvegreen(green:Float) {
        self.green = Int(green)
    }
    
    func absorveblue(blue:Float) {
        self.blue = Int(blue)
    }
    
    func devolvecellstat() -> Int {
        return statcell
    }
    
    func devolvesearchstat() -> Int {
        return statsearch
    }
    
    func setcell(cellnew:Int) {
        self.statcell = cellnew
    }
    
    func setsearch(searchnew:Int) {
        self.statsearch = searchnew
    }
    
    //funcao que carrega o ficheiro Plist, por questoes de visualizacao se o utilizador mudar a cor de fundo para totalmente preto coloca o fundo branco
    func loadstats() {
        let fm = FileManager.default
        var BasePath = fm.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask)
        
        print(BasePath[0])
        let FullPath = BasePath[0].appendingPathComponent("demo.plist")
        
        //let dic = NSMutableDictionary(contentsOf: FullPath)
        //print(dic!)
        
        let fileExists = FileManager().fileExists(atPath: FullPath.path)
        
        if fileExists == false {
            
        }else{
            
            let data = try? Data(contentsOf:FullPath)
            let swiftDictionary = try? PropertyListSerialization.propertyList(from: data!, options: [], format: nil) as! [String:Any]
            
            self.red = swiftDictionary?["red"] as! Int
            self.blue = swiftDictionary?["blue"] as! Int
            self.green = swiftDictionary?["green"] as! Int
            self.statcell = swiftDictionary?["cellx"] as! Int
            self.statsearch = swiftDictionary?["searchy"] as! Int
            
            if self.red == 0 && self.blue == 0 && self.green == 0 {
                self.red = 255
                self.blue = 255
                self.green = 255
            }
        }
    }
    
    //funcao que transforma os valores inteiros das cores em um UIColor
    func ativarcor() -> UIColor {
        return UIColor.MudarCor(red: Int(self.red), green: Int(self.green), blue: Int(self.blue), alpha: Int(100))
    }
    
    //funcao que guarda no ficheiro Plist a informacao
    func save() {
        
        let fm = FileManager.default
        
        var BasePath = fm.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask)
        
        print(BasePath[0])
        let FullPath = BasePath[0].appendingPathComponent("demo.plist")
        
        //let dic2 = NSMutableDictionary(contentsOf: FullPath)
        let dic:NSMutableDictionary = ["red":self.red,"blue":self.blue,"green":self.green,"cellx":self.statcell,"searchy":self.statsearch]
        dic.write(to: FullPath, atomically: true)
    }
    //Funcao do tipo GET que elimina o CoreData e faz o download da base de dados remota da entidade Contacto
    func carregarREST(idsarray:Array<Int>) -> Array<Int> {
        DeleteAllData(entidade: "Contacto")
        
        var arrayResultet:Array<AnyObject>?
        var ids:Array<Int> = []
        let url = URL(string: "http://213.32.71.49/ios/example/contactos")
        let data = try? Data(contentsOf: url!)
        arrayResultet = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Array<AnyObject>
        for d in arrayResultet! {
            let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let ct1 = Contacto(context: ctx)
            let idd = d["id"]
            let nomed = d["nome"]
            let apelidod = d["apelido"]
            let telemoveld = d["telemovel"]
            let localidaded = d["localidade"]
            ids.append(Int(idd as! String)!)
            
            ct1.id = Int16(idd as! String)!
            ct1.nome = nomed as? String
            ct1.apelido = apelidod as? String
            ct1.telemovel = telemoveld as? String
            ct1.localidade = localidaded as? String
            
            do {
                try ctx.save()
            } catch {
                
            }
        }

        return ids
    }
    
    //Funcao do tipo GET que elimina o CoreData e faz o download da base de dados remota da entidade lembrete
    func carregarlembretesREST(idsarray:Array<Int>) -> Array<Int> {
        DeleteAllData(entidade: "Lembrete")
        
        var arrayResultet:Array<AnyObject>?
        var ids:Array<Int> = []
        let url = URL(string: "http://213.32.71.49/ios/example/lembretes")
        let data = try? Data(contentsOf: url!)
        arrayResultet = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Array<AnyObject>
        for d in arrayResultet! {
            let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let lb1 = Lembrete(context: ctx)
            let idld = d["idlembrete"]
            let idcd = d["idcontacto"]
            let titulod = d["titulo"]
            let conteudod = d["conteudo"]

            ids.append(Int(idld as! String)!)
            
            lb1.idlembrete = Int16(idld as! String)!
            lb1.idcontacto = Int16(idcd as! String)!
            lb1.titulo = titulod as? String
            lb1.conteudo = conteudod as? String
            
            do {
                try ctx.save()
            } catch {
                
            }
        }
        
        return ids
    }
    
    //funcao que faz o search na base de dados atraves do GET, que esta preparada para receber o tipo de pesquisa e o valor a pesquisar e devolve os elementos do LIKE do valor mencionado
    func carregarRESTSearch(idsarray:Array<Int>, tipo: String, Valor: String) -> Array<Int> {
        DeleteAllData(entidade: "Contacto")
        var arrayResultet2:Array<AnyObject>?
        var ids2:Array<Int> = []
        let tipoget : String = tipo
        let valorget : String = Valor
        let url2 = URL(string: "http://213.32.71.49/ios/example/contactossearch/" + tipoget + "/" + valorget)
        let data2 = try? Data(contentsOf: url2!)
        arrayResultet2 = try? JSONSerialization.jsonObject(with: data2!, options: .mutableContainers) as! Array<AnyObject>
        for d in arrayResultet2! {
            let ctx2 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let ct2 = Contacto(context: ctx2)
            let idd2 = d["id"]
            let nomed2 = d["nome"]
            let apelidod2 = d["apelido"]
            let telemoveld2 = d["telemovel"]
            let localidaded2 = d["localidade"]
            ids2.append(Int(idd2 as! String)!)
            
            ct2.id = Int16(idd2 as! String)!
            ct2.nome = nomed2 as? String
            ct2.apelido = apelidod2 as? String
            ct2.telemovel = telemoveld2 as? String
            ct2.localidade = localidaded2 as? String
            
            do {
                try ctx2.save()
            } catch {
                
            }
        }
        return ids2
        
    }
    
    //Funcao que elimina todo o conteudo de uma entidade a especificar no coredata
    func DeleteAllData(entidade: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entidade))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
    
    //funcao que adiciona o contacto do tipo POST
    func addcontactoREST(nome:String, apelido: String, telemovel: String, localidade: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/addcontacto")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "nome=" + nome + "&apelido=" + apelido + "&telemovel=" + telemovel + "&localidade=" + localidade
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    //funcao que adiciona o lembrete do tipo POST
    func addlembreteREST(idc:String, titulo: String, conteudo: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/addlembrete")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "idcontacto=" + idc + "&titulo=" + titulo + "&conteudo=" + conteudo
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    //Funcao que edita o contacto do tipo POST que recebe argumentos para alterar
    func editarcontactoREST(idc: String, nome:String, apelido: String, telemovel: String, localidade: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/update/" + idc)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "nome=" + nome + "&apelido=" + apelido + "&telemovel=" + telemovel + "&localidade=" + localidade
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    //Funcao que edita o lembrete do tipo POST que recebe argumentos para alterar
    func editarlembreteREST(idl: String, idc: String, titulo:String, conteudo: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/updatelembrete/" + idl)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "idcontacto=" + idc + "&titulo=" + titulo + "&conteudo=" + conteudo
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    //funcao que elimina o contacto tipo DELETE
    func deletecontactoREST(idc: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/delete/" + idc)
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    //funcao que elimina um unico lembrete especificado do tipo DELETE
    func deletelembreteREST(idl: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/deletelembrete/" + idl)
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    //funcao que conecta ao servidor REST do tipo DELETE para eliminar varios lembretes do mesmo contacto
    func deletevarioslembreteREST(idc: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/deletevarioslembrete/" + idc)
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
       //funcao que recebe dados de contacto caso o utilizador derepente obtenha internet e caso tenha registros que a base de dados MySQL nao tenha, adiciona a base de dados
    func novidadesContactoREST(nome:String, apelido: String, telemovel: String, localidade: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/equilibrio")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "telemovel=" + telemovel + "&localidade=" + localidade + "&apelido=" + apelido + "&nome=" + nome
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    //funcao que recebe dados de lembrete caso o utilizador derepente obtenha internet e caso tenha registros que a base de dados MySQL nao tenha, adiciona a base de dados
    func novidadesLembreteREST(idc: String, titulo:String, conteudo: String) {
        let url = URL(string:"http://213.32.71.49/ios/example/equilibriolembrete")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "titulo=" + titulo + "&idcontacto=" + idc + "&conteudo=" + conteudo
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
}
