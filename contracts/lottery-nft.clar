;; lottery-nft.clar
;; Definición del NFT
(define-non-fungible-token lucky-number uint)

;; Variables de estado
(define-data-var last-token-id uint u0)
(define-map token-numbers uint uint)

;; Función privada para generar el número (000-999)
(define-private (generate-lucky-number)
    (let (
        ;; Usamos el ID actual y el tx-sender para la semilla
        (seed (sha256 (concat (unwrap-panic (to-consensus-buff? (var-get last-token-id))) (unwrap-panic (to-consensus-buff? tx-sender)))))
    )
    ;; Convertimos los primeros bytes del hash en un número y aplicamos módulo 1000
    (mod (buff-to-uint-le (unwrap-panic (slice? seed u0 u4))) u1000)
    )
)

;; Función pública para mintear
(define-public (mint-lucky-number)
    (let (
        (new-id (+ (var-get last-token-id) u1))
        (lucky-num (generate-lucky-number))
    )
    (begin
        ;; Intentar el minteo
        (try! (nft-mint? lucky-number new-id tx-sender))
        ;; Guardar el número de la suerte en el mapa
        (map-set token-numbers new-id lucky-num)
        ;; Actualizar el contador de IDs
        (var-set last-token-id new-id)
        ;; Devolvemos el número obtenido en el NFT
        (ok lucky-num)
    )
    )
)

;; Función de lectura para ver qué número le tocó a un NFT
(define-read-only (get-lucky-number (id uint))
    (ok (map-get? token-numbers id))
)

;; Función para saber quién es el dueño (estándar básico)
(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? lucky-number id))
)
