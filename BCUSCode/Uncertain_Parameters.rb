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

# *****************************************************************************
# DISCLAIMER

# THE SOFTWARE IS SUPPLIED "AS IS" WITHOUT WARRANTY OF ANY KIND.

# NEITHER THE UNITED STATES GOVERNMENT, NOR THE UNITED STATES DEPARTMENT OF
# ENERGY, NOR UCHICAGO ARGONNE, LLC, NOR ANY OF THEIR EMPLOYEES, MAKES ANY
# WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LEGAL LIABILITY OR
# RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY
# INFORMATION, DATA, APPARATUS, PRODUCT, OR PROCESS DISCLOSED, OR REPRESENTS
# THAT ITS USE WOULD NOT INFRINGE PRIVATELY OWNED RIGHTS.

# *****************************************************************************

# Modified Date and By:
# - Update 27-Mar-2017 by RTM
# to add verbose printouts and finished the error messages
# using abort() when UQ parameters are not found
# - Update 27-Mar-2017 by RTM
# renaming the uncertain parameter libraries so the first
# word is Uncertainty to help directory sorting
# 21-Apr-2017 by RTM
# ran rubocop lint for code cleanup

# - Updated on July 2016 by Yuna Zhang from Argonne National Laboratory
# - Created on Feb 27, 2015 by Yuming Sun and Matt Riddle from Argonne

# 1. Introduction
# This is the main code used for searching model for parameters to be
# perturbued for uncertainty and sensitivity analysis.

# 2. Call structure
# Refer to 'Function Call Structure_UA.pptx'

#===============================================================%
#     author: Yuming Sun and Matt Riddle                        %
#     date: Feb 27, 2015                                        %
#===============================================================%

# Main code used for searching model for parameters to be perturbued for
# uncertainty and sensitivity analysis

require 'csv'
require 'rubyXL'

# uncertain_parameters
require_relative 'uncertainty_boiler'
require_relative 'uncertainty_chiller'
require_relative 'uncertainty_design_specific_outdoor_air'
require_relative 'uncertainty_DX_coil'
require_relative 'uncertainty_envelop'
require_relative 'uncertainty_fan_pump'
require_relative 'uncertainty_operation'
require_relative 'uncertainty_thermostat'

