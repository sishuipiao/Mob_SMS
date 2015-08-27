//
//  FriendsCell.swift
//  Mob_SMS
//
//  Created by Steven on 14/11/21.
//  Copyright (c) 2014年 DevStore. All rights reserved.
//

import UIKit
protocol FriendsCellDelegate:NSObjectProtocol {
    func FriendsCellClick (cell:FriendsCell)
}
class FriendsCell: UITableViewCell {
    
    var img:UIImage?
    var name:String?
    var nameDesc:String?
    var index:Int?
    var section:Int?

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameDescLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    var delegate:FriendsCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnClick(sender: AnyObject) {
        delegate?.FriendsCellClick(self)
    }
    
}
