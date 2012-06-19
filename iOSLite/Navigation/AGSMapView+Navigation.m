//
//  AGSMapView+LiteNavigation.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Navigation.h"
#import "EDNLiteHelper.h"
#import "EDNLiteNavigationHelper.h"
#import <CoreLocation/CoreLocation.h>

@implementation AGSMapView (Navigation)
EDNLiteNavigationHelper *__ednLiteNavigationHelper = nil;
NSInteger __ednLiteScaleForGeolocation = -1;

#pragma mark - Center
- (void) centerAtLat:(double) latitude Long:(double) longitude withScaleLevel:(NSInteger)scaleLevel
{
    // Build an AGSPoint using the Lat and Long
    AGSPoint *webMercatorCenterPt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    // Get the map scale represented by the integer level
    double scale = [EDNLiteHelper getScaleForLevel:scaleLevel];

    // Here's the code to do the zoom, but we don't know whether we want to run it now, or
    // need to queue it up until the AGSMapView is loaded.
    void (^zoomCode)() = ^void
    {
        [self zoomToScale:scale withCenterPoint:webMercatorCenterPt animated:YES];
    };
    
    if (self.loaded)
    {
        // If the mapView is already loaded, just run this code.
        zoomCode();
    }
    else 
    {
        // Otherwise we queue this block up to be run when self (an AGSMapView) *has* loaded
        // since the behaviour doesn't work before then. This is because the map will not yet 
        // be fully initialized for UI interaction until then.
        [EDNLiteHelper queueBlock:zoomCode untilMapViewLoaded:self];
    }
}

- (void) centerAtLat:(double) latitude Long:(double) longitude
{
    AGSPoint *p = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    [self centerAtPoint:p animated:YES];
}

- (void) centerAtPoint:(AGSPoint *)point withScaleLevel:(NSInteger)scaleLevel
{
    double scaleForLevel = [EDNLiteHelper getScaleForLevel:scaleLevel];
    [self zoomToScale:scaleForLevel withCenterPoint:point animated:YES];
}

#pragma mark - Zoom
- (void) zoomToLevel:(NSInteger)level
{
    AGSPoint *currentCenterPoint = self.visibleArea.envelope.center;
    double scaleForLevel = [EDNLiteHelper getScaleForLevel:level];
    [self zoomToScale:scaleForLevel withCenterPoint:currentCenterPoint animated:YES];
}

#pragma mark - Geolocation (GPS)
- (void) centerAtMyLocation
{
    [self ensureNavigationHelperInitialized];
    
    if ([__ednLiteNavigationHelper isEnabled])
    {
        [__ednLiteNavigationHelper getLocation];
    }
	else {
		UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"Cannot Find You" message:@"Location Services Not Enabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[v show];
	}
}

#pragma mark - Centerpoint of map
- (AGSPoint *) getWebMercatorCenterPoint
{
    return self.visibleArea.envelope.center;    
}

- (AGSPoint *) getLatLongCenterPoint
{
    return [EDNLiteHelper getWGS84PointFromPoint:[self getWebMercatorCenterPoint]];
}

#pragma mark - Internal
- (void) centerAtMyLocationWithScaleLevel:(NSInteger)scaleLevel
{
    __ednLiteScaleForGeolocation = scaleLevel;
    [self centerAtMyLocation];
}

- (void) gotLocation:(NSNotification *)notification
{
    CLLocation *newLocation = [notification.userInfo objectForKey:kEDNLiteGeolocationSucceededLocationKey];
    if (__ednLiteScaleForGeolocation == -1)
    {
        [self centerAtLat:newLocation.coordinate.latitude
                     Long:newLocation.coordinate.longitude];
    }
    else
    {
        [self centerAtLat:newLocation.coordinate.latitude
                     Long:newLocation.coordinate.longitude
           withScaleLevel:__ednLiteScaleForGeolocation];
    }
    __ednLiteScaleForGeolocation = -1;    
}

- (void) failedToGetLocation:(NSNotification *)notification
{
    NSLog(@"Error getting location: %@", [notification.userInfo objectForKey:@"error"]);
}

- (void) ensureNavigationHelperInitialized
{
    if (!__ednLiteNavigationHelper)
    {
        __ednLiteNavigationHelper = [[EDNLiteNavigationHelper alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gotLocation:)
                                                     name:kEDNLiteGeolocationSucceeded
                                                   object:__ednLiteNavigationHelper];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(failedToGetLocation:)
                                                     name:kEDNLiteGeolocationError
                                                   object:__ednLiteNavigationHelper];
    }    
}
@end