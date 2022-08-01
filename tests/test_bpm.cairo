%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.starknet.common.syscalls import (
    get_contract_address, get_block_number, get_block_timestamp, get_caller_address
)

@contract_interface
namespace Bpm:
    func get_fill_from_square(square : felt) -> (fill : felt):
    end

    func get_square_from_map(bitmap_len, bitmap : felt*, index) -> (square : felt):
    end

    func generate_rows(bitmap_len : felt, bitmap : felt*, rows_len : felt, rows : felt*, size, y) -> (rows_len : felt, rows : felt*):
    end

    func join_rows(bitmap_len : felt, bitmap : felt*, rows_len, rows : felt*, size, x, y) -> (res_len, res : felt*):
    end

    func generate_row(bitmap_len : felt, bitmap : felt*, i, x, y) -> (row_len : felt, row : felt*):
    end

    func render_svg(bitmap_len : felt, bitmap : felt*) -> (svg_len : felt, svg : felt*):
    end
end

@view
func __setup__{bitwise_ptr : BitwiseBuiltin*, syscall_ptr: felt*, range_check_ptr}():
    alloc_locals
    local bpm: felt
    let (local caller: felt) = get_contract_address()
    %{ context.bpm = deploy_contract("./src/bpm.cairo", []).contract_address %}
    %{ print("deployed") %}
    return ()
end


@external
func test_find{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }():
    alloc_locals

    local bpm: felt
    %{ ids.bpm = context.bpm %}

    let (bitmap : felt*) = alloc()
    assert bitmap[0] = 0x7624778dedc75f8b322b9fa1632a610d
    assert bitmap[1] = 0x40b85e106c7d9bf0e743a9ce291b9c63

    let (square1 : felt) = Bpm.get_square_from_map(bpm, 2, bitmap, 1)
    let (square2 : felt) = Bpm.get_square_from_map(bpm, 2, bitmap, 2)
    let (square3 : felt) = Bpm.get_square_from_map(bpm, 2, bitmap, 3)
    let (square4 : felt) = Bpm.get_square_from_map(bpm, 2, bitmap, 4)
    let (square5 : felt) = Bpm.get_square_from_map(bpm, 2, bitmap, 5)

    tempvar s1 = square1
    tempvar s2 = square2
    tempvar s3 = square3
    tempvar s4 = square4
    tempvar s5 = square5

    %{print(str(ids.s1))%}
    %{print(str(ids.s2))%}
    %{print(str(ids.s3))%}
    %{print(str(ids.s4))%}
    %{print(str(ids.s5))%}
    return ()
end

@external
func test_join_rows{
    bitwise_ptr : BitwiseBuiltin*,
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals

    local bpm: felt
    %{ ids.bpm = context.bpm %}

    let (bitmap : felt*) = alloc()
    assert bitmap[0] = 0x7724778dedc75f8b322b9fa1632a610d
    assert bitmap[1] = 0x40b85e106c7d9bf0e743a9ce291b9c63

    let (tmp : felt*) = alloc()
    let (res_len, res) = Bpm.join_rows(bpm, 2, bitmap, 0, tmp, 20, 0, 0)

    display_array_elements(res_len, res)
    return ()
end


@external
func test_render_svg{
    bitwise_ptr : BitwiseBuiltin*,
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals

    local bpm: felt
    %{ ids.bpm = context.bpm %}

    let (bitmap : felt*) = alloc()
    assert bitmap[0] = 0x7624778dedc75f8b322b9fa1632a610d
    assert bitmap[1] = 0x40b85e106c7d9bf0e743a9ce291b9c63

    let (res_len, res) = Bpm.render_svg(bpm, 2, bitmap)

    display_array_elements(res_len, res)
    return ()
end

@external
func test_get_fill{
    bitwise_ptr : BitwiseBuiltin*,
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
    }():
    alloc_locals

    local bpm: felt
    %{ ids.bpm = context.bpm %}

    let (bitmap : felt*) = alloc()
    assert bitmap[0] = 0x7624778dedc75f8b322b9fa1632a610d
    assert bitmap[1] = 0x40b85e106c7d9bf0e743a9ce291b9c63

    let (square1 : felt) = Bpm.get_square_from_map(bpm, 2, bitmap, 1)
    let (color : felt) = Bpm.get_fill_from_square(bpm, square1)
    
    %{print(str(ids.square1))%}
    %{print(ids.color)%}
    return ()
end


@external
func test_generate_row{
    bitwise_ptr : BitwiseBuiltin*,
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals

    local bpm: felt
    %{ ids.bpm = context.bpm %}

    let (bitmap : felt*) = alloc()
    assert bitmap[0] = 0x7624778dedc75f8b322b9fa1632a610d
    assert bitmap[1] = 0x40b85e106c7d9bf0e743a9ce291b9c63
    
    let (row_len, row) = Bpm.generate_row(bpm, 2, bitmap, 0, 0, 0)

    display_array_elements(row_len, row)
    return ()
end

@external 
func test_generate_rows{
    bitwise_ptr : BitwiseBuiltin*,
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}():
    alloc_locals

    local bpm: felt
    %{ ids.bpm = context.bpm %}

    let (bitmap : felt*) = alloc()
    assert bitmap[0] = 0x7624778dedc75f8b322b9fa1632a610d
    assert bitmap[1] = 0x40b85e106c7d9bf0e743a9ce291b9c63

    let (temp : felt*) = alloc()

    let (rows_len, rows) = Bpm.generate_rows(bpm, 2, bitmap, 0, temp, 8, 0)

    display_array_elements(rows_len, rows)
    return ()
end

func display_array_elements{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(resstr_len: felt, resstr: felt*):
    if resstr_len == 0:
        return ()
    end

    let index = [resstr]
    %{print(str(ids.index) + ",") %}
    return display_array_elements(resstr_len - 1, resstr + 1)
end
