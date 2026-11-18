# Simulated higher-order SCA board (circuit model)

`board_sim` models a lab attack board without physical hardware.

## Circuit (logical)

```text
          3V3
           │
        [shunt 1Ω]······· differential amp ····· 12-bit ADC model
           │                      │
        DUT Vdd              sample @ trigger
           │
     ┌─────┴─────┐
     │  "MCU"    │  ← AArch64 kernels under qemu (real krivox .S)
     │  masked   │
     │  ML-KEM   │──── GPIO trigger (sim): high during secret op
     └───────────┘
```

## What is simulated

| Piece | Model |
| --- | --- |
| Shunt + amp | Leakage ∝ Hamming weight of touched coeffs + Gaussian noise |
| ADC | int16 samples written to a trace buffer |
| Trigger | region markers around share / NTT / basemul windows |
| DUT firmware | **real** `libmlkem_neon.a` asm (order-1 and order-2 share paths) |
| Attacker | offline 1st/2nd-order CPA (HOCPA) on captured traces |

## Higher-order path

1. DUT stores secret as 2 or 3 arithmetic shares (asm).
2. Each share touch emits a sample (HW).
3. Order-2 attack combines sample pairs before correlating with hypotheses.

Physical ChipWhisperer / STM32 is optional later; this board lets anyone `make sim` today.
