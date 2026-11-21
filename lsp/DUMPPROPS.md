Since you have a programmer's mindset, you are going to love how AutoLISP handles this.

What you are asking for is called **Object Reflection** (similar to running `dir(object)` or `__dict__` in Python). In CAD, the Properties Panel is just a visual wrapper for the underlying ActiveX/COM database (VLA-Objects).

We can write a script that accesses the VLA-Object and dumps every single underlying property straight to the console so you can copy it out as text.

Here is the script to build your new **`DUMPPROPS`** command.

### The AutoLISP Script: `DumpProps`


### How to use it:

1. Make sure you are on **Layout 1**.
2. Run the command **`DUMPPROPS`**.
3. Click the edge of your Viewport (the rectangle showing your floor plan).
4. The screen will instantly flip to the CAD Text Window (the equivalent of a terminal console), displaying a massive list of properties formatted like this:
* `Center (RO) = (148.5 210.0 0.0)`
* `CustomScale = 0.2`
* `DisplayLocked = -1`
* `Layer = "0"`



### The "Save to Text File" Hacker Trick

If you don't want to manually copy and paste from the terminal, you can tell CAD to automatically write a `.txt` file to your hard drive.

1. Type **`LOGFILEON`** and hit Enter. *(CAD is now silently recording everything that happens in the console to a text file).*
2. Run **`DUMPPROPS`** and click your viewport.
3. Type **`LOGFILEOFF`** to stop the recording.
4. Type **`LOGFILEPATH`** to see exactly which folder the `.txt` file was saved in (usually in your `AppData\Local\Temp` folder).

**Did the script successfully dump the properties, and what does it say next to `CustomScale` in that massive text list?**