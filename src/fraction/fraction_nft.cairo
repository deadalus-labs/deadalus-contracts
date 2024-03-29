// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.9.0 (presets/erc721.cairo)

/// # ERC721 Preset
///
/// The ERC721 contract offers a batch-mint mechanism that
/// can only be executed once upon contract construction.
#[starknet::contract]
mod FractionNFT {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use starknet::ContractAddress;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataCamelOnly =
        ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    /// Sets the token `name` and `symbol`.
    /// Mints the `token_ids` tokens to `recipient` and sets
    /// each token's URI.
    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        recipient: ContractAddress,
        token_amount: u256
    ) {
        self.erc721.initializer(name, symbol);
        self._mint_assets(recipient, token_amount);
    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _mint_assets(
            ref self: ContractState, recipient: ContractAddress, mut token_amount: u256,
        ) {
            let mut id = 1;
            let token_uri: felt252 = 'bit.ly/42TzZaT';
            loop {
                if token_amount == 0 {
                    break;
                }
                self.erc721._mint(recipient, id);
                self.erc721._set_token_uri(id, token_uri);
                id += 1;
                token_amount -= 1;
            }
        }
    }
}
