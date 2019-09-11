#!/bin/bash
echo "Bayesian Calibration"
echo "This bash file will run the Bayesian calibration in following commands:"
echo "ruby -S BC.rb --osm --epw --priorsFile --utilityData --outFile --simFile --fieldFile --postsFile --pvalsFile --numLHD --numMCMC --numBurnin --numOutVars --numWVars --seed --numProcesses --noSim --noEP --noCleanup --noPlots --noRunCal --interactive --verbose"

ruby -S BC.rb ExampleBuilding.osm Weather_USA_PA_Willow.Grove.NAS.724086_TMY3.epw --priorsFile Prior.csv --utilityData Utility.csv --numLHD 10 --numMCMC 200 --numBurnin 3 --seed 1 --numProcesses 3 --noRunCal --verbose
