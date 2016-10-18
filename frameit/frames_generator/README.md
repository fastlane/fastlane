# Prepare and upload new device frames

Since October 2016 we host the device frame resources since Apple removed lots of old device frame images.

To run the wizard helping you prepare new device assets, just run `rake` in this directory. 

You have to run this wizard every time we want to update the device assets.

This will generate 2 directories:

- The time stamp based one, that's used if the user specifies a certain version in their Framefile
- The latest one that will be downloaded by default
