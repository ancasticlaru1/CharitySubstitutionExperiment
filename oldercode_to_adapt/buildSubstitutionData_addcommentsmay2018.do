*buildSubstitutionData.do
*Inputs, merges, and cleans data from Omnibus+employability survey (Focus on students perhaps, as nonstudents might be showing selective attrition)
*? Also from piggyback on Ramon+Brit?

    * SET PATH
* I will set a path right now
    clear

    capture cd $HOME
    capture cd "Google Drive/substitution_experiment_is_back/2016 retooling for mass experiment/similaritysurveydata/rawdata/forgerhard"

    global PGRAW "/home/gerhard/gerhard.riener@gmail.com/substitution_experiment_is_back/Build/Data"
    capture cd "$PGRAW"

capture cd /Users/yosemite/githubs/CharitySubstitutionExperiment/data/

    !cp "/Users/yosemite/Google Drive/substitution_experiment_is_back/2016 retooling for mass experiment/similaritysurveydata/output/studentomnibus.dta" .

    ****************************
    **IMPORT NON-STUDENT DATA***
    ****************************

clear
    * First ask
*import delimited "NonstudentsFirstAsk.csv", rowrange(4)
import delimited "NonstudentsFirstAsk.csv", rowrange(4)

     gen asiffinished=finished
     replace asiffinished="TRUE" if timeplacebo_bhf_pagesubmit!=. | timepleasecontinue_pagesubmit!=. | time_nsa_donint_pagesubmit !=. | timing_ns1_dondom_pagesubmit!=.

*MOVE drops to end ... no need to drop it right away
*drop time* status startdate enddate distributionchannel regyet nsbeforewinask nsb4whichchar winscreen nsbeforeask v69 losescreen winscreenafter nsafterdon nsafterwhichchar noasklose q44 v81 gift bhfextra oxfamextra totalextra title rand_num rankingroup


    *label define Treatment 1 "After" 2 "Before" 3 "Domestic Happy After" 4 "Domestic Happy First" 5  "Internat. Happy After" 6 "Internat.  Happy First" 7 "Lose No ask" 8 "No ask", modify

    encode sex, generate(gender)
    drop sex

    *Fix a coding error (recover firstasktreat for some obs)
    replace firstasktreat="international_happyfirst" if firstasktreat=="" & oxfamdonation!=.
**DOUBLECHECK this

    encode firstasktreat, gen(Treatment)
    replace Treatment=Treatment+2
    recode Treatment 7=8
    label define Treatment 1 "After" 2 "Before" 3 "Domestic Happy After" 4 "Domestic Happy First" 5  "Internat. Happy After" 6 "Internat.  Happy First" 7 "Lose No ask" 8 "No ask", modify
    label values Treatment Treatment

    gen CharityTreat=1 if Treatment==3|Treatment==4
    replace CharityTreat =2 if  Treatment==5|Treatment==6
    replace CharityTreat =0 if  Treatment==8

    label define CharityTreat 1 "Domestic" 2 "Internat." 0 "No ask", modify
    label values CharityTreat CharityTreat

    gen DHappyAskBefore=0 if Treatment==3|Treatment==5
    replace DHappyAskBefore=1 if Treatment==4|Treatment==6

    rename oxfamdonation DonationInterFirstAsk
    rename bhfdonation DonationDomesticFirstAsk

    gen Donation1=DonationInterFirstAsk
    replace Donation1=DonationDomesticFirstAsk if Donation1==.


    drop if asiffinished=="False"

    order recruitmentid  CharityTreat DHappyAskBefore DonationInterFirstAsk DonationDomesticFirstAsk totaldonation happiness_1 gender childpresentmdl
    drop if recruitmentid==.
save ../Temp/NonstudentsFirstAsk, replace
    ***********************
    *** Read second nonstudent ask from OMNIBUS
    ***********************

!cp "/Users/yosemite/Google Drive/substitution_experiment_is_back/2016 retooling for mass experiment/similaritysurveydata/output/nonstudentomnibus.dta" .

    clear
    *use nonstudentomnibus.dta, clear, clear
    *order recruitmentid DonationInterSecondAsk DonationDomesticSecondAsk
    *save NonstudentsSecondAsk, replace

    * merge

    *use ../Temp/NonstudentsFirstAsk, clear
    use  ../oldercode_to_adapt/recoverdata/NonstudentsFirstAsk, clear
    merge 1:1 recruitmentid using ../Temp/nonstudentomnibus
    *merge 1:1 recruitmentid using ../oldercode_to_adapt/recoverdata/nonstudentomnibus

*TODO - check how there could be  obs here than for the 1st ask when we only invited people who did the first ask -- check again whether the first ask from the non-last download!
    gen Experimentnum=1
    order Experimentnum recruitmentid  CharityTreat DHappyAskBefore DonationInterFirstAsk DonationDomesticFirstAsk DonationInterSecondAsk DonationDomesticSecondAsk
    rename recruitmentid code
    tostring code, replace
save ../Temp/Nonstudents, replace
    **Will want to keep only merged obs?, but more to consider selective attrition

    keep if Finished=="TRUE" & _merge==3
