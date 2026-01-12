/**************************************************************************
Program:     adae.sas
Purpose:     Create Adverse Events Analysis Dataset (ADAE)
Study:       Simulated Phase II Oncology Study
Author:      Nithisha S
**************************************************************************/

/*-----------------------------------------------------------------------
Input Data:
  AE    - Adverse Events (SDTM)
  ADSL  - Subject-Level Analysis Dataset

Output Data:
  ADAE  - Adverse Events Analysis Dataset
-----------------------------------------------------------------------*/

/*-------------------------
Read AE
-------------------------*/
libname sdtm xport "/home/u63998401/ADAM_DATA/AE.xpt";

data ae;
    set sdtm.ae;

    keep STUDYID USUBJID AEBODSYS AEDECOD AESEV AESER
         AESTDTC AEENDTC;
run;

proc sort data=ae;
    by USUBJID AESTDTC;
run;

/*-------------------------
Read ADSL
-------------------------*/
libname adam "/home/u63998401/ADAM_DATA";

proc sort data=adam.adsl out=adsl;
    by USUBJID;
run;

/*-------------------------
Merge AE with ADSL
-------------------------*/
data adae;
    merge ae (in=a)
          adsl (keep=USUBJID TRT01A TRT01AN TRTSDT SAFFL);
    by USUBJID;

    if a;

    /* Convert AE dates */
    length AESTDT AEENDT 8;
    format AESTDT AEENDT date9.;

    if AESTDTC ne "" then AESTDT = input(AESTDTC, is8601da.);
    if AEENDTC ne "" then AEENDT = input(AEENDTC, is8601da.);

    /* Treatment-Emergent Flag */
    length TRTEMFL $1;

    if SAFFL = "Y" and AESTDT >= TRTSDT then TRTEMFL = "Y";
    else TRTEMFL = "N";

    label
        AEBODSYS = "Body System or Organ Class"
        AEDECOD  = "Adverse Event Preferred Term"
        AESEV    = "Severity"
        AESER    = "Serious Event"
        AESTDT   = "AE Start Date"
        AEENDT   = "AE End Date"
        TRTEMFL  = "Treatment-Emergent AE Flag";
run;

/*-------------------------
QC Checks
-------------------------*/
title "QC: Treatment-Emergent Flag";
proc freq data=adae;
    tables TRTEMFL SAFFL / missing;
run;

title "QC: AE by Treatment Group";
proc freq data=adae;
    tables TRT01A*AEBODSYS / missing;
run;

title "QC: Sample Records";
proc print data=adae(obs=10);
    var USUBJID TRT01A AEBODSYS AEDECOD AESTDT TRTSDT TRTEMFL;
run;
