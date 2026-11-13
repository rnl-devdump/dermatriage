class ExanthemInfo {
  final String id;
  final String name;
  final String pathogen;
  final String virusFamily;
  final String incubationPeriod;
  final String transmission;
  final String morphologySummary;
  final String lesionEvolution;
  final String anatomicalDistribution;
  final String lymphadenopathyProfile;
  final List<String> clinicalFeatures;
  final List<String> differentialPoints;
  final List<String> redFlags;
  final String
  triagePriority; // 'Level 1: High Priority', 'Level 2: Urgent', 'Level 3: Standard', 'Level 4: Routine'
  final String isolationGuideline;
  final double modelPrecision;
  final double modelRecall;
  final double modelF1;
  final int modelSupport;
  final List<String> sampleAssets;

  const ExanthemInfo({
    required this.id,
    required this.name,
    required this.pathogen,
    required this.virusFamily,
    required this.incubationPeriod,
    required this.transmission,
    required this.morphologySummary,
    required this.lesionEvolution,
    required this.anatomicalDistribution,
    required this.lymphadenopathyProfile,
    required this.clinicalFeatures,
    required this.differentialPoints,
    required this.redFlags,
    required this.triagePriority,
    required this.isolationGuideline,
    required this.modelPrecision,
    required this.modelRecall,
    required this.modelF1,
    required this.modelSupport,
    required this.sampleAssets,
  });

  static const List<ExanthemInfo> allExanthems = [
    ExanthemInfo(
      id: 'mpox',
      name: 'Mpox (Monkeypox)',
      pathogen: 'Monkeypox Virus (MPXV)',
      virusFamily: 'Poxviridae (Orthopoxvirus genus)',
      incubationPeriod: '5 to 21 days (typically 6-13 days)',
      transmission:
          'Close skin-to-skin contact, respiratory droplets, contaminated fomites',
      morphologySummary:
          'Firm, deep-seated, well-circumscribed papulovesicular lesions advancing to tense pustules with pronounced central umbilication, eventual thick dark crusting and scarring.',
      lesionEvolution:
          'Synchronous progression in any anatomical zone: Macules (1-2d) -> Papules (1-2d) -> Vesicles (1-2d) -> Pustules (5-7d) -> Desiccation/Crusting (7-14d).',
      anatomicalDistribution:
          'Centrifugal predilection: initial lesions frequently appear on face, oral mucosa, palms and soles, and perianal/genital mucosal boundaries.',
      lymphadenopathyProfile:
          'Prominent, painful, firm lymphadenopathy (submandibular, cervical, axillary, or inguinal). Hall-mark clinical discriminator against Varicella.',
      clinicalFeatures: [
        'Prodromal high fever, chills, and intense asthenia',
        'Marked painful regional lymphadenopathy prior to or concurrent with rash',
        'Distinct central lesion umbilication with firm indurated bases',
        'Palmar and plantar involvement in over 70% of classical presentations',
        'Painful proctitis or pharyngitis when mucosal sites are infected',
      ],
      differentialPoints: [
        'Vs Chickenpox: Mpox lesions are synchronous and deep-seated with prominent lymphadenopathy; Chickenpox is pleomorphic ("dewdrops") with mild/absent lymphadenopathy.',
        'Vs Cowpox: Cowpox is typically a solitary or paucifocal large black eschar, whereas Mpox is generalized/clustered multi-lesion.',
        'Vs HFMD: HFMD lesions are non-umbilicated, flat or oval grey-white blisters on palms/soles without prominent cervical/inguinal lymphadenopathy.',
      ],
      redFlags: [
        'Ocular involvement or keratitis (risk of corneal scarring/blindness)',
        'Secondary bacterial soft-tissue sepsis or confluent cellulitis',
        'Severe pharyngeal edema causing airway compromise',
        'Altered mental status, encephalopathy, or severe hemodynamic collapse',
      ],
      triagePriority: 'Level 1: High Priority',
      isolationGuideline:
          'Strict Airborne & Contact Precautions in an airborne infection isolation room (AIIR) or single room. Full PPE (fit-tested N95, fluid-resistant gown, eye protection, gloves).',
      modelPrecision: 0.8400,
      modelRecall: 0.7778,
      modelF1: 0.8077,
      modelSupport: 27,
      sampleAssets: [
        'assets/images/samples/mpox_sample_1.jpg',
        'assets/images/samples/mpox_sample_2.jpg',
      ],
    ),
    ExanthemInfo(
      id: 'chickenpox',
      name: 'Chickenpox (Varicella)',
      pathogen: 'Varicella-Zoster Virus (VZV)',
      virusFamily: 'Herpesviridae (Alphaherpesvirinae)',
      incubationPeriod: '10 to 21 days (typically 14-16 days)',
      transmission:
          'Highly contagious via airborne droplets and direct contact with blister vesicle fluid',
      morphologySummary:
          'Superficial thin-walled clear vesicles on an erythematous base classically described as "dewdrops on a rose petal", rapidly progressing to pustules and crusts.',
      lesionEvolution:
          'Pleomorphic / Asynchronous presentation: new crops appear in successive waves over 3 to 5 days, resulting in simultaneous coexistence of macules, papules, intact vesicles, and crusted lesions on the same body region.',
      anatomicalDistribution:
          'Centripetal distribution: commences on scalp, face, and trunk before sparingly extending to proximal extremities; rarely involves palms and soles.',
      lymphadenopathyProfile:
          'Absent to mild, generalized, non-tender lymph node enlargement.',
      clinicalFeatures: [
        'Mild prodromal low-grade fever, malaise, and anorexia in children',
        'Successive crops of intensely pruritic polymorphic lesions',
        'Rapid evolution from tear-drop vesicle to rupture within 8-12 hours',
        'Absence of deep-seated induration or classical central umbilication',
        'Mucosal shallow erosions in palate or genital mucosa',
      ],
      differentialPoints: [
        'Vs Mpox: Multiple stages of lesions present simultaneously (pleomorphism); palms and soles typically spared; lymphadenopathy is minimal.',
        'Vs Measles: Measles rash is non-vesicular (morbilliform maculopapular) without fluid-filled blisters.',
        'Vs HFMD: HFMD lesions predominate on hands, feet, and mouth rather than generalized trunk distribution.',
      ],
      redFlags: [
        'Secondary invasive Streptococcus or Staphylococcus superinfection (necrotizing fasciitis)',
        'Varicella pneumonia (especially in adults, smokers, or pregnant females)',
        'Cerebellar ataxia or post-infectious encephalitis',
        'Aspirin administration leading to Reye Syndrome risk (strictly avoid salicylates)',
      ],
      triagePriority: 'Level 3: Standard',
      isolationGuideline:
          'Airborne and contact isolation until all vesicles have completely dried and formed firm dry crusts (minimum 5-7 days from rash onset).',
      modelPrecision: 0.6667,
      modelRecall: 0.6667,
      modelF1: 0.6667,
      modelSupport: 9,
      sampleAssets: [
        'assets/images/samples/chickenpox_sample_1.jpg',
        'assets/images/samples/chickenpox_sample_2.jpg',
      ],
    ),
    ExanthemInfo(
      id: 'measles',
      name: 'Measles (Rubeola)',
      pathogen: 'Measles Morbillivirus',
      virusFamily: 'Paramyxoviridae',
      incubationPeriod:
          '7 to 14 days (typically 10-12 days to prodrome, 14 days to rash)',
      transmission:
          'Extremely contagious via aerosolized respiratory droplets remaining viable in air up to 2 hours',
      morphologySummary:
          'Confluent erythematous maculopapular (morbilliform) rash that starts discrete and coalesces into large irregular patches; resolves with coppery hyperpigmentation and fine desquamation.',
      lesionEvolution:
          'Non-vesicular cephalocaudal wave: originates behind ears and along hairline, descends over face and neck, then sweeps over trunk and extremities within 3 days.',
      anatomicalDistribution:
          'Cephalocaudal pattern (Head -> Neck -> Torso -> Arms/Legs). Palmar and plantar involvement is uncommon.',
      lymphadenopathyProfile:
          'Mild generalized lymphadenopathy, prominent post-auricular and occipital nodes.',
      clinicalFeatures: [
        'Intense prodrome with high spiking fever (> 39.5 C / 103 F)',
        'The Classic "Three Cs": Cough (barking), Coryza (severe rhinitis), and Conjunctivitis (photophobia)',
        'Pathognomonic Koplik spots: tiny 1-2 mm blue-white spots with red halos on buccal mucosa (precedes rash by 24-48h)',
        'Confluent facial rash giving a characteristic "measly" facies',
        'Fine branny desquamation during recovery phase',
      ],
      differentialPoints: [
        'Vs Mpox & Chickenpox: Entirely maculopapular without vesicular fluid; lack of pustules or umbilicated crusts.',
        'Vs Cowpox: Generalized confluent morbilliform pattern rather than localized ulcerating necrotic eschar.',
        'Vs Drug exanthem: Presence of Koplik spots, high fever, and photophobic conjunctivitis.',
      ],
      redFlags: [
        'Severe secondary bronchopneumonia (leading cause of measles mortality)',
        'Acute measles encephalitis or subacute sclerosing panencephalitis (SSPE)',
        'Severe corneal ulceration and xerophthalmia (prevented by high-dose Vitamin A)',
        'Severe dehydration from persistent diarrhea',
      ],
      triagePriority: 'Level 2: Urgent',
      isolationGuideline:
          'Immediate airborne isolation (negative pressure room, N95 respiratory protection for all staff). Reportable immediately to public health authorities.',
      modelPrecision: 0.8571,
      modelRecall: 1.0000,
      modelF1: 0.9231,
      modelSupport: 6,
      sampleAssets: [
        'assets/images/samples/measles_sample_1.jpg',
        'assets/images/samples/measles_sample_2.jpg',
      ],
    ),
    ExanthemInfo(
      id: 'cowpox',
      name: 'Cowpox',
      pathogen: 'Cowpox Virus (CPXV)',
      virusFamily: 'Poxviridae (Orthopoxvirus genus)',
      incubationPeriod: '9 to 12 days',
      transmission:
          'Direct contact with infected animal reservoirs (domestic cats, pet rats, wild rodents), rarely human-to-human',
      morphologySummary:
          'Solitary or paucifocal (1 to 3) lesions starting as an inflamed macule, transforming into a hard indurated papule, hemorrhagic vesicle, and ultimately a large deeply excavated black necrotic eschar.',
      lesionEvolution:
          'Slow localized progression over 3 to 6 weeks: Papule -> Hemorrhagic Bulla -> Central Necrosis -> Thick Black Eschar (Anthrax-like) -> Scarring.',
      anatomicalDistribution:
          'Focal and asymmetrical: almost exclusively on inoculation sites such as fingers, hands, forearms, or face.',
      lymphadenopathyProfile:
          'Severe, exquisitely painful regional lymphadenitis and localized ascending lymphangitis.',
      clinicalFeatures: [
        'History of rodent contact or scratch/bite from outdoor domestic cat',
        'Profound localized erythema, edema, and induration surrounding solitary eschar',
        'Systemic symptoms including low-grade fever, malaise, and localized tenderness',
        'Central dark necrotic depression surrounded by a ring of tense inflammatory vesicles',
        'Protracted healing course requiring weeks to complete re-epithelialization',
      ],
      differentialPoints: [
        'Vs Cutaneous Anthrax: Anthrax eschars are painless with non-pitting gelatinous edema; Cowpox lesions are exquisitely painful with marked acute inflammation.',
        'Vs Mpox: Cowpox is localized/solitary with a prominent black necrotic eschar; Mpox is generalized and multifocal.',
        'Vs Orf / Milker\'s Nodule: Parapoxviruses show distinctive targetoid erythema without deep black hemorrhagic necrosis.',
      ],
      redFlags: [
        'Disseminated cowpox (generalized spread) in patients with atopic dermatitis (eczema herpeticum-like)',
        'Severe immunosuppression leading to fulminant necrotizing disease',
        'Ocular cowpox leading to severe blepharoconjunctivitis or panophthalmitis',
        'Secondary pyogenic cellulitis / MRSA superinfection',
      ],
      triagePriority: 'Level 1: High Priority',
      isolationGuideline:
          'Contact precautions. Occlusive dressing over necrotic lesion. Healthcare workers should wear gloves and gown during wound dressing changes.',
      modelPrecision: 0.7500,
      modelRecall: 0.8571,
      modelF1: 0.8000,
      modelSupport: 7,
      sampleAssets: [
        'assets/images/samples/cowpox_sample_1.jpg',
        'assets/images/samples/cowpox_sample_2.jpg',
      ],
    ),
    ExanthemInfo(
      id: 'hfmd',
      name: 'Hand, Foot, and Mouth Disease (HFMD)',
      pathogen:
          'Coxsackievirus A16, Enterovirus A71 (EV-A71), Coxsackievirus A6',
      virusFamily: 'Picornaviridae (Enterovirus genus)',
      incubationPeriod: '3 to 6 days',
      transmission:
          'Fecal-oral route, contact with blister fluid, or respiratory droplets in childcare and school environments',
      morphologySummary:
          'Small (2-5 mm), oval or football-shaped greyish-white papulovesicles oriented along skin tension lines, surrounded by a thin erythematous halo.',
      lesionEvolution:
          'Rapid resolution: maculopapules evolve into discrete non-pruritic blisters that do not crust or scar, resolving spontaneously within 7 to 10 days.',
      anatomicalDistribution:
          'Characteristic acral predilection: palms, soles, interdigital spaces, buttocks, knees, and painful intraoral ulcerations (herpangina on tongue and buccal mucosa).',
      lymphadenopathyProfile:
          'Generally absent or mild cervical reactive nodes secondary to oral ulcerations.',
      clinicalFeatures: [
        'Pediatric predilection (primarily infants and children under 5 years)',
        'Painful intraoral vesicles that rapidly ulcerate, leading to dysphagia and refusal to feed',
        'Elliptical or football-shaped vesicles on palms and soles that run parallel to Langer lines',
        'Low-grade fever (38-39 C) lasting 24-48 hours',
        'Late complication of painless onychomadesis (nail shedding) 4-8 weeks post-recovery',
      ],
      differentialPoints: [
        'Vs Mpox: HFMD blisters are small, non-umbilicated, painless or mildly tender, and self-limiting without significant lymphadenopathy.',
        'Vs Chickenpox: Lesions confined primarily to palms, soles, and mouth; lack of generalized centripetal pleomorphic crops on torso.',
        'Vs Aphthous Stomatitis: Regular aphthae lack concomitant palm and sole cutaneous vesicles.',
      ],
      redFlags: [
        'EV-A71 associated brainstem encephalitis, aseptic meningitis, or acute flaccid paralysis',
        'Neurogenic pulmonary edema or cardio-respiratory collapse',
        'Severe dehydration in young toddlers due to painful oral enanthem',
        'High persistent fever > 39 C for more than 3 consecutive days',
      ],
      triagePriority: 'Level 3: Standard',
      isolationGuideline:
          'Contact and enteric precautions. Exclusion from daycare/school until oral ulcers have healed and child has been afebrile for 24 hours. Rigorous hand hygiene.',
      modelPrecision: 0.9333,
      modelRecall: 0.8750,
      modelF1: 0.9032,
      modelSupport: 16,
      sampleAssets: [
        'assets/images/samples/hfmd_sample_1.jpg',
        'assets/images/samples/hfmd_sample_2.jpg',
      ],
    ),
    ExanthemInfo(
      id: 'healthy',
      name: 'Healthy Skin (Control Baseline)',
      pathogen: 'None (Physiological Baseline)',
      virusFamily: 'Intact Cutaneous Micro-Environment',
      incubationPeriod: 'N/A',
      transmission: 'N/A',
      morphologySummary:
          'Smooth, intact epidermal architecture with uniform pigmentation, normal skin turgor, and complete absence of inflammatory erythema, papules, pustules, or ulcerations.',
      lesionEvolution:
          'Stable physiological epidermal renewal; normal barrier function without active immunological cascade.',
      anatomicalDistribution:
          'Generalized intact cutaneous envelope across all anatomical dermatomes.',
      lymphadenopathyProfile: 'Normal, non-palpable, non-tender lymph nodes.',
      clinicalFeatures: [
        'Intact epidermal surface with preserved skin furrow patterns',
        'Absence of inflammatory hypervascularity or perilesional erythema',
        'Absence of microvesicles, purulent exudate, or crusting',
        'Normal capillary refill time (< 2 seconds)',
        'Serves as negative control baseline for clinical screening accuracy',
      ],
      differentialPoints: [
        'Essential specificity benchmark in the MSLD v2.0 dataset to minimize false positive referrals.',
        'Ensures that non-pathological skin tones and lighting variations are not misdiagnosed as infectious exanthems.',
      ],
      redFlags: [
        'Presence of newly developed rapidly expanding pigmented lesions (ABCDE melanoma screening)',
        'Sudden onset petechiae or non-blanching purpura (meningococcemia screen)',
      ],
      triagePriority: 'Level 4: Routine',
      isolationGuideline:
          'No isolation or infection control restrictions required. Patient reassurance and guidance on general skin hygiene.',
      modelPrecision: 0.8000,
      modelRecall: 0.8889,
      modelF1: 0.8421,
      modelSupport: 9,
      sampleAssets: [
        'assets/images/samples/healthy_sample_1.jpg',
        'assets/images/samples/healthy_sample_2.jpg',
      ],
    ),
  ];
}
