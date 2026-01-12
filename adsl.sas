/**************************************************************************
Program:     adsl.sas
Purpose:     Create Subject-Level Analysis Dataset (ADSL)
Study:       Simulated Phase II Oncology Study
Author:      Nithisha S
**************************************************************************/

/*-----------------------------------------------------------------------
Input Data:
  DM  - Demographics
  EX  - Exposure

Output Data:
  ADSL - Subject-Level Analysis Dataset
-----------------------------------------------------------------------*/

/*-------------------------
Read Demographics (DM)
-------------------------*/
libname sdtm xport "/home/u63998401/ADAM_DATA/DM.xpt";

data dm;
    set sdtm.dm;

    keep STUDYID USUBJID AGE SEX RACE RANDDT ARM ARMCD;

    /* Derive Age Groups */
    length AGEGR1 $8 AGEGR1N 8;

    if 18 <= AGE < 41 then do;
        AGEGR1  = "18-40";
        AGEGR1N = 1;
    end;
    else if 41 <= AGE < 65 then do;
        AGEGR1  = "41-64";
        AGEGR1N = 2;
    end;
    else if AGE >= 65 then do;
        AGEGR1  = "65+";
        AGEGR1N = 3;
    end;
run;

proc sort data=dm;
    by USUBJID;
run;

/*-------------------------
Read Exposure (EX)
-------------------------*/
libname sdtm xport "/home/u63998401/ADAM_DATA/EX.xpt";

proc sort data=sdtm.ex out=ex;
    by USUBJID EXSTDTC;
run;

/*-------------------------
Derive Treatment Variables
-------------------------*/
data trt;
    set ex;
    by USUBJID;

    length TRT01P TRT01A $10 TRT01PN TRT01AN 8;
    format TRTSDT TRTEDT date9.;

    if first.USUBJID then do;

        /* Planned & Actual Treatment */
        if upcase(strip(EXTRT)) = "CMP-135" then do;
            TRT01P  = "CMP-135";
            TRT01PN = 1;
            TRT01A  = "CMP-135";
            TRT01AN = 1;
        end;
        else if upcase(strip(EXTRT)) = "PLACEBO" then do;
            TRT01P  = "Placebo";
            TRT01PN = 0;
            TRT01A  = "Placebo";
            TRT01AN = 0;
        end;

        /* First Treatment Date */
        if EXSTDTC ne "" then TRTSDT = input(EXSTDTC, is8601da.);
    end;

    /* Last Treatment Date */
    if EXENDTC ne "" then TRTEDT = input(EXENDTC, is8601da.);

    retain TRTSDT;
run;

/*-------------------------
Create ADSL
-------------------------*/
data adsl;
    merge dm (in=a)
          trt;
    by USUBJID;

    if a;

    /* Population Flags */
    length ITTFL SAFFL EFFFL $1;

    /* ITT: Randomized */
    if RANDDT ne . then ITTFL = "Y";
    else ITTFL = "N";

    /* Safety: Received Treatment */
    if TRTSDT ne . then SAFFL = "Y";
    else SAFFL = "N";

    /* Efficacy: ITT + Safety */
    if ITTFL = "Y" and SAFFL = "Y" then EFFFL = "Y";
    else EFFFL = "N";

    label
        AGEGR1  = "Age Group"
        AGEGR1N = "Age Group (Numeric)"
        TRT01P  = "Planned Treatment"
        TRT01PN = "Planned Treatment (Numeric)"
        TRT01A  = "Actual Treatment"
        TRT01AN = "Actual Treatment (Numeric)"
        RANDDT  = "Randomization Date"
        TRTSDT  = "First Treatment Date"
        TRTEDT  = "Last Treatment Date"
        ITTFL   = "Intent-to-Treat Population Flag"
        SAFFL   = "Safety Population Flag"
        EFFFL   = "Efficacy Population Flag";
run;

/*-------------------------
QC Checks
-------------------------*/
title "QC: Population Flags";
proc freq data=adsl;
    tables ITTFL SAFFL EFFFL / missing;
run;

title "QC: Treatment Assignment";
proc freq data=adsl;
    tables TRT01P*TRT01A / missing;
run;

title "QC: Key Dates";
proc print data=adsl(obs=10);
    var USUBJID RANDDT TRTSDT TRTEDT;
run;
