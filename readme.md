This is my cloud backup of my personal configuration files. Use at your own risk.

To set up the global gitignore file, run the following command from the root directory of this repo

    git config --global core.excludesfile ./.gitignore_global

I reference my own file system(s) here, so you'll likely need to make some edits if you want it to work for you as well.

Make sure to separately download the following vim bundles. The sym links expect these to be located at $THIS-DIRECTORY/../../

    valloric/YouCompleteMe
    Shutnik/jshint2
    chumakd/perlomni
	kien/rainbow_parentheses
    scrooloose/syntastic
    tpope/vim-fireplace
    pangloss/vim-javascript

Make sure to install YouCompleteMe using the instructions here: https://github.com/Valloric/YouCompleteMe#full-installation-guide
