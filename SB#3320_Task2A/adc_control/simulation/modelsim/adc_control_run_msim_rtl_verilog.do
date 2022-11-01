transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Ashish\ Rathore/Downloads/adc_control {C:/Users/Ashish Rathore/Downloads/adc_control/adc_control.v}

vlog -vlog01compat -work work +incdir+C:/Users/Ashish\ Rathore/Downloads/adc_control/simulation/modelsim {C:/Users/Ashish Rathore/Downloads/adc_control/simulation/modelsim/adc_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  adc_tb

add wave *
view structure
view signals
run 20000 ns