save ../Temp/Nonstudentsallgood, replace


    ***********************************
    **IMPORT STUDENT DATA**************
    ***********************************

    * First ask

    *!cp "/Users/yosemite/Google Drive/substitution_experiment_is_back/2016 retooling for mass experiment/similaritysurveydata/output/studentomnibus.dta" .
    *use studentomnibus.dta

    * Read second ask
    clear
*import delimited "StudentsSecondAsk.csv"
import delimited "StudentsSecondAsk.csv"

    gen Donation2= ask_stc_10_mx25
    replace Donation2 = ask_cruk_10_mx25a if Donation2 ==.

  *Which second round treatment for students
  gen Dsecondaskdom= ask_cruk_10_mx25a!=.
  gen Dsecondaskint= ask_stc_10_mx25!=.

    *drop ask_stc_10_mx25 ask_cruk_10_mx25a

    drop if code==""

save ../Temp/StudentsSecondAsk, replace

    *** merge
    *merge 1:1 code using ../Temp/studentomnibus.dta
    merge 1:1 code using ../oldercode_to_adapt/recoverdata/studentomnibus.dta
    gen Experimentnum=2

***Todo: need to code variable the same format so they don't overwrite each other in the append
 foreach X in "gender" "STUDIES" "winscreen" "losescreen" {
    encode `X', gen(`X'1)
    drop `X'
    rename `X'1 `X'
    }

 foreach X of varlist DistributionChannel LANGS OTR* BROAD PACT likert_time*  {
    recast str30 `X'
    }

 foreach X of varlist merit MENT  {
    recast str100 `X'
    }

save ../Temp/Students, replace

*KEEP merged only (??)
    keep if _merge==3
save ../Temp/Students_substitution, replace

    *APPEND NON-STUDENT and STUDENT*
    clear

***Todo: need to code variable the same format so they don't overwrite each other in the append

use ../Temp/Nonstudentsallgood, clear

        /***Todo: need to code variable the same format so they don't overwrite each other in the append
        foreach X in "finished" "YearsEnglish" "winscreen" "losescreen" {
            cap encode `X', gen(`X'1)
            drop `X'
            cap rename `X'1 `X'
            }
        */

    **Recover happiness treatment (randomisation ordering) for student treatment
    ***Create key variables, Reconcile variable names between student and nonstudent versions
    *replace gender = sex

    cap encode gender, gen(DgenderNS)

    foreach X of varlist finished YearsEnglish STUDIES BROAD PACT {
        rename `X' `X'NS
    }

append using ../Temp/Students

    replace gender=Gender if gender==.

    *** Employability variables
    gen lnsalrequest1=log(salaryrequest1)

*Todo - merge to cleaned omnibus responses!

