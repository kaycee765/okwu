;; BASIC-MESSAGING-SYSTEM - STAGE 1
;; Initial implementation with core messaging functionality

;; Error responses
(define-constant ACCESS-DENIED u200)
(define-constant USER-EXISTS u201)
(define-constant USER-NOT-FOUND u202)

;; Basic system limits
(define-constant MESSAGE-LIMIT u512)

;; System counters
(define-data-var message-id-counter uint u0)
(define-data-var user-count uint u0)

;; Core data structures
(define-map users principal 
  {
    active: bool,
    registration-block: uint
  }
)

(define-map messages uint 
  {
    sender: principal,
    receiver: principal,
    data: (buff 512),
    block-height: uint
  }
)

;; Helper functions
(define-private (get-block-height)
  (default-to u0 (get-block-info? height u0))
)

;; Read-only functions
(define-read-only (get-user (user principal))
  (map-get? users user)
)

(define-read-only (is-user-active (user principal))
  (is-some (map-get? users user))
)

(define-read-only (get-message-data (msg-id uint))
  (map-get? messages msg-id)
)

;; User registration
(define-public (register-user)
  (let (
    (caller tx-sender)
    (current-block (get-block-height))
  )
    ;; Check if user already registered
    (asserts! (not (is-user-active caller)) 
              (err USER-EXISTS))
    
    ;; Register user
    (map-set users caller
      {
        active: true,
        registration-block: current-block
      }
    )
    
    ;; Update counter
    (var-set user-count (+ (var-get user-count) u1))
    (ok true)
  )
)

;; Send message
(define-public (send-message (to principal) (content (buff 512)))
  (let (
    (caller tx-sender)
    (msg-id (var-get message-id-counter))
    (current-block (get-block-height))
  )
    ;; Verify sender is registered
    (asserts! (is-user-active caller) 
              (err USER-NOT-FOUND))
    
    ;; Verify receiver is registered
    (asserts! (is-user-active to) 
              (err USER-NOT-FOUND))
    
    ;; Store message
    (map-set messages msg-id
      {
        sender: caller,
        receiver: to,
        data: content,
        block-height: current-block
      }
    )
    
    ;; Increment counter
    (var-set message-id-counter (+ msg-id u1))
    
    (ok msg-id)
  )
)

;; Get system stats
(define-read-only (get-stats)
  {
    total-messages: (var-get message-id-counter),
    total-users: (var-get user-count)
  }
)