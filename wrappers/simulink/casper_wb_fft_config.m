function casper_wb_fft_config(this_block)

  % Revision History:
  %
  %   31-Aug-2020  (11:48 hours):
  %     Original code was machine generated by Xilinx's System Generator after parsing
  %     /home/talon/Documents/CASPERWORK/casper_dspdevel/wrappers/simulink/wideband_fft_top.vhd
  %
  % Get the path of this script
  filepath = fileparts(which('casper_wb_fft_config'));

  this_block.setTopLevelLanguage('VHDL');

  this_block.setEntityName('wideband_fft_top');
  wb_fft_blk = this_block.blockName;
  wb_fft_blk_parent = get_param(wb_fft_blk, 'Parent');
  
  %constant widths for 
  dp_stream_bsn = 64;
  bsn_data_type = sprintf('Fix_%d_0',dp_stream_bsn);
  dp_stream_empty = 16;
  empty_data_type = sprintf('Fix_%d_0',dp_stream_empty);
  dp_stream_channel = 32;
  channel_data_type = sprintf('Fix_%d_0',dp_stream_channel);
  dp_stream_error = 32;
  error_data_type = sprintf('Fix_%d_0',dp_stream_error);

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
  use_reorder = get_param(wb_fft_blk_parent,'use_reorder');
  use_fft_shift = get_param(wb_fft_blk_parent,'use_fft_shift');
  use_separate = get_param(wb_fft_blk_parent,'use_separate');
  wb_factor = get_param(wb_fft_blk_parent,'wb_factor');
  dbl_wb_factor = str2double(wb_factor);
  if dbl_wb_factor<1
       error("Cannot have wideband factor <1"); 
  end 
  nof_points = get_param(wb_fft_blk_parent,'nof_points');
  dbl_nof_points = 2^str2double(nof_points);
  nof_points = num2str(dbl_nof_points);
  i_d_w = get_param(wb_fft_blk_parent,'in_dat_w');
  in_data_type = sprintf('Fix_%s_0', i_d_w);
  o_d_w = get_param(wb_fft_blk_parent,'out_dat_w');
  out_data_type = sprintf('Fix_%s_0', o_d_w);
  o_g_w = get_param(wb_fft_blk_parent,'out_gain_w');
  s_d_w = get_param(wb_fft_blk_parent,'stage_dat_w');
  t_d_w = get_param(wb_fft_blk_parent,'twid_dat_w');
  double_t_d_w = str2double(t_d_w);
  max_addr_w = get_param(wb_fft_blk_parent,'max_addr_w');
  guard_w = get_param(wb_fft_blk_parent,'guard_w');
  guard_en = get_param(wb_fft_blk_parent,'guard_enable');
  variant = get_param(wb_fft_blk_parent,'use_variant');
  technology = get_param(wb_fft_blk_parent,'vendor_technology');
  use_dsp = get_param(wb_fft_blk_parent,'use_dsp');
  ovflw_behav = get_param(wb_fft_blk_parent,'ovflw_behav');
  use_round = get_param(wb_fft_blk_parent,'use_round');
  ram_primitive = get_param(wb_fft_blk_parent,'ram_primitive');
  fifo_primitive = get_param(wb_fft_blk_parent,'fifo_primitive');
  xtra_dat_sigs = checkbox2bool(get_param(wb_fft_blk_parent,'xtra_dat_sigs'));
  use_reorder = checkbox2bool(use_reorder);
  use_fft_shift = checkbox2bool(use_fft_shift);
  use_separate = checkbox2bool(use_separate);
  guard_en = checkbox2bool(guard_en);
  
  function stages = stagecalc(nof_points)
    stages = ceil(log2(nof_points));
  end
  num_stages = stagecalc(dbl_nof_points);
  ovflwshiftreg_type = sprintf('Ufix_%d_0',num_stages);

  technology_int = 0;
  if strcmp(technology, 'Xilinx')
    technology_int = 0;
  end % if technology Xilinx
  if strcmp(technology, 'UniBoard')
    technology_int = 1;
  end % if technology UniBoard

  %Update the vhdl top file with the required ports per wb_factor:
  vhdlfile = top_wb_fft_code_gen(dbl_wb_factor,dbl_nof_points,double_t_d_w, technology_int, xtra_dat_sigs,str2double(i_d_w),str2double(o_d_w),str2double(s_d_w));

