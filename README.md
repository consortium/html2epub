# html2epub

`html2epub` is a workflow to convert an HTML file into an EPUB electronic publication. It uses libraries from the Transpect system. You provide the HTML file, the styles and the images, and `html2epub` creates an EPUB file that is readable on most tablets and eReaders.

## Input

The input for `html2epub` is an HTML file, more specifically an XHTML5 file. An XHTML file is a file that is at the same time valid HTML and XML. XML is a standard markup language used in many file formats. Regular HTML5 is inspired by XML, is more lenient: it accepts certain shorthands that make it easier to write, but harder for other tools to process.

These are some of the things to think about when writing XHTML5:

    <p>In an XHTML file, all tags should be closed, so also a self-cosing element like a line break<br/>
    needs to includes a closing / slash. All attributes like classnames <span class="important">should be surrounded by quotes</a>.</p>

To find out all differences, consult [the guide from WHATWG](https://wiki.whatwg.org/wiki/HTML_vs._XHTML).

Web browsers can deal with both XHTML and HTML files. By default a web browser will interpret a page as an HTML file. When a web browser recognises that a file is XHTML it will interpret the file in a more strict manner just like `html2epub` will. That is why, when working on an HTML file for use with `html2epub`, you will want to preview it in the browser as XHTML. The easiest way to make sure your browser interprets your file this way, is to give it the `.xhtml` extension.

### File tree

`html2epub` will work with just one file as input. This will create an EPUB without images or styles, that will rely on the default styling of the reading devices.

In most cases, you will want to provide styling and images though. That is why `html2epub` accepts a zip file as input, in which you can combine all these different files.

The easiest approach is to have the html file in the root. Then create subfolders for the images, styles, fonts: 

    .
    ├── fonts
    │   ├── GentiumBasic.otf
    │   ├── ...
    ├── images
    │   └── cover.jpg
    │   ├── ...
    ├── styles
    │   └── style.css
    │   ├── ...
    ├── name-of-publication.xhtml

This is probably similar to the approach you would take when making a web site. What is important is to make sure that the links between the HTML file and the other files are relative.

So in your HTML file, make links like this:

    <link href="styles/style.css" rel="stylesheet" type="text/css"/>

in your stylesheet link to fonts like this:

    src : url(../fonts/GentiumBasic.otf);

The relative links will have the advantage that you can move all the files to another computer, or a web server (whether on the root or within a subfolder) and they will still work.

As you can see there is only one html file. In a website, you would probably name this file index.html, but in this case you should give it the name of your publicatin. You should zip all these files into one zip file, which you should give the same name as the HTML file (i.e., in `name-of-publication.zip` include at least `name-of-publication.xhtml`.)

## Web interface

The easiest way to run html2epub is by connecting to the web interface. With your web browser, open `frontend_example.html`. It connects to the le-tex server, where an install of this library is hosted. In this way you can use the interface of the browser and you don’t need to install libraries on your own computer. To download the files, you need the credentials: you can find them in the source of the html file.

## Local installation

Running html2epub on your own computer requires familiarity with the command line. The computer should also have Java installed, and the Git source code management system.

Git is used to download various scripts upon which html2epub depends. These required dependencies are includes as ‘submodules’. After cloning the repository, in the terminal, move to the folder `html2epub`, and run:

   git submodule update --init --recursive

### Example usage

From the `html2epub` folder, in the terminal, run:

    make conversion IN_FILE=/path/to/zip_file.zip

The files will be created in the `output` folder of html2epub.

## Metadata

An EPUB provides metadata tot the reading device. The most important are the title and author since every reading system displays these data. Other metadata are ISBN number, etc.

The EPUB has its own configuration file to store the metadata. Html2epub takes care of extracting metadata from the HTML file and saving it in an EPUB specific manner.

Html2epub takes it cues from [scholarly HTML](http://scholarlyhtml.org/core-specification/). The idea is to use add a `property` attribute to tags that are already in the HTML, to connotate that the content of these tags represent that specific metadata. In this way you do not have to keep track of metadata separately from the contents. This technique is known as RDF/A, and this is how you use it inside your HTML document:

    <h1 property="http://purl.org/dc/terms/title" class="_notoc">Reproducing Autonomy</h1>
    <h2>Work, Money, Crisis and Contemporary Art</h2>
    <p property="http://purl.org/dc/terms/creator">by Kerstin Stakemeier &amp; Marina Vishmidt</p>

### Table of Contents

EPUB’s feature a table of contents that can be used to navigate the various chapters of a digital publication. By default, html2epub takes all the headers marked as `h1` and builds the TOC from this. You can prevent a `h1` from being used in the Table of Contents by adding a class `_notoc`, as in the example above.

### Cover Image

The easiest way to provide a cover image, is to simply add an image called `cover.jpg` to the folder `images`. `epub2html` will automatically create the corresponding cover page.