class UncertainParameters
  def initialize
    @envelop_uncertainty = EnvelopUncertainty.new
    @operation_uncertainty = OperationUncertainty.new
    @boiler_uncertainty = BoilerUncertainty.new
    @fan_pump_uncertainty = FanPumpUncertainty.new
    @design_spec_OA_uncertainty = DesignSpecificOutdoorAirUncertainty.new
    @DX_cooling_coil_uncertainty = DXCoilUncertainty.new
    @chillerEIR_uncertainty = ChillerUncertainty.new
    @thermostat_uncertainty = ThermostatUncertainty.new
  end

  # Write into the uq cvs the uncertainty distribution information
  def find(model, uq_table, out_file_path_name, verbose = false)
    @envelop_uncertainty.material_find(model)
    @operation_uncertainty.operation_parameters_find(model)
    @boiler_uncertainty.boiler_find(model)
    @fan_pump_uncertainty.fan_find(model)
    @fan_pump_uncertainty.pump_find(model)
    @design_spec_OA_uncertainty.design_spec_OA_find(model)
    @DX_cooling_coil_uncertainty.DX_coil_single_speed_find(model)
    @DX_cooling_coil_uncertainty.DX_coil_two_speed_find(model)
    @chillerEIR_uncertainty.chiller_find(model)

    # Create a csv file that contains uncertain parameters
    CSV.open(out_file_path_name.to_s, 'wb') do |csv|
      csv << [
        'Parameter Type', 'Object in the model', 'Parameter Base Value',
        'Distribution', 'Mean or Mode', 'Std Dev', 'Min', 'Max'
      ]
    end

    # Write in the created csv file (take input from uncertainty)
    CSV.open(out_file_path_name.to_s, 'a+') do |csv|
      uq_table.each do |uq_param|
        next if uq_param[3] == 'Off'
        if verbose
          puts "Searching for #{uq_param[1]} #{uq_param[2]} in the model"
        end
        case uq_param[1]
        when /StandardOpaqueMaterial/
          param_attr, param_name =
            case uq_param[2]
            when /Conductivity/
              ['std_mat_conductivity', 'Conductivity']
            when /Density/
              ['std_mat_density', 'Density']
            when /SpecificHeat/
              ['std_mat_specificHeat', 'SpecificHeat']
            when /SolarAbsorptance/
              ['std_mat_solarAbsorptance', 'SolarAbsorptance']
            when /ThermalAbsorptance/
              ['std_mat_thermalAbsorptance', 'ThermalAbsorptance']
            when /VisibleAbsorptance/
              ['std_mat_visibleAbsorptance', 'VisibleAbsorptance']
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @envelop_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @envelop_uncertainty.std_mat_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! " \
              "StandardOpaqueMaterial #{uq_param[2]} not found\n\n"
            )
          end
        when /StandardGlazing/
          param_attr, param_name =
            case uq_param[2]
            when /Conductivity/
              [
                'std_glz_conductivity',
                'Conductivity'
              ]
            when /ThermalResistance/
              [
                'std_glz_thermalResistance',
                'ThermalResistance'
              ]
            when /SolarTransmittance/
              [
                'std_glz_solarTransmittance',
                'SolarTransmittance'
              ]
            when /FrontSideSolarReflectance/
              [
                'std_glz_front_solarReflectance',
                'FrontSideSolarReflectance'
              ]
            when /BackSideSolarReflectance/
              [
                'std_glz_back_solarReflectance',
                'BackSideSolarReflectance'
              ]
            when /InfraredTransmittance/
              [
                'std_glz_infraredTransmittance',
                'InfraredTransmittance'
              ]
            when /VisibleTransmittance/
              [
                'std_glz_visibleTransmittance',
                'VisibleTransmittance'
              ]
            when /FrontSideVisibleReflectance/
              [
                'std_glz_front_visibleReflectance',
                'FrontSideVisibleReflectance'
              ]
            when /BackSideVisibleReflectance/
              [
                'std_glz_back_visibleReflectance',
                'BackSideVisibleReflectance'
              ]
            when /FrontSideInfraredHemisphericalEmissivity/
              [
                'std_glz_front_infraredEmissivity',
                'FrontSideInfraredHemisphericalEmissivity'
              ]
            when /BackSideInfraredHemisphericalEmissivity/
              [
                'std_glz_back_infraredEmissivity',
                'BackSideInfraredHemisphericalEmissivity'
              ]
            when /DirtCorrectionFactor/
              [
                'std_glz_dirtCorrectionFactor',
                'DirtCorrectionFactor'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @envelop_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @envelop_uncertainty.std_glz_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! " \
              "StandardGlazing #{uq_param[2]} not found\n\n"
            )
          end
        when /Infiltration/
          case uq_param[2]
          when /FlowPerExteriorArea/
            csv << ['Infiltration', 'FlowPerExteriorArea', '', *uq_param[4..8]]
          else
            abort("\n!!!ABORTING!!! Infiltration #{uq_param[2]} not found\n\n")
          end

        when /Lights/
          param_attr, param_name =
            case uq_param[2]
            when /WattsPerSpaceFloorArea/
              [
                'lights_watts_per_floor_area',
                'Lights_WattsPerSpaceFloorArea'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @operation_uncertainty.lights_space_type.each_with_index do |spacetype, index|
              csv << [
                param_name, spacetype,
                @operation_uncertainty.send(param_attr.to_sym)[index],
                *uq_param[4..8]
              ]
            end
          else
            abort("\n!!!ABORTING!!! Lights #{uq_param[2]} not found\n\n")
          end
        when /PlugLoad/
          param_attr, param_name =
            case uq_param[2]
            when /WattsPerSpaceFloorArea/
              [
                'plugload_watts_per_floor_area',
                'PlugLoad_WattsPerSpaceFloorArea'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @operation_uncertainty.plugload_space_type.each_with_index do |spacetype, index|
              csv << [
                param_name, spacetype,
                @operation_uncertainty.send(param_attr.to_sym)[index],
                *uq_param[4..8]
              ]
            end
          else
            abort("\n!!!ABORTING!!! PlugLoad #{uq_param[2]} not found\n\n")
          end
        when /People/
          param_attr, param_name =
            case uq_param[2]
            when /SpaceFloorAreaPerPerson/
              [
                'people_floor_area_per_person',
                'People_SpaceFloorAreaPerPerson'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @operation_uncertainty.people_space_type.each_with_index do |spacetype, index|
              csv << [
                param_name, spacetype,
                @operation_uncertainty.send(param_attr.to_sym)[index],
                *uq_param[4..8]
              ]
            end
          else
            abort("\n!!!ABORTING!!! People #{uq_param[2]} not found\n\n")
          end
        when /HotWaterBoiler/
          param_attr, param_name =
            case uq_param[2]
            when /Efficiency/
              ['hotwaterboiler_efficiency', 'HotWaterBoilerEfficiency']
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @boiler_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @boiler_uncertainty.hotwaterboiler_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! HotWaterBoiler #{uq_param[2]} not found\n\n"
            )
          end
        when /SteamBoiler/
          param_attr, param_name =
            case uq_param[2]
            when /Efficiency/
              ['steamboiler_efficiency', 'SteamBoilerEfficiency']
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @boiler_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @boiler_uncertainty.steamboiler_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort("\n!!!ABORTING!!! SteamBoiler #{uq_param[2]} not found\n\n")
          end
        when /FanConstantVolume/
          param_attr, param_name =
            case uq_param[2]
            when /Efficiency/
              [
                'fan_constant_efficiency',
                'FanConstantVolumeEfficiency'
              ]
            when /Motor_efficiency/
              [
                'fan_constant_motorEfficiency',
                'FanConstantVolumeMotorEfficiency'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @fan_pump_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @fan_pump_uncertainty.fan_constant_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! FanConstantVolume #{uq_param[2]} not found\n\n"
            )
          end
        when /FanVariableVolume/
          param_attr, param_name =
            case uq_param[2]
            when /Efficiency/
              [
                'fan_variable_efficiency',
                'FanVariableVolumeEfficiency'
              ]
            when /Motor_efficiency/
              [
                'fan_variable_motorEfficiency',
                'FanVariableVolumeMotorEfficiency'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @fan_pump_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @fan_pump_uncertainty.fan_variable_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! FanVariableVolume #{uq_param[2]} not found\n\n"
            )
          end
        when /PumpConstantSpeed/
          param_attr, param_name =
            case uq_param[2]
            when /Motor_efficiency/
              [
                'pump_constant_motorEfficiency',
                'PumpConstantSpeedMotorEfficiency'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @fan_pump_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @fan_pump_uncertainty.pump_constant_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! PumpConstantSpeed #{uq_param[2]} not found\n\n"
            )
          end
        when /PumpVariableSpeed/
          param_attr, param_name =
            case uq_param[2]
            when /Motor_efficiency/
              [
                'pump_variable_motorEfficiency',
                'PumpVariableSpeedMotorEfficiency'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @fan_pump_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name, @fan_pump_uncertainty.pump_variable_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! PumpVariableSpeed #{uq_param[2]} not found\n\n"
            )
          end
        when /DesignSpecificationOutdoorAir/
          param_attr, param_name =
            case uq_param[2]
            when /OutdoorAirFlowPerPerson/
              [
                'design_spec_OA_flow_per_person',
                'DesignSpecificOutdoorAirFlowPerPerson'
              ]
            when /OutdoorairFlowPerZoneFloorArea/
              [
                'design_spec_OA_flow_per_floor_area',
                'DesignSpecificOutdoorAirFlowPerZoneFloorArea'
              ]
            when /OutdoorAirFlowRate/
              [
                'design_spec_OA_flow_rate',
                'DesignSpecificOutdoorAirFlowRate'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @design_spec_OA_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name,
                @design_spec_OA_uncertainty.design_spec_OA_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! " \
              "DesignSpecificationOutdoorAir #{uq_param[2]} not found\n\n"
            )
          end
        when /SingleSpeedDXCoolingUnits/
          param_attr, param_name =
            case uq_param[2]
            when /RatedTotalCoolingCapacity/
              [
                'DX_coil_single_speed_totalCapacity',
                'DXCoolingCoilSingleSpeedRatedTotalCapacity'
              ]
            when /RatedSenisbleHeatRatio/
              [
                'DX_coil_single_speed_sensibleHeatRatio',
                'DXCoolingCoilSingleSpeedRatedSenisbleHeatRatio'
              ]
            when /RatedCOP/
              [
                'DX_coil_single_speed_COP',
                'DXCoolingCoilSingleSpeedRatedCOP'
              ]
            when /RatedAirFlowRate/
              [
                'DX_coil_single_speed_airFlowRate',
                'DXCoolingCoilSingleSpeedRatedAirFlowRate'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @DX_cooling_coil_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name,
                @DX_cooling_coil_uncertainty.DX_coil_single_speed_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! " \
              "SingleSpeedDXCoolingUnits #{uq_param[2]} not found\n\n"
            )
          end
        when /TwoSpeedDXCoolingUnits/
          param_attr, param_name =
            case uq_param[2]
            when /RatedHighSpeedCOP/
              [
                'DX_coil_two_speed_highCOP',
                'DXCoolingCoilTwoSpeedRatedHighSpeedCOP'
              ]
            when /RatedLowSpeedCOP/
              [
                'DX_coil_two_speed_lowCOP',
                'DXCoolingCoilTwoSpeedRatedLowSpeedCOP'
              ]
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @DX_cooling_coil_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name,
                @DX_cooling_coil_uncertainty.DX_coil_two_speed_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! " \
              "TwoSpeedDXCoolingUnits #{uq_param[2]} not found\n\n"
            )
          end
        when /ChillerElectricEIR/
          param_attr, param_name =
            case uq_param[2]
            when /ReferenceCOP/
              ['chiller_ref_COPs', 'ChillerElectricEIRReferenceCOP']
            else
              [nil, nil]
            end
          unless param_attr.nil?
            @chillerEIR_uncertainty.send(param_attr.to_sym).each_with_index do |value, index|
              csv << [
                param_name,
                @chillerEIR_uncertainty.chiller_name[index],
                value, *uq_param[4..8]
              ]
            end
          else
            abort(
              "\n!!!ABORTING!!! " \
              "ChillerElectricEIR #{uq_param[2]} not found\n\n"
            )
          end
        when /ThermostatSettings/
          case uq_param[2]
          when /ThermostatSetpointCooling/
            csv << [
              'CoolingSetpoint', 'DualSetpoint:CoolingSetpoint',
              'CoolingSetpointTemperature', *uq_param[4..8]
            ]
          when /ThermostatSetpointHeating/
            csv << [
              'HeatingSetpoint', 'DualSetpoint:HeatingSetpoint',
              'HeatingSetpointTemperature', *uq_param[4..8]
            ]
          else
            abort("\n!!!ABORTING!!! #{uq_param[2]} not found\n\n")
          end
        else
          abort("\n!!!ABORTING!!! UQ Class #{uq_param[1]} not found\n\n")
        end
      end
    end
    puts "#{out_file_path_name} has been generated." if verbose
  end

  def apply(model, param_types, param_names, param_values)
    @envelop_uncertainty.material_set(
      model, param_types, param_names, param_values
    )
    @envelop_uncertainty.infiltration_flow_per_ext_surface_set(
      model, param_types, param_names, param_values
    )
    @operation_uncertainty.lights_watts_per_area_set(
      model, param_types, param_names, param_values
    )
    @operation_uncertainty.plugload_watts_per_area_set(
      model, param_types, param_names, param_values
    )
    @operation_uncertainty.people_area_per_person_set(
      model, param_types, param_names, param_values
    )
    @boiler_uncertainty.boiler_set(
      model, param_types, param_names, param_values
    )
    @fan_pump_uncertainty.fan_set(
      model, param_types, param_names, param_values
    )
    @fan_pump_uncertainty.pump_set(
      model, param_types, param_names, param_values
    )
    @design_spec_OA_uncertainty.design_spec_OA_set(
      model, param_types, param_names, param_values
    )
    @DX_cooling_coil_uncertainty.DX_coil_single_speed_set(
      model, param_types, param_names, param_values
    )
    @DX_cooling_coil_uncertainty.DX_coil_two_speed_set(
      model, param_types, param_names, param_values
    )
    @chillerEIR_uncertainty.chiller_set(
      model, param_types, param_names, param_values
    )
  end

  def apply_thermostat(
    model, uq_table, out_file_path_name, model_output_path,
    param_types, param_values
  )
    # Create a csv file that contains thermostat if the user turn it on
    CSV.open(out_file_path_name.to_s, 'wb') do |csv|
      csv << [
      'Parameter Type', 'Object in the model',
      'Parameter Base Value', 'Adjusted Value'
      ]
    end
    
    CSV.open(out_file_path_name.to_s, 'a+') do |csv|
      uq_table.each do |uq_param|
        next if uq_param[3] == 'Off'
        case uq_param[1]
        when /ThermostatSettings/
          case uq_param[2]
          when /ThermostatSetpointCooling/
            param_types.each_with_index do |type, index|
              next unless type =~ /CoolingSetpoint/
              adjust_value_cooling = param_values[index]
              @thermostat_uncertainty.cooling_set(
                model, adjust_value_cooling, model_output_path
              )
              @thermostat_uncertainty.clg_set_sch_value.each_with_index do |value, index1|
                csv << [
                  'CoolingSetpoint',
                  @thermostat_uncertainty.clg_set_sch_name[index1],
                  value,
                  param_values[index]
                ]
              end
            end
          when /ThermostatSetpointHeating/
            param_types.each_with_index do |type, index|
              next unless type =~ /HeatingSetpoint/
              adjust_value_heating = param_values[index]
              @thermostat_uncertainty.heating_set(
                model, adjust_value_heating, model_output_path
              )
              @thermostat_uncertainty.htg_set_sch_value.each_with_index do |value, index1|
                csv << [
                  'HeatingSetpoint',
                  @thermostat_uncertainty.htg_set_sch_name[index1],
                  value,
                  param_values[index]
                ]
              end
            end
          end
        end
      end
    end
  end
end
