# SPDX-License-Identifier: Apache 2.0

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from immutablex.starknet.access.AccessControl import AccessControl, DEFAULT_ADMIN_ROLE

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    default_admin : felt
):
    AccessControl.initializer(default_admin)
    return ()
end

@view
func has_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, account : felt
) -> (res : felt):
    let (res) = AccessControl.has_role(role, account)
    return (res)
end

@view
func get_role_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt
) -> (role_admin : felt):
    let (role_admin) = AccessControl.get_role_admin(role)
    return (role_admin)
end

@external
func grant_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, account : felt
):
    AccessControl.grant_role(role, account)
    return ()
end

@external
func revoke_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, account : felt
):
    AccessControl.revoke_role(role, account)
    return ()
end

@external
func renounce_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, account : felt
):
    AccessControl.renounce_role(role, account)
    return ()
end

@external
func set_role_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, admin_role : felt
):
    AccessControl.only_role(DEFAULT_ADMIN_ROLE)
    AccessControl._set_role_admin(role, admin_role)
    return ()
end
