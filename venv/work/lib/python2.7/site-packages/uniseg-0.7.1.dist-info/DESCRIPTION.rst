Introduction
============

A pure Python module to determine Unicode text segmentations.

You can see the full documentation including the package reference on 
http://uniseg-python.readthedocs.org.


Features
========

This package provides:

- Functions to get Unicode Character Database (UCD) properties concerned with 
  text segmentations.
- Functions to determin segmentation boundaries of Unicode strings.
- Classes that help implement Unicode-aware text wrapping on both console 
  (monospace) and graphical (monospace / propotional) font environments.

Supporting segmentations are:

*code point*
    `Code point <http://www.unicode.org/glossary/#code_point>`_ is *"any value 
    in the Unicode codespace."* It is the basic unit for processing Unicode 
    strings.
*grapheme cluster*
    `Grapheme cluster <http://www.unicode.org/glossary/#grapheme_cluster>`_ 
    approximately represents *"user-perceived character."* They may be made 
    up of single or multiple Unicode code points. e.g. "G" + *acute-accent* is 
    a *user-perceived character*.
*word break*
    Word boundaries are familiar segmentation in many common text operations. 
    e.g. Unit for text highlighting, cursor jumping etc. Note that *words* are 
    not determinable only by spaces or punctuations in text in some languages. 
    Such languages like Thai or Japanese require dictionaries to determine 
    appropriate word boundaries. Though the package only provides simple word 
    breaking implementation which is based on the scripts and doesn't use any 
    dictionaires, it also provides ways to customize its default behaviours.
*sentensce break*
    Sentence breaks are also common in text processing but they are more 
    contextual and less formal. The sentence breaking implementation (which is 
    specified in UAX: Unicode Standard Annex) in the package is simple and 
    formal too. But it must be still useful in some usages.
*line break*
    Implementing line breaking algorithm is one of the key features of this 
    package. The feature is important in many general text presentations in 
    both CLI and GUI applications.


Requirements
============

- Python 2.7 / 3.3 / 3.4


Download
========

Source / binary distributions (PyPI)
    https://pypi.python.org/pypi/uniseg
All sources and build tools etc. (Bitbucket)
    https://bitbucket.org/emptypage/uniseg-python


Install
=======

Just type::

    % pip install uniseg

or download the archive and::

    % python setup.py install


Changes
=======

0.7.1 (2015-05-02)
  - CHANGE: wrap.Wrapper.wrap(): returns the count of lines now.
  - Separate LICENSE from README.txt for the packaging-related reason in some 
    environments.
0.7.0 (2015-02-27)
  - CHANGE: Quited gathering all submodules's members on the top, uniseg 
    module.
  - CHANGE: Reform ``uniseg.wrap`` module and sample scripts.
  - Maintained uniseg.wrap module, and sample scripts work again.
0.6.4 (2015-02-10)
  - Add ``uniseg-dbpath`` console command, which just print the path of 
    ``ucd.sqlite3``.
  - Include sample scripts under the package's subdirectory.
0.6.3 (2015-01-25)
  - Python 3.4
  - Support modern setuptools, pip and wheel.
0.6.2 (2013-06-09)
  - Python 3.3
0.6.1 (2013-06-08)
  - Unicode 6.2.0


References
==========

*UAX #14: Unicode Line Breaking Algorithm* (6.2.0)
    http://www.unicode.org/reports/tr14/tr14-30.html
*UAX #29 Unicode Text Segmentation* (6.2.0)
    http://www.unicode.org/reports/tr29/tr29-21.html


Related / Similar Projects
==========================

`PyICU <https://pypi.python.org/pypi/PyICU>`_ - Python extension wrapping the ICU C++ API
    *PyICU* is a Python extension wrapping International Components for 
    Unicode library (ICU). It also provides text segmentation supports and 
    they just perform richer and faster than those of ours. PyICU is an 
    extension library so it requires ICU dynamic library (binary files) and 
    compiler to build the extention. Our package is written in pure Python; 
    it runs slower but is more portable.
`pytextseg <https://pypi.python.org/pypi/pytextseg>`_ - Python module for text segmentation
    *pytextseg* package forcuses very similar goal to ours; it provides 
    Unicode-aware text wrapping features. They designed and uses their 
    original string class (not built-in ``unicode`` / ``str`` classes) for the 
    purpose. We use strings as just ordinary built-in ``unicode`` / ``str`` 
    objects for text processing in our modules.


