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
//
//  ViewController.m
//  Chip8jnt
//
//  Created by Jonathan da Silva Santos on 26/05/13.
//  Copyright (c) 2013 Jonathan da Silva Santos. All rights reserved.
//

#import "ViewController.h"
#import "Chip8.h"
#import "Chip8jntUtils.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Receives notification from debug;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debugRefresh) name:@"debugRefresh" object:nil];

    // We create a object to execute some utils functions
    Chip8jntUtils *utils = [[Chip8jntUtils alloc] init];
    
    self.ch8 = [[Chip8 alloc] init];
    self.ch8.canvas = self.canvas;
    self.debugTable.dataSource = self.ch8;
    self.debugTable.delegate =self;
    
    // Print all roms names in console;
    NSLog(@"%@", [utils getAllRomsFilenames] );
    NSString *romName = @"BC_test.ch8";

    BOOL debug = NO;
    [self.ch8 startWithRom:romName andDebug:debug];
    
    // If debug is true we need to hide the keyboard layer to show debug table
    if(debug) {
        [self.keyboardView setAlpha:0.3];
        [self.stepButton setHidden:NO];
    } else {
        
        [self.stepButton setHidden:YES];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 18;
}

- (void)debugRefresh {
    
    [self.debugTable reloadData];
}

- (IBAction)debugStep:(id)sender {
    [self.ch8 cycle]; // Run a emulate cycle;
}

- (IBAction)touchDownKey:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    [self.ch8 setPress:button.tag];
}

- (IBAction)touchUpsideKey:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    [self.ch8 setUnpress:button.tag];
}

@end
