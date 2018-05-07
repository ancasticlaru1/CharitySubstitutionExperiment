* omnibussurveyinput.do
* Inputs and cleans omnibus part of data
* Called in importOmnibusEssex.do


gen Dfemale=gender=="female"
    label define gender 0 "male" 1 "female" 2 "other" 3 "Pavey"
    encode gender, gen(Gender) label(gender)
    drop gender

gen Dwhite=RACE=="White"
    encode RACE, gen(Race)
    drop RACE

    rename SIBLINGS Siblings
    rename SIBORDER SiblBirthOrder
    rename NUMCHILD ChildrenNo
    encode SINGLE, gen(MaritalStatus)
    drop SINGLE
    encode UNISTDNT , gen(UniStudent) label(yesno)
    drop UNISTDNT
    encode EXPPREF , gen(ExperimentParticipation)
    drop EXPPREF

    label define Education 1 `"    Doctorate (PhD)"', modify
    label define Education 2 `"    Post-Secondary Education (College, A-Levels, NVQ3 or below, or similar)"', modify
    label define Education 3 `"    Post-graduate Degree (MA, MSc etc.)"', modify
    label define Education 4 `"    Undergraduate Degree (BA, BSc etc.)"', modify
    label define Education 5 `"    Vocational Qualification (Diploma, Certificate, BTEC, NVQ 4 and above, or similar)"', modify
    label define Education 6 `"Secondary Education (GCSE/O-Levels) or below"', modify

