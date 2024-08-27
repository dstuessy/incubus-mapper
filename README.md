# Incubus Mapper

A tilemap level editor, nothing more to it.

Work in progress, you're not gonna get much out of this.

Run the app using [Love2D](https://www.love2d.org/). Install the engine somewhere on your machine and add it to your PATH.
Then execute the following command.

``` sh
$ love . <target/tileset.png> <target/savefile>
```

**Note:** due to limitations with Love2D, the save file is found within Love2D's save folder on your machine. This will vary between different operating systems. See the [Love2D documentation](https://www.love2d.org/wiki/love.filesystem) for your machine's save file location.

### Usage

Click to select a tile from the tileset palette. Click on the canvas to place the selected tile.

Hold Left Alt while clicking to fill the whole canvas with the same tile.

Hold Left Shift while dragging to fill a selected area with the same tile.

Hold Right Click to move the canvas around.