%inport declarations
this_block.addSimulinkInport('rst');
in_rst_port = this_block.port('rst');
in_rst_port.setType('Ufix_1_0');
in_rst_port.useHDLVector(false);
this_block.addSimulinkInport('in_sync');
in_sync_port = this_block.port('in_sync');
in_sync_port.setType('Ufix_1_0');
in_sync_port.useHDLVector(false);
this_block.addSimulinkInport('in_valid');
in_valid_port = this_block.port('in_valid');
in_valid_port.setType('Ufix_1_0');
in_valid_port.useHDLVector(false);
this_block.addSimulinkInport('in_shiftreg');
in_shiftreg_port = this_block.port('in_shiftreg');
in_shiftreg_port.setType(ovflwshiftreg_type);

  %If a simple interface is required by the user, hide these other signals
  if xtra_dat_sigs
  %extra signals inport declarations 
  this_block.addSimulinkInport('in_bsn');
  in_bsn_port = this_block.port('in_bsn');
  in_bsn_port.setType(bsn_data_type);

  this_block.addSimulinkInport('in_sop');
  in_sop_port = this_block.port('in_sop');
  in_sop_port.setType('Ufix_1_0');
  in_sop_port.useHDLVector(false);
  
  this_block.addSimulinkInport('in_eop');
  in_eop_port = this_block.port('in_eop');
  in_eop_port.setType('Ufix_1_0');
  in_eop_port.useHDLVector(false);
  
  this_block.addSimulinkInport('in_empty');
  in_empty_port = this_block.port('in_empty');
  in_empty_port.setType(empty_data_type);
  
  this_block.addSimulinkInport('in_err');
  in_err_port = this_block.port('in_err');
  in_err_port.setType(error_data_type);
  
  this_block.addSimulinkInport('in_channel');
  in_channel_port = this_block.port('in_channel');
  in_channel_port.setType(channel_data_type);
  end
  
  %Dynamically add in im, re per wb_factor:
  for i=0:dbl_wb_factor-1
      in_im_port = sprintf('in_im_%d',i);
      this_block.addSimulinkInport(in_im_port);
      in_im = this_block.port(in_im_port);
      in_im.setType(in_data_type);
  
      in_re_port = sprintf('in_re_%d',i);
      this_block.addSimulinkInport(in_re_port);
      in_re = this_block.port(in_re_port);
      in_re.setType(in_data_type);
  end
  
  this_block.addSimulinkOutport('out_sync');
  out_sync_port = this_block.port('out_sync');
  out_sync_port.setType('Ufix_1_0');
  out_sync_port.useHDLVector(false);
  
  this_block.addSimulinkOutport('out_valid');
  out_valid_port = this_block.port('out_valid');
  out_valid_port.setType('Ufix_1_0');
  out_valid_port.useHDLVector(false);
  
  this_block.addSimulinkOutport('out_ovflw');
  out_ovflw_port = this_block.port('out_ovflw');
  out_ovflw_port.setType(ovflwshiftreg_type);

  if xtra_dat_sigs
    this_block.addSimulinkOutport('out_bsn');
    out_bsn_port = this_block.port('out_bsn');
    out_bsn_port.setType(bsn_data_type);
    
    this_block.addSimulinkOutport('out_sop');
    out_sop_port = this_block.port('out_sop');
    out_sop_port.setType('Ufix_1_0');
    out_sop_port.useHDLVector(false);
    
    this_block.addSimulinkOutport('out_eop');
    out_eop_port = this_block.port('out_eop');
    out_eop_port.setType('Ufix_1_0');
    out_eop_port.useHDLVector(false);
    
    this_block.addSimulinkOutport('out_empty');
    out_empty_port = this_block.port('out_empty');
    out_empty_port.setType(empty_data_type);
    
    this_block.addSimulinkOutport('out_err');
    out_err_port = this_block.port('out_err');
    out_err_port.setType(error_data_type);
    
    this_block.addSimulinkOutport('out_channel');
    out_channel_port = this_block.port('out_channel');
    out_channel_port.setType(channel_data_type);
  end

  %Dynamically add out im, re per wb_factor:
  for i=0:dbl_wb_factor-1
    out_im_port = sprintf('out_im_%d',i);
    this_block.addSimulinkOutport(out_im_port);
    out_im = this_block.port(out_im_port);
    out_im.setType(out_data_type);
    
    out_re_port = sprintf('out_re_%d',i);
    this_block.addSimulinkOutport(out_re_port);
    out_re = this_block.port(out_re_port);
    out_re.setType(out_data_type);
  end

  % -----------------------------
   if (this_block.inputRatesKnown)
     setup_as_single_rate(this_block,'clk','ce')
   end  % if(inputRatesKnown)
  % -----------------------------
    
  %      Add generics to blackbox (this_block)
  %      The addGeneric function takes  3 parameters, generic name, type and constant value.
  %      Supported types are boolean, real, integer and string.
  this_block.addGeneric('use_reorder','boolean',bool2str(use_reorder));
  this_block.addGeneric('use_fft_shift','boolean',bool2str(use_fft_shift));
  this_block.addGeneric('use_separate','boolean',bool2str(use_separate));
  this_block.addGeneric('wb_factor','natural',wb_factor);
  this_block.addGeneric('nof_points','natural',nof_points);
  this_block.addGeneric('in_dat_w','natural',i_d_w);
  this_block.addGeneric('out_dat_w','natural',o_d_w);
  this_block.addGeneric('out_gain_w','natural',o_g_w);
  this_block.addGeneric('stage_dat_w','natural',s_d_w);
  this_block.addGeneric('twiddle_dat_w','natural',t_d_w);
  this_block.addGeneric('max_addr_w','natural',max_addr_w);
  this_block.addGeneric('guard_w','natural',guard_w);
  this_block.addGeneric('guard_enable','boolean',bool2str(guard_en));
  this_block.addGeneric('use_variant','String',variant);
  this_block.addGeneric('use_dsp','String',use_dsp);
  this_block.addGeneric('ovflw_behav','String',ovflw_behav);
  this_block.addGeneric('use_round','String',use_round);
  this_block.addGeneric('ram_primitive','String',ram_primitive);
  this_block.addGeneric('fifo_primitive','String',fifo_primitive);
  

  % Add addtional source files as needed.
  %  |-------------
  %  | Add files in the order in which they should be compiled.
  %  | If two files "a.vhd" and "b.vhd" contain the entities
  %  | entity_a and entity_b, and entity_a contains a
  %  | component of type entity_b, the correct sequence of
  %  | addFile() calls would be:
  %  |    this_block.addFile('b.vhd');
  %  |    this_block.addFile('a.vhd');
  %  |-------------

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

