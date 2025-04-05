;; Adaptation Tracking Contract
;; Monitors modifications for different learning needs

(define-data-var last-adaptation-id uint u0)

(define-map adaptations
  { adaptation-id: uint }
  {
    resource-id: uint,
    adaptation-type: (string-utf8 50),
    description: (string-utf8 500),
    creator: principal,
    target-need: (string-utf8 50),
    creation-time: uint
  }
)

(define-map resource-to-adaptation
  { resource-id: uint, adaptation-id: uint }
  { exists: bool }
)

(define-public (create-adaptation
    (resource-id uint)
    (adaptation-type (string-utf8 50))
    (description (string-utf8 500))
    (target-need (string-utf8 50)))
  (let
    (
      (new-id (+ (var-get last-adaptation-id) u1))
    )
    (asserts! (> (len adaptation-type) u0) (err u1)) ;; Adaptation type cannot be empty
    (asserts! (> (len description) u0) (err u2)) ;; Description cannot be empty
    (asserts! (> (len target-need) u0) (err u3)) ;; Must target at least one need

    ;; Store the adaptation
    (map-set adaptations
      { adaptation-id: new-id }
      {
        resource-id: resource-id,
        adaptation-type: adaptation-type,
        description: description,
        creator: tx-sender,
        target-need: target-need,
        creation-time: block-height
      }
    )

    ;; Create a simple mapping between resource and adaptation
    (map-set resource-to-adaptation
      { resource-id: resource-id, adaptation-id: new-id }
      { exists: true }
    )

    (var-set last-adaptation-id new-id)
    (ok new-id)
  )
)

(define-read-only (get-adaptation (adaptation-id uint))
  (map-get? adaptations { adaptation-id: adaptation-id })
)

(define-read-only (is-adaptation-for-resource (resource-id uint) (adaptation-id uint))
  (default-to false (get exists (map-get? resource-to-adaptation { resource-id: resource-id, adaptation-id: adaptation-id })))
)

(define-read-only (get-last-adaptation-id)
  (var-get last-adaptation-id)
)