***Generating key variables,

    encode firstasktreat, generate(firstasktreat1)

    gen DNS_sample = childpresentmdl!=""
    gen DfirstaskDom = (firstasktreat1>=3&firstasktreat1<=6)
    gen DfirstaskInt = (firstasktreat1>=7&firstasktreat1<=10)
    gen DfirstNoask = firstasktreat1==12

    cap gen Dsecondaskdom = DonationDomesticSecondAsk!=.
    cap gen Dsecondaskint = DonationInterSecondAsk!=.
    replace Dsecondaskint=1 if ask_stc_10_mx25!=.
    replace Dsecondaskdom=1 if ask_cruk_10_mx25a!=.

    gen Dbothaskdom = (DfirstaskDom*Dsecondaskdom)==1
    gen Dbothaskint = (DfirstaskInt*Dsecondaskint)==1
    gen Dbothasksame = (Dbothaskdom+Dbothaskint)

    gen Dsomefirstask = 1-DfirstNoask

    gen Cat_ask1_sub = 1*DfirstaskDom+2*DfirstaskInt
    gen Cat_ask2_sub = 1*Dsecondaskdom

    gen Dnochild = ChildrenNo==0

    drop totaldonation
    egen totaldonation=rsum(Donation1 Donation2)


    drop if CharityTreat == .
    gen Charity1 = .
    replace Charity1 = CharityTreat
    gen Charity2 = 1 if DonationDomesticSecondAsk !=.
    replace Charity2 = 2 if DonationInterSecondAsk !=.
    drop DonationInterFirstAsk DonationInterSecondAsk DonationDomesticSecondAsk CharityTreat

    rename happiness_1 Happiness1
    replace current_happiness_1 = v127 if current_happiness_1 == ""
    replace current_happiness_1 = v128 if current_happiness_1 == ""
    replace current_happiness_1 = v131 if current_happiness_1 == ""
    gen Happiness3=s1happyafter_dom_1
    replace Happiness3=s1happyfirst_dom_1 if Happiness3 == ""
    replace Happiness3=s1happyfirst_int_1  if Happiness3 == ""
    replace Happiness3=s1happyafter_int_1  if Happiness3 == ""
    replace Happiness3=s1happynoask_1  if Happiness3 == ""
    replace Happiness3=v208  if Happiness3 == ""

    replace Happiness1 = Happiness3 if Happiness1 == ""



    encode current_happiness_1 , gen(Happiness2) label(Happiness )
    encode Happiness1, gen(Happiness99) label(Happiness)
    drop Happiness1
    rename Happiness99 Happiness1

    drop v127 v128 v131 current_happiness_1 Happiness s1happyfirst_dom_1 s1happyfirst_int_1 s1happyafter_dom_1 s1happyafter_int_1 s1happynoask_1 v208



    order Experimentnum code Donation1 Donation2 Charity1 Charity2

    drop timepleasecontinue_firstclick timepleasecontinue_lastclick timepleasecontinue_pagesubmit timepleasecontinue_clickcount timenbrcontact_firstclick timenbrcontact_lastclick timenbrcontact_pagesubmit timenbrcontact_clickcount timenbrname_firstclick timenbrname_lastclick timenbrname_pagesubmit timenbrname_clickcount timenbrhaveemail_firstclick timenbrhaveemail_lastclick timenbrhaveemail_pagesubmit timenbrhaveemail_clickcount timenbrwouldemail_lastclick timenbrwouldemail_pagesubmit timenbrwouldemail_clickcount timehappiness_firstclick timehappiness_lastclick timehappiness_pagesubmit timehappiness_clickcount time_ns1_donint_firstclick time_ns1_donint_lastclick time_ns1_donint_pagesubmit time_ns1_donint_clickcount time_ns1_dondom_firstclick time_ns1_dondom_lastclick time_ns1_dondom_pagesubmit time_ns1_dondom_clickcount time_nsa_donint_firstclick time_nsa_donint_lastclick time_nsa_donint_pagesubmit time_nsa_donint_clickcount timeplacebo_bhf_firstclick timeplacebo_bhf_lastclick timeplacebo_bhf_pagesubmit timeplacebo_bhf_clickcount likert_time_recip_1 likert_time_recip_2 likert_time_recip_3 happytime_s50pct_FirstClick happytime_s50pct_LastClick happytime_s50pct_PageSubmit happytime_s50pct_ClickCount timehappy_FirstClick timehappy_LastClick timehappy_PageSubmit timehappy_PageSubmit timehappy_ClickCount timedon_FirstClick timedon_LastClick timedon_PageSubmit timedon_ClickCount time_s1_don_dom_FirstClick time_s1_don_dom_LastClick time_s1_don_dom_PageSubmit time_s1_don_dom_ClickCount v166 v167 v168 v169 v171 v172 v173 v174 time_s1_don_int_FirstClick time_s1_don_int_LastClick time_s1_don_int_PageSubmit time_s1_don_int_ClickCount v181 v182 v183 v184 v186 timeplacebo_dom_FirstClick timeplacebo_dom_LastClick timeplacebo_dom_PageSubmit timeplacebo_dom_ClickCount v195 v196 v197 v198 timeplacebo_int_FirstClick timeplacebo_int_LastClick timeplacebo_int_PageSubmit timeplacebo_int_ClickCount v204 v205 v206 v207  timenbrwouldemail_firstclick v187 v188 v189


save  ../Output/Essex2017.dta, replace

***some analysis work we should put on the analysis side
    /*
    keep if (DfirstaskDom==1|DfirstaskInt==1|DfirstNoask==1) & Donation2!=.

    reg Donation2 Dsomefirstask, cluster(code)

    reg Donation2 DfirstaskDom DfirstaskInt, cluster(code)
    reg Donation2 DfirstaskDom DfirstaskInt Dsecondaskdom Dbothaskdom Dbothaskint, cluster(code)
    reg Donation2 DfirstaskDom DfirstaskInt Dbothasksame, cluster(code)

    reg totaldonation DfirstaskDom DfirstaskInt, cluster(code)
    reg totaldonation Dsomefirstask, cluster(code)

   * reg totaldonation DfirstaskDom DfirstaskInt Dsecondaskdom Dsecondaskint Dbothaskdom Dbothaskint, cluster(code)

    reg totaldonation DfirstaskDom DfirstaskInt Dsecondaskdom Dsecondaskint Dbothaskdom Dbothaskint, cluster(code)

    reg Donation DfirstaskDom DfirstaskInt DHappyAskBefore if Dsomefirstask , cluster(code)

***SOME relevant controls and interactions to consider; these could carry over into G&P analysis as well
    summ Dnorelig Dnochild Dwhite pctcorrecteyes
        - these have been reconciled across the 2 samples
        - although these don't seem to relate to charitable giving much

    Pers* -- the personality characteristics seem strongly related to charitable giving
    ValueConformity ValueTradition ValueSecurity are also strongly related to it
    -- might be worth doing model fitting on these controls


    reg Donation DfirstaskDom DfirstaskInt DHappyAskBefore if Dsomefirstask , cluster(code)

    stepwise, pr(.20) :  reg totaldonation DfirstaskDom DfirstaskInt  Dnorelig Dnochild Dwhite pctcorrecteyes Pers* ValueConformity ValueTradition ValueSecurity , robust
    stepwise, pr(.20) :  reg Donation2 DfirstaskDom DfirstaskInt Dbothasksame Dnorelig Dnochild Dwhite pctcorrecteyes Pers* ValueConformity ValueTradition ValueSecurity , robust
