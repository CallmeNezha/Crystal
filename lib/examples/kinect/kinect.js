
const Kinect = require('./addon')

let depthArray = new Float32Array(512*424)
Kinect.CreateKinect()

while (1) {
  Kinect.GetDepthBuffer(depthArray)
  console.log(depthArray)
}

Kinect.DestroyKinect()
