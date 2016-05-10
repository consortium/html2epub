# html2epub
XProc libraries to convert EPUB from XHTML5

The input file format of the converter should be a .html, .xhtml or a zip.

Using a zip allows to include assets: a stylesheet, images, fonts, etc. The zip needs to contain one HTML file, that needs to have the same name as the zip file (i.e., in `my-awesome.zip` include at least `my-awesome.html`.)

## Installation

The required dependencies are includes as submodules. After cloning this repository, in the terminal, run:

   git submodule update --init --recursive

## Example usage

From the html2epub folder, in the terminal, run:

    make conversion IN_FILE=/path/to/zip_file.zip

The files will be created in the `output` folder of html2epub.

## Web interface

You can also use the web interface. Open `frontend_example.html`. It connects to the le-tex server, where an install of this library is hosted. In this way you can use the interface of the browser and you don’t need to install libraries on your own computer. To download the files, you need the credentials: you can find them in the source of the html file.
