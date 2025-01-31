;; Stacking Rewards Collateral Contract - No Traits Version
;; Enables loans backed by future STX stacking rewards

;; Constants
(define-constant CONTRACT-OWNER 'SP000000000000000000002Q6VF78.stacking-rewards)
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



(define-public (request-loan (amount uint) (interest uint))
    (let (
        (staking (unwrap! (map-get? stacking-info tx-sender) ERR-NOT-FOUND))
        (loan-id (+ (var-get loan-count) u1))
        (total-rewards (calculate-rewards (get amount staking) (get cycles staking)))
    )
        ;; Check collateral ratio
        (asserts! (>= (* total-rewards u100) 
            (* amount (var-get collateral-ratio))) 
            ERR-INSUFFICIENT-BALANCE)
        
        ;; Create loan record
        (map-set loans
            {loan-id: loan-id}
            {
                borrower: tx-sender,
                lender: tx-sender,  ;; Placeholder until funded
                amount: amount,
                collateral: total-rewards,
                interest: interest,
                start-block: block-height,
                end-block: (+ block-height (* (get cycles staking) u2100)),
                status: STATUS-PENDING,
                repaid: u0
            }
        )
        
        ;; Update counter
        (var-set loan-count loan-id)
        (ok loan-id)
    )
)
(define-public (fund-loan (loan-id uint))
    (let (
        (loan (unwrap! (map-get? loans {loan-id: loan-id}) ERR-NOT-FOUND))
    )
        (asserts! (is-eq (get status loan) STATUS-PENDING) ERR-LOAN-ACTIVE)
        
        ;; Transfer funds
        (try! (stx-transfer? (get amount loan) tx-sender (get borrower loan)))
        
        ;; Update loan
        (map-set loans
            {loan-id: loan-id}
            (merge loan {
                lender: tx-sender,
                status: STATUS-ACTIVE
            })
        )
        
        (ok true)
    )
)


(define-public (repay-from-rewards (loan-id uint) (cycle uint))
    (let (
        (loan (unwrap! (map-get? loans {loan-id: loan-id}) ERR-NOT-FOUND))
        (cycle-info (unwrap! (get-cycle-info (get borrower loan) cycle) ERR-NOT-FOUND))
    )
        (asserts! (is-eq (get status loan) STATUS-ACTIVE) ERR-LOAN-ACTIVE)
        
        ;; Calculate repayment amount
        (let (
            (available (- (get expected cycle-info) (get claimed cycle-info)))
            (remaining (- (+ (get amount loan) 
                (/ (* (get amount loan) (get interest loan)) u100))
                (get repaid loan)))
            (payment (if (< available remaining) available remaining))
        )
            ;; Process payment
            (try! (stx-transfer? payment tx-sender (get lender loan)))
            
            ;; Update loan
            (map-set loans
                {loan-id: loan-id}
                (merge loan {
                    repaid: (+ (get repaid loan) payment),
                    status: (if (>= (+ (get repaid loan) payment)
                        (+ (get amount loan) 
                            (/ (* (get amount loan) (get interest loan)) u100)))
                        STATUS-REPAID
                        STATUS-ACTIVE)
                })
            )
            
            (ok payment)
        )
    )
)

;; Admin functions
(define-public (set-collateral-ratio (new-ratio uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set collateral-ratio new-ratio)
        (ok true)
    )
)

(define-public (set-min-cycles (new-min uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set min-cycles new-min)
        (ok true)
    )
)