# -*- coding: utf-8 -*-
"""

Use this to check snappy funcions' parameters.

Created on Sat Feb 18, 2023
Last updated on: Sat Feb 18, 2023

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% REQUESTED MODULE

# snappy module to create products:
from snappy import GPF

#%% LOADING GPT: USE THIS TO GET THE OPERATORS' PARAMETERS

def listParams(operator_name):
    GPF.getDefaultInstance().getOperatorSpiRegistry().loadOperatorSpis()
    op_spi = GPF.getDefaultInstance().getOperatorSpiRegistry().getOperatorSpi(operator_name)
    print('Op name:', op_spi.getOperatorDescriptor().getName())
    print('Op alias:', op_spi.getOperatorDescriptor().getAlias())
    param_Desc = op_spi.getOperatorDescriptor().getParameterDescriptors()
    for param in param_Desc:
        print(param.getName(), "or", param.getAlias())

#listParams('Terrain-Flattening')

import subprocess

print(subprocess.Popen(['gpt', '-h', 'Terrain-Flattening'],
                       stdout = subprocess.PIPE,
                       universal_newlines = True).communicate()[0])
