;; lottery-v1.clar
(define-non-fungible-token lucky-number uint)
(define-data-var last-id uint u0)

(define-public (mint)
  (let ((new-id (+ (var-get last-id) u1)))
    (begin
      (try! (nft-mint? lucky-number new-id tx-sender))
      (var-set last-id new-id)
      (ok new-id)
    )
  )
)

(define-read-only (get-last-id)
  (ok (var-get last-id))
)
