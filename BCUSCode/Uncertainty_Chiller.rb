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
# 21-Apr-2017 RTM: used rubocop linter for code cleanup

# 1. Introduction
# This is the subfunction called by Uncertain_Parameters to generate chiller
# efficiency uncertainty distribution.
class ChillerUncertainty < OpenStudio::Model::Model
  attr_reader :chiller_name
  attr_reader :chiller_Reference_COP

  def initialize
    @chiller_name = []
    @chiller_Reference_COP = []
  end

  def chiller_find(model)
    # loop through to find water boiler
    model.getLoops.each do |loop|
      loop.supplyComponents.each do |supply_component|
        next if supply_component.to_ChillerElectricEIR.empty?
        chiller = supply_component.to_ChillerElectricEIR.get
        @chiller_name << chiller.name.to_s
        @chiller_Reference_COP << chiller.referenceCOP.to_f
      end
    end
  end

  # find thermal efficiency for boiler
  def chiller_method(model, parameter_types, _parameter_names, parameter_value)
    parameter_types.each_with_index do |type, index|
      next unless type =~ /ChillerElectricEIRReferenceCOP/
      model.getLoops.each do |loop|
        loop.supplyComponents.each do |supply_component|
          unless supply_component.to_ChillerElectricEIR.empty?
            chiller = supply_component.to_ChillerElectricEIR.get
            chiller.setReferenceCOP(parameter_value[index])
          end
        end
      end
    end
  end
end
