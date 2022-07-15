%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_label_location

@view
func getFillFromSquare(square : felt) -> (fill : felt):
    let (colors_address) = get_label_location(colors)
    return ([colors_address + square])
    colors:
    dw '#ffffff'
    dw '#aaaaaa'
    dw '#555555'
    dw '#000000'
    dw '#ffff55'
    dw '#00aa00'
    dw '#55ff55'
    dw '#ff5555'
    dw '#aa0000'
    dw '#aa5500'
    dw '#aa00aa'
    dw '#ff55ff'
    dw '#55ffff'
    dw '#00aaaa'
    dw '#0000aa'
    dw '#5555ff'
end
