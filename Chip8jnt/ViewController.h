//
// This file is part of Chip8jnt-iOS.
//
// Chip8jnt-iOS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Chip8jnt-iOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//
//  ViewController.h
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chip8Canvas.h"
@class Chip8;
@interface ViewController : UIViewController <UITableViewDelegate>
@property (nonatomic, strong) Chip8 *ch8;
@property (nonatomic, strong) IBOutlet Chip8Canvas *canvas;
@property (nonatomic, strong) IBOutlet UITableView *debugTable;

- (void)debugRefresh; // Request to refresh data;
- (IBAction)debugStep:(id)sender; // Run a emulate cycle;

@end
