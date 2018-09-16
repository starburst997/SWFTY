# SWFTY

![SWFTY](https://github.com/starburst997/SWFTY/raw/master/ref/swfty.gif)

**WIP** *Not to be used in production yet, PRs, issues, etc. are very much welcome*

## TODO

Currently there is a POC export working that will output a `.swfty` (*pronounced schwifty*) from a `.swf` file that is basically a `.zip` file containing a `.png` texture and a `.json` file containing the definitions of all the Sprite / MovieClip.

The JSON look like that:
```json
{
  "definitions": [
    {
      "id": 3,
      "name": "Test",
      "children": [
        {
          "id": 3,
          "name": null,
          "x": -77.10000000000001,
          "y": -5.65,
          "scaleX": 1.4877630099449886,
          "scaleY": 1.7703821837418336,
          "rotation": -33.24528761197778,
          "visible": true,
          "shapes": [
            {
              "id": 0,
              "bitmap": 1,
              "x": 0,
              "y": 0,
              "scaleX": 1,
              "scaleY": 1,
              "rotation": 0
            }
          ]
        }
      ]
    },
    ...
  ],
  "tiles": [
    {
      "id": 1,
      "x": 0,
      "y": 0,
      "width": 90,
      "height": 93
    },
    ...
  ]
}
```

A POC renderer is the next step as well as having the exporter available in command-line form.

## Preface

*Warning: Wall of text! Will clean it up eventually and provide GIFs and what's not*

Convert `.swf` files created by Adobe Animate into `.swft` which is essentially a ZIP container that include one texture file encompassing all bitmaps and JSON files defining all MovieClips (optionally including scale down version of the texture for different screen size minimizing memory / gpu usage).

The main motivation behind this project is to provide tile-based SWF rendering and add a bit more constraints to FLA authoring to makes sure they perform well on lower-end device by having only one texture. It forces the developper to think in terms of layer, one layer takes one draw calls, each layers should be it's own SWF. Text's font can be embed as part of the Texture (usefull for numbers or if you don't care about localization), otherwise the text rendering is done on top of the layer (using OpenFL's TextField if using OpenFL or Bitmap Fonts when using Heaps).

Currently "graphics" are not used, only bitmaps from FLA, this is to keep the conversion as fast as possible (keep your graphics as guided layer and then use convert to bitmap on a non-guide layer). This can be a bit of pain and I'll definitely explore other path, we could always have the SWF run afterward and then "screenshot" each individual Sprite but that would add more processing time everytime we do a modification on the FLA and need to test it (or simply use OpenFL rendering which should make thing a bit faster). Maybe have a debug mode that use a plain-old SWF file?

You should always use Lossless instead of JPEG since everything will be added to one Texture (instead of having a .jpg and then an alpha png for it)

Layers on a project could look like that (top is rendered first, bottom last):
* Custom Layer (your custom game render, do not use SWF, ideally you should be using Tilemaps, GL, whatever fits your need)
* SWFTile Layer, UI.fla (your main UI for the game, aka "HUD", ideally no popups since texts are rendered on top)
* SWFTile Layer, Popup.fla (a popup that goes on top of everything, ideally one FLA per popup)
* SWFTile Layer, AnotherPopup.fla (just another popup, you get the idea)

The idea is to use one FLA per "layer", so whenever you don't need a layer, you can dispose of it reclaiming some memory. Only what we need is loaded and nothing else.

Many things are not supported right now, like Buttons, Sounds, Frames, Timeline, Animation, etc. See this as being more like a description on where a bunch of bitmap are being positioned (for now, more functionality could be added, but this is more of a UI builder).

If you need to load "external" images (like icons) that aren't part of the FLA, you can create placeholder that are the same dimension as those and then you can replace them in the texture and add the placeholder Sprite and it would display that icon, the icon will be part of the Spritesheet and so we keep the draw call to 1 for that layer. You do need to know beforehand as well how much you will be displaying on screen at once.

Adobe Animate is an amazing IDE to create compelling UI and this library does put a lot of constraints but I felt like it is very easy to create unoptimized FLA and those can become a real issue especially on lower-end device and on game that make heavy usage of UI, even what seems like simple UI can bubble up to hundreds of draw calls, mobile device needs to be optimized to provide a smooth experience but also to bring the battery usage down to a minimum (and RAM down).

This project has two part, one the tool to generate the SWFTile based file format from SWF file exported by Adobe Animate, second is render code to load and display / manipulate MovieClip from those generated file.

Includes example to use in OpenFL (eventually Heaps).

## Copyright
Powered by OpenFL

MIT license and copyright 2018 JD, blablabla