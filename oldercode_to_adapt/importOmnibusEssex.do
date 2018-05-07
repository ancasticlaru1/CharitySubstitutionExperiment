*importOmnibusEssex.do
***This imports and processes omnibus data -- from students (first ask/G&P), omnibus part should be similar or identical for nonstudents (second ask)
***For use in Substitution, G&P, and other analyses

clear

   /* cap cd $home
    cap cd "Google Drive/giving and probability"
    cap cd "AllDataAnalysisAllExperiments/data/essexomnibusdata"
    * Gerhard's paths
    cap cd "C:\Users\Gerhard Riener\Google Drive\giving and probability\"
    cap cd "AllDataAnalysisAllExperiments\data\essexomnibusdata"
*/

    capture cd $HOME
    capture cd "Google Drive/substitution_experiment_is_back/2016 retooling for mass experiment/similaritysurveydata/rawdata/forgerhard"

    global PGRAW "C:\Users\Gerhard Riener\Google Drive\substitution_experiment_is_back\2016 retooling for mass experiment\similaritysurveydata\rawdata\forgerhard"
    capture cd "$PGRAW"

import delimited "StudentsFirstAsk.csv", varnames(1) case(preserve) asfloat encoding(UTF-8) rowrange(4) clear

    destring sbeforeask  Durationinseconds  SIBLINGS SIBORDER NUMCHILD ENGYEARS Q283_FirstClick Q283_LastClick Q283_PageSubmit Q283_ClickCount Q284_FirstClick Q284_LastClick Q284_PageSubmit Q284_ClickCount safterask Q286_FirstClick Q286_LastClick Q286_PageSubmit Q286_ClickCount  happytime_s50pct_FirstClick happytime_s50pct_LastClick happytime_s50pct_PageSubmit happytime_s50pct_ClickCount, replace

    *clean s1donation variable
    gen Donation1= s1_don_dom_hb
    replace Donation1=s1_don_dom_ha if Donation1==.
    replace Donation1=s1_don_int_hb if Donation1==.
    replace Donation1=s1_don_int_ha if Donation1==.

    *Moved: Put drops in only at end *drop DistributionChannel

    ***************************
    ***KEY OUTCOME VARIABLES

    ***Generate Donation variables

    gen DonationBefore=sbeforeask
    *gen DonationBefore2 = v141
    replace DonationBefore=v142 if DonationBefore ==.
    *replace DonationBefore2=0 if DonationBefore2 ==.
    gen DonationAfter = safterask
    replace DonationAfter =0 if DonationAfter ==.

    egen Donation=rsum(Donation1 DonationAfter DonationBefore)

    gen Donated=Donation>0
    gen DonatedAll=Donation==10
    gen DonatedNothing=Donation==0

    replace choosechar=choosechar1 if choosechar==""
    *replace choosechar=choosechar2 if choosechar==""
    *replace choosechar=choosechar3 if choosechar==""
    gen DchoseOxfam =  choosechar=="IM_5hx1EKECRPVMETP"
    gen DchoseBHF =  choosechar=="IM_9Sr7SDlok72WZ0x"
    gen catcharchoice = 0 + 1*DchoseOxfam+2*DchoseBHF
    *label define chosenchar 1 "Oxfam" 2 "BHF"
    *label values ChosenCharity chosenchar
