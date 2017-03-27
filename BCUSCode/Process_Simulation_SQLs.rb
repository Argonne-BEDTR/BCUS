=begin comments
Copyright © 2016 , UChicago Argonne, LLC
All Rights Reserved
OPEN SOURCE LICENSE

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.  Software changes, modifications, or derivative works, should be noted with comments and the author and organization’s name.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the names of UChicago Argonne, LLC or the Department of Energy nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

4. The software and the end-user documentation included with the redistribution, if any, must include the following acknowledgment:

   "This product includes software produced by UChicago Argonne, LLC under Contract No. DE-AC02-06CH11357 with the Department of Energy.”

******************************************************************************************************
DISCLAIMER

THE SOFTWARE IS SUPPLIED "AS IS" WITHOUT WARRANTY OF ANY KIND.

NEITHER THE UNITED STATES GOVERNMENT, NOR THE UNITED STATES DEPARTMENT OF ENERGY, NOR UCHICAGO ARGONNE, LLC, NOR ANY OF THEIR EMPLOYEES, MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LEGAL LIABILITY OR RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY INFORMATION, DATA, APPARATUS, PRODUCT, OR PROCESS DISCLOSED, OR REPRESENTS THAT ITS USE WOULD NOT INFRINGE PRIVATELY OWNED RIGHTS.

***************************************************************************************************

Modified Date and By:
- Created on Feb 27 by Yuming Sun from Argonne National Laboratory

1. Introduction
This function reads simulation results generated in SQL.

=end

require 'openstudio'
require 'fileutils'
require 'rubyXL'
require 'csv'

module OutPut

  def OutPut.Read(num_of_runs, project_path, out_prefix, settingsfile_path, verbose=false)
	
	debug = true
	
	if debug
		puts
		puts "number_of_runs = #{num_of_runs}"
		puts "project_path = #{project_path}"
		puts "out_prefix = #{out_prefix}"
		puts "settingsfile_path = #{settingsfile_path}"
		#puts "outfile_name = #{outfile_name}"
		puts
	end

