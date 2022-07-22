%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.starknet.common.syscalls import (
    get_contract_address, get_block_number, get_block_timestamp, get_caller_address
)

@contract_interface
namespace Bpm:
    func getFillFromSquare(square : felt) -> (fill : felt):
    end

    func getSquareFromMap(bitmap, actual_index) -> (square : felt):
    end

    func generateRows(bitmap_len : felt, bitmap : felt*, rows_len : felt, rows : felt*, x) -> (rows_len : felt, rows : felt*):
    end

    func joinRows(bitmap_len : felt, bitmap : felt*, rows_len, rows : felt*, size, x) -> (res_len, res : felt*):
    end

    func generateRow(bitmap_len : felt, bitmap : felt*, i, y) -> (row_len : felt, row : felt*):
    end

    func renderSvg(bitmap_len : felt, bitmap : felt*) -> (svg_len : felt, svg : felt*):
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
    let (local caller: felt) = get_contract_address()
    local bpm: felt
    %{ ids.bpm = context.bpm %}

    let bitmap = '0x7624778dedc75f8b322b9fa1632a610d40b85e106c7d9bf0e743a9ce291b9c63'

    let (square : felt) = Bpm.getSquareFromMap(bpm, bitmap, 2)
    %{print(str(ids.square))%}
    return ()
end

func display_array_elements{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(resstr_len: felt, resstr: felt*):
    if resstr_len == 0:
        return ()
    end

    let index = [resstr]
    %{print(str(ids.index) + " | " + str(ids.resstr_len)) %}
    return display_array_elements(resstr_len - 1, resstr + 1)
end
