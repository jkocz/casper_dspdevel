function filterbank_top_config(this_block)

  filepath = fileparts(which('filterbank_top_config'));
  this_block.setTopLevelLanguage('VHDL');

  this_block.setEntityName('top_fil');
  filterbank_blk = this_block.blockName;
  filterbank_blk_parent = get_param(filterbank_blk,'Parent');

  function boolval =  checkbox2bool(bxval)
    if strcmp(bxval, 'on')
     boolval= true;
    elseif strcmp(bxval, 'off')
     boolval= false;
    end 
 end

 function strboolval = bool2str(bval)
     if bval
         strboolval = 'TRUE';
     elseif ~bval
         strboolval = 'FALSE';
     end
 end

  %Fetch subsystem mask parameters for dynamic ports:
  wb_factor = str2double(get_param(filterbank_blk_parent,'wb_factor'));
  if wb_factor<1
       error("Cannot have wideband factor <1"); 
  end
  big_endian_wb_in = checkbox2bool(get_param(filterbank_blk_parent,'big_endian_wb_in'));
  big_endian_wb_out = checkbox2bool(get_param(filterbank_blk_parent,'big_endian_wb_out'));
  nof_chan = get_param(filterbank_blk_parent,'nof_chan');
  nof_bands = get_param(filterbank_blk_parent,'nof_bands');
  i_d_w = get_param(filterbank_blk_parent,'in_dat_w');
  str_i_dat_type = sprintf('Fix_%s_0',i_d_w);
  o_d_w = get_param(filterbank_blk_parent,'out_dat_w');
  str_o_dat_type = sprintf('Fix_%s_0',o_d_w);
  c_d_w = get_param(filterbank_blk_parent,'coef_dat_w');
  win = get_param(filterbank_blk_parent, 'win');
  fwidth = get_param(filterbank_blk_parent, 'fwidth');
  nof_taps = str2double(get_param(filterbank_blk_parent,'nof_taps'));
  nof_streams = get_param(filterbank_blk_parent,'nof_streams');
  backoff_w = get_param(filterbank_blk_parent,'backoff_w');
  technology = get_param(filterbank_blk_parent,'technology');
  ram_primitive = get_param(filterbank_blk_parent,'ram_primitive');

  technology_int = 0;
  if strcmp(technology, 'Xilinx')
    technology_int = 0;
  end % if technology Xilinx
  if strcmp(technology, 'UniBoard')
    technology_int = 1;
  end % if technology UniBoard

  %Generate the top level vhdl file as well as the mem files. Returned is the location of the mem files for adding to the project.
  vhdlfile = top_fil_code_gen(wb_factor,str2double(nof_bands),nof_taps,win,...
      str2double(fwidth),technology_int,str2double(i_d_w),str2double(o_d_w),str2double(c_d_w));

  %Input signals
  this_block.addSimulinkInport('rst');
  rst_port = this_block.port('rst');
  rst_port.setType('Ufix_1_0');
  rst_port.useHDLVector(false);

  this_block.addSimulinkInport('in_val');
  in_val_port = this_block.port('in_val');
  in_val_port.setType('Ufix_1_0');
  in_val_port.useHDLVector(false);

  %Output signals
  this_block.addSimulinkOutport('out_val');
  out_val_port = this_block.port('out_val');
  out_val_port.setType('Ufix_1_0');
  out_val_port.useHDLVector(false);

  %Data in/out signals
  for i=0:wb_factor-1
    in_dat_str = sprintf('in_dat_%d',i);
    this_block.addSimulinkInport(in_dat_str);
    this_block.port(in_dat_str).setType(str_i_dat_type);
    this_block.port(in_dat_str).useHDLVector(true);
    out_dat_str = sprintf('out_dat_%d',i);
    this_block.addSimulinkOutport(out_dat_str);
    this_block.port(out_dat_str).setType(str_o_dat_type);
    this_block.port(out_dat_str).useHDLVector(true);
  end

  % -----------------------------
   if (this_block.inputRatesKnown)
     setup_as_single_rate(this_block,'clk','ce')
   end  % if(inputRatesKnown)
  % -----------------------------

    uniqueInputRates = unique(this_block.getInputRates);

  % (!) Custimize the following generic settings as appropriate. If any settings depend
  %      on input types, make the settings in the "inputTypesKnown" code block.
  %      The addGeneric function takes  3 parameters, generic name, type and constant value.
  %      Supported types are boolean, real, integer and string.
  this_block.addGeneric('g_big_endian_wb_in','boolean',bool2str(big_endian_wb_in));
  this_block.addGeneric('g_big_endian_wb_out','boolean',bool2str(big_endian_wb_out));
  this_block.addGeneric('g_in_dat_w','natural',i_d_w);
  this_block.addGeneric('g_coef_dat_w','natural',c_d_w);
  this_block.addGeneric('g_out_dat_w','natural',o_d_w);
  this_block.addGeneric('g_wb_factor','natural',num2str(wb_factor));
  this_block.addGeneric('g_nof_chan','natural',nof_chan);
  this_block.addGeneric('g_nof_bands','natural',nof_bands);
  this_block.addGeneric('g_nof_taps','natural',num2str(nof_taps));
  this_block.addGeneric('g_nof_streams','natural',nof_streams);
  this_block.addGeneric('g_backoff_w','natural',backoff_w);
  this_block.addGeneric('g_ram_primitive','String',ram_primitive);

  %get location of generated hdl source files:
  srcloc = fileparts(vhdlfile);
  
  % Copy across the technology_select_pkg as per mask's vendor_technology
  source_technology_select_pkg = '';
  if strcmp(technology, 'Xilinx')
    source_technology_select_pkg = [filepath '/../../technology/technology_select_pkg_casperxpm.vhd'];
  end % if technology Xilinx
  if strcmp(technology, 'UniBoard')
    source_technology_select_pkg = [filepath '/../../technology/technology_select_pkg_casperunb1.vhd'];
  end % if technology UniBoard
  copyfile(source_technology_select_pkg, [srcloc '/technology_select_pkg.vhd']);

  %Add files:
  this_block.addFileToLibrary(vhdlfile,'xil_defaultlib'); %weirdly this file should come first... but then the compile order changes.

  this_block.addFileToLibrary([filepath '/../../common_pkg/common_pkg.vhd'],'common_pkg_lib');
  this_block.addFileToLibrary([filepath '/../../common_components/common_pipeline.vhd'],'common_components_lib');
  this_block.addFileToLibrary([filepath '/../../casper_adder/common_add_sub.vhd'],'casper_adder_lib');
  this_block.addFileToLibrary([filepath '/../../casper_adder/common_adder_tree.vhd'],'casper_adder_lib');
  this_block.addFileToLibrary([filepath '/../../casper_adder/common_adder_tree_a_str.vhd'],'casper_adder_lib');
  this_block.addFileToLibrary([filepath '/../../casper_multiplier/tech_mult_component.vhd'],'casper_multiplier_lib');
  this_block.addFileToLibrary([srcloc '/technology_select_pkg.vhd'],'technology_lib');
  this_block.addFileToLibrary([filepath '/../../casper_multiplier/tech_mult.vhd'],'casper_multiplier_lib');
  this_block.addFileToLibrary([filepath '/../../common_components/common_pipeline_sl.vhd'],'common_components_lib');
  this_block.addFileToLibrary([filepath '/../../casper_multiplier/common_mult.vhd'],'casper_multiplier_lib');
  this_block.addFileToLibrary([filepath '/../../casper_ram/common_ram_pkg.vhd'],'casper_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_component_pkg.vhd'],'casper_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_ram_crw_crw.vhd'],'casper_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_ram_cr_cw.vhd'],'casper_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_ram/common_ram_crw_crw.vhd'],'casper_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_ram/common_ram_rw_rw.vhd'],'casper_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_ram/common_ram_r_w.vhd'],'casper_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_requantize/common_round.vhd'],'casper_requantize_lib');
  this_block.addFileToLibrary([filepath '/../../casper_requantize/common_resize.vhd'],'casper_requantize_lib');
  this_block.addFileToLibrary([filepath '/../../casper_requantize/common_requantize.vhd'],'casper_requantize_lib');
  this_block.addFileToLibrary([srcloc '/fil_pkg.vhd'],'casper_filter_lib');
  this_block.addFileToLibrary([filepath '/../../casper_filter/fil_ppf_ctrl.vhd'],'casper_filter_lib');
  this_block.addFileToLibrary([filepath '/../../casper_filter/fil_ppf_filter.vhd'],'casper_filter_lib');
  this_block.addFileToLibrary([filepath '/../../casper_filter/fil_ppf_single.vhd'],'casper_filter_lib');
  this_block.addFileToLibrary([filepath '/../../ip_xpm/mult/ip_mult_infer.vhd'],'ip_xpm_mult_lib');
  this_block.addFileToLibrary([filepath '/../../ip_xpm/ram/ip_xpm_ram_cr_cw.vhd'],'ip_xpm_ram_lib');
  this_block.addFileToLibrary([filepath '/../../ip_xpm/ram/ip_xpm_ram_crw_crw.vhd'],'ip_xpm_ram_lib');
  this_block.addFileToLibrary([filepath '/../../casper_filter/fil_ppf_wide.vhd'],'casper_filter_lib');
return;
end

% ------------------------------------------------------------

function setup_as_single_rate(block,clkname,cename) 
  inputRates = block.inputRates; 
  uniqueInputRates = unique(inputRates); 
  if (length(uniqueInputRates)==1 & uniqueInputRates(1)==Inf) 
    block.addError('The inputs to this block cannot all be constant.'); 
    return; 
  end 
  if (uniqueInputRates(end) == Inf) 
     hasConstantInput = true; 
     uniqueInputRates = uniqueInputRates(1:end-1); 
  end 
  if (length(uniqueInputRates) ~= 1) 
    block.addError('The inputs to this block must run at a single rate.'); 
    return; 
  end 
  theInputRate = uniqueInputRates(1); 
  for i = 1:block.numSimulinkOutports 
     block.outport(i).setRate(theInputRate); 
  end 
  block.addClkCEPair(clkname,cename,theInputRate); 
  return; 

% ------------------------------------------------------------
end
