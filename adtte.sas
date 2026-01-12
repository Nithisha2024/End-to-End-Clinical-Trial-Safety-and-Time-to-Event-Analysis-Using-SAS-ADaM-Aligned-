/**************************************************************************
Program:     adtte.sas
Purpose:     Create Time-to-Event Analysis Dataset (ADTTE)
Study:       Simulated Phase II Oncology Study
Endpoint:    Overall Survival (OS)
Author:      Nithisha S
**************************************************************************/

/*-----------------------------------------------------------------------
Input Data:
  ADSL - Subject-Level Analysis Dataset
  DS   - Disposition (Death / Follow-up)
Output Data:
  ADTTE - Time-to-Event Analysis Dataset
-----------------------------------------------------------------------*/

/*-------------------------
Read ADSL
-------------------------*/
libname adam "/home/u63998401/ADAM_DATA";

proc sort data=adam.adsl out=adsl;
    by USUBJID;
run;

/*-------------------------
Read Death Information from DS
-------------------------*/
libname sdtm xport "/home/u63998401/ADAM_DATA/DS.xpt";

data death;
    set sdtm.ds;

    /* Keep death records only */
    if upcase(DSDECOD) = "DEATH";

    keep USUBJID DSDTC;
run;

proc sort data=death;
    by USUBJID;
run;

/*-------------------------
Merge ADSL with Death Info
-------------------------*/
data adtte;
    merge adsl (in=a keep=USUBJID TRT01A TRT01AN RANDDT)
          death (in=b);
    by USUBJID;

    if a;

    length PARAMCD PARAM $20;
    PARAMCD = "OS";
    PARAM   = "Overall Survival";

    /* Event Date */
    length ADT 8;
    format ADT date9.;

    if b and DSDTC ne "" then ADT = input(DSDTC, is8601da.);

    /* Censoring Logic */
    length CNSR 8;

    if ADT ne . then CNSR = 0;  /* Event */
    else CNSR = 1;              /* Censored */

    /* Analysis Value: Time from Randomization */
    length AVAL 8;

    if CNSR = 0 then AVAL = ADT - RANDDT + 1;
    else if CNSR = 1 then AVAL = .;  /* No follow-up date assumed */

    label
        PARAMCD = "Parameter Code"
        PARAM   = "Parameter Description"
        ADT     = "Event Date"
        CNSR    = "Censoring Indicator (0=Event, 1=Censored)"
        AVAL    = "Analysis Value (Days)";
run;

/*-------------------------
QC Checks
-------------------------*/
title "QC: Event vs Censoring";
proc freq data=adtte;
    tables CNSR / missing;
run;

title "QC: Time-to-Event Summary";
proc means data=adtte n mean min max;
    var AVAL;
run;

title "QC: Sample Records";
proc print data=adtte(obs=10);
    var USUBJID TRT01A RANDDT ADT CNSR AVAL;
run;
