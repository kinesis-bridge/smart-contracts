(namespace "NAMESPACE")

(module eth-address-utils GOVERNANCE
  @doc "Some utils to convert Ethereum Address to-from Base64"

  (defcap GOVERNANCE () (enforce-guard "NAMESPACE.upgrade-admin"))

  ; Engineering note:
  ; A ETH address is 160 bits => 40 Hex nibbles
  ; But in base64 => Ideally everything should be in multiple of 24
  ;     => So we take 168 bits => 28 chars
  ; To be sure we have a reproductive (=padded) result we prepend with bits "100000000000000000000000"
  ;   = OR with 1<<191 , and then remove the 4 leading chars
  ;
  ; Note: this module doesn't handle Ethereum address "case-dependant" checksums (ERC-55)

  (defconst B16_LEAD (shift 1 167))
  (defconst B64_LEAD (shift 1 191))

  (defun remove-b16-prefix:string (x:string)
    @doc "Remove 0x (if present) from and Hexa string"
    (if (= "0x" (take 2 x))
        (take (- 2 (length x)) x)
        x))

  (defun int168-to-b64:string (x:integer)
    @doc "Convert a int to a b64 string with a 28 bytes (168 bits output)"
    (take -28 (int-to-str 64 (| B64_LEAD x ))))

  (defun int168-to-b16:string (x:integer)
    @doc "Convert a int to a b16 string with a 42 bytes (168 bits output)"
    (take -40 (int-to-str 16 (| B16_LEAD x))))


  (defun eth-address-to-b64:string (address:string)
    @doc "Convert a Ethereum address to Base64"
    (int168-to-b64 (str-to-int 16 (remove-b16-prefix address))))

  (defun b64-to-eth-address:string (prefix:bool address-b64:string)
    @doc "Convert a  address to Base64 with optional 0x prefix"
    (+ (if prefix "0x" "")
       (int168-to-b16 (str-to-int 64 address-b64))))
)
