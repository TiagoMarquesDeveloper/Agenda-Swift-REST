//
//  OpcoesViewController.swift
//  AgendaHype
//
//  Created by PowerX56 on 2/16/18.
//  Copyright © 2018 PowerX56. All rights reserved.
//

import UIKit

class OpcoesViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var redbar: UISlider!
    @IBOutlet weak var greenbar: UISlider!
    @IBOutlet weak var bluebar: UISlider!
    var statsfile:plistclasse?
    
    @IBOutlet weak var pv1: UIPickerView!
    @IBOutlet weak var pv2: UIPickerView!
    
    let opcoes1 = ["Nome","Nome/Contacto","Nome/Contacto/foto"]
    let opcoes2 = ["Primeiro Nome","Ultimo nome","Telefone","Localidade"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate e datasource as pickerviews
        pv1.dataSource = self
        pv1.delegate = self
        pv2.dataSource = self
        pv2.delegate = self
        
        statsfile = plistclasse()
        
        // Do any additional setup after loading the view.
        statsfile?.loadstats()
        
        //altera os valores das pickerviews conforme os dados anteriormente registrados na plist
        pv1.selectRow((statsfile?.devolvecellstat())!, inComponent: 0, animated: true)
        pv2.selectRow((statsfile?.devolvesearchstat())!, inComponent: 0, animated: true)
        
        //mais carregamento de dados
        view.backgroundColor = statsfile?.ativarcor()
        redbar.maximumValue = 255
        redbar.value = statsfile!.devolvered()
        greenbar.maximumValue = 255
        greenbar.value = statsfile!.devolvegreen()
        bluebar.maximumValue = 255
        bluebar.value = statsfile!.devolveblue()
    }
    
    //a alteracao de um dos sliders vai dar trigger imediato para guardar a alteracao de cor na plist
    @IBAction func redchange(_ sender: Any) {
        statsfile?.absorvered(red: redbar.value)
        statsfile?.save()
        view.backgroundColor = statsfile?.ativarcor()
    }
    
    @IBAction func greenchange(_ sender: Any) {
        statsfile?.absorvegreen(green: greenbar.value)
        statsfile?.save()
        view.backgroundColor = statsfile?.ativarcor()
    }
    
    @IBAction func bluechange(_ sender: Any) {
        statsfile?.absorveblue(blue: bluebar.value)
        statsfile?.save()
        view.backgroundColor = statsfile?.ativarcor()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pv1 {
            return opcoes1.count
        }else if pickerView == pv2 {
            return opcoes2.count
        }else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pv1 {
            return opcoes1[row]
        }else if pickerView == pv2 {
            return opcoes2[row]
        }else{
            return nil
        }
    }
    
    //alteracao da opcao selecionada na pickerview altera o valor na plist
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            statsfile?.setcell(cellnew: opcoes1.index(of: opcoes1[row])!)
        }else if pickerView == pv2 {
            statsfile?.setsearch(searchnew: opcoes2.index(of: opcoes2[row])!)
        }
        statsfile?.save()
    }
    
}
