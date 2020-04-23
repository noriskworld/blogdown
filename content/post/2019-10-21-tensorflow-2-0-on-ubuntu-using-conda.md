---
title: Tensorflow 2.0 on Ubuntu using Conda
author: Yunwei Hu
date: '2019-10-21'
slug: tensorflow-2-0-on-ubuntu-using-conda
categories:
  - machine learning
tags: [tensorflow]
---
TensorFlow 2.0 has been released! But Anaconda still hasn’t supported yet so I think we will have to install by pip until Anaconda officially supports. 

# Anaconda and other Requirements

I am using Anaconda distribution on my Ubuntu box, the offial [installation instruction](https://www.tensorflow.org/install) is using the `pip`, thus a little detour is required. 

I already have NVIDIA® GPU drivers version 430.50 and CUDA 10.1.

Now, Anaconda is supporting install cudnn 7.6.0 so we don’t have to manually copy cudnn to our environment anymore. Therefore we will create an environment which has cudnn, cupti and cudatoolkit. CUDA10.1 is not supported by tf2.0 yet. 

```
conda create -n your_env_name python=3.6 cudnn cupti cudatoolkit=10.0
```

Then, activate your_environment and install Tensorflow-gpu 2.0 with pip in it.

```
conda activate your_env_name
pip install tensorflow-gpu
```

# RTX GPU

Additional step if you are using RTX GPU, such as the 20X0 series. 
I am using RTX2070. We have to allow memory growth. 

The following `python` code will be needed before using tensorflow-gpu. 

```
# always use this for RTX2070 on TF2
import tensorflow as tf
import tensorflow.keras.backend as K
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)
```
Otherwise, GPU cannot be allocated. You may receive an error message similar to below:

```
UnknownError:  Failed to get convolution algorithm. This is probably because cuDNN failed to initialize, so try looking to see if a warning log message was printed above.
	 [[node model/conv1d_1/conv1d (defined at /home/jason/anaconda3/envs/tf2gpu/lib/python3.6/site-packages/tensorflow_core/python/framework/ops.py:1751) ]] [Op:__inference_distributed_function_14081]
```
And, that is it. 