* recreating tables

*See log files: exp_simple_resultsE_runs1-3_update_to_1to6_cut and newtestsB.log for precursors

use run1_6_data_xtA

*Figures 2-3
. *FIRST WAVE
. sort stage
. graph twoway scatter m_sa_ m_cr_ m_mrc_ stage if newid==343, xlabel(1 2 3 4 5 6) xscale(range(0.5 6.5)) title("Wave 1, mean gifts by treatment stage")
>  msymbol(O D T S X) mcolor(red orange gs5) || line m_tot_ stage if newid==343, lcolor(black)
. graph export "C:\Docs\expgraphs/firstwave_means.png", replace

. 
. *SECOND WAVE
. sort A_stage
. graph twoway scatter mA_sa_ mA_cr_ mA_mrc_ mA_un_ mA_tnc_ A_stage if newid==401, xscale(range(.75 13.25)) xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13) 
. graph twoway scatter mA_sa_ mA_cr_ mA_mrc_ mA_un_ mA_tnc_ A_stage if newid==401, xscale(range(.75 13.25)) xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13) msymbo
> l(O D T S X) title("Wave 2, mean gifts by treatment stage") mcolor(red orange gs5 green blue) || line mA_tot_ A_stage, lcolor(black)

. graph export "C:\Docs\expgraphs/secondwave_Ameans.png", replace

. *graph export 
. graph dot (mean) cr_ sa_ mrc_ tnc_ un_, over(A_stage) linetype(dot)
. graph twoway scatter mrA_sa_ mrA_cr_ mrA_mrc_ mrA_un_ mrA_tnc_ A_stage if newid==401, xscale(range(.75 13.25)) xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13) m
> symbol(O D T S X) mcolor(red orange gs5 green blue) || line mA_tot_ A_stage if newid==401, lcolor(black)
. graph export "C:\Docs\expgraphs/secondwave_run4means.png", replace



*Table 4 
*do this by wave:
summ sa_1 Gsa_1 mrc_2 Gmrc_2 cr_3 Gcr_3 tot_4 Gtot_4 sa_4 Gsa_4 mrc_4 Gmrc_4 cr_4 Gcr_4 tot_5 Gtot_5 sa_5 Gsa_5 mrc_5 Gmrc_5 cr_5 Gcr_5 tot_6 Gtot_6 sa_6 Gsa_6 mrc_6 Gmrc_6 cr_6 Gcr_6 totgiftd6 gave_ever if conditio==1


use run1_6_data_xtA, clear	
* Table  5 (categories)

. *0. Non-givers and occasional responders to shocks (i.e, gave <25% of the time)
. egen G1tot_ = rmax(Gtotsa_ Gtotmrc_ Gtotcr_) if wave==1
. replace Gtot_ = G1tot if wave==1
. drop G1tot_
. egen Gtotpct = mean(Gtot_), by(newid)
. 
. gen shocky = Gtotpct<(1/4)
. label variable shocky "Gave < 25% of the time"
. 
. *1. Those with a (relatively) 'fixed purse'
. egen sdtot = sd(tot_), by(newid)
. *Define: where std deviation of total gift less than 25% of average total gift
. gen fixypurse = (sdtot < avgift*.25)
. label variable fixypurse "Relatively fixed purse (s.d.<25%), frequent giver"

. *2. Flexible purse, some crowd-out
. *the default category 
. gen flexpurse =1

. *3. "Kantian": no crowd-out unless similar charity 
. gen kantian = (count_subst_un_cr>0 & count_subst_un_cr~=.)*(count_subst_tnc_cr==0)*(count_Dsubst_cms_==0)
. label variable kantian "Crowd-out similar charities only"
. *4. No crowd-out -- i.e., never lowered their gift to a charity (where charity available), and raised gift to another
. *but gave positive gifts to more than one charity 
. gen nocrowd = (count_subst_==0)
. label variable nocrowd "No substitutions, multiple charities, frequent giver"
. label variable count_subst_ "Number of substitution periods"
. label variable count_comp_ "Number of complement periods"
. *5. gave to one charity only
. gen onechar = numchars==1
. label variable onechar "Only gave to 1 cause"
. *Fix flexible purse
. replace flexpurse = (1-shocky)*(1-fixypurse)*(1-kantian)*(1-nocrowd)*(1-onechar)

. label variable flexpurse "Flexible purse, multiple charities, frequent giver"

. gen subsnocomp = (count_subst_>0)*(count_comp_==0)
. gen compnosubs= (count_subst_==0)*(count_comp_>0)
. 
. for var nocrowd fixypurse : replace X = X*(1-onechar)
. for var nocrowd : replace X = X*(1-shocky)

