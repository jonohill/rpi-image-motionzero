# rpi-image-motionzero

Builds RPi image containing MotionZero.

Base image:
```
packer/build base.json
```

Final image (containing secrets):
```
packer/build -var-file=vars.json config.json
```
