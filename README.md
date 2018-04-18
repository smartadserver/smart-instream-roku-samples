# SVSRokuSample

This sample demonstrates how to request VAST responses from Smart AdServer with the help of Roku Advertising Framework in a Roku SceneGraph app. 
It is based on the RAF Video Node Sample available on Roku's developer website.

## How does it work

Shipped with this sample you'll find the SmartAdServer.brs script that contains 4 functions. 
- BuildAdCallURL() to create the minimum required URL to perform ad calls requesting a VAST 3.0 response.
- AddAdvertisingMacrosInfosToAdCallURL() to add Roku custom identifiers to the ad call URL.
- AddRTBParametersToAdCallURL() to add RTB parameters to this URL.
- AddContentDataParametersToAdCallURL to add Content data parameters to this URL.

PlayerTask (extends Task) in this sample is responsible for playing the main content and requesting / displaying the ads. 
The code handles pre-roll, mid-roll and post-roll ads on the same video content.

The ad call URL is built before each Ad break using SmartAdServers.brs functions with the correct parameters and then passed to RAF with the .setAdUrl() function.
Workflow continues as described in Roku Advertising Framework documentation with .getAds() and .showAds(). Please refer to official Roku's documentation for more information about Roku Advertising Framework and Policies.

[SmartAdServer Instream SDK Documentation](http://documentation.smartadserver.com/instreamSDK/)

