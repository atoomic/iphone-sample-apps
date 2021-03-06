//
//  RootViewController.h
//  TubeStatus
//
//  Created by Malcolm Barclay on 28/06/2008.
//

/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version, see <http://www.gnu.org/licenses/>.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*/

#import <UIKit/UIKit.h>
#import "TubeLine.h"

@interface RootViewController : UITableViewController {
	NSMutableArray *displayList;
}

@property (nonatomic, retain) NSMutableArray *displayList;

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier;
- (void)addTubeLine:(TubeLine *)tubeLine;

- (void)setUpDisplayList;

@end
