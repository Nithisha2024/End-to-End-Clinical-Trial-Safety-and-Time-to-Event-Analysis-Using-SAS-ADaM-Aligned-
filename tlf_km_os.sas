/**************************************************************************
Program:     tlf_km_os.sas
Purpose:     Kaplan–Meier Plot for Overall Survival
Study:       Simulated Phase II Oncology Study
Author:      Nithisha S
**************************************************************************/

/*-----------------------------------------------------------------------
Input Data:
  ADTTE - Time-to-Event Analysis Dataset
-----------------------------------------------------------------------*/

libname adam "/home/u63998401/ADAM_DATA";

/*-------------------------
Prepare Analysis Dataset
-------------------------*/
data kmdata;
    set adam.adtte;

    /* Use OS records only */
    where PARAMCD = "OS";

    /* Create event indicator for PROC LIFETEST */
    if CNSR = 0 then EVENT = 1;
    else EVENT = 0;

    label
        AVAL  = "Time to Event (Days)"
        EVENT = "Event Indicator (1=Event, 0=Censored)";
run;

/*-------------------------
Kaplan–Meier Analysis
-------------------------*/
ods graphics on;

proc lifetest data=kmdata plots=survival(cb=hw);
    time AVAL*EVENT(0);
    strata TRT01A;
    title "Kaplan–Meier Plot for Overall Survival";
run;

ods graphics off;
