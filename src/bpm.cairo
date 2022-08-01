%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import split_int, split_felt
from starknet_felt_packing.contracts.bits_manipulation import external as bits_manipulation
from starknet_felt_packing.contracts.pow2 import pow2
from arrays.array_manipulation import add_last, join
from cairopen.binary.bits import Bits
from caistring.contracts.str import literal_from_number
from starkware.cairo.common.alloc import alloc

# Gets color/fill from a particular square
@view
func get_fill_from_square(square : felt) -> (fill : felt):
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
func get_square_from_map{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap_len, bitmap : felt*, index) -> (square : felt):
    alloc_locals

    let x = 64 - index
    let (e, i) = unsigned_div_rem(x, 32) 
    let e1 = bitmap_len-(e+1)
    let element = bitmap[e1]

    let (square : felt) = bits_manipulation.actual_get_element_at(element, i*4, 4)

    return (square)
end

# Generates a blob of rows.
@view
func generate_rows{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap_len, bitmap : felt*, rows_len : felt, rows : felt*, size, y) -> (rows_len : felt, rows : felt*):
    alloc_locals
    let size_res = size * size * 7
    if y == (size):
        tempvar bitwise_ptr = bitwise_ptr
        return (rows_len, rows)
    end
    let (tmp : felt*) = alloc()

    let (pixelRow_len, pixelRow) = join_rows(bitmap_len, bitmap, 0, tmp, size, 0, y)
    %{ print("joined row " + str(ids.y)) %}
    let (res_len, res) = join(rows_len, rows, pixelRow_len, pixelRow)

    return generate_rows(bitmap_len, bitmap, res_len, res, size, y+1)
end

# Joins rows that are generated.
@view
func join_rows{
    bitwise_ptr : BitwiseBuiltin*,
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(bitmap_len, bitmap : felt*, rows_len, rows : felt*, size, x, y) -> (res_len, res : felt*):
    alloc_locals
    if x == (size):
        return (rows_len, rows)
    end
    let index = size * y + (x + 1)

    let (row_len, row) = generate_row(bitmap_len, bitmap, index, x, y)

    let (res_len, res : felt*) = join(rows_len, rows, row_len, row)

    return join_rows(bitmap_len, bitmap, res_len, res, size, x+1, y)
end


# Generates a singular row.
@view
func generate_row{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap_len, bitmap : felt*, i, x, y) -> (row_len : felt, row : felt*):
    alloc_locals
    let (square : felt) = get_square_from_map(bitmap_len, bitmap, i)
    let (fill : felt) = get_fill_from_square(square)
    let (x_lit : felt) = literal_from_number(x)
    let (y_lit : felt) = literal_from_number(y)

    let (row : felt*) = alloc()
    assert row[0] = '<rect fill="'
    assert row[1] = fill
    assert row[2] = '" x="'
    assert row[3] = x_lit
    assert row[4] = '" y="'
    assert row[5] = y_lit
    assert row[6] = '" width="1" height="1" />'

    return (7, row)
end

@view
func render_svg{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(bitmap_len, bitmap : felt*) -> (svg_len, svg : felt*):
    alloc_locals
    let (rows : felt*) = alloc()
    let (res_len : felt, res : felt*) = generate_rows(bitmap_len, bitmap, 0, rows, 8, 0)

    let (string : felt*) = alloc()
    assert string[0] = '<?xml version="1.0" encoding="'
    assert string[1] = 'UTF-8" standalone="no"?><svg x'
    assert string[2] = 'mlns="http://www.w3.org/2000/s'
    assert string[3] = 'vg" version="1.1" viewBox="0 0'
    assert string[4] = ' 8 8">'

    let (res1_len, res1 : felt*) = join(5, string, res_len, res)
    let (svg_len : felt, svg : felt*) = add_last(res1_len, res1, '</svg>')
    return (svg_len, svg)
end
