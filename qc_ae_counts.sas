/**************************************************************************
Program:     qc_ae_counts.sas
Purpose:     QC Validation of AE Counts
Author:      Nithisha S
**************************************************************************/

libname adam "/home/u63998401/ADAM_DATA";

/* Independent count using PROC FREQ */
proc freq data=adam.adae noprint;
    where TRTEMFL = "Y";
    tables TRT01A*AEBODSYS / out=qc_freq;
run;

/* Compare with production summary */
proc compare base=ae_soc compare=qc_freq;
    id TRT01A AEBODSYS;
run;
