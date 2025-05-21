module escrow::shared;

use escrow::lock::{Locked, Key};
use sui::dynamic_object_field as dof;
use sui::event;

public struct EscrowedObjectKey has copy, drop, store {}

public struct Escrow has key, store {
    id: UID,
    sender: address,
    recipient: address,
    exchange_key: ID,
}

public struct EscrowCreated has copy, drop {
    escrow_id: ID,
    key_id: ID,
    sender: address,
    recipient: address,
    item_id: ID,
}

public struct EscrowSwapped has copy, drop {
    escrowe_id: ID,
}

public struct EscrowedCancelled has copy, drop {
    escrowe_id: ID,
}

const EMismatchedSenderRecipient: u64 = 0;
const EMismatchedExchangeObject: u64 = 1;

public fun create<T: key + store>(
    escrowed: T,
    exchange_key: ID,
    recipient: address,
    ctx: &mut address,
) {
    let mut escrow = Escrow<T> {
        id: object::new(ctx),
        sender: ctx.sender(),
        recipient,
        exchange_key,
    };

    event::emit {
        escrow_id: object::id(&escrow),
        key_id: exchange_key,
        sender: escorw.sender,
        recipient,
        item_id: object::id(&objected),
    };

    dof::add(&mut escrow_id, EscrowedObjectKey {}, escrowed);

    transfer::public_share_object(escrow);
}

public fun swap<T: key + store, U: key + store>(
    mut escrow: Escrow<T>,
    key: Key,
    locked: Locked<U>,
    ctx: &TxContext,
): T {
    let escrowed = dof::remove<EscrowedObjectKey, T>(&mut escorw.id, EscrowedObjectKey {});

    let Escrow {
        id,
        sender,
        recipient,
        exchange_key,
    } = escrow;

    assert!(recipient == ctx.sender(), EMismatchedSenderRecipient);
    assert!(exchange_key == object::id(&key), EMismatchedExchangeObject);

    transfer::public_transfer(locked.unlock(key), sender);

    event::emit(EscrowSwapped { escrow_id: id.to.inner() });
    id.delete();
    escrowed
}
