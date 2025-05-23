;; PRIVATE-MESSAGING-SYSTEM - REFACTORED IMPLEMENTATION
;; Enhanced communication platform with participant management and secure messaging

;; Response codes
(define-constant UNAUTHORIZED-ACCESS u100)
(define-constant PARTICIPANT-ALREADY-EXISTS u101)
(define-constant PARTICIPANT-NOT-REGISTERED u102)
(define-constant COMMUNICATION-NOT-FOUND u103)
(define-constant INBOX-CAPACITY-EXCEEDED u104)

;; Configuration limits
(define-constant COMMUNICATION-SIZE-LIMIT u1024)
(define-constant INBOX-CAPACITY-LIMIT u25)

;; Global tracking variables
(define-data-var total-communications uint u0)
(define-data-var registered-participants uint u0)
(define-data-var processing-communication-id uint u0)

;; Core data mappings
(define-map participants principal 
  {
    status: bool,
    public-key: (buff 33),
    joined-at: uint,
    sent-communications: uint
  }
)

(define-map communications uint 
  {
    from-participant: principal,
    to-participant: principal,
    payload: (buff 1024),
    created-at: uint,
    viewed: bool
  }
)

(define-map participant-inbox principal (list 25 uint))

;; Utility function for timestamp
(define-private (current-timestamp)
  (default-to u0 (get-block-info? time u0))
)

;; Query functions
(define-read-only (fetch-participant-details (participant principal))
  (map-get? participants participant)
)

(define-read-only (check-participant-status (participant principal))
  (is-some (map-get? participants participant))
)

(define-read-only (fetch-communication-details (comm-id uint))
  (map-get? communications comm-id)
)

(define-read-only (fetch-participant-inbox (participant principal))
  (default-to (list) (map-get? participant-inbox participant))
)

(define-read-only (platform-metrics)
  {
    communications-count: (var-get total-communications),
    participants-count: (var-get registered-participants)
  }
)

;; Participant onboarding
(define-public (join-platform (public-key (buff 33)))
  (let (
    (new-participant tx-sender)
    (join-timestamp (current-timestamp))
  )
    ;; Ensure participant doesn't already exist
    (asserts! (not (check-participant-status new-participant)) 
              (err PARTICIPANT-ALREADY-EXISTS))
    
    ;; Create participant profile
    (map-set participants new-participant
      {
        status: true,
        public-key: public-key,
        joined-at: join-timestamp,
        sent-communications: u0
      }
    )
    
    ;; Setup empty inbox
    (map-set participant-inbox new-participant (list))
    
    ;; Increment participant counter
    (var-set registered-participants (+ (var-get registered-participants) u1))
    (ok true)
  )
)

;; Communication transmission
(define-public (transmit-communication (target-participant principal) (payload (buff 1024)))
  (let (
    (sender tx-sender)
    (comm-id (var-get total-communications))
    (timestamp (current-timestamp))
    (sender-profile (unwrap! (fetch-participant-details sender) (err PARTICIPANT-NOT-REGISTERED)))
    (target-inbox (fetch-participant-inbox target-participant))
  )
    ;; Validate sender registration
    (asserts! (check-participant-status sender) 
              (err PARTICIPANT-NOT-REGISTERED))
    
    ;; Validate target registration
    (asserts! (check-participant-status target-participant) 
              (err PARTICIPANT-NOT-REGISTERED))
    
    ;; Verify inbox capacity
    (asserts! (< (len target-inbox) INBOX-CAPACITY-LIMIT)
              (err INBOX-CAPACITY-EXCEEDED))
    
    ;; Record the communication
    (map-set communications comm-id
      {
        from-participant: sender,
        to-participant: target-participant,
        payload: payload,
        created-at: timestamp,
        viewed: false
      }
    )
    
    ;; Update target's inbox
    (map-set participant-inbox 
             target-participant
             (unwrap-panic (as-max-len? (append target-inbox comm-id) u25)))
    
    ;; Update sender's communication count
    (map-set participants sender
      (merge sender-profile { 
        sent-communications: (+ (get sent-communications sender-profile) u1)
      })
    )
    
    ;; Advance communication counter
    (var-set total-communications (+ comm-id u1))
    
    (ok comm-id)
  )
)

;; Communication viewing
(define-public (view-communication (comm-id uint))
  (let (
    (viewer tx-sender)
    (comm-details (unwrap! (fetch-communication-details comm-id) (err COMMUNICATION-NOT-FOUND)))
  )
    ;; Ensure viewer is the intended recipient
    (asserts! (is-eq (get to-participant comm-details) viewer) 
              (err UNAUTHORIZED-ACCESS))
    
    ;; Update viewed status
    (map-set communications comm-id
      (merge comm-details { viewed: true })
    )
    
    (ok true)
  )
)

;; Communication removal
(define-public (remove-communication (comm-id uint))
  (let (
    (requester tx-sender)
    (comm-details (unwrap! (fetch-communication-details comm-id) (err COMMUNICATION-NOT-FOUND)))
  )
    ;; Verify requester has permission (sender or recipient)
    (asserts! (or 
               (is-eq (get from-participant comm-details) requester)
               (is-eq (get to-participant comm-details) requester))
             (err UNAUTHORIZED-ACCESS))
    
    ;; Remove from inbox if requester is recipient
    (if (is-eq (get to-participant comm-details) requester)
        (begin
          (var-set processing-communication-id comm-id)
          (map-set participant-inbox 
                   requester 
                   (fold filter-communication-from-inbox (fetch-participant-inbox requester) (list))))
        true)
    
    ;; Purge the communication record
    (map-delete communications comm-id)
    
    (ok true)
  )
)

;; Helper function for inbox filtering
(define-private (filter-communication-from-inbox (comm-id uint) (filtered-inbox (list 25 uint)))
  (if (is-eq comm-id (var-get processing-communication-id))
      filtered-inbox
      (unwrap-panic (as-max-len? (append filtered-inbox comm-id) u25)))
)

;; Security key modification
(define-public (modify-security-key (updated-key (buff 33)))
  (let (
    (participant tx-sender)
    (current-profile (unwrap! (fetch-participant-details participant) (err PARTICIPANT-NOT-REGISTERED)))
  )
    ;; Apply the key update
    (map-set participants participant
      (merge current-profile { public-key: updated-key })
    )
    
    (ok true)
  )
)