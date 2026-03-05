;; lottery-nft.clar
;; Definir el estándar SIP-009 (puedes importarlo o definir el trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token lucky-number uint)

;; Variables de estado
(define-data-var last-token-id uint u0)
(define-map token-numbers uint uint) ;; ID del NFT -> Número (000-999)

;; Errores
(define-constant ERR-NOT-AUTHORIZED (err u100))

;; Lógica de "Aleatoriedad" (Pseudo-random)
(define-private (generate-lucky-number)
    (let (
        (block-hash (default-to 0x00 (get-block-info? header-hash (- block-height u1))))
        (hash (sha256 (concat block-hash (unwrap-panic (to-consensus-buff? tx-sender)))))
    )
    ;; Obtenemos el módulo 1000 para que sea entre 0 y 999
    (mod (buff-to-uint-le (slice? hash u0 u4)) u1000))
)

;; Función pública para mintear
(define-public (mint-lucky-number)
    (let (
        (new-id (+ (var-get last-token-id) u1))
        (lucky-num (generate-lucky-number))
    )
    (begin
        ;; Mintear el NFT al sender
        (try! (nft-mint? lucky-number new-id tx-sender))
        ;; Guardar el número asociado a ese ID
        (map-set token-numbers new-id lucky-num)
        ;; Actualizar el contador
        (var-set last-token-id new-id)
        (ok new-id))
    )
)

;; Read-only: Consultar el número de un NFT
(define-read-only (get-number-of (token-id uint))
    (ok (map-get? token-numbers token-id))
)