*REM- we neglected to get the choice of charities from those in half the after treatments; asked them to confirm later, half responded; could fix later

    *** Generate Happiness variable
    label define Happiness 7 `"Extremely happy"', modify
    label define Happiness 1 `"Extremely unhappy"', modify
    label define Happiness 6 `"Moderately happy"', modify
    label define Happiness 2 `"Moderately unhappy"', modify
    label define Happiness 4 `"Neither happy nor unhappy"', modify
    label define Happiness 5 `"Slightly happy"', modify
    label define Happiness 3 `"Slightly unhappy"', modify
	encode happiness_1, gen(Happiness) label(Happiness)
	drop happiness_1


    ***************************
    ***KEY TREATMENT VARIABLES AND VALIDITY/INCLUSION VARIABLES

    encode firstasktreat, gen(Treatment)

    label define Treatment 1 "After" 2 "Before" 3 "Domestic Happy After" 4 "Domestic Happy First" 5  "Internat. Happy After" 6 "Internat.  Happy First" 7 "Lose No ask" 8 "No ask", modify
    label values Treatment Treatment

    gen CharityTreat=1 if Treatment==3|Treatment==4
    replace CharityTreat =2 if  Treatment==5|Treatment==6
    replace CharityTreat =0 if  Treatment==8

    label define CharityTreat 1 "Domestic" 2 "Internat." 0 "No ask", modify
    label values CharityTreat CharityTreat

    gen DHappyAskBefore=0 if Treatment==3|Treatment==5
    replace DHappyAskBefore=1 if Treatment==4|Treatment==6
    drop if code==""
    duplicates drop code, force

        *gen Oxfam: IM_5hx1EKECRPVMETP * BHF: IM_9Sr7SDlok72WZ0x

    encode winprize, gen(WonPrize)
    replace WonPrize=2 if WonPrize==1
    replace WonPrize=1 if WonPrize==.

    encode Finished, gen(FinishedSurvey)
	label define yesno 1 "Yes" 0 "No", modify
	drop Finished

    gen firstaskdom=(firstasktreat=="domestic_ha")+(firstasktreat=="domestic_hb")
    gen askhappybefore =(firstasktreat=="international_hb")+(firstasktreat=="domestic_hb")
    gen askhappybefore_int =(firstasktreat=="international_hb")

    ***************************
    *** PERSONAL CHARACTERISTICS and OMNIBUS RESPONSES
do "/Users/yosemite/Google Drive/giving and probability/AllDataAnalysisAllExperiments/build/omnibus/code/omnibussurveyinput.do"

    ***************************
    * CLEAN UP
    capture drop v142 Q174 Q175 *_LastClick *_FirstClick *_PageSubmit *_ClickCount DonationBefore1 DonationBefore2 DonationAfter safterask v141 SEX losenoask happytime_s50pct_LastClick choosecharity firstasktreat winprize sbeforeask BIRTH

    *drop timehappy_FirstClick timehappy_LastClick timehappy_PageSubmit timehappy_ClickCount s1happyfirst_dom_1 timedon_FirstClick timedon_LastClick timedon_PageSubmit timedon_ClickCount s1_don_dom_hb time_s1_don_dom_FirstClick time_s1_don_dom_LastClick time_s1_don_dom_PageSubmit time_s1_don_dom_ClickCount s1_don_dom_ha v165 v166 v167 v168 s1happyafter_dom_1 v170 v171 v172 v173 s1happyfirst_int_1 time_s1_don_int_FirstClick time_s1_don_int_LastClick time_s1_don_int_PageSubmit time_s1_don_int_ClickCount s1_don_int_hb v180 v181 v182 v183 s1_don_int_ha v185 v186 v187 v188 s1happyafter_int_1 timeplacebo_dom_FirstClick timeplacebo_dom_LastClick timeplacebo_dom_PageSubmit timeplacebo_dom_ClickCount v194 v195 v196 v197 s1happynoask_1 timeplacebo_int_FirstClick timeplacebo_int_LastClick timeplacebo_int_PageSubmit timeplacebo_int_ClickCount v203 v204 v205 v206 v207 Q287_FirstClick Q287_LastClick Q287_PageSubmit Q287_ClickCount beforeask_from10 v213 Q288_FirstClick Q288_LastClick Q288_PageSubmit Q288_ClickCount beforeask_from50 Q51 Q289_FirstClick Q289_LastClick Q289_PageSubmit Q289_ClickCount donfrom10or50_3 donfrom10or50_4 S1Donation S1Reward v136 Status winscreen v130 losescreen

    ***************************
    ***Globals for categories of variables

    global OUTCOMES Donation Donated DonatedAll DonatedNothing Happiness choosechar

    global TREATMENTS Treatment WonPrize

    global CHARACTERISITCS Gender Age RelConfession Race UniStudent FirstLangEng FluentEng YearsEnglish NativeLanguage BirthNationUK Nation Siblings SiblBirthOrder MaritalStatus Child ChildrenNo LivedAbroad ImpairC EducationMother EducationFather WorkMother WorkFather BirthDate

    global PERSONALITY RiskAttitude TrustGeneral PersExtrovert PersCritical PersDependable PersAnxious PersOpenness PersReserved PersSympathetic PersCareless PersCalm PersConventional ValueAchieve ValueStimu ValueSelfDir ValueBenevol ValueTradition ValueConformity ValueSecurity PersWorth PersQuality ValuePower ValueHedon ValueUniversal PersFail PersCompar PersNotProud PersPosAtt PersSatisfied PersNoRespect PersUseless PersNoGood

    global ATTITUDES AuthoritarianValues1 AuthoritarianValues2 AuthoritarianValues3 AuthoritarianValues4 IdeologyHomosexuality IdeologyProstitution IdeologyAbortion IdeologyDivorce IdeologySex

    global METADATA code StartDate EndDate Progress Durationinseconds Finished RecordedDate ResponseId FinishedSurvey ExperimentParticipation

    drop if code==""
    duplicates drop code, force

    order $OUTCOMES $TREATMENTS $CHARACTERISITCS $PERSONALITY $ATTITUDES $METADATA

    gen DNSpool=0
save ../../output/studentomnibus.dta, replace


    **************************
    * NONSTUDENT OMNIBUS INPUT
    **************************
import delimited "NonstudentsSecondAsk.csv", varnames(1) case(preserve) asfloat encoding(UTF-8) rowrange(4) clear

    destring   Durationinseconds  ns2*, replace
    drop if RecruitmentID==.
    rename RecruitmentID recruitmentid

    gen DonationInterSecondAsk=ns2_don_int_ha
    replace DonationInterSecondAsk=ns2_don_int_hb if DonationInterSecondAsk==.

    gen DonationDomesticSecondAsk=ns2_don_dom_ha
    replace DonationDomesticSecondAsk=ns2_don_dom_hb if DonationDomesticSecondAsk==.

    gen Donation2=DonationInterSecondAsk
    replace Donation2=DonationDomesticSecondAsk if Donation2==.

    gen Dask2Dom = DonationDomesticSecondAsk!=.


    *keep if Finished=="TRUE"

    * gen asiffinished=finished
    * replace asiffinished="TRUE" if timeplacebo_BHF_PageSubmit!=. | timepleasecontinue_PageSubmit!=. | time_nsa_donint_PageSubmit !=. | timing_ns1_dondom_PageSubmit!=.
*DROPS later *drop time* status startdate enddate distributionchannel regyet nsbeforewinask nsb4whichchar winscreen nsbeforeask v69 losescreen winscreenafter nsafterdon nsafterwhichchar noasklose q44 v81 gift bhfextra oxfamextra totalextra title rand_num rankingroup

*    destring   Durationinseconds  SIBLINGS SIBORDER NUMCHILD ENGYEARS Q283_FirstClick Q283_LastClick Q283_PageSubmit Q283_ClickCount Q284_FirstClick Q284_LastClick Q284_PageSubmit Q284_ClickCount safterask Q286_FirstClick Q286_LastClick Q286_PageSubmit Q286_ClickCount  happytime_s50pct_FirstClick happytime_s50pct_LastClick happytime_s50pct_PageSubmit happytime_s50pct_ClickCount, replace


    ***KEY OUTCOME VARIABLES

    ***Generate Donation variables

    gen Donated2=Donation2>0
    gen DonatedAll2=Donation2==10
    gen DonatedNothing2=Donation2==0

    *** Generate Happiness variable
    label define Happiness 7 `"Extremely happy"', modify
    label define Happiness 1 `"Extremely unhappy"', modify
    label define Happiness 6 `"Moderately happy"', modify
    label define Happiness 2 `"Moderately unhappy"', modify
    label define Happiness 4 `"Neither happy nor unhappy"', modify
    label define Happiness 5 `"Slightly happy"', modify
    label define Happiness 3 `"Slightly unhappy"', modify
	encode happiness_1, gen(Happiness) label(Happiness)
	drop happiness_1

    ***************************
    ***KEY TREATMENT VARIABLES AND VALIDITY/INCLUSION VARIABLES
    gen DHappyAskBefore_ask2=0 if ns2_don_dom_ha!=.|ns2_don_int_ha!=.
    replace DHappyAskBefore_ask2=1 if ns2_don_dom_hb!=.|ns2_don_int_hb!=.

    gen askhappybefore_intask2 =(ns2_don_int_hb!=.)

    ***************************
    *** PERSONAL CHARACTERISTICS and OMNIBUS RESPONSES
