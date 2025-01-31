;; Stacking Rewards Collateral Contract - No Traits Version
;; Enables loans backed by future STX stacking rewards

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-INVALID-STACKING (err u105))
(define-constant ERR-LOAN-ACTIVE (err u106))

;; Status constants
(define-constant STATUS-PENDING u1)
(define-constant STATUS-ACTIVE u2)
(define-constant STATUS-REPAID u3)
(define-constant STATUS-DEFAULTED u4)

;; Data Maps
(define-map stacking-info
    principal
    {
        amount: uint,
        cycles: uint,
        start-block: uint,
        unlock-block: uint,
        rewards-per-cycle: uint
    }
)

(define-map loans
    {loan-id: uint}
    {
        borrower: principal,
        lender: principal,
        amount: uint,
        collateral: uint,
        interest: uint,
        start-block: uint,
        end-block: uint,
        status: uint,
        repaid: uint
    }
)

(define-map reward-cycles
    {stacker: principal, cycle: uint}
    {
        expected: uint,
        claimed: uint,
        loan-id: uint
    }
)
;; Variables
(define-data-var loan-count uint u0)
(define-data-var min-cycles uint u3)
(define-data-var collateral-ratio uint u150)

;; Read-only functions
(define-read-only (get-stacking-info (stacker principal))
    (map-get? stacking-info stacker)
)

(define-read-only (get-loan (id uint))
    (map-get? loans {loan-id: id})
)

(define-read-only (get-cycle-info (stacker principal) (cycle uint))
    (map-get? reward-cycles {stacker: stacker, cycle: cycle})
)

(define-read-only (calculate-rewards (amount uint) (cycles uint))
    (* amount (* cycles u100))  ;; Example reward calculation
)

;; Public functions
(define-public (register-stacking (amount uint) (cycles uint))
    (let (
        (rewards-estimate (calculate-rewards amount cycles))
    )
        (asserts! (>= cycles (var-get min-cycles)) ERR-INVALID-STACKING)
        (asserts! (> amount u0) ERR-INVALID-STACKING)
        (asserts! (is-none (map-get? stacking-info tx-sender)) ERR-ALREADY-EXISTS)
        
        (map-set stacking-info
            tx-sender
            {
                amount: amount,
                cycles: cycles,
                start-block: block-height,
                unlock-block: (+ block-height (* cycles u2100)),
                rewards-per-cycle: (/ rewards-estimate cycles)
            }
        )
        
        (ok rewards-estimate)
    )
)