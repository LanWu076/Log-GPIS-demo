# Log-GPIS demo
This repository contains a demo code to illustrate the basic idea of our paper **Faithful Euclidean Distance Field from Log-Gaussian Process Implicit Surfaces**. 

## Matlab version
R2019b Update 4(9.7.0.1296695)

## License

## 2D demo
The observation is a circle to show our Log-GPIS in a 2D case. To show the results, just run LogGPIS_demo_2D.m. Figure 1 to 6 will show the mean distance inference of the whittle kernel and the Matern kernel with lambda varying from 30 to 40. Figure 7 shows the Root Mean Sqrt Error of different kernels and different lambda parameters.

## 3D demo
The observation is a sphere to show our Log-GPIS in a 3D case. Just run LogGPIS_demo_3D.m. This 3D demo demonstrates that Log-GPIS allows for 3D prediction. The result is a black sphere showing the measurements, and the coloured shape or slice is the distance values of query points.

## Citation
 
If you think Log-GPIS useful in your research, please consider citing our arXiv version:
```
@article{wu2020faithful,
  title={Faithful Euclidean Distance Field from Log-Gaussian Process Implicit Surfaces},
  author={Wu, Lan and Lee, Ki Myung Brian and Liu, Liyang and Vidal-Calleja, Teresa},
  journal={arXiv preprint arXiv:2010.11487},
  year={2020}
}
   
```
