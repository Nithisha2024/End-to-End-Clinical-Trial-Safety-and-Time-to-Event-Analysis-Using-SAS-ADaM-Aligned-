/**************************************************************************
Program:     tlf_ae_summary.sas
Purpose:     Treatment-Emergent AE Summary by SOC and PT
Author:      Nithisha S
**************************************************************************/

libname adam "/home/u63998401/ADAM_DATA";

/*-------------------------
Filter Treatment-Emergent AEs
-------------------------*/
data ae_te;
    set adam.adae;
    where TRTEMFL = "Y";
run;

/*-------------------------
SOC-Level Summary
-------------------------*/
proc sql;
    create table ae_soc as
    select TRT01A,
           AEBODSYS,
           count(distinct USUBJID) as N
    from ae_te
    group by TRT01A, AEBODSYS;
quit;

/*-------------------------
PT-Level Summary
-------------------------*/
proc sql;
    create table ae_pt as
    select TRT01A,
           AEBODSYS,
           AEDECOD,
           count(distinct USUBJID) as N
    from ae_te
    group by TRT01A, AEBODSYS, AEDECOD;
quit;

/*-------------------------
Display Table
-------------------------*/
title "Summary of Treatment-Emergent Adverse Events";

proc print data=ae_pt noobs;
    var TRT01A AEBODSYS AEDECOD N;
run;
