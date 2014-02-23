/* Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Web Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(5CSXFC6D6F31) Path("/home/zhehao/programs/ez8/processor/output_files/") File("sockit_top.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(SOCVHPS) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
