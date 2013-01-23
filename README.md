xml_edit
========

Chef LWRP that uses xmlstarlet to perform in-place, partial edits on XML files.

Background / Caveats
====================

## Why I Needed This

I had a Jenkins installation with multiple instances.  Jenkins stores config data in XML files, which get modified by the web UI.  When I wanted to make the same change across all instances, or setup a copy of an instance, I had to use the web UI to make settings.  Boo.

I could not place the XML files under full template control because Jenkins makes writes to the files, and those writes are meaningful state. I needed somthing that could make a partial file edit (like Chef::Util::FileEdit) but was XML aware, and maybe had some idempotency smarts built-in.

## Why You Should Seriously Not Use This

Most of the arguments against can be found in the FileEdit mailing list thread, http://lists.opscode.com/sympa/arc/chef-dev/2012-06/msg00025.html .  It boils down to reproducibility - if you have a file that some non-chef process is injecting *meaningful* state into, you will not be able to recreate that on a fresh system using chef.  So, giving ourselves a tool to enable partial edits (to preserve that non-chef meaningful state) is encouraging a dangerous practice.

Of course, in reality, there are other state-capturing processes besides Chef.  In my case, the Jenkins config files are backed up anyway, so the user-added state gets preserved; it's then my problem to get that onto a new system.

Some other issues crop up.  One is idempotency; there are many edge cases here, and it is very possible that this LWRP might repeatedly make an edit it doesn't need to, possibly trashing your data.  Pull requests and tests welcome.

Another concern is incremental edits.  If each edit resource makes a small, incremental change, you can never delete any of those resources, or a new system won't have the same series of changes.  You can get around that by combining edits, but it is fraught with peril.

## Better Alternatives

* Find a way to template the whole file.
* If you can convince the other process to write to a different file, you could use the template partials mechanism in chef 0.11+ to have the other process write to a file, which you then include into your master.
* Change technology stacks to avoid rudely designed software :)

Maturity
========

Not even implemented yet.  This README exists basically as an RFC.

This is in early development, and is not likely to be portable, or safe-ish to use, for a bit yet.

Requirements
============

You'll need xmlstarlet installed, which provides the 'xml' or 'xmlstarlet' binary.  The path is configurable.

Platforms
=========

Developed and tested under omnios, but is likely to work on any unix-like operating system.  Pull requests welcome.

Recipes
=======

None, yet.

Attributes
==========

Provides in a cookbook attributes file:

    default[:xml_edit][:xml_binary_path] = '/usr/bin/xml'

Under omnios, path defaults to '/opt/omni/bin/xml'.

Note: Your OS may package it as '/usr/bin/xmlstarlet'.  

Resources
=========

`xml_edit`
----------

## General Behavior

Overall, I tried to make this work somewhat similarly to `template` resource, but that's not entirely possible.

* Unlike template, we cannot detect if a change is needed by applying the edit to a copy of the file, then compare signatures; we have to assume another process may be making edits, so a changed checksum file does not indicate a need to re-run the edit.  Instead, we rely on you providing an xpath conditional.
* Like template, when a change is needed, backup the original to /var/chef/backups . 
* Unlike template, if the XML is missing on the filesystem, an exception is thrown.  It doesn't create files; use `cookbook_file` for that.

## Actions

* :insert  Insert an XML payload into a file, if it is not already present
* :replace Replace an XPath value with another value, if different
* :delete  Delete the matched nodes.

## Attribute Parameters
* path - filesystem path to the XML file to edit.  Defaults to the resource name.
* payload - well-formed XML string value to insert or replace.
* cursor_xpath - location for the insertion, replacement, or deletion.
* backups - integer, number of backup copies of the file to keep in /var/chef/backups.  Default 5.
* only_if_xpath - String xpath statement.  The resource will only be executed if the xpath query returns something (nonzero nodes, or a nonempty, non-zero value).
* not_if_xpath - Inverse of only_if_xpath.

Note that neither of only_if_xpath nor not_if_xpath is required, and plain not_if/only_if are also available to you.  

## Examples

### Original File

    <?xml version="1.0"?>
    <bookshelf>
       <book>
          <author>Conway, Damien</author>
          <title>Perl Best Practices</title>
       </book>
       <book>
          <author>Atwood, Margaret</author>
          <title>Oryx and Crake</title>
       </book>
       <leaflet in_print="false">
         <author>Wolfe, Clinton</author>
         <title>Great Ideas I Have Had, With No Negative Unintended Consequences</title>
       </leaflet>
    </bookshelf>

### Insert a Book

    xml_edit "the_file.xml" do
      cursor_xpath "/bookshelf"
      payload <<-EOX
        <book>
          <author>Atwood, Margaret</author>
          <title>The Year of the Flood</title>
       </book>
      EOX
      not_if_xpath "//book/title[text()='The Year of the Flood']"
    end

Result:

    <?xml version="1.0"?>
    <bookshelf>
       <book>
          <author>Conway, Damien</author>
          <title>Perl Best Practices</title>
       </book>
       <book>
          <author>Atwood, Margaret</author>
          <title>Oryx and Crake</title>
       </book>
       <leaflet in_print="false">
         <author>Wolfe, Clinton</author>
         <title>Great Ideas I Have Had, With No Negative Unintended Consequences</title>
       </leaflet>
       <book>
          <author>Atwood, Margaret</author>
          <title>The Year of The Flood</title>
       </book>
    </bookshelf>
