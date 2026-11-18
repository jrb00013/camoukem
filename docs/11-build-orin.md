# Build on Jetson Orin

```bash
sudo apt install build-essential
make CROSS_COMPILE= all test
```

Native `gcc` targets AArch64; NEON is available. Use `CNTVCT_EL0` later for benches.
