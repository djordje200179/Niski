//synthesis translate_off

`include "uvm_macros.svh"
import uvm_pkg::*;

class counter_item extends uvm_sequence_item;
	rand bit en;

	bit [7:0] value;
	bit will_overflow;

	`uvm_object_utils_begin(counter_item)
		`uvm_field_int(en, UVM_DEFAULT | UVM_BIN)
		`uvm_field_int(value, UVM_NOPRINT)
		`uvm_field_int(will_overflow, UVM_NOPRINT)
	`uvm_object_utils_end
	
	function new(string name = "counter_item");
		super.new(name);
	endfunction
endclass

class counter_gen extends uvm_sequence;
	`uvm_object_utils(counter_gen)
	
	function new(string name = "counter_gen");
		super.new(name);
	endfunction
	
	localparam ITERATIONS = 20;
	
	virtual task body();
		for (int i = 0; i < ITERATIONS; i++) begin
			counter_item item = counter_item::type_id::create("item");
			start_item(item);
			item.randomize();

			`uvm_info("Generator", $sformatf("Item %0d/%0d created", i + 1, ITERATIONS), UVM_LOW)
			item.print();
			
			finish_item(item);
		end
	endtask
endclass

interface counter_if(input bit clk);
	logic rst;
	logic en;
	
	logic [7:0] value;
	logic will_overflow;
endinterface

class counter_drv extends uvm_driver#(counter_item);
	`uvm_component_utils(counter_drv)
	
	function new(string name = "counter_drv", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual counter_if vif;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if (!uvm_config_db#(virtual counter_if)::get(this, "", "counter_if", vif)) 
			`uvm_fatal("Driver", "No interface.")
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
	
		forever begin
			counter_item item;
			seq_item_port.get_next_item(item);
			
			`uvm_info("Driver", "", UVM_LOW)
			
			vif.en <= item.en;
			
			@(posedge vif.clk);
			
			seq_item_port.item_done();
		end
	endtask
endclass

class counter_mon extends uvm_monitor;
	`uvm_component_utils(counter_mon)

	function new(string name = "counter_mon", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual counter_if vif; 
	uvm_analysis_port#(counter_item) mon_analysis_port;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if (!uvm_config_db#(virtual counter_if)::get(this, "", "counter_if", vif)) 
			`uvm_fatal("Monitor", "No interface.")
		
		mon_analysis_port = new("mon_analysis_port", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		@(posedge vif.clk);
		
		forever begin
			counter_item item = counter_item::type_id::create("item");

			@(posedge vif.clk); 
			item.en = vif.en;
			item.value = vif.value; 
			item.will_overflow = vif.will_overflow;
			
			`uvm_info("Monitor", "", UVM_LOW)
			mon_analysis_port.write(item);
		end
	endtask
endclass

class counter_agent extends uvm_agent;
	`uvm_component_utils(counter_agent)

	function new(string name = "counter_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	counter_drv drv;
	counter_mon mon;
	
	uvm_sequencer#(counter_item) seq;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		drv = counter_drv::type_id::create("drv", this);
		mon = counter_mon::type_id::create("mon", this);
		seq = uvm_sequencer#(counter_item)::type_id::create("seq", this);
	endfunction
	
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		drv.seq_item_port.connect(seq.seq_item_export);
	endfunction
endclass

class counter_sb extends uvm_scoreboard;
	`uvm_component_utils(counter_sb)
	
	function new(string name = "counter_sb", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	uvm_analysis_imp#(counter_item, counter_sb) mon_analysis_imp;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		mon_analysis_imp = new("mon_analysis_imp", this);
	endfunction
	
	bit [7:0] counter = 8'h00;
	
	virtual function write(counter_item item);
		if (counter == item.value)
			`uvm_info("Scoreboard", $sformatf("PASS!"), UVM_LOW)
		else
			`uvm_error("Scoreboard", $sformatf("FAIL! expected = %8b, got = %8b", counter, item.value))
		
		if (item.en) 
			counter++;
	endfunction
endclass

class counter_env extends uvm_env;
	`uvm_component_utils(counter_env)
	
	function new(string name = "counter_env", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	counter_agent agent;
	counter_sb sb;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	
		agent = counter_agent::type_id::create("agent", this);
		sb = counter_sb::type_id::create("sb", this);
	endfunction
	
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		agent.mon.mon_analysis_port.connect(sb.mon_analysis_imp);
	endfunction
endclass

class counter_test extends uvm_test;
	`uvm_component_utils(counter_test)
	
	function new(string name = "counter_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual counter_if vif;
	counter_env env;
	counter_gen gen;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	
		if (!uvm_config_db#(virtual counter_if)::get(this, "", "counter_if", vif))
			`uvm_fatal("Test", "No interface.")
		
		env = counter_env::type_id::create("env", this);
		gen = counter_gen::type_id::create("gen");
	endfunction
	
	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		
		vif.rst <= 1;
		#20 vif.rst <= 0;
		
		gen.start(env.agent.seq);
		
		phase.drop_objection(this);
	endtask
endclass

module counter_tb;
	reg clk;

	counter_if dut_if (
		.clk(clk)
	);

	counter dut (
		.clk(clk),
		.rst(dut_if.rst),
		.en(dut_if.en),
		.value(dut_if.value),
		.will_overflow(dut_if.will_overflow)
	);

	initial begin
		clk = 0;

		forever
			#10 clk = ~clk;
	end

	initial begin
		uvm_config_db#(virtual counter_if)::set(
			null, "*", "counter_if", dut_if
		);

		run_test("counter_test");
	end
endmodule

//synthesis translate_on