@ECHO *** BCUS Installation Test ***
@ECHO This batch file will test your installation of Ruby, and BC in BCUS:



@echo.

ruby -S BC.rb test.osm test.epw --numMCMC 30 --numBurnin 3 --seed 1 %1 %2 %3 %4
