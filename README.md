# Warcraft 3 Tool kit for 3DS Max
This repository contains a few 3DS max script that aims at quickly
configure a scene to be exported as a MDX/MDL file used by Warcraft 3.

People who create customs game in Warcraft 3 often wishes to add custom models
to their game, it is a common practice to take models from other video game
by importing them into 3ds Max and exporting them to MDX/MDL format which is
used by Warcraft 3.

However, this process isn't simple due to models from other video game being
created using different tools, following different procedure to finally being
exported in a format fitting their game. For those reasons, models exported then
imported into MDX/MDL format often requires manual edit by Warcraft 3 modder,
some of those which can take up to multiple dozen hours.

Scripts from this repository aim at cutting editing time by automating
recurrent task.

If you have a 3D model composed of multiple animations which are contained in
separate max file, those scripts allow you to batch export the animation from those max
files into xaf file which can then be batch loaded into your scene/3D model.

Following tools are available in this repository :
* A macro script to batch export 3DS Max file animation under the xaf format
* A macro script to batch load xaf animation file into a scene
* A few options to prepare a scene for export toward MDX/MDL format

## How to install
Copy the wc3-toolkit-scripts folder into the scripts folder of your 3ds Max
application.

Example: `C:\Program Files\Autodesk\3ds Max 2020\scripts\`

In 3ds Max, you have to run/import those scripts, click on the `Utilies` panel,
click on the `MAXScript` button, then click on `Run Script`, open each script
from the wc3-toolkit-scripts folder.

![](https://i.imgur.com/IN8zmdA.jpeg)
_Adding the scripts to 3DS Max._

Those scripts are macroScript, meaning they’re triggered using a hotkey, you have
to map a hotkey to those script.

Click on `Customize` then `Customize User Interface`, in the `Keyboard` tab, click
on the `Category` rollout and select `AnimationScript`. Add a hotkey for
`Max Batch Anim Load` & `Max Batch Anim Save`, e.g `SHIFT + D` and `SHIFT + V`.

![](https://i.imgur.com/qtTf9Bf.jpeg)
_Setting the hotkeys for the macroScript._


In the same rollout, look for `Warcraft III Tools` and click on it, add a hotkey
for `Scene Setup Tools`, e.g `SHIFT + W`.

Now you can press those hotkeys to open the tools and use them.

## How to use

### Batch Anim Save
Press the hotkey you affiliated to the Batch Anim Save macroScript, select the
folder containing your max file model animation, those files are then displayed
into a list on the macroScript window, from this list, select which file you wish
to save as xaf file, xaf file will be saved in the same directory.

### Batch Anim Load
Requirement : You must have a max file of your 3D model opened, the bones structure
should be the same as the max file which had its animation exported, otherwise
the script execution will result in unexpected errors.

This script allows you to batch load a folder containing xaf file into a 3DS
Max scene.

Press the hotkey you affiliated to the Batch Anim Load macroScript, select the
folder containing your xaf file animation, those files are then displayed into
a list on the macroScript window, from this list, select which file you wish
to load on your current scene.

You can choose a time interval between animation, this, however, seems irrevelant
with the time interval between animation sequence in MDX/MDL file, I used NeoDex
for the export, I don’t know how the exporter writes time interval between sequence.

The script will try to name the keynote track, it will look for the following key
word in the xaf filename :`attack, stand, sprint, run, die, weaponskill`.
The name assigned follows Warcraft 3 animation sequence name format.

Example: a xaf named `space_marine_attack_1.xaf` will load an animation
mation sequence
 named `Attack - 1`.

### Scene Setup Tools
This macroScript contains 3 options to configure a scene before exporting it
to MDX/MDL format :

#### Remove Zero Weight
This option removes the 0 value from the weight table, apparently it can fix
animation that aren't exported correctly into MDX/MDL format. If you have
an exported model who has animation messed up, you can try this option to fix it.

#### Convert Relic to Warcraft material
Convert a Dawn of War 2 model material to Warcraft 3 Material. Works only with
Neodex Exporter.

#### Scale up to MDX standard
This option scale up every object of the scene by the input value.

I may have missed an option in the Neodex Exporter, but my export seems
extremely tiny for Warcraft 3 standard. Therefore I added this option.
