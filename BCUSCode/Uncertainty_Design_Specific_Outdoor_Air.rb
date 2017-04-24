# Copyright © 2016 , UChicago Argonne, LLC
# All Rights Reserved
# OPEN SOURCE LICENSE
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.  Software changes,
#    modifications, or derivative works, should be noted with comments and the
#    author and organization's name.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the names of UChicago Argonne, LLC or the Department of Energy nor
#    the names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# 4. The software and the end-user documentation included with the
#    redistribution, if any, must include the following acknowledgment:
#
#    "This product includes software produced by UChicago Argonne, LLC under
#     Contract No. DE-AC02-06CH11357 with the Department of Energy."
#
# *****************************************************************************
# DISCLAIMER
#
# THE SOFTWARE IS SUPPLIED "AS IS" WITHOUT WARRANTY OF ANY KIND.
#
# NEITHER THE UNITED STATES GOVERNMENT, NOR THE UNITED STATES DEPARTMENT OF
# ENERGY, NOR UCHICAGO ARGONNE, LLC, NOR ANY OF THEIR EMPLOYEES, MAKES ANY
# WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LEGAL LIABILITY OR
# RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY
# INFORMATION, DATA, APPARATUS, PRODUCT, OR PROCESS DISCLOSED, OR REPRESENTS
# THAT ITS USE WOULD NOT INFRINGE PRIVATELY OWNED RIGHTS.
#
# *****************************************************************************

# Modified Date and By:
# - Created on July 2015 by Yuna Zhang from Argonne National Laboratory
# - 01-apr-2017: Refactored to better match ruby coding standards by RTM
# 21-Apr-2017 RTM ran rubocop linter for code cleanup

# 1. Introduction
# This is the subfunction called by Uncertain_Parameters to generate design
# specific outdoor air uncertainty distribution.
class DesignSpecificOutdoorAirUncertainty
  attr_reader :design_spec_outdoor_air_name
  attr_reader :design_spec_outdoor_air_flow_per_person
  attr_reader :design_spec_outdoor_air_flow_per_floor_area
  attr_reader :design_spec_outdoor_air_flow_rate

  def initialize
    @design_spec_outdoor_air_name = []
    @design_spec_outdoor_air_flow_per_person = []
    @design_spec_outdoor_air_flow_per_floor_area = []
    @design_spec_outdoor_air_flow_rate = []
  end

  def design_spec_outdoor_air_find(model)
    space_types = model.getSpaceTypes
    instances_array = []
    space_types.each do |space_type|
      next if space_type.spaces.empty?
      instances_array << space_type.designSpecificationOutdoorAir
    end
    instances_array.each do |instance|
      next if instance.empty?
      instance = instance.get
      @design_spec_outdoor_air_name << instance.name.to_s
      if instance.outdoorAirFlowperPerson > 0
        @design_spec_outdoor_air_flow_per_person << instance.outdoorAirFlowperPerson.to_f
      end
      if instance.outdoorAirFlowperFloorArea > 0
        @design_spec_outdoor_air_flow_per_floor_area << instance.outdoorAirFlowperFloorArea.to_f
      end
      if instance.outdoorAirFlowRate > 0
        @design_spec_outdoor_air_flow_rate << instance.outdoorAirFlowRate.to_f
      end
    end
  end

  def design_spec_outdoor_air_method(model, parameter_types, _parameter_names,
                                     parameter_value)
    parameter_types.each_with_index do |type, index|
      if type =~ /OutdoorAirFlowPerPerson/
        instances_array = []
        model.getSpaceTypes.each do |space_type|
          next if space_type.spaces.empty?
          instances_array << space_type.designSpecificationOutdoorAir
        end
        instances_array.each do |instance|
          next if instance.empty?
          instance = instance.get
          instance.setOutdoorAirFlowperPerson(parameter_value[index])
        end
      elsif type =~ /OutdoorairFlowPerZoneFloorArea/
        instances_array = []
        model.getSpaceTypes.each do |space_type|
          next if space_type.spaces.empty?
          instances_array << space_type.designSpecificationOutdoorAir
        end
        instances_array.each do |instance|
          next if instance.empty?
          instance = instance.get
          instance.setOutdoorAirFlowperFloorArea(parameter_value[index])
        end
      elsif type =~ /OutdoorAirFlowRate/
        instances_array = []
        model.getSpaceTypes.each do |space_type|
          next if space_type.spaces.empty?
          instances_array << space_type.designSpecificationOutdoorAir
        end
        instances_array.each do |instance|
          next if instance.empty?
          instance = instance.get
          instance.setOutdoorAirFlowRate(parameter_value[index])
        end
      end
    end
  end
end
