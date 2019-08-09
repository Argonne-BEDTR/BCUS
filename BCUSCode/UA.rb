# Copyright © 2019, UChicago Argonne, LLC
# All Rights Reserved
# OPEN SOURCE LICENSE

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.  Software changes,
#    modifications, or derivative works, should be noted with comments and the
#    author and organization's name.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# 3. Neither the names of UChicago Argonne, LLC or the Department of Energy nor
#    the names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.

# 4. The software and the end-user documentation included with the
#    redistribution, if any, must include the following acknowledgment:

#    "This product includes software produced by UChicago Argonne, LLC under
#     Contract No. DE-AC02-06CH11357 with the Department of Energy."

# ******************************************************************************
# DISCLAIMER

# THE SOFTWARE IS SUPPLIED "AS IS" WITHOUT WARRANTY OF ANY KIND.

# NEITHER THE UNITED STATES GOVERNMENT, NOR THE UNITED STATES DEPARTMENT OF
# ENERGY, NOR UCHICAGO ARGONNE, LLC, NOR ANY OF THEIR EMPLOYEES, MAKES ANY
# WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LEGAL LIABILITY OR
# RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY
# INFORMATION, DATA, APPARATUS, PRODUCT, OR PROCESS DISCLOSED, OR REPRESENTS
# THAT ITS USE WOULD NOT INFRINGE PRIVATELY OWNED RIGHTS.

# ******************************************************************************

# 1. Introduction
# This is the main function of uncertainty analysis.

require 'optparse'

require_relative 'run_analysis'

# Parse command line inputs from the user
options = {:osmName => nil, :epwName => nil}
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: UA.rb [options]'

  # osmName: OpenStudio Model Name in .osm
  opts.on('-o', '--osm osmName', 'osmName') do |osm_name|
    options[:osmName] = osm_name
  end

  # epwName: weather file used to run simulation in .epw
  opts.on('-e', '--epw epwName', 'epwName') do |epw_name|
    options[:epwName] = epw_name
  end

  options[:uqRepo] = 'Parameter_UQ_Repository_V1.0.xlsx'
  opts.on(
    '-u', '--uqRepo uqRepo',
    'UQ repository file, default "Parameter_UQ_Repositorty_V1.0.xlsx"'
  ) do |uq_repo|
    options[:uqRepo] = uq_repo
  end

  options[:numLHD] = 500
  opts.on(
    '--numLHD numLHD',
    'Number of sample points of Monte Carlo simulation ' \
    'with Latin Hypercube Design sampling, default 500'
  ) do |num_lhd|
    options[:numLHD] = num_lhd
  end

  options[:outFile] = 'Simulation_Output_Settings.xlsx'
  opts.on(
    '--outFile outFile',
    'Simulation output setting file, default "Simulation_Output_Settings.xlsx"'
  ) do |out_file|
    options[:outFile] = out_file
  end

  options[:randSeed] = 0
  opts.on(
    '--seed seednum',
    'Integer random number seed, 0 = no seed, default 0'
  ) do |seednum|
    options[:randSeed] = seednum
  end

  options[:numProcesses] = 0
  opts.on(
    '--numProcesses numProcesses',
    'Number of parallel processes for simulation, 0 = no parallel, default 0'
  ) do |n_processes|
    options[:numProcesses] = n_processes
  end

  options[:noEP] = false
  opts.on('--noEP', 'Do not run EnergyPlus') do
    options[:noEP] = true
  end

  options[:noCleanup] = false
  opts.on('-n', '--noCleanup', 'Do not clean up intermediate files.') do
    options[:noCleanup] = true
  end

  options[:interactive] = false
  opts.on(
    '-i', '--interactive',
    'Run with interactive prompts to check setup files.'
  ) do
    options[:interactive] = true
  end

  options[:verbose] = false
  opts.on(
    '-v', '--verbose',
    'Run in verbose mode with more output info printed'
  ) do
    options[:verbose] = true
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

# Run main analysis function
RunAnalysis.run('UA', options)

puts 'UA.rb completed successfully!'
