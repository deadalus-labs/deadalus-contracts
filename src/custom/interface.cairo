#[starknet::interface]
trait ICustom<TState> {
    fn get_token_trait(self: @TState, token_id: u256) -> TokenTrait;
}

#[derive(Serde, Copy, Drop, starknet::Store)]
struct TokenTrait {
    foo: felt252
}
