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