do "/Users/yosemite/Google Drive/giving and probability/AllDataAnalysisAllExperiments/build/omnibus/code/omnibussurveyinput_nonstudent.do"

*THESE need a lot of relabling because we forgot to label this earlier version!


    ***************************
    * CLEAN UP
    capture drop Q174 Q175 *_LastClick *_FirstClick *_PageSubmit *_ClickCount DonationBefore1 DonationBefore2 DonationAfter safterask v141 SEX losenoask happytime_s50pct_LastClick choosecharity firstasktreat winprize sbeforeask BIRTH

    gen DNSpool=1
save ../../output/nonstudentomnibus, replace


***********************
***Put all Omnibus together
***********************
append using ../../output/studentomnibus.dta, force
save  ../../output/allomnibus.dta, replace

*NOTE: These omnibus survey responses must be xompared closely, it will take a long time to reconcile them

    **************************
    /*FIRST ANALYSIS*/
    // reg Donation i.Treatment if Treatment<3, robust
    // bys Gender: reg Donation i.Treatment if Treatment<3, robust
    // xi: reg Donation i.Gender*i.Treatment if Treatment<3, robust

    // xi: poisson Donation i.gender*i.Treatment if Treatment<3, robust
    // xi: qreg Donation i.gender*i.Treatment if Treatment<3

    // bys Gender: ranksum Donation if Treatment<3,by(Treatment)

    // reg Donated i.Treatment if Treatment<3, robust
    // logit Donated i.Treatment if Treatment<3, robust or
    // xi: logit Donated i.Gender*i.Treatment if Treatment<3, robust or

    // reg DonatgedAll i.Treatment if Treatment<3, robust
    // reg  DonatedNothing i.Treatment if Treatment<3, robust
