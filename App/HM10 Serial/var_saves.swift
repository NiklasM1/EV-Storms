//
//  var_saves.swift
//  Serial
//
//  Created by Niklas Mischke on 02.02.21.
//  Copyright © 2021 Balancing Rock. All rights reserved.
//

import Foundation
import CoreBluetooth

public var info_array = [["BioNTech", "BNT162b2\nmRNA-basierter Impfstoff\n2x verabreichen\n95% Wirksamkeit"],
						 ["Moderna", "mRNA-1273\nmRNA-basierter Impfstoff\n2x verabreichen\n94,1% Wirksamkeit"],
						 ["AstraZeneca", "ChAdOx1 nCoV-19\nVektorviren-Impfstoff\n2x verabreichen\n90% Wirksamkeit"],
						 ["Janssen", "Ad26.COV2-S\nVektorviren-Impfstoff\n1x verabreichen\n66% Wirksamkeit"]]

public func reset() {
	label = [0,0,0,0,0,0,0]
	Progress = 0.0
	Image = UIImage(named: "Lego-0")!
	count = 0
}

public var output = [0,0,0,0,0,0,0]
public var label = [0,0,0,0,0,0,0]

public var Progress:Float = 0.0
public var Image:UIImage = UIImage(named: "Lego-0")!
public var count:Int = 0
public var gesamt:Int = 0
