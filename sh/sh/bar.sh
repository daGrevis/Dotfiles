#!/bin/sh

# Draws a percentage the way htop's bar mode does, e.g. "[||||||     53%]" for
# 53: ten cells in square brackets, one per tenth, a "|" for each tenth that is
# used, and the number to the right of them.
#
# htop is the only meter this setup has, so the bars in the tmux status bar copy
# it, down to how it paints them: the cells in green and the number bold in
# bright black, which is what htop's own capture shows. Only the brackets are
# dimmer, see below.
#
# "green" and "brightblack" are the terminal's colours, and home.nix paints
# those from the theme, so a bar in tmux and a bar in htop come out the same.
#
# Takes the percentage as the first argument, as a whole number, with or
# without a "%".
#
# Prints plain text. With --tmux first, wraps the parts in tmux style sequences
# instead, which only a status bar reads.

# Ten cells, so that one cell is one tenth and the whole range shows. htop
# draws its number over the cells, which its own meters are wide enough to
# carry, but ten cells would lose their top third under it, hence the number
# beside them here.
cells=10

styled=false
if [ "$1" = "--tmux" ]; then
    styled=true
    shift
fi

percentage=${1%\%}

# Four columns for the number, the width of "100%", whatever it says, so that
# the bar keeps its place as the number grows a digit.
text=$(printf '%4s' "$percentage%")

# A part of a cell counts as a whole one, hence the 99, because that is what
# htop does: anything above nothing lights the first cell.
full=$(((percentage * cells + 99) / 100))
[ "$full" -gt "$cells" ] && full=$cells

used=""
free=""
cell=0
while [ "$cell" -lt "$cells" ]; do
    cell=$((cell + 1))
    if [ "$cell" -le "$full" ]; then
        used="$used|"
    else
        free="$free "
    fi
done

# The cells that are free and the number are one run of dim text, like htop
# draws them.
#
# The brackets are grey. htop draws its own bold in the colour of the text
# around them, where they carry a meter that fills a quarter of the screen, but
# in a status bar a frame that bright reads as louder than the reading it holds.
# $THEME_FG3 is the theme's own grey, and a terminal has no name for one.
if $styled; then
    printf '#[fg=%s][#[fg=green]%s#[fg=brightblack,bold]%s%s#[default]#[fg=%s]]#[default]\n' \
        "${THEME_FG3:-brightblack}" "$used" "$free" "$text" "${THEME_FG3:-brightblack}"
else
    printf '[%s%s%s]\n' "$used" "$free" "$text"
fi