# Find the path of sql
    #workbook = RubyXL::Parser.parse("#{project_path}/Simulation_Output_Settings.xlsx")
    workbook = RubyXL::Parser.parse(settingsfile_path)		

    #output_table = workbook['TotalEnergy'].extract_data  outdated by June 28th

    output_table = Array.new
    output_table_row = Array.new
    workbook['TotalEnergy'].each { |row|
      output_table_row = []
      row.cells.each { |cell|
        output_table_row.push(cell.value)
      }
      output_table.push(output_table_row)
    }


    total_site_energy = []
    total_source_energy = []
    electricity_total_end_uses = []
    electricity_heating =[]
    electricity_cooling =[]
    electricity_water_systems = []
    electricity_interior_lighting = []
    electricity_exterior_lighting = []
    electricity_interior_equipment = []
    electricity_exterior_equipment = []
    electricity_fans = []
    electricity_pumps = []
    electricity_heat_rejection = []
    natural_gas_total_end_uses = []
    natural_gas_heating = []
    natural_gas_cooling = []
    natural_gas_water_systems = []
    district_cooling = []
    district_heating = []
    district_cooling_total_end_uses = []
    district_heating_total_end_uses = []


    (1..num_of_runs).each { |sample_num|
      sqlFilePath = "#{project_path}/#{out_prefix}_Simulations/Sample#{sample_num}/ModelToIdf/EnergyPlus-0/eplusout.sql"
      sqlFile = OpenStudio::SqlFile.new(sqlFilePath)
      (1..(output_table.length-1)).each { |output_num|
        case output_table[output_num].to_s
          when /Total Site Energy/
            if not sqlFile.totalSiteEnergy.empty?
              total_site_energy << sqlFile.totalSiteEnergy.get
            else
              total_site_energy << ''
            end
          when /Total Source Energy/
            if not sqlFile.totalSourceEnergy.empty?
              total_source_energy << sqlFile.totalSourceEnergy.get
            else
              total_source_energy << ''
            end
          when /Electricity Total End Uses/
            if not sqlFile.electricityTotalEndUses.empty?
              electricity_total_end_uses << sqlFile.electricityTotalEndUses.get
            else
              electricity_total_end_uses << ''
            end
          when /Electricity Heating/
            if sqlFile.electricityHeating.empty?
              electricity_heating << sqlFile.electricityHeating.get
            else
              electricity_heating << ''
            end
          when /Electricity Cooling/
            if not sqlFile.electricityCooling.empty?
              electricity_cooling << sqlFile.electricityCooling.get
            else
              electricity_cooling << ''
            end
          when /Electricity Water Systems/
            if not sqlFile.electricityWaterSystems.empty?
              electricity_water_systems << sqlFile.electricityWaterSystems.get
            else
              electricity_water_systems << ''
            end
          when /Electricity Interior Lighting/
            if not sqlFile.electricityInteriorLighting.empty?
              electricity_interior_lighting << sqlFile.electricityInteriorLighting.get
            else
              electricity_interior_lighting << ''
            end

          when /Electricity Exterior Lighting/
            if not sqlFile.electricityExteriorLighting.empty?
              electricity_exterior_lighting << sqlFile.electricityExteriorLighting.get
            else
              electricity_exterior_lighting << ''
            end
          when /Electricity Interior Equipment/
            if not sqlFile.electricityInteriorEquipment.empty?
              electricity_interior_equipment << sqlFile.electricityInteriorEquipment.get
            else
              electricity_interior_equipment << ''
            end
          when /Electricity Exterior Equipment/
            if not sqlFile.electricityExteriorEquipment.empty?
              electricity_exterior_equipment << sqlFile.electricityExteriorEquipment.get
            else
              electricity_exterior_equipment << ''
            end
          when /Electricity Fans/
            if not sqlFile.electricityFans.empty?
              electricity_fans << sqlFile.electricityFans.get
            else
              electricity_fans << ''
            end
          when /Electricity Pumps/
            if not sqlFile.electricityPumps.empty?
              electricity_pumps << sqlFile.electricityPumps.get
            else
              electricity_pumps << ''
            end
          when /Electricity Heat Rejection/
            if not sqlFile.electricityHeatRejection.empty?
              electricity_heat_rejection << sqlFile.electricityHeatRejection.get
            else
              electricity_heat_rejection << ''
            end
          when /Natural Gas Total End Uses/
            if not sqlFile.naturalGasTotalEndUses.empty?
              natural_gas_total_end_uses << sqlFile.naturalGasTotalEndUses.get
            else
              natural_gas_total_end_uses << ''
            end
          when /Natural Gas Heating/
            if not sqlFile.naturalGasHeating.empty?
              natural_gas_heating << sqlFile.naturalGasHeating.get
            else
              natural_gas_heating << ''
            end
          when /Natural Gas Cooling/
            if not sqlFile.naturalGasCooling.empty?
              natural_gas_cooling << sqlFile.naturalGasCooling.get
            else
              natural_gas_cooling << ''
            end
          when /Natural Gas Water Systems/
            if not sqlFile.naturalGasWaterSystems.empty?
              natural_gas_water_systems << sqlFile.naturalGasWaterSystems.get
            else
              natural_gas_water_systems << ''
            end
          when /District Cooling/
            if not sqlFile.districtCoolingCooling.empty?
              district_cooling << sqlFile.districtCoolingCooling.get
            else
              district_cooling << ''
            end
          when /District Heating/
            if not sqlFile.districtHeatingHeating.empty?
              district_heating << sqlFile.districtHeatingHeating.get
            else
              district_heating << ''
            end
          when /District Cooling Total End Uses/
            if not sqlFile.districtCoolingTotalEndUses.empty?
              district_cooling_total_end_uses << sqlFile.districtCoolingTotalEndUses.get
            else
              district_cooling_total_end_uses << ''
            end
          when /District Heating Total End Uses/
            if not sqlFile.districtHeatingTotalEndUses.empty?
              district_heating_total_end_uses << sqlFile.districtHeatingTotalEndUses.get
            else
              district_heating_total_end_uses << ''
            end
        end
      }
    }

    # put all output array to final_output

    final_output = []
    header = []
    (1..(output_table.length-1)).each { |output_num|
      case output_table[output_num].to_s
        when /Total Site Energy/
          final_output << total_site_energy
          header << 'Total Site Energy [GJ]'
        when /Total Source Energy/
          final_output << total_source_energy
          header << 'Total Source Energy [GJ]'
        when /Electricity Total End Uses/
          final_output << electricity_total_end_uses
          header << 'Electricity Total End Uses [GJ]'
        when /Electricity Heating/
          final_output << electricity_heating
          header << 'Electricity Heating [GJ]'
        when /Electricity Cooling/
          final_output << electricity_cooling
          header << 'Electricity Cooling [GJ]'
        when /Electricity Water Systems/
          final_output << electricity_water_systems
          header << 'Electricity Water Systems [GJ]'
        when /Electricity Interior Lighting/
          final_output << electricity_interior_lighting
          header << 'Electricity Interior Lighting [GJ]'
        when /Electricity Exterior Lighting/
          final_output << electricity_exterior_lighting
          header << 'Electricity Exterior Lighting [GJ]'
        when /Electricity Interior Equipment/
          final_output << electricity_interior_equipment
          header << 'Electricity Interior Equipment [GJ]'
        when /Electricity Exterior Equipment/
          final_output << electricity_exterior_equipment
          header << 'Electricity Exterior Equipment [GJ]'
        when /Electricity Fans/
          final_output << electricity_fans
          header << 'Electricity Fans [GJ]'
        when /Electricity Pumps/
          final_output << electricity_pumps
          header << 'Electricity Pumps [GJ]'
        when /Electricity Heat Rejection/
          final_output << electricity_heat_rejection
          header << 'Electricity Heat Rejection [GJ]'
        when /Natural Gas Total End Uses/
          final_output << natural_gas_total_end_uses
          header << 'Natural Gas Total End Uses [GJ]'
        when /Natural Gas Heating/
          final_output << natural_gas_heating
          header << 'Natural Gas Heating [GJ]'
        when /Natural Gas Cooling/
          final_output << natural_gas_cooling
          header << 'Natural Gas Cooling [GJ]'
        when /Natural Gas Water Systems/
          final_output << natural_gas_water_systems
          header << 'Natural Gas Water Systems [GJ]'
        when /District Cooling/
          final_output << district_cooling
          header << 'District Cooling [GJ]'
        when /District Heating/
          final_output << district_heating
          header << 'District Heating [GJ]'
        when /District Cooling Total End Uses/
          final_output << district_cooling_total_end_uses
          header << 'District Cooling Total End Uses [GJ]'
        when /District Heating Total End Uses/
          final_output << district_heating_total_end_uses
          header << 'District Heating Total End Uses [GJ]'
      end
    }

    # Save to final_output to csv files
    table = final_output.transpose
    CSV.open("#{project_path}/#{out_prefix}_Output/Simulation_Results_Building_Total_Energy.csv", 'wb') do |csv|
      csv << header
    end

    CSV.open("#{project_path}/#{out_prefix}_Output/Simulation_Results_Building_Total_Energy.csv", 'a+') do |csv|
      table.each do |row|
        csv << row
      end
      puts 'Simulation_Results_Building_Total_Energy.csv is saved to the folder' if verbose
    end

    #workbook = RubyXL::Parser.parse("#{project_path}/Simulation_Output_Settings.xlsx")
		workbook = RubyXL::Parser.parse(settingsfile_path)	
    # meters_table = workbook['Meters'].extract_data  outdated by June 28th
    meters_table = Array.new
    meters_table_row = Array.new
    workbook['Meters'].each { |row|
      meters_table_row = []
      row.cells.each { |cell|
        meters_table_row.push(cell.value)
      }
      meters_table.push(meters_table_row)
    }


    (1..(meters_table.length-1)).each { |meter_index|
      var_value = []
      (1..num_of_runs).each { |sample_num|
        sqlFilePath = "#{project_path}/#{out_prefix}_Simulations/Sample#{sample_num}/ModelToIdf/EnergyPlus-0/eplusout.sql"
        sqlFile = OpenStudio::SqlFile.new(sqlFilePath)
        query_var_index = "SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary
           WHERE VariableName = '#{meters_table[meter_index][0]}' AND
           ReportingFrequency = '#{meters_table[meter_index][1]}'"
        if not sqlFile.execAndReturnFirstDouble(query_var_index).empty?
          var_index = sqlFile.execAndReturnFirstDouble(query_var_index).get

          query_var_value = "SELECT VariableValue FROM ReportMeterData
           WHERE ReportMeterDataDictionaryIndex = #{var_index}"
          var_value << sqlFile.execAndReturnVectorOfDouble(query_var_value).get
        else
          var_value << []
        end
      }

      case meters_table[meter_index][1]
        when /Monthly/
          header = ['Jan', 'Feb', 'Mar', 'April', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec']
        when /Daily/
          header = ['Day 1', 'Day 2', 'Day 3', '...']
        when /Hourly/
          header = ['Hour 1', 'Hour 2', 'Hour 3', '...']
        else
          header = ['TimeStep 1', 'TimeStep 2', 'TimeStep 3', '...']
      end

      CSV.open("#{project_path}/#{out_prefix}_Output/Meter_#{meters_table[meter_index][0].split(':')[0]}_#{meters_table[meter_index][0].split(':')[1]}.csv", 'wb') do |csv|
        csv << header
      end

      CSV.open("#{project_path}/#{out_prefix}_Output/Meter_#{meters_table[meter_index][0].split(':')[0]}_#{meters_table[meter_index][0].split(':')[1]}.csv", 'a+') do |csv|
        var_value.each do |row|
          csv << row
        end
        puts "Meter_#{meters_table[meter_index][0].split(':')[0]}_#{meters_table[meter_index][0].split(':')[1]}.csv is saved to the Output folder" if verbose
      end

    }

    weather_var = []

    sqlFilePath = "#{project_path}/#{out_prefix}_Simulations/Sample1/ModelToIdf/EnergyPlus-0/eplusout.sql"
    sqlFile = OpenStudio::SqlFile.new(sqlFilePath)

    query_var_index = "SELECT ReportVariableDataDictionaryIndex FROM ReportVariableDataDictionary
           WHERE VariableName = 'Site Outdoor Air Drybulb Temperature' AND
           ReportingFrequency = 'Monthly'"

    if not sqlFile.execAndReturnFirstDouble(query_var_index).empty?
      var_index = sqlFile.execAndReturnFirstDouble(query_var_index).get
      query_var_value = "SELECT VariableValue FROM ReportVariableData
           WHERE ReportVariableDataDictionaryIndex = #{var_index}"
      weather_var << sqlFile.execAndReturnVectorOfDouble(query_var_value).get
    else
      weather_var << []
    end

    # Query Horizontal Solar Irradiation
    query_var_index = "SELECT ReportVariableDataDictionaryIndex FROM ReportVariableDataDictionary
           WHERE VariableName = 'Site Ground Reflected Solar Radiation Rate per Area' AND
           ReportingFrequency = 'Monthly'"

    if not sqlFile.execAndReturnFirstDouble(query_var_index).empty?
      var_index = sqlFile.execAndReturnFirstDouble(query_var_index).get

      query_var_value = "SELECT VariableValue FROM ReportVariableData
           WHERE ReportVariableDataDictionaryIndex = #{var_index}"
      ground_reflec_solar = sqlFile.execAndReturnVectorOfDouble(query_var_value).get
      horizontal_total_solar = ground_reflec_solar.collect { |n| n * 5 }
      weather_var << horizontal_total_solar
    else
      weather_var << []
    end

    weather_out = (weather_var.transpose)*num_of_runs

    CSV.open("#{project_path}/#{out_prefix}_Output/Monthly_Weather.csv", 'wb') do |csv|
      csv << ['Monthly DryBuld Temp [C]', 'Monthly Horizontal Solar [W/m^2]']
    end

    CSV.open("#{project_path}/#{out_prefix}_Output/Monthly_Weather.csv", 'a+') do |csv|
      weather_out.each do |row|
        csv << row
      end
    end
  end
end




