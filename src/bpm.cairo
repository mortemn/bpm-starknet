%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starknet_felt_packing.contracts.bits_manipulation import external as bits_manipulation
from arrays.array_manipulation import add_last, join
from cairopen.binary.bits import Bits
from starkware.cairo.common.alloc import alloc


# Gets color/fill from a particular square
@view
func getFillFromSquare(square : felt) -> (fill : felt):
    let (colors : felt*) = alloc()
    assert colors[0] = '#ffffff'
    assert colors[1] = '#aaaaaa'
    assert colors[2] = '#555555'
    assert colors[3] = '#000000'
    assert colors[4] = '#ffff55'
    assert colors[5] = '#00aa00'
    assert colors[6] = '#55ff55'
    assert colors[7] = '#ff5555'
    assert colors[8] = '#aa0000'
    assert colors[9] = '#aa5500'
    assert colors[10] = '#aa00aa'
    assert colors[11] = '#ff55ff'
    assert colors[12] = '#55ffff'
    assert colors[13] = '#00aaaa'
    assert colors[14] = '#0000aa'
    assert colors[15] = '#5555ff'
    return (colors[square])
end

@view
func getSquareFromMap{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap, actual_index) -> (square : felt):
    alloc_locals

    let (res : felt) = bits_manipulation.actual_get_element_at(bitmap, actual_index, 8)

    # let shift = 252 - (index * 4)
    # let (shl1 : felt) = Bits.leftshift('15', 252)
    # let (and : felt) = bitwise_and(shl1, element)
    # let (square : felt) = Bits.rightshift(shift, and)
    return (res)
end

# Generates a blob of rows.
@view
func generateRows{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap, rows_len : felt, rows : felt*, x) -> (rows_len : felt, rows : felt*):
    alloc_locals
    if x == 64:
        tempvar bitwise_ptr = bitwise_ptr
        return (64, rows)
    end

    let (pixelRow_len, pixelRow) = joinRows(bitmap, 0, rows, 8, x)
    let (res_len, res) = join(rows_len, rows, pixelRow_len, pixelRow)

    return generateRows(bitmap, res_len, res, x+8)
end

# Joins rows that are generated.
@view
func joinRows{
    bitwise_ptr : BitwiseBuiltin*,
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(bitmap, rows_len, rows : felt*, size, x) -> (res_len, res : felt*):
    alloc_locals
    if rows_len == size:
        return (rows_len, rows)
    end

    let (row_len, row) = generateRow(bitmap, x, rows_len)
    let (res_len, res : felt*) = join(rows_len, rows, row_len, row)

    return joinRows(bitmap, res_len, res, rows_len+1, x)
end


# Generates a singular row.
@view
func generateRow{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap, i, y) -> (row_len : felt, row : felt*):
    alloc_locals
    let (square : felt) = getSquareFromMap(bitmap, i)
    let (fill : felt) = getFillFromSquare(square)

    let (row : felt*) = alloc()
    assert row[0] = '<rect fill="'
    assert row[1] = fill
    assert row[2] = '" x="0" y="'
    assert row[3] = y
    assert row[4] = '"width="1" height="1" />'

    return (5, row)
end

# Renders svg version of bitmap. Due to restrictions of felt character limit,
# felts are stored into arrays.
# To make the implementation of getFillFromSquare easier, an element on the
# bitmap stores 28 characters.
@view
func renderSvg{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap) -> (svg_len : felt, svg : felt*):
    alloc_locals
    let (rows : felt*) = alloc()
    let (res_len, res : felt*) = generateRows(bitmap, 0, rows, 0)

    let (string : felt*) = alloc()
    assert string[0] = '<?xml version="1.0" encoding="'
    assert string[1] = 'UTF-8" standalone="no"?><svg x'
    assert string[1] = 'mlns="http://www.w3.org/2000/s'
    assert string[2] = 'vg" version="1.1" viewBox="0 0'
    assert string[3] = ' 8 8">'

    let (res1_len : felt, res1 : felt*) = join(1, string, res_len, res)
    let (svg_len : felt, svg : felt*) = add_last(res1_len, res1, '</svg>')
    return (svg_len, svg)
end