. sutex fixypurse flexpurse shocky nocrowd onechar count_subst_  count_comp_ if stage==4 & wave==2, digits(2) title("Types of behavior, 2nd wave") label
>  file("C:/Docs/exptables/types.tex") replace

*table 6
use "C:\Documents and Settings\david reinstein\My Documents\My Dropbox\Givingexperiments\substitution experiment stata code\second wave\run1_6_data_xtA.dta", clear
*uses bDsa variables 

*table 7
*Lou: log results do not match paper results,log results can be replicated. First,second,third [columns?] matches paper results,fourth command error on TNC choice (Dchar3) of one extra zero, last one does not match at all. 

*DR: lou, what log are you talking about?

* col 2 -- *could add clustering: xtreg lgift_ othershocked stage Dobsdknown  lprc Dchar3 Dchar4  if ( Dchar2+Dchar3+Dchar4>0) &((stage>3 & run<4) | (run>3)), re vce(cluster newid) 
*similar, ... significance of 'othershocked' lower but still significant at 5%

use "C:\Documents and Settings\david reinstein\My Documents\My Dropbox\Givingexperiments\substitution experiment stata code\second wave\run1_6_data_charity_level.dta", clear
xtreg gift_ shocked othershocked stage Dobsdknown Dchar3 Dchar4  if ( Dchar2+Dchar3+Dchar4>0) &((stage>3 & run<4) | (run>3)), re
xtreg lgift_ othershocked stage Dobsdknown  lprc Dchar3 Dchar4  if ( Dchar2+Dchar3+Dchar4>0) &((stage>3 & run<4) | (run>3)), re
xtpoisson gift_ othershocked stage Dobsdknown  lprc Dchar3 Dchar4  if ( Dchar2+Dchar3+Dchar4>0) &((stage>3 & run<4) | (run>3)), re

*col 4
*Was: xtreg lgift_ stage Dobsdknown  lprc  prccr_other  lprccr_other   lprcmrc_other  lprcsa_other  un_prcshock un_prcshock_onCR un_ch un_ch_onCR Dchar3 Dchar4  if ( Dchar2+Dchar3+Dchar4>0) &((stage>3 & run<4) | (run>3)), re
*Should be:
xtreg lgift_ stage Dobsdknown  lprc  prccr_other  lprccr_other   lprcmrc_other  lprcsa_other  un_prcshock  un_prcshock_onCR un_ch un_ch_onCR tnc_ch Dchar3 Dchar4  if ( Dchar2+Dchar3+Dchar4>0) &((stage>3 & run<4)  | (run>3)), re

*col 5:  (added "tnc_ch")
xtpoisson gift_ stage Dobsdknown  lprc  prccr_other  lprccr_other   lprcmrc_other  lprcsa_other  un_prcshock un_prcshock_onCR un_ch un_ch_onCR tnc_ch Dchar3 Dchar4  if ( Dchar2+Dchar3+Dchar4>0) &((stage>3 & run<4) | (run>3)), re

*table 8
*Lou: Do before to recreate variables missing, table 22 to gen gifttot_oth, results do not match what is in the paper
*egen notcr_ = rsum(sa_ mrc_ tnc_ un_) ... 

*DR: this was not what generated this table:
*xtivreg gift_ gifttot_oth notcr_ stage Dobsdknown (cr_=prccr_other  un_ch tnc_ch) if wave==2, fe
*ivtobit gift_ gifttot_oth notcr_ stage Dobsdknown (cr_=prccr_other  un_ch tnc_ch) if wave==2, fe

*DR: I think it must have been (working on this)

recode prcun_other   .=0
recode prctnc_other   .=0

xtivreg gift_ stage Dobsdknown Dchar3 Dchar4 (gifttot_oth=prcmrc_other prcsa_other prccr_other   prcun_other  un_ch tnc_ch) if wave==2 & ( Dchar2+Dchar3+Dchar4>0), fe
*-- this comes very close, right number observations, but first coefficients is  not exact (rounding error?)

ivtobit gift_ stage Dobsdknown Dchar3 Dchar4 (gifttot_oth=prcmrc_other prcsa_other prccr_other   prcun_other  un_ch tnc_ch) if wave==2 & ( Dchar2+Dchar3+Dchar4>0), ll(0) ul(20)
*this is exactly as in table. Note the upper limit does not matter here as no one hits it.

Table 9
*Lou: Results do not match
use "run1_6_data_charity_level.dta"
gen stage5 = 0
replace stage5 = 1 if stage == 5
xtreg gift_ Dchar3 Dchar4 lprc lprcsa lprcmrc lprccr lprcsa stage stage5 Dobsdknown if (wave==2), fe


