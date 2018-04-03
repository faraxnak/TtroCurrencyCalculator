//
//  CountryListView.swift
//  Pods
//
//  Created by Farid on 12/14/16.
//
//

import UIKit
import EasyPeasy
import TtroCountryPicker

@objc protocol CountryListViewDelegate {
    func onAddCountry()
}

class CountryListView: UIView {

    var countryListTableView : UITableView!
    
    var delegate : CountryListViewDelegate!
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        countryListTableView = UITableView()
        addSubview(countryListTableView)
        countryListTableView.easy.layout(Edges())
        
        countryListTableView.register(CountryTableViewCell.self, forCellReuseIdentifier: String(describing: CountryTableViewCell.self))
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        countryListTableView.tableFooterView = footerView
        let addCountryButton = UIButton(type: .system)
        addCountryButton.setTitle("Add Country To List", for: .normal)
        addCountryButton.setTitleColor(UIColor.white, for: .normal)
        footerView.addSubview(addCountryButton)
        addCountryButton.easy.layout(Center())
        addCountryButton.addTarget(self, action: #selector(self.onAddCountry), for: .touchUpInside)
        countryListTableView.backgroundColor = UIColor.clear
        countryListTableView.sectionIndexBackgroundColor = UIColor.clear
        countryListTableView.separatorStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onAddCountry(){
        delegate.onAddCountry()
    }
}
