;; Effectiveness Assessment Contract
;; Measures impact on educational outcomes

(define-map assessments
  {
    resource-id: uint,
    adaptation-id: uint,
    student: principal
  }
  {
    effectiveness-score: uint,
    feedback: (string-utf8 500),
    assessor: principal,
    assessment-time: uint
  }
)

(define-map aggregated-scores
  { adaptation-id: uint }
  {
    total-score: uint,
    assessment-count: uint,
    average-score: uint
  }
)

(define-public (submit-assessment
    (resource-id uint)
    (adaptation-id uint)
    (effectiveness-score uint)
    (feedback (string-utf8 500)))
  (let
    (
      (existing-aggregate (default-to
                          { total-score: u0, assessment-count: u0, average-score: u0 }
                          (map-get? aggregated-scores { adaptation-id: adaptation-id })))
      (new-count (+ (get assessment-count existing-aggregate) u1))
      (new-total (+ (get total-score existing-aggregate) effectiveness-score))
      (new-average (/ new-total new-count))
    )
    ;; Score must be between 1 and 10
    (asserts! (and (>= effectiveness-score u1) (<= effectiveness-score u10)) (err u1))

    ;; Store the individual assessment
    (map-set assessments
      {
        resource-id: resource-id,
        adaptation-id: adaptation-id,
        student: tx-sender
      }
      {
        effectiveness-score: effectiveness-score,
        feedback: feedback,
        assessor: tx-sender,
        assessment-time: block-height
      }
    )

    ;; Update the aggregated scores
    (map-set aggregated-scores
      { adaptation-id: adaptation-id }
      {
        total-score: new-total,
        assessment-count: new-count,
        average-score: new-average
      }
    )

    (ok true)
  )
)

(define-read-only (get-assessment
    (resource-id uint)
    (adaptation-id uint)
    (student principal))
  (map-get? assessments
    {
      resource-id: resource-id,
      adaptation-id: adaptation-id,
      student: student
    }
  )
)

(define-read-only (get-adaptation-score (adaptation-id uint))
  (default-to
    { total-score: u0, assessment-count: u0, average-score: u0 }
    (map-get? aggregated-scores { adaptation-id: adaptation-id })
  )
)

(define-read-only (get-top-adaptations (limit uint))
  ;; This is a simplified version without using list-adaptations
  ;; In a real implementation, we would need a different approach
  ;; to efficiently find and sort top adaptations
  (ok limit)
)

