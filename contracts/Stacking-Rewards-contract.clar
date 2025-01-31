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