*DR: trying...
xtpoisson gift_ Dchar3 Dchar4 lprc lprccr_other   lprcmrc_other  lprcsa_other  stage stage5 Dobsdknown if (wave==2) & (Dchar2+Dchar3+Dchar4>0), fe 

*--this replicates it


* revise "xtreg lcr_ lprcsa lprcmrc lprccr un_prcshock un_ch tnc_ch stage stage5 Dobsdknown if (wave==2), fe "
*DR -- Lou, what is this??

Appendix, tables 10-17
see "exp_simple_resultsE_runs1-3_update_to_1to6A"

Appendix, figure 4-7 (particular subjects)
. graph twoway line meantot_runstage stage if newid==402 || line  meantot_runstage stage if newid==502 || line meantot_runstage stage if newid==602
. graph export "C:/Docs/expgraphs/meantot_by_runstage_line.png", replace

Appendix, figure 8
. insheet using "c:/data/experiment/secondsforhist.csv"
. graph twoway histogram secforh, bin(25) freq xlabel(0 5 to 95, valuelabel) ylabel(0 2 to 14, valuelabel) title("stage 1-3 response times in seconds") 
> saving(responsetime1_3, replace)

Appendix, tables 18-21
for any ${survarsA}: tab X \ latab X, dec(2) tf("C:\Docs\exptables/survey_tab") replace 
...etc.

Appendix table 22 "descriptive regressions"

use "C:\Documents and Settings\david reinstein\My Documents\My Dropbox\Givingexperiments\substitution experiment stata code\second wave\run1_6_data_charity_level.dta", clear
gen cmsgift = (charity=="cms")*gift_
egen giftcms = max(cmsgift), by(newid stage)
gen totgiftst = (charity=="tot")*gift_
egen gifttot = max(totgiftst), by(newid stage)
gen gifttot_oth = gifttot-gift_

gen giftcms_oth = giftcms-gift_ if  ( Dchar2+Dchar3+Dchar4>0)

xtrc gift_ gifttot_oth Dchar3 Dchar4 stage Dobsdknown if ( Dchar2+Dchar3+Dchar4>0)  & ((stage>3  & run<4 ) | (run>3)),fe
xtrc gift_ gifttot_oth Dchar3 Dchar4 stage Dobsdknown if (Dchar2+Dchar3+Dchar4>0)  & (wave==1)
*...etc

*table 24
*Lou: in [] shows variables that I can not identify from datasets

*DR: This replicates it:
xi: xtpoisson gift_ Dchar3 Dchar4 lprc i.gaveout|lprc lprccr_other   lprcmrc_other  lprcsa_other  un_ch un_prcshock tnc_ch stage Dobsdknown if ( wave == 2) & (Dchar2+Dchar3+Dchar4>0) , re

*(DR) New -- adding "gaveout" as a dummy:
xi: xtpoisson gift_ Dchar3 Dchar4  i.gaveout*lprc lprccr_other   lprcmrc_other  lprcsa_other  un_ch un_prcshock tnc_ch stage Dobsdknown if ( wave == 2) & (Dchar2+Dchar3+Dchar4>0) , re
*...results are similar, gaveout dummy positive but not significant. 

*table 25
*Lou: results do not match again, not sure how to limit to subset, sex 1 or 2 is female and etc.
*DR: Lou -- you should try to be a detective for these things. E.g., note if you do "tab sex" you get it labeled. tab sex, sum(sex) lets you see the numbers and labels -- 1=male, 2=female.
*DR: Lou, Can you try again to recreate/replicate this table, considering how I fixed the tables above? 

*Lou: I have gather commands for table 25 that would  reproduce same results as in the paper.
*There are several issues: in the table , columns 2 and 4 it is reported that you use *log(gift+0.1) transformation but results match only using gift as the dependent variable. 

*DR: I think it should just be 'gift' in each case and not "lgift." Does that match the tables results? I think the labels were off -- I should use 

xtpoisson gift_ Dchar3 Dchar4  lprc othershocked stage movie Dobsd Dobsdknown Dobsdopsex,re

*table 26
*Lou: Results do not match with paper results
gen lprcWave1 = 0
replace lprcWave1 = lprc*wave if wave == 1
gen gifttot_othWave1 = 0
replace gifttot_othWave1 = gifttot_oth*wave if wave == 1

*DR: this replicates it:
xtpoisson gift_ lprc lprcWave1 Dchar3 Dchar4 lprccr_other   lprcmrc_other  lprcsa_other   un_ch un_prcshock tnc_ch stage Dobsdknown if (Dchar2+Dchar3+Dchar4>0)  ,re
