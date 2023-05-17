
# Vertex Aligner

"Vertex Aligner" is a MaxScript tool for aligning vertices in 3ds Max. \
The script offers three modes for aligning vertices: \
1.align between two vertices\
2.align to one vertex\
3.align to coordinates\
this script works with spline objects, Editable Poly and Edit Poly modifier for now.\
support for editable mesh , editable pach , and also other modifiers will be added in future


## Installation

To use "Vertex Aligner," follow these steps:

1. Open 3ds Max and go to the "scripting" menu.
2. Select "Run Script" and navigate to the location where you saved "vertex_aligner.ms" file.
3. Select "vertex_aligner.ms" and click "Open" to run it.
4. The script should open a dialog box with options for the three modes:
> * "Align between two vertices"
> * "Align to one vertex" 
> * "Align to coordinates"
5. Select the desired mode and follow the prompts to select the vertices or enter the coordinates as needed.

## Compatibility

"Vertex Aligner" is compatible with:


## Modes

### Align between two vertices

This mode allows you to align vert(s) to the abstract line between two other vertices. To use this mode:

1. Select firs base vertex and press "set" button
2. Select second base vertex and press "set" button
3. Select target vert(s) and press "set" button
4. press align button.

### Align to one vertex

This mode allows you to align vert(s) to one base vertex. To use this mode:

1. Select the base vertex and press "set" button
2. select target vert(s) and press "set" button
3. enable desired align axis(es) "X" , "Y" and "Z"
4.press align button

### Align to coordinates

This mode allows you to align vert(s) to specific coordinates. To use this mode:

1. enable desired align axis(es) "X" , "Y" and "Z"
2. Enter the X, Y, and Z coordinates for the position you want to align to.
3. select target vert(s) and press "set" button
4. press align button

## Support

If you encounter any issues or have any questions about "Vertex Aligner," please feel free to contact me. I am happy to help and welcome any feedback or suggestions for improvement.

## License

"Vertex Aligner" is released under the Apache License 2.0 with the "no endorsement" clause. See the LICENSE file for details.