this_block.addFileToLibrary(vhdlfile,'xil_defaultlib');
this_block.addFileToLibrary([filepath '/../../common_pkg/common_pkg.vhd'],'common_pkg_lib');
this_block.addFileToLibrary([filepath '/../../common_components/common_pipeline.vhd'],'common_components_lib');
this_block.addFileToLibrary([filepath '/../../casper_adder/common_add_sub.vhd'],'casper_adder_lib');
this_block.addFileToLibrary([filepath '/../../common_components/common_async.vhd'],'common_components_lib');
this_block.addFileToLibrary([filepath '/../../common_components/common_areset.vhd'],'common_components_lib');
this_block.addFileToLibrary([filepath '/../../common_components/common_bit_delay.vhd'],'common_components_lib');
this_block.addFileToLibrary([filepath '/../../common_components/common_pipeline_sl.vhd'],'common_components_lib');
this_block.addFileToLibrary([filepath '/../../casper_multiplier/tech_mult_component.vhd'],'casper_multiplier_lib');
this_block.addFileToLibrary([srcloc '/technology_select_pkg.vhd'],'technology_lib');
this_block.addFileToLibrary([filepath '/../../casper_multiplier/tech_complex_mult.vhd'],'casper_multiplier_lib');
this_block.addFileToLibrary([filepath '/../../casper_multiplier/common_complex_mult.vhd'],'casper_multiplier_lib');
this_block.addFileToLibrary([filepath '/../../casper_counter/common_counter.vhd'],'casper_counter_lib');
this_block.addFileToLibrary([filepath '/../../common_components/common_delay.vhd'],'common_components_lib');
this_block.addFileToLibrary([filepath '/../../casper_fifo/common_rl_decrease.vhd'],'casper_fifo_lib');
this_block.addFileToLibrary([filepath '/../../casper_fifo/common_fifo_rd.vhd'],'casper_fifo_lib');
this_block.addFileToLibrary([filepath '/../../casper_fifo/tech_fifo_component_pkg.vhd'],'casper_fifo_lib');
this_block.addFileToLibrary([filepath '/../../casper_fifo/tech_fifo_sc.vhd'],'casper_fifo_lib');
this_block.addFileToLibrary([filepath '/../../casper_fifo/common_fifo_sc.vhd'],'casper_fifo_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/common_ram_pkg.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_component_pkg.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_ram_crw_crw.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_ram_cr_cw.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/common_ram_crw_crw.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/common_paged_ram_crw_crw.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/common_paged_ram_rw_rw.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/common_paged_ram_r_w.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_requantize/common_round.vhd'],'casper_requantize_lib');
this_block.addFileToLibrary([filepath '/../../casper_requantize/common_resize.vhd'],'casper_requantize_lib');
this_block.addFileToLibrary([filepath '/../../casper_requantize/common_requantize.vhd'],'casper_requantize_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_rom_r_r.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/tech_memory_rom_r.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../casper_ram/common_rom_r_r.vhd'],'casper_ram_lib');
this_block.addFileToLibrary([filepath '/../../common_pkg/common_str_pkg.vhd'],'common_pkg_lib');
this_block.addFileToLibrary([filepath '/../../casper_multiplexer/common_zip.vhd'],'casper_multiplexer_lib');
this_block.addFileToLibrary([srcloc   '/fft_gnrcs_intrfcs_pkg.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([srcloc   '/twiddlesPkg.vhd'],'r2sdf_fft_lib');
this_block.addFileToLibrary([srcloc   '/rTwoSDFPkg.vhd'],'r2sdf_fft_lib');
this_block.addFileToLibrary([filepath '/../../r2sdf_fft/rTwoBF.vhd'],'r2sdf_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_requantize/r_shift_requantize.vhd'],'casper_requantize_lib');
this_block.addFileToLibrary([filepath '/../../r2sdf_fft/rTwoWMul.vhd'],'r2sdf_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_r2_bf_par.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_r2_par.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../r2sdf_fft/rTwoBFStage.vhd'],'r2sdf_fft_lib');
this_block.addFileToLibrary([filepath '/../../r2sdf_fft/rTwoWeights.vhd'],'r2sdf_fft_lib');
this_block.addFileToLibrary([filepath '/../../r2sdf_fft/rTwoSDFStage.vhd'],'r2sdf_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_sepa.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_reorder_sepa_pipe.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_r2_pipe.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_sepa_wide.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_r2_wide.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_wide_unit_control.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../casper_wb_fft/fft_wide_unit.vhd'],'casper_wb_fft_lib');
this_block.addFileToLibrary([filepath '/../../ip_xpm/mult/ip_cmult_rtl_3dsp.vhd'],'ip_xpm_mult_lib');
this_block.addFileToLibrary([filepath '/../../ip_xpm/mult/ip_cmult_rtl_4dsp.vhd'],'ip_xpm_mult_lib');
this_block.addFileToLibrary([filepath '/../../ip_xpm/fifo/ip_xilinx_fifo_sc.vhd'],'ip_xpm_fifo_lib');
this_block.addFileToLibrary([filepath '/../../ip_xpm/ram/ip_xpm_ram_cr_cw.vhd'],'ip_xpm_ram_lib');
this_block.addFileToLibrary([filepath '/../../ip_xpm/ram/ip_xpm_ram_crw_crw.vhd'],'ip_xpm_ram_lib');
this_block.addFileToLibrary([filepath '/../../ip_xpm/ram/ip_xpm_rom_r.vhd'],'ip_xpm_ram_lib');
this_block.addFileToLibrary([filepath '/../../ip_xpm/ram/ip_xpm_rom_r_r.vhd'],'ip_xpm_ram_lib');
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