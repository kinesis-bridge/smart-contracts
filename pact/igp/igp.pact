;; InterchainGasPaymaster

(namespace "NAMESPACE")

(enforce-guard (keyset-ref-guard "NAMESPACE.bridge-admin"))

;; Manages payments on a source chain to cover gas costs of relaying
;; messages to destination chains and includes the gas overhead per destination

(module igp GOVERNANCE
  (implements igp-iface)

  (defconst AUTO-AMOUNT 0.0)

  (defschema igp-data-schema
    domain: integer
    oracle:module{gas-oracle-iface}
    gas-amount:decimal
  )

  (deftable igp-data-table:{igp-data-schema})

  ;; Capabilities
  (defcap GOVERNANCE () (enforce-guard "NAMESPACE.upgrade-admin"))

  (defcap ONLY_ADMIN () (enforce-guard "NAMESPACE.bridge-admin"))

  ;; Events
  (defcap GAS_PAYMENT
    (
      message-id:string
      destination-domain:integer
      kda-amount:decimal
    )
    @doc "Emitted when gas payment is transferred to treasury"
    @event true
  )

  ;; Treasury
  (defconst IGP_ACCOUNT
    (create-principal
      (keyset-ref-guard "NAMESPACE.relayers")
      ))

  (defun initialize ()
      true)

  (defun set-remote-data:bool (domain:integer gas-amount:decimal oracle:module{gas-oracle-iface})
    (with-capability (ONLY_ADMIN)
      (write igp-data-table (int-to-str 10 domain)
          {
            'domain: domain,
            'gas-amount: gas-amount,
            'oracle: oracle
          })
      )
      true
  )

  ;; An example: we transfer from Kadena to Ethereum
  ;; Gas amount required = 300_000 units
  ;; Gas price = 17 gwei (early morning - low fees)
  ;; Remote tx price = 300_000 * 17_000_000_000 = 5.1e15 wei (7.92 USD)

  ;; ETH price = 1555 USD, Kadena price = 0.41 USD =>
  ;; => Token exchange rate = 1555/0.41 = 3.792e3
  ;; Kadena tx price = 5.1e15 * 3.792e3 = 19.33e18 KDA (7.92 USD)

  ;; Another example: we transfer from Kadena to MockChain
  ;; Gas amount required = 2800 units
  ;; Gas price = 0.00051
  ;; Remote tx price = 2.8e3 * 5.1e-4 = 1.428 (0.002856 USD)

  ;; MockChain price = 0.002 USD, Kadena price = 0.52 USD =>
  ;; => Token exchange rate = 0.002 / 0.52 = 3.84e-3
  ;; Kadenx tx price = 1.428 * 3.84e-3 = 0.00548352 (0.002851 USD)


  (defun quote-gas-payment:decimal (domain:integer)
    @doc "Return the gas payment amount in KDA"
    (with-read igp-data-table (int-to-str 10 domain)
      {'gas-amount := gas-amount,
       'oracle := oracle:module{gas-oracle-iface}}

      (bind (oracle::get-exchange-rate-and-gas-price domain)
        {'token-exchange-rate := token-exchange-rate,
         'gas-price:= gas-price}

        (* (* gas-amount gas-price) token-exchange-rate)))
  )

  (defun pay-for-gas:bool (id:string domain:integer gas-amount:decimal)
    @doc "Pay gas for a transfer on the source chain"
    ; Only 0.0 (for Automatic is supported for the third parameters).
    ; We don't remove it for backward compatibility reasons
    (enforce (= AUTO-AMOUNT gas-amount) "Only automatically determined gas amount is supported")

    (let ((amount (quote-gas-payment domain)))
      (coin.transfer (at "sender" (chain-data)) IGP_ACCOUNT amount)
      (emit-event (GAS_PAYMENT id domain amount)))
  )
)

(if (read-msg "init")
  [
    (create-table NAMESPACE.igp.igp-data-table)
  ]
  "Upgrade complete")
