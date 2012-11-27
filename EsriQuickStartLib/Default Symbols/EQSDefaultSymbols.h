//
//  EQSDefaultSymbols.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import <Foundation/Foundation.h>

#import "EQSShadowLineSymbol.h"

// Forward reference the class
@class EQSDefaultSymbols;

@interface AGSMapView (EQSDisplay)
- (EQSDefaultSymbols *) defaultSymbols;
@end

@interface EQSDefaultSymbols : NSObject
@property (nonatomic, strong) AGSMarkerSymbol *geolocation;

@property (nonatomic, strong) AGSMarkerSymbol *findPlace;
@property (nonatomic, strong) AGSMarkerSymbol *reverseGeocode;
@property (nonatomic, strong) AGSMarkerSymbol *failedGeocode;

@property (nonatomic, strong) EQSShadowLineSymbol *route;
@property (nonatomic, strong) AGSMarkerSymbol *routeStart;
@property (nonatomic, strong) AGSMarkerSymbol *routeEnd;

@property (nonatomic, strong) AGSSimpleLineSymbol *routeSegment;
@property (nonatomic, strong) AGSMarkerSymbol *routeSegmentStart;
@end


