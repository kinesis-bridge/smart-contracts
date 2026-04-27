;; StorageGasOracle

(namespace "NAMESPACE")

(enforce-guard (keyset-ref-guard "NAMESPACE.bridge-admin"))
;; Gas Oracle module stores data needed for determining transaction price
;; on another chain. The values are passed to InterchainGasPayment module (IGP).
; This implementation uses data provided by KIA for Ethereum

; For backward compatibility, we implement gas-oracle-iface but shouldn't be necessary

(module gas-oracle-eth-kia GOVERNANCE
  (implements gas-oracle-iface)

  (use gas-oracle-iface)
  (use KIA_NAMESPACE.kia-oracle)

  ;; Capabilities
  (defcap GOVERNANCE () (enforce-guard "NAMESPACE.upgrade-admin"))

  (defun disable-manual-input:bool ()
    (enforce false "Manually setting value is not allowed"))

  (defun enforce-ethereum:bool (domain:integer)
    (enforce (= domain 1) "Only Ethereum is supported by this Oracle"))

  (defun /=0:decimal (x:decimal y:decimal)
    (if (= 0.0 y) 0.0
        (/ x y)))

  (defun round-price:decimal (x:decimal)
    (round x 12))

  (defun kia-value:decimal (key:string)
    ; At this point we could check the timestamp, to see if the value is not outdated and return
    ; a default value..; But it's definitvely better to ignore the timestamp and
    ; simply return the last known good value
    (compose (KIA_NAMESPACE.kia-oracle.get-value) (at'value)
             key))

  (defun from-gwei:decimal (x:decimal)
    (* x 0.000000001))

  (defun kda-eth-rate: decimal ()
    (round-price (/=0 (kia-value "ETH/USD") (kia-value "KDA/USD"))))

  (defun eth-gas-price: decimal ()
    (from-gwei (kia-value "EthGas")))

  (defun set-remote-gas-data-configs:bool (configs:[object{remote-gas-data-input}])
    (disable-manual-input))


  (defun set-remote-gas-data:bool (config:object{remote-gas-data-input})
    (disable-manual-input))

  (defun get-exchange-rate-and-gas-price:object{remote-gas-data} (domain:integer)
    (enforce-ethereum domain)
    {'token-exchange-rate: (kda-eth-rate),
     'gas-price: (eth-gas-price)
    }
  )
)