gen Dmomedhsorless = MOMEDUC=="High School Degree"
    encode MOMEDUC, gen(EducationMother) label(Education)
    encode DADEDUC, gen(EducationFather) label(Education)
    drop MOMEDUC DADEDUC
    label define Education 1 `"Doctorate (PhD)"', modify
    label define Education 2 `"Post-Secondary Education (College, A-Levels, NVQ3 or below, or similar)"', modify
    label define Education 3 `"Post-graduate Degree (MA, MSc etc.)"', modify
    label define Education 4 `"Undergraduate Degree (BA, BSc etc.)"', modify
    label define Education 5 `"Vocational Qualification (Diploma, Certificate, BTEC, NVQ 4 and above, or similar)"', modify
    label define Education 6 `"Secondary Education (GCSE/O-Levels) or below"', modify

    label define Work 1 `"Construction, Extraction, and maintenance"', modify
    label define Work 2 `"Farming, Fishing, and Forestry"', modify
    label define Work 3 `"Government"', modify
    label define Work 4 `"Homemaker"', modify
    label define Work 5 `"Management, Professional, and related"', modify
    label define Work 6 `"Other"', modify
    label define Work 7 `"Production, Transportation, and Material Moving"', modify
    label define Work 8 `"Sales and Office"', modify
    label define Work 9 `"Service"', modify
    label define Work 10 `"Unemployed"', modify

    encode MOMJOB, gen(WorkMother) label(Work)
    encode DADJOB, gen(WorkFather) label(Work)
    drop MOMJOB DADJOB


    gen BirthDate = date(BIRTH,"DMY")
    format BirthDate %td
    gen today = "06/06/2017"
    gen today2 = date(today, "DMY")
    format today2 %dD_m_Y
    gen Age = (today2 - BirthDate)/365.25
    format Age %2.0f
    drop today today2

    encode RELIG , gen(RelConfession)
        drop  RELIG
        gen Dmuslim = RelConfession==6
        gen Dchristian = RelConfession==4
        gen Dnorelig = (RelConfession==1)+(RelConfession==2)

    encode IMPAIR, gen(ImpairC) label(yesno)
    drop IMPAIR
    encode PREVPAR , gen(PrevPar) label(yesno)
    drop PREVPAR
    encode CHILD , gen(Child) label(yesno)
    drop CHILD
    replace ChildrenNo=0 if ChildrenNo ==.
    encode birth_nation, gen(BirthNationUK) label(yesno)
    drop  birth_nation
    encode ABROAD , gen(LivedAbroad) label(yesno)
    drop ABROAD
    encode NATION , gen(Nation)
    drop NATION
    encode FIRSTLANG , gen(FirstLangEng) label(yesno)
    drop FIRSTLANG
    encode FLUENT  , gen(FluentEng) label(yesno)
    rename ENGYEARS YearsEnglish

    drop FLUENT
    encode HOMELANG , gen(NativeLanguage)
    drop HOMELANG

    * Risk aversion
        label define Risk 1 "Completely unwilling to take risks", modify
        label define Risk 2 "1", modify
        label define Risk 3 "2", modify
        label define Risk 4 "3", modify
        label define Risk 5 "4", modify
        label define Risk 6 "Risk Neutral", modify
        label define Risk 7 "6", modify
        label define Risk 8 "7", modify
        label define Risk 9 "8", modify
        label define Risk 10 "9", modify
        label define Risk 11 "Very willing to take risks", modify
    encode RISK, gen(RiskAttitude) label(Risk)
    drop RISK

    * Personality attributes
    label define agreedisagree 1 "Disagree Strongly" 2 "Disagree moderately" 3 "Disagree a little" 4 "Neither agree nor disagree" 5 "Agree a little" 6 "Agree Moderately" 7 "Agree Strongly"
        encode ATTRIBUTES_1 , gen(PersExtrovert) label(agreedisagree)
        encode ATTRIBUTES_2 , gen(PersCritical) label(agreedisagree)
        encode ATTRIBUTES_3 , gen(PersDependable) label(agreedisagree)
        encode ATTRIBUTES_4 , gen(PersAnxious) label(agreedisagree)
        encode ATTRIBUTES_5 , gen(PersOpenness) label(agreedisagree)
        encode ATTRIBUTES_6 , gen(PersReserved) label(agreedisagree)
        encode ATTRIBUTES_7 , gen(PersSympathetic) label(agreedisagree)
        recode PersSympathetic 8=2
        encode ATTRIBUTES_8 , gen(PersCareless) label(agreedisagree)
        encode ATTRIBUTES_9 , gen(PersCalm) label(agreedisagree)
        encode ATTRIBUTES_10 , gen(PersConventional) label(agreedisagree)
        drop ATTRIBUTES_*

    * Social values
    label define importance 1 "No Importance" 2 "1" 3 "2" 4 "3" 5 "4" 6 "5" 7 "6" 8 "7" 9 "Supreme Importance"
        encode POWER, gen(ValuePower) label(importance)
        encode ACHIEVE, gen(ValueAchieve) label(importance)
        encode HEDON, gen(ValueHedon) label(importance)
        encode STIMUL, gen(ValueStimu) label(importance)
        encode SELFD, gen(ValueSelfDir) label(importance)
        encode UNIVE, gen(ValueUniversal) label(importance)
        encode BENEV, gen(ValueBenevol) label(importance)
        encode TRADI, gen(ValueTradition) label(importance)
        encode CONFO, gen(ValueConformity) label(importance)
        encode SECUR, gen(ValueSecurity) label(importance)
        drop POWER ACHIEVE HEDON STIMUL SELFD UNIVE BENEV TRADI CONFO  SECUR

        * Personal qualities
        label define agreedisagree2 1 "Strongly Disagree" 2 "Disagree" 3 "Agree" 4 "Strongly Agree"
    *	encode ESTEEM, gen(PersEsteem) label(agreedisagree2)
        encode WORTH, gen(PersWorth) label(agreedisagree2)
        encode GOODQ, gen(PersQuality) label(agreedisagree2)
        encode FAIL, gen(PersFail) label(agreedisagree2)
        encode COMPAR, gen(PersCompar) label(agreedisagree2)
        encode PROUD, gen(PersNotProud) label(agreedisagree2)
        encode POSAT, gen(PersPosAtt) label(agreedisagree2)
        encode SATIS, gen(PersSatisfied) label(agreedisagree2)
        encode RESPECT, gen(PersNoRespect) label(agreedisagree2)
        encode USELESS, gen(PersUseless) label(agreedisagree2)
        encode NOGOOD, gen(PersNoGood) label(agreedisagree2)
        drop WORTH GOODQ FAIL COMPAR PROUD POSAT SATIS RESPECT USELESS NOGOOD
        encode trust, gen(TrustGeneral)
        drop trust

    * Mind in the EYES
    forvalues i=1/18{
	    encode EYES`i', gen(Eyes`i')
	    drop EYES`i'
    }

    * AUTHORITARIANISM
    forvalues i=1/4{
	    encode auth`i' , gen(AuthoritarianValues`i')
	    drop auth`i'
    }

    * DECISION MODE
    encode decisionmode, gen(DecisionMode)
    drop decisionmode

    * SOCIAL IDEOLOGY
    label define Ideology 1 "Never justifiable"  2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9"  10 "Always Justifiable"
	encode social_ideo_1, gen(IdeologyHomosexuality) label(Ideology)
	encode social_ideo_2, gen(IdeologyProstitution) label(Ideology)
	encode social_ideo_3, gen(IdeologyAbortion) label(Ideology)
	encode social_ideo_4, gen(IdeologyDivorce) label(Ideology)
	encode social_ideo_5, gen(IdeologySex) label(Ideology)
	drop social_ideo_*

    foreach X of varlist Eyes* {
        egen mode`X'=mode(`X')
        gen Dcorrect`X'=(`X'==mode`X')
        drop mode*
    }
    egen pctcorrecteyes=rmean(Dcorrect*)
