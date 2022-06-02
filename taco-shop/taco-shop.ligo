type taco_supply is
  record [
    current_stock : nat;
    max_price     : tez
  ]

type taco_shop_storage is map (nat, taco_supply)

type return is list (operation) * taco_shop_storage

const ownerAddress : address =
  ("tz1TGu6TN5GSez2ndXXeDX6LgUDvLzPLqgYV" : address)

function buy_taco (const taco_kind_index : nat ; var taco_shop_storage : taco_shop_storage) : return is {
  // Retrieve the taco_kind from the contract's storage or fail
  var taco_kind : taco_supply :=
    case taco_shop_storage[taco_kind_index] of [
      Some (kind) -> kind
    | None -> (failwith ("Unknown kind of taco.") : taco_supply)
    ];

   const current_purchase_price : tez =
     taco_kind.max_price / taco_kind.current_stock;

  if Tezos.amount =/= current_purchase_price then
    // We won't sell tacos if the amount is not correct
    failwith ("Sorry, the taco you are trying to purchase has a different price");

  // Decrease the stock by 1n, because we have just sold one
  taco_kind.current_stock := abs (taco_kind.current_stock - 1n);

  // Update the storage with the refreshed taco_kind
  taco_shop_storage[taco_kind_index] := taco_kind;

  const ownerAddress : address = ("tz1SLY8y5Z2V1pwojurXWdJKZjC5XjLZn9Ue" : address);
 const donationAddress : address = ("tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx" : address);

const receiver : contract (unit) =
  case (Tezos.get_contract_opt (ownerAddress) : option(contract(unit))) of [
    Some (contract) -> contract
  | None -> (failwith ("Not a contract") : contract (unit))
  ];

const donationReceiver : contract (unit) =
  case (Tezos.get_contract_opt (donationAddress) : option(contract(unit))) of [
    Some (contract) -> contract
  | None  -> (failwith ("Not a contract") : contract (unit))
  ];

const donationAmount : tez = Tezos.amount / 10n;

const operations : list (operation) = block {
    // Pedro will get 90% of the amount
    const op = case (Tezos.amount - donationAmount) of [
      | Some (x) -> Tezos.transaction (unit, x, receiver)
      | None -> (failwith ("Insufficient balance") )
    ] ;
  } with list [ op; Tezos.transaction (unit, donationAmount, donationReceiver) ];