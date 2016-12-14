//
//  CountryTableViewCell.swift
//  Pods
//
//  Created by Farid on 12/14/16.
//
//

import UIKit
import EasyPeasy

open class CountryTableViewCell: BWSwipeRevealCell {
    var flagImageView : UIImageView!
    var nameLabel : UILabel!
    var infoLabel : UILabel!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initElements()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initElements()
    }
    
    static let cellHeight : CGFloat = 75
    static let elementHeight : CGFloat = 50
    
    func initElements(){
        backgroundColor = UIColor.ttroColors.white.color
        
        flagImageView = UIImageView()
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(flagImageView)
        flagImageView <- [
            Height(CountryTableViewCell.elementHeight),
            Width(CountryTableViewCell.elementHeight),
            Left(10).to(contentView, .left),
            CenterY().to(contentView, .centerY)
        ]
        
        flagImageView.layer.masksToBounds = true
        flagImageView.layer.cornerRadius = CountryTableViewCell.elementHeight/2
        flagImageView.contentMode = .scaleAspectFit
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        nameLabel <- [
            Height(CountryTableViewCell.elementHeight),
            Width(*0.6).like(contentView),
            Left(10).to(flagImageView, .right),
            CenterY().to(contentView, .centerY)
        ]
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoLabel)
        infoLabel <- [
            Height(CountryTableViewCell.elementHeight),
            Right(10).to(contentView, .right),
            CenterY().to(contentView, .centerY),
            Width(<=0*0.5).like(contentView)
        ]
    }
}
